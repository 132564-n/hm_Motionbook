import { common } from '@kit.AbilityKit';
import { DatabaseHelper } from '../utils/DatabaseHelper';
import { HomePage } from './HomePage';
import { CreatePage } from './CreatePage';
import { MinePage } from './MinePage';

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
      // 即使数据库失败也允许进入，使用内存模式
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
          HomePage()
        }
        .tabBar(this.TabBuilder('首页', 0, $r('app.media.ic_home'), $r('app.media.ic_home_filled')))

        TabContent() {
          CreatePage()
        }
        .tabBar(this.TabBuilder('创作', 1, $r('app.media.ic_create'), $r('app.media.ic_create_filled')))

        TabContent() {
          MinePage()
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
