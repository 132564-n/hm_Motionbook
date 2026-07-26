# 0005: 采用 7 阶段 Skill 驱动工作流

## 状态

Accepted

## 背景

项目已完成 MVP 基础框架开发，需要建立可持续的开发工作流来：
- 保证代码质量（审查、测试）
- 保持架构清晰（设计、文档）
- 规范化提交和决策流程
- 充分利用 TRAE 可用的 skill 生态

此前开发流程较随意：访谈→写代码→测试，缺少固定的"每次对话开场动作"，导致每次新对话都需要用户重新解释背景。

## 决策

采用 **7 阶段 Skill 驱动工作流**，并将"开场动作"固化到 `CLAUDE.md` 和 `docs/WORKFLOW.md`。

### 工作流阶段

| 阶段 | 触发 | 主要 Skill |
|------|------|-----------|
| 1. 需求探索 | 新功能/新想法 | research / brainstorming / grilling |
| 2. 领域建模 | 需求明确后 | domain-modeling / codebase-design / prototype |
| 3. 测试驱动实现 | 设计确定后 | tdd / frontend-design |
| 4. 代码审查 | 功能切片完成 | code-review / grilling |
| 5. 调试修复 | 报错/失败 | diagnosing-bugs / tdd |
| 6. 文档提交 | 功能稳定 | doc-coauthoring / git-commit |
| 7. 能力扩展 | 现有 skill 不足 | find-skills / skill-creator |

### 固定开场动作

每次新对话开始时，AI 必须：
1. 读取 `CONTEXT.md`
2. 读取 `docs/WORKFLOW.md`
3. 检查最新 ADR
4. 主动给出 2-3 个下一步选项

### Skill 调用原则

- 一次只跑一个 skill
- 先读 CONTEXT.md 再调 skill
- skill 产出必须归档（ADR/文档/测试进 Git）
- grilling 用于关键决策，不滥用

## 后果

- 优点：
  - 每次对话有明确起点，无需重新解释背景
  - Skill 各司其职，避免混乱
  - 决策有据可查（ADR + WORKFLOW.md）
  - 强制测试和审查，提升代码质量
- 缺点：
  - 每次对话开场有固定开销（读 3 个文件）
  - 小改动也要走流程可能略显繁琐
  - 需要维护 WORKFLOW.md 的状态更新

## 缓解措施

- 开场动作保持轻量（只读 3 个文件，快速给出选项）
- 用户可随时说"跳过流程"直接做事
- WORKFLOW.md 的"当前状态"由 AI 自动维护

## 参考

- [docs/WORKFLOW.md](../WORKFLOW.md) — 完整工作流定义
- [CLAUDE.md](../../CLAUDE.md) — Agent 入口配置
