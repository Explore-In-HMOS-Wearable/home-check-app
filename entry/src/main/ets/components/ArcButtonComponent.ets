import { router } from '@kit.ArkUI';
import {
  LengthMetrics, LengthUnit,
  ArcButton, ArcButtonOptions, ArcButtonStatus, ArcButtonStyleMode, ArcButtonPosition
} from '@kit.ArkUI';

@Component
export struct ArcButtonComponent {
  @Prop label: string = 'Button';
  @Prop arcPosition?: ArcButtonPosition;
  @Prop styleMode: ArcButtonStyleMode = ArcButtonStyleMode.EMPHASIZED_LIGHT;
  @Prop status: ArcButtonStatus = ArcButtonStatus.NORMAL;
  @Prop fontSize: number = 15;
  @Prop shadowEnabled: boolean = true;
  @Prop routeUrl?: string;

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
          if (this.routeUrl && this.routeUrl.length > 0) {
            router.pushUrl({ url: this.routeUrl });
          }
        }
      })
    })
  }
}
