import { ProjectType } from '../models/Models';
import { router } from '@kit.ArkUI';

/**
 * 创作页
 * 提供创作类型选择
 */
@Component
export struct CreatePage {
  private navigateToCreate(type: ProjectType): void {
    const params = { type: type };
    if (type === ProjectType.IMAGE_TEXT) {
      router.pushUrl({ url: 'pages/ImageTextEditPage', params: params });
    } else if (type === ProjectType.AUDIO) {
      router.pushUrl({ url: 'pages/AudioCreatePage', params: params });
    }
  }

  @Builder
  CreateCard(title: string, desc: string, icon: Resource, color: string, type: ProjectType) {
    Column() {
      Column() {
        Image(icon)
          .width(48)
          .height(48)
          .fillColor('#FFFFFF')

        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ top: 12 })

        Text(desc)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .opacity(0.85)
          .margin({ top: 4 })
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding(24)
      .borderRadius(20)
      .backgroundColor(color)
      .alignItems(HorizontalAlign.Center)
    }
    .onClick(() => {
      this.navigateToCreate(type);
    })
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('创作')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })

      // 创作类型列表
      Scroll() {
        Column() {
          this.CreateCard('图文创作', '编辑图片，添加文字和贴纸\n打造精美图文内容', $r('app.media.ic_image_text'), '#FF6B35', ProjectType.IMAGE_TEXT)

          this.CreateCard('音频创作', '录制声音，剪辑和混音\n制作专业音频内容', $r('app.media.ic_audio'), '#007DFF', ProjectType.AUDIO)

          this.CreateCard('模板创作', '一键套用精美模板\n快速生成创作作品', $r('app.media.ic_template'), '#34C759', ProjectType.TEMPLATE)
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 24 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}
