import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { DatabaseHelper } from '../utils/DatabaseHelper';
import { ProjectRepository } from '../repositories/ProjectRepository';
import { Project, ProjectType, ProjectStatus } from '../models/Models';

/**
 * 应用主入口
 * 负责初始化数据库和展示底部 Tab 导航
 */
@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State isDbReady: boolean = false;

  aboutToAppear(): void {
    this.initDatabase();
  }

  private async initDatabase(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      await DatabaseHelper.getInstance().init(context);
      this.isDbReady = true;
    } catch (err) {
      console.error('数据库初始化失败: ' + JSON.stringify(err));
      this.isDbReady = true;
    }
  }

  @Builder
  TabBuilder(title: string, targetIndex: number, icon: Resource, selectedIcon: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedIcon : icon)
        .width(24)
        .height(24)
        .margin({ bottom: 4 })

      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === targetIndex ? '#007DFF' : '#666666')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex;
    })
  }

  @Builder
  HomeTabContent() {
    HomePage()
  }

  @Builder
  CreateTabContent() {
    CreatePage()
  }

  @Builder
  MineTabContent() {
    MinePage()
  }

  build() {
    if (!this.isDbReady) {
      Column() {
        LoadingProgress()
          .width(48)
          .height(48)
          .color('#007DFF')
        Text('正在初始化...')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 16 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F1F3F5')
    } else {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          this.HomeTabContent()
        }
        .tabBar(this.TabBuilder('首页', 0, $r('app.media.ic_home'), $r('app.media.ic_home_filled')))

        TabContent() {
          this.CreateTabContent()
        }
        .tabBar(this.TabBuilder('创作', 1, $r('app.media.ic_create'), $r('app.media.ic_create_filled')))

        TabContent() {
          this.MineTabContent()
        }
        .tabBar(this.TabBuilder('我的', 2, $r('app.media.ic_mine'), $r('app.media.ic_mine_filled')))
      }
      .barWidth('100%')
      .barHeight(56)
      .scrollable(false)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
  }
}

/**
 * 首页
 * 展示创作入口和最近作品列表
 */
@Component
struct HomePage {
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
      Row() {
        Text('图文音频创作')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })

      Scroll() {
        Column() {
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

/**
 * 创作页
 * 提供创作类型选择
 */
@Component
struct CreatePage {
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
      Row() {
        Text('创作')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })

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

/**
 * 我的页面
 * 展示用户信息和设置
 */
@Component
struct MinePage {
  @State totalProjects: number = 0;
  @State draftCount: number = 0;
  @State completedCount: number = 0;
  private repo: ProjectRepository = new ProjectRepository();

  aboutToAppear(): void {
    this.loadStats();
  }

  onPageShow(): void {
    this.loadStats();
  }

  private async loadStats(): Promise<void> {
    try {
      const all = await this.repo.getAll();
      this.totalProjects = all.length;
      this.draftCount = all.filter(p => p.status === ProjectStatus.DRAFT).length;
      this.completedCount = all.filter(p => p.status === ProjectStatus.COMPLETED).length;
    } catch (err) {
      console.error('加载统计失败: ' + JSON.stringify(err));
    }
  }

  @Builder
  StatItem(value: number, label: string) {
    Column() {
      Text(value.toString())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#007DFF')
      Text(label)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  SettingItem(title: string, icon: Resource, showArrow: boolean = true) {
    Row() {
      Image(icon)
        .width(20)
        .height(20)
        .fillColor('#666666')
        .margin({ right: 12 })

      Text(title)
        .fontSize(15)
        .fontColor('#182431')
        .layoutWeight(1)

      if (showArrow) {
        Text('>')
          .fontSize(20)
          .fontColor('#CCCCCC')
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor('#FFFFFF')
  }

  build() {
    Column() {
      Row() {
        Text('我的')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })

      Scroll() {
        Column() {
          Row() {
            Column() {
              Text('创作者')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('motionbook@harmonyos')
                .fontSize(12)
                .fontColor('#FFFFFF')
                .opacity(0.85)
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(20)
          .borderRadius(16)
          .backgroundColor('#007DFF')

          Row() {
            this.StatItem(this.totalProjects, '总作品')
            this.StatItem(this.draftCount, '草稿')
            this.StatItem(this.completedCount, '已完成')
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ top: 12 })

          Column() {
            this.SettingItem('作品管理', $r('app.media.ic_settings'))
            Divider().color('#F1F3F5')
            this.SettingItem('导出设置', $r('app.media.ic_settings'))
            Divider().color('#F1F3F5')
            this.SettingItem('关于应用', $r('app.media.ic_settings'))
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ top: 12 })
          .clip(true)
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
