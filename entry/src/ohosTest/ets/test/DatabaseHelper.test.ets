import { describe, beforeAll, it, expect } from '@ohos/hypium';
import { DatabaseHelper } from '../../../main/ets/utils/DatabaseHelper';

export default function DatabaseHelperTest() {
  describe('DatabaseHelper', () => {
    it('getInstance_shouldReturnSameInstance', 0, () => {
      const instance1 = DatabaseHelper.getInstance();
      const instance2 = DatabaseHelper.getInstance();
      expect(instance1).assertEqual(instance2);
    });

    it('getInstance_shouldReturnNonNullInstance', 0, () => {
      const instance = DatabaseHelper.getInstance();
      expect(instance !== null && instance !== undefined).assertTrue();
    });

    it('getStore_beforeInit_shouldThrowError', 0, () => {
      const instance = DatabaseHelper.getInstance();
      try {
        instance.getStore();
        expect(true).assertFalse();
      } catch (e) {
        expect(e.message).assertEqual('数据库未初始化，请先调用 init()');
      }
    });

    it('getPreferences_beforeInit_shouldThrowError', 0, () => {
      const instance = DatabaseHelper.getInstance();
      try {
        instance.getPreferences();
        expect(true).assertFalse();
      } catch (e) {
        expect(e.message).assertEqual('Preferences 未初始化，请先调用 init()');
      }
    });
  });
}
