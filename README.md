# 鸿蒙图文音频创作工具 (hm_Motionbook)

一款面向自媒体创作者和普通用户的鸿蒙原生图文音频创作工具。

## 项目状态

🚧 MVP 开发中

## 技术栈

- **语言**: ArkTS
- **框架**: HarmonyOS SDK (Stage Model)
- **存储**: SQLite (relationalStore) + Preferences
- **最低 API**: 12 (HarmonyOS 5.0+)

## 功能模块

### MVP 范围
- ✅ 图文编辑（图片选择、文字叠加、多页管理）
- ✅ 音频创作（录音、播放、片段管理、音量调节）
- ✅ 作品管理（草稿、完成、删除、详情查看）
- ✅ 本地数据存储

### 后续规划
- ⬜ AI 辅助创作（云端 AI 服务）
- ⬜ 模板库
- ⬜ 多平台发布
- ⬜ 鸿蒙分布式协同
- ⬜ 服务卡片
- ⬜ 鸿蒙账号集成

## 项目结构

```
entry/src/main/
├── ets/
│   ├── entryability/
│   │   └── EntryAbility.ets        # 应用入口
│   ├── models/
│   │   └── Models.ets              # 数据模型
│   ├── repositories/
│   │   └── ProjectRepository.ets   # 项目数据仓库
│   ├── utils/
│   │   └── DatabaseHelper.ets      # 数据库助手
│   └── pages/
│       ├── Index.ets               # 主入口（Tab 导航）
│       ├── HomePage.ets            # 首页
│       ├── CreatePage.ets          # 创作页
│       ├── MinePage.ets            # 我的
│       ├── ImageTextEditPage.ets   # 图文编辑
│       ├── AudioCreatePage.ets     # 音频创作
│       └── WorkDetailPage.ets      # 作品详情
├── resources/
│   └── base/
│       ├── element/                # 字符串、颜色
│       └── profile/                # 页面路由配置
└── module.json5                    # 模块配置
```

## 开发环境

- DevEco Studio (推荐最新版本)
- HarmonyOS SDK 5.0+
- HarmonyOS 模拟器或真机

## 文档

- [CONTEXT.md](./CONTEXT.md) - 项目上下文
- [docs/adr/](./docs/adr/) - 架构决策记录
- [docs/agents/](./docs/agents/) - Agent 配置

## 许可证

Apache-2.0
