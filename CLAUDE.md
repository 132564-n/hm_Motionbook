## Agent skills

### ⚠️ 每次对话开场动作（必读）

每次新对话开始时，AI 必须执行以下步骤：

1. 读取 `CONTEXT.md` — 了解项目目的、领域、约束
2. 读取 `docs/WORKFLOW.md` — 确认当前工作流阶段和待办
3. 检查 `docs/adr/` 最新 ADR — 了解近期架构决策
4. 根据 WORKFLOW.md 中定义的格式，**主动给出下一步建议**（2-3 个选项）

详见 [docs/WORKFLOW.md](docs/WORKFLOW.md)。

### Issue tracker

Issues live in GitHub Issues at [132564-n/hm_Motionbook](https://github.com/132564-n/hm_Motionbook/issues). See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

### Workflow

项目开发遵循 7 阶段工作流，每个阶段对应特定 skill 组合：
1. 需求探索（research / brainstorming / grilling）
2. 领域建模（domain-modeling / codebase-design / prototype）
3. 测试驱动实现（tdd / frontend-design）
4. 代码审查（code-review / grilling）
5. 调试修复（diagnosing-bugs / tdd）
6. 文档提交（doc-coauthoring / git-commit）
7. 能力扩展（find-skills / skill-creator）

完整说明见 [docs/WORKFLOW.md](docs/WORKFLOW.md)。
