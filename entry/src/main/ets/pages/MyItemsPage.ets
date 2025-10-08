import dbUtils, { ItemRow } from '../common/utils/DBUtils';
import commonUtils from '../common/utils/CommonUtils';
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute, ComponentContent,
  LengthMetrics } from '@kit.ArkUI';

interface EditItemData {
  name: string;
  category: string;
  note: string;
  isCritical: boolean;
}

@CustomDialog
struct EditItemDialog {
  controller?: CustomDialogController;

  name: string = '';
  category: string = '';
  note: string = '';
  isCritical: boolean = false;

  cancel: () => void = () => {};
  confirm: (data: EditItemData) => void = () => {};
  @State private touched: boolean = false;

  build(): void {
    Column() {

      Scroll() {
        Column() {

          Column({ space: 6 }) {
            Row() { Text('Name *').fontSize(14).fontColor('#111827') }
            TextInput({ text: this.name, placeholder: 'e.g., Windows, Iron…' })
              .height(40).maxLines(1).fontColor(Color.Black)
              .onChange((v: string): void => { this.name = v; this.touched = true; })
              .border({
                width: 1,
                color: (this.touched && (this.name.trim().length === 0)) ? '#EF4444' :
                  (this.name.trim().length > 0 ? '#10B981' : '#E5E7EB')
              })
              .borderRadius(10)
              .padding({ left: 10, right: 10 })
            if (this.touched && this.name.trim().length === 0) {
              Text('Name is required.').fontSize(12).fontColor('#DC2626')
            }
          }

          Column({ space: 6 }) {
            Text('Category').fontSize(14).fontColor('#111827')
            TextInput({ text: this.category, placeholder: 'Optional (e.g., Kitchen)' })
              .height(40).maxLines(1).fontColor(Color.Black)
              .onChange((v: string): void => { this.category = v; })
              .border({ width: 1, color: '#E5E7EB' })
              .borderRadius(10)
              .padding({ left: 10, right: 10 })
          }

          Column({ space: 6 }) {
            Text('Note').fontSize(14).fontColor('#111827')
            TextInput({ text: this.note, placeholder: 'Optional note' })
              .height(96).maxLines(4).fontColor(Color.Black)
              .onChange((v: string): void => { this.note = v; })
              .border({ width: 1, color: '#E5E7EB' })
              .borderRadius(10)
              .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          }

          Row({ space: 8 }) {
            Toggle({ type: ToggleType.Switch, isOn: this.isCritical })
              .onChange((val: boolean): void => { this.isCritical = val; })
            Text(this.isCritical ? 'Marked as critical' : 'Mark as critical')
              .fontSize(14).fontColor('#111827')
          }
          .alignItems(VerticalAlign.Center)

          Text('Changes will be saved for this item.')
            .fontSize(12).fontColor('#6B7280').margin({ top: -2 })
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')

      Row({ space: 10 }) {
        Button('Cancel')
          .type(ButtonType.Capsule)
          .backgroundColor('#F3F4F6')
          .fontColor('#111827')
          .onClick((): void => { this.cancel(); this.controller?.close(); })

        Button('Save')
          .type(ButtonType.Capsule)
          .backgroundColor(this.name.trim().length > 0 ? '#2563EB' : '#9CA3AF')
          .fontColor(Color.White)
          .enabled(this.name.trim().length > 0)
          .onClick((): void => {
            const trimmed: string = (this.name ?? '').trim();
            if (trimmed.length === 0) { this.touched = true; return; }
            this.confirm({
              name: trimmed,
              category: (this.category ?? '').trim(),
              note: (this.note ?? '').trim(),
              isCritical: this.isCritical
            });
            this.controller?.close();
          })
      }
      .justifyContent(FlexAlign.End)
      .padding({ left: 16, right: 16, bottom: 14 })
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}



@Builder
function myItemsHeader(): void {
  Column() {
    Text('My Items')
      .fontSize(22)
      .fontWeight(FontWeight.Bold)
  }
  .margin(0)
}

@Entry
@Component
export struct MyItemsPage {
  @State items: ItemRow[] = [];
  @State loading: boolean = false;
  @State onlyCritical: boolean = false;

  @State editName: string = '';
  @State editCategory: string = '';
  @State editNote: string = '';
  @State editCritical: boolean = false;

  private editingId: number | null = null;
  private editDialog: CustomDialogController | null = null;

  private readonly watchSize: string = '466px';
  private readonly listSize: string = '414px';

  private ctx?: UIContext;
  private headerCc?: ComponentContent<object>;

  aboutToAppear(): void {
    this.ctx = this.getUIContext();
    this.headerCc = new ComponentContent<object>(this.ctx as UIContext, wrapBuilder(myItemsHeader));
    void this.loadItems();
  }

  private async loadItems(): Promise<void> {
    if (this.loading) {
      return;
    }
    this.loading = true;
    try {
      const rows: ItemRow[] = await dbUtils.queryAll();
      const filtered: ItemRow[] = this.onlyCritical ?
      rows.filter((r: ItemRow) => r.isCritical === 1) :
        rows;

      const fresh: ItemRow[] = [];
      for (let i = 0; i < filtered.length; i++) {
        fresh.push(this.cloneRow(filtered[i]));
      }
      this.items = fresh;
    } catch (e) {
      const msg: string = e instanceof Error ? e.message : String(e);
      console.error('[MyItemsPage.loadItems] ' + msg);
      commonUtils.showToast('Load error');
    } finally {
      this.loading = false;
    }
  }

  private cloneRow(src: ItemRow): ItemRow {
    const row: ItemRow = {
      id: src.id,
      name: src.name,
      category: (src as ItemRow).category !== undefined ? src.category : null,
      note: (src as ItemRow).note !== undefined ? src.note : null,
      isCritical: src.isCritical
    };
    return row;
  }

  private getSectionKeys(): string[] {
    const base: string[] = ['controls'];
    if (this.items.length === 0 && !this.loading) {
      base.push('empty');
      return base;
    }
    for (let i = 0; i < this.items.length; i++) {
      const r: ItemRow = this.items[i];
      base.push(this.keyFor(r));
    }
    return base;
  }

  private keyFor(r: ItemRow): string {
    const n = (r.name || '').split(' ').join('_');
    const c = (r.category ? r.category : '').split(' ').join('_');
    const no = (r.note ? r.note : '').split(' ').join('_');
    return 'item-' + r.id + '-' + r.isCritical + '-' + n + '-' + c + '-' + no;
  }


  private getRowFromKey(key: string): ItemRow | undefined {
    if (!key.startsWith('item-')) {
      return undefined;
    }
    let i: number = 5;
    let idStr: string = '';
    while (i < key.length) {
      const ch: string = key.charAt(i);
      if (ch >= '0' && ch <= '9') {
        idStr += ch;
        i++;
      } else {
        break;
      }
    }
    const idNum: number = Number(idStr);
    if (Number.isNaN(idNum)) {
      return undefined;
    }
    for (let k = 0; k < this.items.length; k++) {
      if (this.items[k].id === idNum) {
        return this.items[k];
      }
    }
    return undefined;
  }



  @Builder
  private buildControls(): void {
    Row({ space: 8 }) {
      Image($r('app.media.refresh_ic'))
        .opacity(this.loading ? 0.6 : 1)
        .width(25).height(25)
        .onClick((): void => {
          if (!this.loading) {
            void this.loadItems();
          }
        })

      Row({ space: 6 }) {
        Toggle({ type: ToggleType.Switch, isOn: this.onlyCritical })
          .onChange((v: boolean): void => {
            this.onlyCritical = v;
            void this.loadItems();
          })
        Text('Critical only').fontSize(13).fontColor('#666666')
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 8, color: '#11000000', offsetX: 0, offsetY: 2 })
  }


  @Builder
  private buildEmpty(): void {
    Column({ space: 8 }) {
      Text('No items yet').fontSize(16).fontColor('#666')
      Text('Add a new item and come back.').fontSize(13).fontColor('#999')
    }
    .width('100%')
    .padding(24)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 8, color: '#11000000', offsetX: 0, offsetY: 2 })
  }
  @Builder
  private buildItemCard(row: ItemRow): void {
    Column({ space: 8 }) {
      Row() {
        Text(row.name || 'Unnamed')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')

        Blank()

        if (row.isCritical === 1) {
          Row() {
            Text('CRITICAL')
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor('#B91C1C')
          }
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor('#FEE2E2')
          .borderRadius(999)
          .border({ color: '#FCA5A5', width: 0.6 })
          .margin({ right: 8 })
        }

        Button('•••')
          .type(ButtonType.Circle)
          .height(32)
          .width(32)
          .fontSize(16)
          .backgroundColor('#F3F4F6')
          .fontColor('#111827')
          .onClick((): void => this.showItemActions(row))
          .bindMenu(this.makeMenuForRow(row))
      }
      .width('100%')

      if (row.category) {
        Row() {
          Text(row.category as string)
            .fontSize(12)
            .fontColor('#374151')
        }
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor('#E5E7EB')
        .borderRadius(999)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
      }

      if (row.note) {
        Text(row.note as string)
          .fontSize(13)
          .fontColor('#374151')
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .border({ color: '#F3F4F6', width: 1 })
    .shadow({ radius: 10, color: '#16000000', offsetX: 0, offsetY: 3 })
  }




  private showItemActions(row: ItemRow): void {
    AlertDialog.show({
      title: 'Item actions',
      subtitle: row.name,
      message: 'Select an action',
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      gridCount: 4,
      offset: { dx: 0, dy: -20 },
      primaryButton: {
        value: 'Delete',
        action: (): void => { void this.onDelete(row.id); }
      },
      secondaryButton: {
        value: 'Edit',
        action: (): void => { this.openEditDialog(row); }
      },
      cancel: (): void => {},
      onWillDismiss: (a: DismissDialogAction): void => {
        if (a.reason === DismissReason.PRESS_BACK || a.reason === DismissReason.TOUCH_OUTSIDE) {
          a.dismiss();
        }
      }
    })
  }

  makeMenuForRow(row: ItemRow): CustomBuilder {
    return (): void => this.itemMenu(row);
  }

  @Builder
  private itemMenu(row: ItemRow): void {
    Menu() {
      MenuItem({ content: 'Edit' })
        .onClick((): void => this.openEditDialog(row))

      MenuItem({ content: 'Delete' })
        .onClick((): void => { void this.onDelete(row.id) })
    }
  }

  openEditDialog(row: ItemRow): void {
    this.editingId = row.id;
    this.editDialog = new CustomDialogController({
      builder: EditItemDialog({
        name: row.name,
        category: (row.category ?? '') as string,
        note: (row.note ?? '') as string,
        isCritical: row.isCritical === 1,
        cancel: (): void => {},
        confirm: (data: EditItemData): void => { void this.applyEdit(row.id, data) }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      onWillDismiss: (a: DismissDialogAction): void => {
        if (a.reason === DismissReason.PRESS_BACK || a.reason === DismissReason.TOUCH_OUTSIDE) {
          a.dismiss();
        }
      }
    });
    this.editDialog.open();
  }

  private async applyEdit(id: number, data: EditItemData): Promise<void> {
    const ok: boolean = await dbUtils.updateItem(id, {
      name: data.name,
      category: data.category || null,
      note: data.note || null,
      isCritical: data.isCritical ? 1 : 0
    });

    if (ok) {
      const updatedList: ItemRow[] = [];
      for (let i = 0; i < this.items.length; i++) {
        const r: ItemRow = this.items[i];
        if (r.id === id) {
          updatedList.push(this.mergeRowUpdate(r, data));
        } else {
          updatedList.push(r);
        }
      }
      this.items = updatedList;
      commonUtils.showToast('Item updated ✅');
    } else {
      commonUtils.showToast('Update failed ❌');
    }
  }

  private mergeRowUpdate(oldRow: ItemRow, data: EditItemData): ItemRow {
    const updated: ItemRow = {
      id: oldRow.id,
      name: data.name,
      category: data.category ? data.category : null,
      note: data.note ? data.note : null,
      isCritical: data.isCritical ? 1 : 0
    };
    return updated;
  }
  private async onDelete(id: number): Promise<void> {
    const ok: boolean = await dbUtils.deleteItem(id);
    if (ok) {
      commonUtils.showToast('Deleted ✅');
      void this.loadItems();
    } else {
      commonUtils.showToast('Delete failed ❌');
    }
  }

  build(): void {
    Stack() {
      Column() { }
      .justifyContent(FlexAlign.Center)
      .width(this.watchSize)
      .height(this.watchSize)
      .clip(new Circle({ width: '100%', height: '100%' }))
      .backgroundColor(Color.White)

      if (this.headerCc) {
        ArcList({ initialIndex: 0, header: this.headerCc as ComponentContent<object> }) {
          ForEach(this.getSectionKeys(),
            (key: string, idx: number): void => {
              ArcListItem() {
                Column() {
                  if (key === 'controls') {
                    this.buildControls();
                  } else if (key === 'empty') {
                    this.buildEmpty();
                  } else if (this.getRowFromKey(key) !== undefined) {
                    this.buildItemCard(this.getRowFromKey(key) as ItemRow);
                  } else {
                    this.buildEmpty();
                  }
                }
                .width(this.listSize)
              }
              .align(Alignment.Center)
            },
            (key: string, idx: number): string => key
          )
        }
        .space(LengthMetrics.px(10))
        .borderRadius(this.watchSize)
        .focusable(true)
        .focusOnTouch(true)
        .defaultFocus(true)
      } else {
        Column() {
          Text('Loading…').fontSize(16)
        }
        .alignItems(HorizontalAlign.Center)
      }
    }
    .align(Alignment.Center)
    .width(this.watchSize)
    .height(this.watchSize)
    .border({ color: Color.Black, width: 1 })
    .borderRadius(this.watchSize)
    .backgroundColor('#F5F6F8')
  }
}