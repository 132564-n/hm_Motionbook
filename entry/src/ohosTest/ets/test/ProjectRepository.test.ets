import { describe, beforeAll, beforeEach, it, expect } from '@ohos/hypium';
import { common } from '@kit.AbilityKit';
import { DatabaseHelper } from '../../../main/ets/utils/DatabaseHelper';
import { ProjectRepository } from '../../../main/ets/repositories/ProjectRepository';
import { Project, ProjectType, ProjectStatus } from '../../../main/ets/models/Models';

export default function ProjectRepositoryTest() {
  let repo: ProjectRepository;
  let context: common.UIAbilityContext;

  beforeAll(async () => {
    context = getContext(this) as common.UIAbilityContext;
    await DatabaseHelper.getInstance().init(context);
  });

  beforeEach(async () => {
    repo = new ProjectRepository();
    const store = DatabaseHelper.getInstance().getStore();
    await store.executeSql('DELETE FROM projects');
  });

  describe('ProjectRepository.create', () => {
    it('create_validProject_shouldReturnRowId', 0, async () => {
      const project: Project = {
        title: '测试项目',
        type: ProjectType.IMAGE_TEXT,
        status: ProjectStatus.DRAFT,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
      const id = await repo.create(project);
      expect(id > 0).assertTrue();
    });

    it('create_withContent_shouldPersistContent', 0, async () => {
      const testContent = JSON.stringify({ pages: [] });
      const project: Project = {
        title: '有内容的项目',
        type: ProjectType.AUDIO,
        status: ProjectStatus.DRAFT,
        content: testContent,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
      const id = await repo.create(project);
      const saved = await repo.getById(id);
      expect(saved).assertInstanceOf('Object');
      if (saved) {
        expect(saved.content).assertEqual(testContent);
      }
    });
  });

  describe('ProjectRepository.getById', () => {
    it('getById_existingId_shouldReturnProject', 0, async () => {
      const project: Project = {
        title: '查询测试',
        type: ProjectType.IMAGE_TEXT,
        status: ProjectStatus.DRAFT,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
      const id = await repo.create(project);
      const result = await repo.getById(id);
      expect(result).assertInstanceOf('Object');
      if (result) {
        expect(result.id).assertEqual(id);
        expect(result.title).assertEqual('查询测试');
        expect(result.type).assertEqual(ProjectType.IMAGE_TEXT);
        expect(result.status).assertEqual(ProjectStatus.DRAFT);
      }
    });

    it('getById_nonExistingId_shouldReturnNull', 0, async () => {
      const result = await repo.getById(99999);
      expect(result).assertNull();
    });
  });

  describe('ProjectRepository.update', () => {
    it('update_title_shouldChangeTitle', 0, async () => {
      const project: Project = {
        title: '原标题',
        type: ProjectType.IMAGE_TEXT,
        status: ProjectStatus.DRAFT,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
      const id = await repo.create(project);
      const saved = await repo.getById(id);
      if (saved) {
        saved.title = '新标题';
        await repo.update(saved);
        const updated = await repo.getById(id);
        if (updated) {
          expect(updated.title).assertEqual('新标题');
        }
      }
    });

    it('update_status_shouldChangeStatus', 0, async () => {
      const project: Project = {
        title: '状态测试',
        type: ProjectType.AUDIO,
        status: ProjectStatus.DRAFT,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
      const id = await repo.create(project);
      const saved = await repo.getById(id);
      if (saved) {
        saved.status = ProjectStatus.COMPLETED;
        await repo.update(saved);
        const updated = await repo.getById(id);
        if (updated) {
          expect(updated.status).assertEqual(ProjectStatus.COMPLETED);
        }
      }
    });

    it('update_noId_shouldThrowError', 0, async () => {
      const project: Project = {
        title: '无ID项目',
        type: ProjectType.IMAGE_TEXT,
        status: ProjectStatus.DRAFT,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
      try {
        await repo.update(project);
        expect(true).assertFalse();
      } catch (e) {
        expect(e.message).assertEqual('项目 ID 不能为空');
      }
    });
  });

  describe('ProjectRepository.delete', () => {
    it('delete_existingId_shouldRemoveProject', 0, async () => {
      const project: Project = {
        title: '待删除',
        type: ProjectType.IMAGE_TEXT,
        status: ProjectStatus.DRAFT,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
      const id = await repo.create(project);
      const before = await repo.getById(id);
      expect(before !== null).assertTrue();
      await repo.delete(id);
      const after = await repo.getById(id);
      expect(after).assertNull();
    });
  });

  describe('ProjectRepository.getAll', () => {
    it('getAll_emptyDb_shouldReturnEmptyArray', 0, async () => {
      const result = await repo.getAll();
      expect(Array.isArray(result)).assertTrue();
      expect(result.length).assertEqual(0);
    });

    it('getAll_multipleProjects_shouldReturnAll', 0, async () => {
      for (let i = 0; i < 3; i++) {
        const project: Project = {
          title: `项目 ${i}`,
          type: i % 2 === 0 ? ProjectType.IMAGE_TEXT : ProjectType.AUDIO,
          status: ProjectStatus.DRAFT,
          createdAt: Date.now() + i,
          updatedAt: Date.now() + i
        };
        await repo.create(project);
      }
      const result = await repo.getAll();
      expect(result.length).assertEqual(3);
    });

    it('getAll_shouldBeSortedByUpdatedAtDesc', 0, async () => {
      const project1: Project = {
        title: '旧项目',
        type: ProjectType.IMAGE_TEXT,
        status: ProjectStatus.DRAFT,
        createdAt: 1000,
        updatedAt: 1000
      };
      const project2: Project = {
        title: '新项目',
        type: ProjectType.AUDIO,
        status: ProjectStatus.DRAFT,
        createdAt: 2000,
        updatedAt: 2000
      };
      await repo.create(project1);
      await repo.create(project2);
      const result = await repo.getAll();
      expect(result[0].title).assertEqual('新项目');
      expect(result[1].title).assertEqual('旧项目');
    });
  });

  describe('ProjectRepository.getByStatus', () => {
    it('getByStatus_draft_shouldReturnOnlyDrafts', 0, async () => {
      const draft: Project = {
        title: '草稿',
        type: ProjectType.IMAGE_TEXT,
        status: ProjectStatus.DRAFT,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
      const completed: Project = {
        title: '已完成',
        type: ProjectType.AUDIO,
        status: ProjectStatus.COMPLETED,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
      await repo.create(draft);
      await repo.create(completed);
      const drafts = await repo.getByStatus(ProjectStatus.DRAFT);
      expect(drafts.length).assertEqual(1);
      expect(drafts[0].status).assertEqual(ProjectStatus.DRAFT);
    });
  });
}
