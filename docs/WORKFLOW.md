# 项目工作流（Workflow）

> **每次对话开始时，AI 必须先读取本文件，然后根据当前项目状态给出下一步建议。**

## 固定开场动作（每次对话执行）

1. 读取 [CONTEXT.md](../CONTEXT.md) — 了解项目目的、领域、约束
2. 读取本文件（`docs/WORKFLOW.md`）— 确认当前阶段和待办
3. 检查 [docs/adr/](../adr/) 最新 ADR — 了解近期架构决策
4. 根据当前阶段，**主动给出 2-3 个下一步选项**让用户选择

## 工作流阶段与 Skill 映射

### 阶段 1：需求探索（Discovery）
**触发**：用户提出新功能/新想法时
**Skill 组合**：
- `research` — 调研 HarmonyOS API、竞品、最佳实践
- `brainstorming` — 探索需求和设计方案
- `grilling` — 质询决策，避免过度设计

**产出**：需求文档、调研笔记、决策记录

---

### 阶段 2：领域建模与设计（Design）
**触发**：需求明确后，开始编码前
**Skill 组合**：
- `domain-modeling` — 建立领域模型、统一语言
- `codebase-design` — 设计模块边界、接口分层
- `prototype` — 快速原型验证关键交互

**产出**：更新的 CONTEXT.md、新增 ADR、原型代码

---

### 阶段 3：测试驱动实现（Implementation）
**触发**：设计确定后，开始写功能代码
**Skill 组合**：
- `tdd` — Red→Green 循环，先写测试再写实现
- `frontend-design` — 高品质 UI 实现（鸿蒙 ArkTS）
- `frontend-skill` — 视觉强烈的页面设计

**产出**：测试用例、功能代码、UI 组件

---

### 阶段 4：代码审查（Review）
**触发**：一个功能切片完成后
**Skill 组合**：
- `code-review` — 审查 Standards（规范）和 Spec（符合需求）
- `grilling` — 质询设计选择

**产出**：审查报告、修复 commit

---

### 阶段 5：调试与修复（Debugging）
**触发**：运行时报错、测试失败、性能问题
**Skill 组合**：
- `diagnosing-bugs` — 系统化定位 bug 根因
- `tdd` — 写回归测试验证修复
- `webapp-testing` — 端到端测试（如适用）

**产出**：bug 诊断报告、修复代码、回归测试

---

### 阶段 6：文档与提交（Documentation & Commit）
**触发**：功能稳定，准备归档
**Skill 组合**：
- `doc-coauthoring` — 编写技术文档、API 文档
- `git-commit` — 规范的 conventional commit
- `grilling` — 提交前最后质询

**产出**：文档更新、规范提交

---

### 阶段 7：能力扩展（Extension）
**触发**：发现现有 skill 无法覆盖的场景
**Skill 组合**：
- `find-skills` — 搜索可安装的新 skill
- `skill-creator` — 创建项目专属 skill

**产出**：新 skill 安装/创建

## 鸿蒙项目专用 Skill 使用约定

### HarmonyOS 特定场景

| 场景 | 推荐 Skill | 说明 |
|------|-----------|------|
| 调研 ArkTS API | `research` | 查官方文档、最佳实践 |
| 设计数据层 | `codebase-design` | Repository 模式、模块边界 |
| 实现 ArkTS UI | `frontend-design` | 鸿蒙原生设计语言 |
| 测试 Repository | `tdd` | ohosTest + hypium |
| 调试运行时错误 | `diagnosing-bugs` | 系统化定位 |
| 审查 ArkTS 代码 | `code-review` | 规范 + 需求符合度 |
| 提交功能 | `git-commit` | conventional commit |

### Skill 调用原则

1. **一次只跑一个 skill**：避免多个 skill 同时介入造成混乱
2. **先读 CONTEXT.md 再调 skill**：让 skill 了解项目背景
3. **skill 产出必须归档**：ADR、文档、测试都要进 Git
4. **grilling 用于关键决策**：不是每个小改动都质询

## 当前项目状态

**阶段**：阶段 3（测试驱动实现）进行中

**已完成**：
- ✅ 阶段 1：需求探索（grill-with-docs 完成）
- ✅ 阶段 2：领域建模（CONTEXT.md + 4 个 ADR）
- 🔄 阶段 3：MVP 代码框架已建，16 个单元测试已写
- ⏳ 阶段 4：待审查
- ⏳ 阶段 5：待运行测试
- ⏳ 阶段 6：待文档完善

**下一步候选**：
1. 用 `code-review` 审查已写的 MVP 代码
2. 用 `frontend-design` 提升 HomePage/CreatePage UI 品质
3. 用 `tdd` 为 ImageTextEditPage 补充组件测试
4. 用 `research` 调研鸿蒙分布式能力实现方案
5. 用 `diagnosing-bugs` 系统化检查潜在运行时问题

## 每次对话的输出格式

AI 在每次对话开始时，应该输出：

```
## 当前状态
- 阶段：[阶段X - 名称]
- 上次进展：[简述]
- 待办：[列表]

## 建议的下一步
1. [选项1] — 使用 [skill名] — [说明]
2. [选项2] — 使用 [skill名] — [说明]
3. [选项3] — 使用 [skill名] — [说明]

请选择，或告诉我你想做什么。
```
