import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { DatabaseHelper } from '../utils/DatabaseHelper';
import { ProjectRepository } from '../repositories/ProjectRepository';
import { ProjectStatus } from '../models/Models';

/**
 * 我的页面
 * 展示用户信息和设置
 */
@Component
export struct MinePage {
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
        Text('›')
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
      // 标题栏
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
          // 用户信息卡片
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
          .backgroundImage($r('app.media.bg_user_card'))
          .backgroundColor('#007DFF')

          // 统计数据
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

          // 设置列表
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
