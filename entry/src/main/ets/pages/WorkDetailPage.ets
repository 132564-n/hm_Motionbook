import { router, promptAction } from '@kit.ArkUI';
import { ProjectRepository } from '../repositories/ProjectRepository';
import { Project, ProjectType, ProjectStatus } from '../models/Models';

/**
 * 作品详情页面
 * 展示作品信息、内容预览，提供编辑、导出、删除功能
 */
@Entry
@Component
struct WorkDetailPage {
  @State project: Project | null = null;
  @State projectId: number = 0;
  private repo: ProjectRepository = new ProjectRepository();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.id) {
      this.projectId = params.id as number;
      this.loadProject();
    }
  }

  private async loadProject(): Promise<void> {
    try {
      this.project = await this.repo.getById(this.projectId);
    } catch (err) {
      console.error('加载项目失败: ' + JSON.stringify(err));
    }
  }

  private getProjectTypeText(type: ProjectType): string {
    switch (type) {
      case ProjectType.IMAGE_TEXT: return '图文作品';
      case ProjectType.AUDIO: return '音频作品';
      case ProjectType.TEMPLATE: return '模板作品';
      default: return '未知类型';
    }
  }

  private getStatusText(status: ProjectStatus): string {
    switch (status) {
      case ProjectStatus.DRAFT: return '草稿';
      case ProjectStatus.COMPLETED: return '已完成';
      case ProjectStatus.ARCHIVED: return '已归档';
      default: return '未知';
    }
  }

  private getStatusColor(status: ProjectStatus): string {
    switch (status) {
      case ProjectStatus.DRAFT: return '#FF9500';
      case ProjectStatus.COMPLETED: return '#34C759';
      case ProjectStatus.ARCHIVED: return '#999999';
      default: return '#999999';
    }
  }

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }

  private async editProject(): Promise<void> {
    if (!this.project) return;
    if (this.project.type === ProjectType.IMAGE_TEXT) {
      router.pushUrl({ url: 'pages/ImageTextEditPage', params: { id: this.project.id } });
    } else if (this.project.type === ProjectType.AUDIO) {
      router.pushUrl({ url: 'pages/AudioCreatePage', params: { id: this.project.id } });
    }
  }

  private async exportProject(): Promise<void> {
    if (!this.project) return;
    try {
      promptAction.showToast({
        message: '导出功能开发中',
        duration: 2000
      });
    } catch (err) {
      console.error('导出失败: ' + JSON.stringify(err));
    }
  }

  private async deleteProject(): Promise<void> {
    if (!this.project) return;
    try {
      await this.repo.delete(this.project.id!);
      promptAction.showToast({
        message: '已删除',
        duration: 1500
      });
      setTimeout(() => {
        router.back();
      }, 1500);
    } catch (err) {
      console.error('删除失败: ' + JSON.stringify(err));
    }
  }

  private async markAsCompleted(): Promise<void> {
    if (!this.project) return;
    try {
      this.project.status = ProjectStatus.COMPLETED;
      this.project.updatedAt = Date.now();
      await this.repo.update(this.project);
      promptAction.showToast({
        message: '已标记为完成',
        duration: 1500
      });
      this.loadProject();
    } catch (err) {
      console.error('更新失败: ' + JSON.stringify(err));
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('‹')
          .fontSize(28)
          .fontColor('#182431')
          .onClick(() => {
            router.back();
          })

        Text('作品详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('...')
          .fontSize(20)
          .fontColor('#666666')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      if (this.project) {
        Scroll() {
          Column() {
            // 作品信息卡片
            Column() {
              Row() {
                Text(this.project.title)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#182431')
                  .layoutWeight(1)

                Text(this.getStatusText(this.project.status))
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .backgroundColor(this.getStatusColor(this.project.status))
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(12)
              }
              .width('100%')

              Row() {
                Text(this.getProjectTypeText(this.project.type))
                  .fontSize(13)
                  .fontColor('#666666')
                Text(' · ')
                  .fontSize(13)
                  .fontColor('#CCCCCC')
                Text('创建于 ' + this.formatTime(this.project.createdAt))
                  .fontSize(13)
                  .fontColor('#666666')
              }
              .width('100%')
              .margin({ top: 8 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)

            // 预览区
            Column() {
              Text('内容预览')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#182431')
                .margin({ bottom: 12 })

              if (this.project.type === ProjectType.IMAGE_TEXT) {
                if (this.project.content) {
                  Text('共 ' + JSON.parse(this.project.content).length + ' 页图文内容')
                    .fontSize(13)
                    .fontColor('#666666')
                } else {
                  Text('暂无内容')
                    .fontSize(13)
                    .fontColor('#999999')
                }
              } else if (this.project.type === ProjectType.AUDIO) {
                if (this.project.content) {
                  Text('共 ' + JSON.parse(this.project.content).length + ' 个音频片段')
                    .fontSize(13)
                    .fontColor('#666666')
                } else {
                  Text('暂无音频')
                    .fontSize(13)
                    .fontColor('#999999')
                }
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ top: 12 })

            // 操作按钮
            Column() {
              if (this.project.status === ProjectStatus.DRAFT) {
                Button('继续编辑')
                  .width('100%')
                  .height(48)
                  .type(ButtonType.Capsule)
                  .backgroundColor('#007DFF')
                  .fontColor('#FFFFFF')
                  .fontSize(15)
                  .onClick(() => {
                    this.editProject();
                  })

                Button('标记为完成')
                  .width('100%')
                  .height(48)
                  .type(ButtonType.Capsule)
                  .backgroundColor('#FFFFFF')
                  .fontColor('#34C759')
                  .fontSize(15)
                  .border({ width: 1, color: '#34C759' })
                  .margin({ top: 12 })
                  .onClick(() => {
                    this.markAsCompleted();
                  })
              } else {
                Button('编辑作品')
                  .width('100%')
                  .height(48)
                  .type(ButtonType.Capsule)
                  .backgroundColor('#007DFF')
                  .fontColor('#FFFFFF')
                  .fontSize(15)
                  .onClick(() => {
                    this.editProject();
                  })
              }

              Button('导出作品')
                .width('100%')
                .height(48)
                .type(ButtonType.Capsule)
                .backgroundColor('#FFFFFF')
                .fontColor('#FF6B35')
                .fontSize(15)
                .border({ width: 1, color: '#FF6B35' })
                .margin({ top: 12 })
                .onClick(() => {
                  this.exportProject();
                })

              Button('删除作品')
                .width('100%')
                .height(48)
                .type(ButtonType.Capsule)
                .backgroundColor('#FFFFFF')
                .fontColor('#FF3B30')
                .fontSize(15)
                .border({ width: 1, color: '#FF3B30' })
                .margin({ top: 12 })
                .onClick(() => {
                  this.deleteProject();
                })
            }
            .width('100%')
            .margin({ top: 24 })
          }
          .padding(16)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#F1F3F5')
      } else {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#007DFF')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F1F3F5')
      }
    }
    .width('100%')
    .height('100%')
  }
}
