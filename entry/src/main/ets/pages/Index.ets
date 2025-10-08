import { ArcButtonComponent } from '../components/ArcButtonComponent';
import { ArcButtonPosition, router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  private onTopClick = () => {
    router.pushUrl({ url: 'pages/AddItemPage' });
  }
  onBottomClick: (() => void) | undefined;
  @State message: string = 'Hello World';

  build() {
        Column() {
          ArcButtonComponent({
            label: 'Add Item',
            arcPosition: ArcButtonPosition.TOP_EDGE,
            fontSize: 15,
            shadowEnabled: true,
            routeUrl: 'pages/AddItemPage'
          })


          Blank()


          Button('Check Home')
            .width('120%')
            .onClick(() => {
              router.pushUrl({
                url: 'pages/CheckHome',
              });
            })

          Blank()

          ArcButtonComponent({
            label: 'My Items',
            arcPosition: ArcButtonPosition.BOTTOM_EDGE,
            fontSize: 15,
            shadowEnabled: true,
            routeUrl: 'pages/MyItemsPage'

          })
        }
        .backgroundColor('#F5F6F8')
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)


  }
}