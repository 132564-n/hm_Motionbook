import { relationalStore } from '@kit.ArkData';
import { DatabaseHelper } from '../utils/DatabaseHelper';
import { Project, ProjectType, ProjectStatus } from '../models/Models';

/**
 * 创作项目仓库
 * 负责项目的 CRUD 操作
 */
export class ProjectRepository {
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();

  /**
   * 创建新项目
   */
  async create(project: Project): Promise<number> {
    const store = this.dbHelper.getStore();
    const now = Date.now();
    const values: relationalStore.ValuesBucket = {
      'title': project.title,
      'type': project.type,
      'status': project.status,
      'cover_path': project.coverPath || null,
      'content': project.content || null,
      'created_at': now,
      'updated_at': now
    };
    const rowId = await store.insert('projects', values);
    return rowId;
  }

  /**
   * 更新项目
   */
  async update(project: Project): Promise<void> {
    if (!project.id) {
      throw new Error('项目 ID 不能为空');
    }
    const store = this.dbHelper.getStore();
    const now = Date.now();
    const values: relationalStore.ValuesBucket = {
      'title': project.title,
      'status': project.status,
      'cover_path': project.coverPath || null,
      'content': project.content || null,
      'updated_at': now
    };
    const predicates = new relationalStore.RdbPredicates('projects');
    predicates.equalTo('id', project.id);
    await store.update(values, predicates);
  }

  /**
   * 删除项目
   */
  async delete(id: number): Promise<void> {
    const store = this.dbHelper.getStore();
    const predicates = new relationalStore.RdbPredicates('projects');
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  /**
   * 根据 ID 查询项目
   */
  async getById(id: number): Promise<Project | null> {
    const store = this.dbHelper.getStore();
    const predicates = new relationalStore.RdbPredicates('projects');
    predicates.equalTo('id', id);
    const result = await store.query(predicates, ['id', 'title', 'type', 'status', 'cover_path', 'content', 'created_at', 'updated_at']);

    let project: Project | null = null;
    if (result.goToFirstRow()) {
      project = this.mapRowToProject(result);
    }
    result.close();
    return project;
  }

  /**
   * 查询所有项目
   */
  async getAll(): Promise<Project[]> {
    const store = this.dbHelper.getStore();
    const predicates = new relationalStore.RdbPredicates('projects');
    predicates.orderByDesc('updated_at');
    const result = await store.query(predicates, ['id', 'title', 'type', 'status', 'cover_path', 'content', 'created_at', 'updated_at']);

    const projects: Project[] = [];
    while (result.goToNextRow()) {
      projects.push(this.mapRowToProject(result));
    }
    result.close();
    return projects;
  }

  /**
   * 按状态查询项目
   */
  async getByStatus(status: ProjectStatus): Promise<Project[]> {
    const store = this.dbHelper.getStore();
    const predicates = new relationalStore.RdbPredicates('projects');
    predicates.equalTo('status', status);
    predicates.orderByDesc('updated_at');
    const result = await store.query(predicates, ['id', 'title', 'type', 'status', 'cover_path', 'content', 'created_at', 'updated_at']);

    const projects: Project[] = [];
    while (result.goToNextRow()) {
      projects.push(this.mapRowToProject(result));
    }
    result.close();
    return projects;
  }

  /**
   * 将结果集行映射为 Project 对象
   */
  private mapRowToProject(resultSet: relationalStore.ResultSet): Project {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      title: resultSet.getString(resultSet.getColumnIndex('title')),
      type: resultSet.getString(resultSet.getColumnIndex('type')) as ProjectType,
      status: resultSet.getString(resultSet.getColumnIndex('status')) as ProjectStatus,
      coverPath: resultSet.getString(resultSet.getColumnIndex('cover_path')) || undefined,
      content: resultSet.getString(resultSet.getColumnIndex('content')) || undefined,
      createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
      updatedAt: resultSet.getLong(resultSet.getColumnIndex('updated_at'))
    };
  }
}
