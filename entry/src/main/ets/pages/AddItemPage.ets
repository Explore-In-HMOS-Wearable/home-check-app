import commonUtils from '../common/utils/CommonUtils';
import dbUtils, { ItemInsertInput } from '../common/utils/DBUtils';
import { router } from '@kit.ArkUI';


@Entry
@Component
export struct AddItemPage {
  @State name: string = '';
  @State category: string = '';
  @State note: string = '';
  @State isCritical: boolean = false;
  @State saving: boolean = false;
  @State errorMsg: string = '';

  aboutToAppear() {
    dbUtils.createDB().catch(() => {
    });
  }



  private async onSave() {
    if (this.saving) {
      return;
    }

    const trimmedName: string = this.name ? this.name.trim() : '';
    if (trimmedName.length === 0) {
      commonUtils.showToast('Please enter a name.');
      return;
    }

    this.saving = true;
    try {
      const payload: ItemInsertInput = {
        name: trimmedName,
        category: this.category,
        note: this.note,
        isCritical: this.isCritical
      };

      const ok: boolean = await dbUtils.insertItem(payload);
      if (!ok) {
        this.errorMsg = 'Failed to save the item.';
        commonUtils.showToast('Save failed ❌');
        return;
      }

      this.name = '';
      this.category = '';
      this.note = '';
      this.isCritical = false;

      commonUtils.showToast('Item saved ✅');
      router.replaceUrl({ url: 'pages/Index' });

    } catch (e) {
      const err: Error | string = e instanceof Error ? e : String(e);
      const msg: string = err instanceof Error ? err.message : String(err);
      this.errorMsg = 'Save error: ' + msg;
      console.error('[AddItemPage.onSave] ' + this.errorMsg);
      commonUtils.showToast(this.errorMsg);
    } finally {
      this.saving = false;
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 14 }) {


          Blank().width(400).height(1)


          Column({ space: 6 }) {
            Row() {
              Text('Name *')
                .fontSize(14)
                .fontColor('#374151')
              if (this.name.trim().length > 0) {
                Text('Required')
                  .fontSize(11)
                  .fontColor('#10B981')
                  .padding({ left: 8 })
              }
            }

            TextInput({ placeholder: 'e.g., Windows, Iron, Stove...', text: this.name })
              .maxLines(1)
              .fontColor('#111827')
              .height(40)
              .onChange((v: string) => this.name = v)
              .backgroundColor(Color.White)
              .border({
                width: 1,
                color: this.name.trim().length > 0 ? '#10B981' : '#E5E7EB'
              })
              .borderRadius(10)
              .padding({ left: 10, right: 10 })
          }

          Column({ space: 6 }) {
            Text('Category').fontSize(14).fontColor('#374151')
            TextInput({ placeholder: 'e.g., Kitchen, Living Room', text: this.category })
              .maxLines(1)
              .fontColor('#111827')
              .height(40)
              .onChange((v: string) => this.category = v)
              .backgroundColor(Color.White)
              .border({ width: 1, color: '#E5E7EB' })
              .borderRadius(10)
              .padding({ left: 10, right: 10 })
          }


          Column({ space: 6 }) {
            Text('Note').fontSize(14).fontColor('#374151')
            TextInput({ placeholder: 'Optional note', text: this.note })
              .maxLines(3)
              .height(72)
              .fontColor('#111827')
              .onChange((v: string) => this.note = v)
              .backgroundColor(Color.White)
              .border({ width: 1, color: '#E5E7EB' })
              .borderRadius(10)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          }

          Divider().strokeWidth(0.6).color('#E5E7EB').margin({ top: 2, bottom: 2 })

          Row({ space: 8 }) {
            Toggle({ type: ToggleType.Switch, isOn: this.isCritical })
              .onChange((val: boolean) => this.isCritical = val)
            Text('Mark as critical')
              .fontSize(14)
              .fontColor('#111827')
          }
          .alignItems(VerticalAlign.Center)

          if (this.errorMsg) {
            Text(this.errorMsg)
              .fontColor('#DC2626')
              .fontSize(13)
              .padding({ left: 4, right: 4 })
          }



          Button(this.saving ? 'Saving…' : 'Save')
            .type(ButtonType.Capsule)
            .height(44)
            .width('100%')
            .fontSize(16)
            .backgroundColor(this.saving ? '#9CA3AF' : '#2563EB')
            .fontColor(Color.White)
            .opacity(this.saving ? 0.9 : 1)
            .shadow({ radius: 12, color: '#26000000', offsetX: 0, offsetY: 2 })
            .onClick(() => {
              if (!this.saving) {
                this.onSave();
              }
            })

          Blank().height(12)
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F6F8')


    }
  }

}

