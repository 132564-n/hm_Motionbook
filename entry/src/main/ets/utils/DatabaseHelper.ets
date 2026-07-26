import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { preferences } from '@kit.ArkData';
import { relationalStore } from '@kit.ArkData';

const domain = 0x0001;
const tag = 'DatabaseHelper';

/**
 * 数据库助手类
 * 负责管理 SQLite 数据库和 Preferences 偏好存储
 */
export class DatabaseHelper {
  private static instance: DatabaseHelper;
  private store: relationalStore.RdbStore | null = null;
  private prefs: preferences.Preferences | null = null;

  private constructor() {}

  static getInstance(): DatabaseHelper {
    if (!DatabaseHelper.instance) {
      DatabaseHelper.instance = new DatabaseHelper();
    }
    return DatabaseHelper.instance;
  }

  /**
   * 初始化数据库
   */
  async init(context: common.Context): Promise<void> {
    try {
      await this.initRdb(context);
      await this.initPreferences(context);
      hilog.info(domain, tag, '数据库初始化成功');
    } catch (err) {
      hilog.error(domain, tag, '数据库初始化失败: %{public}s', JSON.stringify(err));
      throw err;
    }
  }

  /**
   * 初始化关系型数据库
   */
  private async initRdb(context: common.Context): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: 'MotionBook.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };

    this.store = await relationalStore.getRdbStore(context, config);
    await this.createTables();
    hilog.info(domain, tag, 'SQLite 数据库初始化完成');
  }

  /**
   * 创建数据表
   */
  private async createTables(): Promise<void> {
    if (!this.store) {
      throw new Error('数据库未初始化');
    }

    // 创作项目表
    const createProjectsTable = `
      CREATE TABLE IF NOT EXISTS projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL DEFAULT '未命名作品',
        type TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'draft',
        cover_path TEXT,
        content TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    `;

    // 音频片段表
    const createAudioClipsTable = `
      CREATE TABLE IF NOT EXISTS audio_clips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        duration INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    `;

    await this.store.executeSql(createProjectsTable);
    await this.store.executeSql(createAudioClipsTable);
    hilog.info(domain, tag, '数据表创建完成');
  }

  /**
   * 初始化偏好存储
   */
  private async initPreferences(context: common.Context): Promise<void> {
    this.prefs = await preferences.getPreferences(context, 'motionbook_prefs');
    hilog.info(domain, tag, 'Preferences 初始化完成');
  }

  /**
   * 获取数据库实例
   */
  getStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('数据库未初始化，请先调用 init()');
    }
    return this.store;
  }

  /**
   * 获取偏好存储实例
   */
  getPreferences(): preferences.Preferences {
    if (!this.prefs) {
      throw new Error('Preferences 未初始化，请先调用 init()');
    }
    return this.prefs;
  }
}
