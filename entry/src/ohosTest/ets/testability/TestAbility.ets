import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const domain = 0x0001;
const tag = 'TestAbility';

export default class TestAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(domain, tag, 'TestAbility onCreate');
  }

  onDestroy(): void {
    hilog.info(domain, tag, 'TestAbility onDestroy');
  }
}
