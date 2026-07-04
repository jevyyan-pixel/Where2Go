# Where2Go Git 管理规范

本项目后续开发遵循以下 Git 规则，目标是让 `main` 分支始终保持可运行、可构建、可回溯。

## 分支规则

- `main` 只保留稳定代码。
- 不在 `main` 上直接做大功能开发。
- 每个明确功能或较大改动新建一个功能分支。

分支命名建议：

```bash
feature/plan-b-ui
feature/calendar-polish
feature/notification-summary
fix/timeline-ordering
docs/update-prd
```

常用流程：

```bash
git checkout main
git pull
git checkout -b feature/xxx
```

## 提交规则

一次提交只做一类清晰改动，避免把不相关内容混在一起。

提交信息建议使用以下前缀：

```text
feat: 新功能
fix: 修复问题
docs: 文档更新
style: 纯样式/UI 调整，不改变业务逻辑
refactor: 重构，不改变行为
test: 测试相关
chore: 工程配置、脚本、杂项
```

示例：

```bash
git commit -m "feat: add sport trip category"
git commit -m "fix: order timeline dates ascending"
git commit -m "style: apply concierge card styling"
git commit -m "docs: add git workflow rules"
```

## 推送前检查

每次 push 前至少执行：

```bash
xcodebuild -project Where2Go.xcodeproj -scheme Where2Go -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test
```

如果改动涉及启动、导航、表单、通知或视觉布局，额外执行：

```bash
xcodebuild -project Where2Go.xcodeproj -scheme Where2Go -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build
```

确认通过后再提交和推送：

```bash
git status
git add .
git commit -m "type: concise description"
git push
```

## 合并规则

- 功能分支完成后再合并回 `main`。
- 合并前确保测试通过。
- 如果只有个人开发，可以本地合并：

```bash
git checkout main
git pull
git merge feature/xxx
git push
```

- 如果通过 GitHub 管理，建议用 Pull Request，并在 PR 描述里记录：
  - 本次改了什么
  - 如何验证
  - 是否有已知问题

## 版本标签

稳定阶段建议打 tag，方便回溯和发布。

示例：

```bash
git tag v0.1.0-plan-b
git push origin v0.1.0-plan-b
```

版本命名建议：

```text
v0.1.0
v0.1.1
v0.2.0
```

带实验性质的阶段版本可以加后缀：

```text
v0.1.0-plan-b
v0.2.0-map-preview
```

## 不应提交的内容

以下内容不应进入仓库：

- `DerivedData/`
- `build/`
- `xcuserdata/`
- `*.xcuserstate`
- `.DS_Store`
- 本机临时文件
- 密钥、token、证书、个人账号配置

当前 `.gitignore` 已覆盖主要 Xcode 和 macOS 临时文件。新增工具或构建产物时，先确认是否需要补充 `.gitignore`。

## 推荐工作节奏

1. 从 `main` 拉取最新代码。
2. 为本次功能创建分支。
3. 小步提交，每次提交描述清楚。
4. push 前跑测试。
5. 合并回 `main` 后，必要时打 tag。
6. 保持 `main` 随时可运行。
