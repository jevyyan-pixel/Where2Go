# Where2Go

Where2Go（今天去哪玩）是一款 iOS 原生行程规划 App。V0.1 聚焦本地行程管理：新增、查看、编辑、删除行程，并通过下一程、日历、时间线和每日摘要帮助用户快速了解安排。

## 当前功能

- SwiftUI + SwiftData 原生 iOS 工程
- 四个底部 Tab：下一程、日历、时间线、设置
- 行程新增、详情、编辑、删除确认
- 按日期和时间排序
- 日历有安排日期标记
- 时间线按日期分组
- 每日行程摘要通知，基于未来 7 天真实行程预排
- 设置页支持外观、默认提醒、摘要时间、通知状态、数据导出和清空本地行程
- JSON 行程备份导出
- V0.1 基础 App 图标

## 开发环境

- Xcode 26.6
- iOS 26.5 Simulator
- 最低系统版本：iOS 17

## 构建

```bash
xcodebuild -project Where2Go.xcodeproj -scheme Where2Go -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build
```

## 测试

```bash
xcodebuild -project Where2Go.xcodeproj -scheme Where2Go -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test
```

## Git 管理规范

后续开发遵循 [Where2Go Git 管理规范](docs/GIT_WORKFLOW.md)：`main` 保持稳定，大功能使用功能分支，push 前运行测试，稳定阶段使用 tag 标记版本。

## V0.1 暂不包含

- 地图预览与地点搜索
- 系统日历同步
- iCloud 多设备同步
- 账号体系
- 行程分享与协作
