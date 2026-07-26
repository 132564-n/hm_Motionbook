import { router } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.PhotoAccessHelper';
import { ProjectRepository } from '../repositories/ProjectRepository';
import { Project, ProjectType, ProjectStatus, ImageTextPage, TextStyle } from '../models/Models';

/**
 * 图文编辑页面
 * 支持图片选择、文字叠加、贴纸、多页排版
 */
@Entry
@Component
struct ImageTextEditPage {
  @State projectId: number = 0;
  @State title: string = '未命名图文';
  @State pages: ImageTextPage[] = [];
  @State currentPageIndex: number = 0;
  @State textInput: string = '';
  @State showTextEditor: boolean = false;
  @State fontSize: number = 16;
  @State textColor: string = '#FFFFFF';
  @State textAlignIndex: number = 1;
  private repo: ProjectRepository = new ProjectRepository();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.type === ProjectType.IMAGE_TEXT) {
      this.createNewProject();
    }
  }

  private async createNewProject(): Promise<void> {
    try {
      const project: Project = {
        title: this.title,
        type: ProjectType.IMAGE_TEXT,
        status: ProjectStatus.DRAFT,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
      this.projectId = await this.repo.create(project);
    } catch (err) {
      console.error('创建项目失败: ' + JSON.stringify(err));
    }
  }

  /**
   * 选择图片
   */
  private async selectImage(): Promise<void> {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.selectionMode = photoAccessHelper.PhotoSelectionMode.SINGLE_IMAGE;
      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      const result = await photoViewPicker.select(photoSelectOptions);

      if (result.photoUris.length > 0) {
        const imageUrl = result.photoUris[0];
        const newPage: ImageTextPage = {
          imageUrl: imageUrl,
          text: '',
          textStyle: {
            fontSize: this.fontSize,
            color: this.textColor,
            fontWeight: 400,
            textAlign: this.textAlignIndex,
            opacity: 1.0
          }
        };
        this.pages.push(newPage);
        this.currentPageIndex = this.pages.length - 1;
      }
    } catch (err) {
      console.error('选择图片失败: ' + JSON.stringify(err));
    }
  }

  /**
   * 添加新页面
   */
  private addNewPage(): void {
    if (this.pages.length === 0) {
      this.selectImage();
    } else {
      this.pages.push({
        imageUrl: '',
        text: '',
        textStyle: {
          fontSize: 16,
          color: '#FFFFFF',
          fontWeight: 400,
          textAlign: 1,
          opacity: 1.0
        }
      });
      this.currentPageIndex = this.pages.length - 1;
    }
  }

  /**
   * 保存项目
   */
  private async saveProject(): Promise<void> {
    if (this.projectId === 0) return;
    try {
      const project = await this.repo.getById(this.projectId);
      if (project) {
        project.title = this.title;
        project.content = JSON.stringify(this.pages);
        project.updatedAt = Date.now();
        await this.repo.update(project);
        console.info('项目保存成功');
      }
    } catch (err) {
      console.error('保存项目失败: ' + JSON.stringify(err));
    }
  }

  /**
   * 完成并保存
   */
  private async completeAndSave(): Promise<void> {
    await this.saveProject();
    router.back();
  }

  private getAlignValue(index: number): TextAlign {
    switch (index) {
      case 0: return TextAlign.Start;
      case 1: return TextAlign.Center;
      case 2: return TextAlign.End;
      default: return TextAlign.Center;
    }
  }

  @Builder
  PageThumbnail(page: ImageTextPage, index: number) {
    Stack({ alignContent: Alignment.Center }) {
      if (page.imageUrl) {
        Image(page.imageUrl)
          .width(56)
          .height(56)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
      } else {
        Column() {
          Text('+')
            .fontSize(24)
            .fontColor('#999999')
        }
        .width(56)
        .height(56)
        .backgroundColor('#F1F3F5')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width(56)
    .height(56)
    .border({
      width: this.currentPageIndex === index ? 2 : 0,
      color: '#007DFF'
    })
    .borderRadius(8)
    .onClick(() => {
      this.currentPageIndex = index;
    })
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#666666')
          .onClick(() => {
            router.back();
          })

        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('完成')
          .fontSize(16)
          .fontColor('#007DFF')
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.completeAndSave();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 主编辑区
      if (this.pages.length === 0) {
        Column() {
          Text('📷')
            .fontSize(48)
          Text('点击添加图片开始创作')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 12 })
          Button('选择图片')
            .type(ButtonType.Capsule)
            .backgroundColor('#007DFF')
            .fontColor('#FFFFFF')
            .margin({ top: 24 })
            .onClick(() => {
              this.selectImage();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F1F3F5')
      } else {
        // 当前编辑页面
        Stack({ alignContent: Alignment.BottomCenter }) {
          Image(this.pages[this.currentPageIndex].imageUrl)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .backgroundColor('#000000')

          // 文字叠加
          if (this.pages[this.currentPageIndex].text) {
            Text(this.pages[this.currentPageIndex].text)
              .fontSize(this.pages[this.currentPageIndex].textStyle?.fontSize || 16)
              .fontColor(this.pages[this.currentPageIndex].textStyle?.color || '#FFFFFF')
              .textAlign(this.getAlignValue(this.pages[this.currentPageIndex].textStyle?.textAlign || 1))
              .padding(16)
              .onClick(() => {
                this.showTextEditor = true;
                this.textInput = this.pages[this.currentPageIndex].text;
              })
          }
        }
        .layoutWeight(1)

        // 底部工具栏
        Column() {
          // 页面缩略图列表
          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.pages, (page: ImageTextPage, index: number) => {
                this.PageThumbnail(page, index)
              }, (page: ImageTextPage, index: number) => index.toString())

              // 添加新页面按钮
              Column() {
                Text('+')
                  .fontSize(24)
                  .fontColor('#007DFF')
              }
              .width(56)
              .height(56)
              .backgroundColor('#F1F3F5')
              .borderRadius(8)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.selectImage();
              })
            }
            .padding({ left: 12, right: 12 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .height(72)
          .width('100%')

          // 工具按钮
          Row() {
            Column() {
              Image($r('app.media.ic_tool_text'))
                .width(24)
                .height(24)
                .fillColor('#666666')
              Text('文字')
                .fontSize(10)
                .fontColor('#666666')
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .onClick(() => {
              this.showTextEditor = true;
              this.textInput = this.pages[this.currentPageIndex].text || '';
            })

            Column() {
              Image($r('app.media.ic_tool_sticker'))
                .width(24)
                .height(24)
                .fillColor('#666666')
              Text('贴纸')
                .fontSize(10)
                .fontColor('#666666')
                .margin({ top: 2 })
            }
            .layoutWeight(1)

            Column() {
              Image($r('app.media.ic_tool_filter'))
                .width(24)
                .height(24)
                .fillColor('#666666')
              Text('滤镜')
                .fontSize(10)
                .fontColor('#666666')
                .margin({ top: 2 })
            }
            .layoutWeight(1)

            Column() {
              Image($r('app.media.ic_tool_template'))
                .width(24)
                .height(24)
                .fillColor('#666666')
              Text('模板')
                .fontSize(10)
                .fontColor('#666666')
                .margin({ top: 2 })
            }
            .layoutWeight(1)

            Column() {
              Image($r('app.media.ic_tool_save'))
                .width(24)
                .height(24)
                .fillColor('#666666')
              Text('保存')
                .fontSize(10)
                .fontColor('#666666')
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .onClick(() => {
              this.saveProject();
            })
          }
          .width('100%')
          .height(64)
          .backgroundColor('#FFFFFF')
          .padding({ top: 8, bottom: 8 })
        }
      }
    }
    .width('100%')
    .height('100%')

    // 文字编辑弹窗
    if (this.showTextEditor) {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Text('编辑文字')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .margin({ bottom: 16 })

          TextArea({ text: this.textInput, placeholder: '请输入文字内容' })
            .width('100%')
            .height(120)
            .fontSize(14)
            .borderRadius(8)
            .backgroundColor('#F1F3F5')
            .onChange((value: string) => {
              this.textInput = value;
            })

          // 文字大小调整
          Row() {
            Text('字号')
              .fontSize(12)
              .fontColor('#666666')
            Slider({ value: this.fontSize, min: 12, max: 48, step: 1 })
              .layoutWeight(1)
              .onChange((value: number) => {
                this.fontSize = Math.floor(value);
              })
            Text(this.fontSize.toString())
              .fontSize(12)
              .fontColor('#666666')
              .width(30)
          }
          .width('100%')
          .margin({ top: 12 })

          // 文字颜色
          Row() {
            ForEach(['#FFFFFF', '#000000', '#FF0000', '#FFD700', '#00FF00', '#007DFF'], (color: string) => {
              Column() {
                Circle({ width: 24, height: 24 })
                  .fill(color)
                  .border({ width: 1, color: '#CCCCCC' })
              }
              .padding(4)
              .onClick(() => {
                this.textColor = color;
              })
            })
          }
          .width('100%')
          .margin({ top: 12 })

          // 对齐方式
          Row() {
            Button('左')
              .layoutWeight(1)
              .type(this.textAlignIndex === 0 ? ButtonType.Capsule : ButtonType.Normal)
              .backgroundColor(this.textAlignIndex === 0 ? '#007DFF' : '#F1F3F5')
              .fontColor(this.textAlignIndex === 0 ? '#FFFFFF' : '#666666')
              .onClick(() => { this.textAlignIndex = 0; })
            Button('中')
              .layoutWeight(1)
              .type(this.textAlignIndex === 1 ? ButtonType.Capsule : ButtonType.Normal)
              .backgroundColor(this.textAlignIndex === 1 ? '#007DFF' : '#F1F3F5')
              .fontColor(this.textAlignIndex === 1 ? '#FFFFFF' : '#666666')
              .onClick(() => { this.textAlignIndex = 1; })
            Button('右')
              .layoutWeight(1)
              .type(this.textAlignIndex === 2 ? ButtonType.Capsule : ButtonType.Normal)
              .backgroundColor(this.textAlignIndex === 2 ? '#007DFF' : '#F1F3F5')
              .fontColor(this.textAlignIndex === 2 ? '#FFFFFF' : '#666666')
              .onClick(() => { this.textAlignIndex = 2; })
          }
          .width('100%')
          .margin({ top: 12 })

          // 按钮
          Row() {
            Button('取消')
              .layoutWeight(1)
              .backgroundColor('#F1F3F5')
              .fontColor('#666666')
              .onClick(() => {
                this.showTextEditor = false;
              })
            Button('确定')
              .layoutWeight(1)
              .backgroundColor('#007DFF')
              .fontColor('#FFFFFF')
              .margin({ left: 12 })
              .onClick(() => {
                if (this.currentPageIndex < this.pages.length) {
                  this.pages[this.currentPageIndex].text = this.textInput;
                  this.pages[this.currentPageIndex].textStyle = {
                    fontSize: this.fontSize,
                    color: this.textColor,
                    fontWeight: 400,
                    textAlign: this.textAlignIndex,
                    opacity: 1.0
                  };
                }
                this.showTextEditor = false;
              })
          }
          .width('100%')
          .margin({ top: 24 })
        }
        .width('80%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0,0,0,0.5)')
    }
  }
}
