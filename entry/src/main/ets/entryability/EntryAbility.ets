import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const domain = 0x0001;
const tag = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(domain, tag, 'onCreate: 应用创建');
  }

  onDestroy(): void {
    hilog.info(domain, tag, 'onDestroy: 应用销毁');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(domain, tag, 'onWindowStageCreate: 窗口创建');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(domain, tag, '加载内容失败: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(domain, tag, '加载内容成功');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(domain, tag, 'onWindowStageDestroy: 窗口销毁');
  }

  onForeground(): void {
    hilog.info(domain, tag, 'onForeground: 应用进入前台');
  }

  onBackground(): void {
    hilog.info(domain, tag, 'onBackground: 应用进入后台');
  }
}
