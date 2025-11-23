import {
  LengthMetrics, LengthUnit,
  ArcButton, ArcButtonOptions, ArcButtonStatus, ArcButtonStyleMode, ArcButtonPosition
} from '@kit.ArkUI';

@Component
export struct ArcButtonComponent {
  @Consume('navStack') navStack: NavPathStack;   // 🔥 parent’tan stack al
  @Prop label: string = 'Button';
  @Prop arcPosition?: ArcButtonPosition;
  @Prop styleMode: ArcButtonStyleMode = ArcButtonStyleMode.EMPHASIZED_LIGHT;
  @Prop status: ArcButtonStatus = ArcButtonStatus.NORMAL;
  @Prop fontSize: number = 15;
  @Prop shadowEnabled: boolean = true;

  // 🔁 router yerine sayfa adı
  @Prop routeName?: string;

  build() {
    ArcButton({
      options: new ArcButtonOptions({
        label: this.label,
        status: this.status,
        position: this.arcPosition,
        styleMode: this.styleMode,
        fontSize: new LengthMetrics(this.fontSize, LengthUnit.FP),
        shadowEnabled: this.shadowEnabled,
        onClick: () => {
          if (this.routeName && this.routeName.length > 0) {
            this.navStack.pushPathByName(this.routeName, null);
          }
        }
      })
    })
  }
}
