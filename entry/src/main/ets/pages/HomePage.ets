import { ProjectRepository } from '../repositories/ProjectRepository';
import { Project, ProjectType, ProjectStatus } from '../models/Models';
import { router } from '@kit.ArkUI';

/**
 * 首页
 * 展示创作入口和最近作品列表
 */
@Component
export struct HomePage {
  @State recentProjects: Project[] = [];
  @State isLoading: boolean = false;
  private repo: ProjectRepository = new ProjectRepository();

  aboutToAppear(): void {
    this.loadRecentProjects();
  }

  onPageShow(): void {
    this.loadRecentProjects();
  }

  private async loadRecentProjects(): Promise<void> {
    this.isLoading = true;
    try {
      this.recentProjects = await this.repo.getByStatus(ProjectStatus.DRAFT);
      // 如果没有草稿，加载所有
      if (this.recentProjects.length === 0) {
        this.recentProjects = await this.repo.getAll();
      }
    } catch (err) {
      console.error('加载作品失败: ' + JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }

  private getProjectTypeText(type: ProjectType): string {
    switch (type) {
      case ProjectType.IMAGE_TEXT: return '图文';
      case ProjectType.AUDIO: return '音频';
      case ProjectType.TEMPLATE: return '模板';
      default: return '未知';
    }
  }

  private getProjectTypeColor(type: ProjectType): string {
    switch (type) {
      case ProjectType.IMAGE_TEXT: return '#FF6B35';
      case ProjectType.AUDIO: return '#007DFF';
      case ProjectType.TEMPLATE: return '#34C759';
      default: return '#999999';
    }
  }

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${month}-${day} ${hours}:${minutes}`;
  }

  private navigateToCreate(type: ProjectType): void {
    const params = { type: type };
    if (type === ProjectType.IMAGE_TEXT) {
      router.pushUrl({ url: 'pages/ImageTextEditPage', params: params });
    } else if (type === ProjectType.AUDIO) {
      router.pushUrl({ url: 'pages/AudioCreatePage', params: params });
    }
  }

  private navigateToDetail(project: Project): void {
    router.pushUrl({ url: 'pages/WorkDetailPage', params: { id: project.id } });
  }

  @Builder
  CreateEntryItem(title: string, subtitle: string, icon: Resource, color: string, type: ProjectType) {
    Column() {
      Row() {
        Column() {
          Text(title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text(subtitle)
            .fontSize(11)
            .fontColor('#FFFFFF')
            .opacity(0.8)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Image(icon)
          .width(32)
          .height(32)
          .fillColor('#FFFFFF')
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .borderRadius(16)
    .backgroundColor(color)
    .onClick(() => {
      this.navigateToCreate(type);
    })
  }

  @Builder
  ProjectItem(project: Project) {
    Row() {
      Column() {
        Text(project.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(this.getProjectTypeText(project.type))
            .fontSize(10)
            .fontColor('#FFFFFF')
            .backgroundColor(this.getProjectTypeColor(project.type))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
            .margin({ right: 8 })

          Text(this.formatTime(project.updatedAt))
            .fontSize(11)
            .fontColor('#999999')
        }
        .margin({ top: 6 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(project.status === ProjectStatus.DRAFT ? '草稿' : '已完成')
        .fontSize(11)
        .fontColor(project.status === ProjectStatus.DRAFT ? '#FF9500' : '#34C759')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 8 })
    .onClick(() => {
      this.navigateToDetail(project);
    })
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('图文音频创作')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })

      // 滚动内容区
      Scroll() {
        Column() {
          // 创作入口区
          Text('开始创作')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .margin({ top: 12, bottom: 12, left: 4 })
            .width('100%')

          Row() {
            this.CreateEntryItem('图文创作', '编辑图片+文字', $r('app.media.ic_image_text'), '#FF6B35', ProjectType.IMAGE_TEXT)
          }
          .width('100%')
          .margin({ bottom: 8 })

          Row() {
            this.CreateEntryItem('音频创作', '录音+剪辑', $r('app.media.ic_audio'), '#007DFF', ProjectType.AUDIO)
          }
          .width('100%')
          .margin({ bottom: 8 })

          Row() {
            this.CreateEntryItem('模板创作', '一键套用模板', $r('app.media.ic_template'), '#34C759', ProjectType.TEMPLATE)
          }
          .width('100%')

          // 最近作品区
          Text('最近作品')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .margin({ top: 24, bottom: 12, left: 4 })
            .width('100%')

          if (this.recentProjects.length === 0) {
            Column() {
              Text('还没有作品')
                .fontSize(14)
                .fontColor('#999999')
              Text('点击上方入口开始创作吧')
                .fontSize(12)
                .fontColor('#CCCCCC')
                .margin({ top: 4 })
            }
            .width('100%')
            .padding(32)
          } else {
            ForEach(this.recentProjects, (project: Project) => {
              this.ProjectItem(project)
            }, (project: Project) => project.id?.toString())
          }
        }
        .padding({ left: 16, right: 16, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}
