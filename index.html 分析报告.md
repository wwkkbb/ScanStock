用户画像：个体小微商户
  追求零成本、离线可用、操作极简的移动端收银工具。典型场景：夫妻店、小卖部、流动摊位——没有专业收银机，不想交软件订阅费，网络不稳定，需要用手机/平板快速扫码收款，定期导
  出数据对账或换机同步。
项目只有一个html原因：易于传播，下载html文件，浏览器打开即可用，降低使用要求（也带来开发不好维护问题）。

# index.html 分析报告

更新时间：2026-04-01

## 1. 文件定位
项目的核心前端逻辑几乎都在根目录的：
- `index.html`

它同时包含：
- HTML 结构
- CSS 样式
- 前端业务逻辑
- 本地数据存储
- 备份与导出
- 扫码与拍照

维护时应把它视为单文件前端应用入口，而不是普通静态首页。

## 2. 主源码与 APK 的关系
主源码：
- `index.html`

APK 打包使用的同步副本：
- `apk-wrapper/www/index.html`

同步脚本：
- `scripts/sync-apk-www.ps1`

所以应遵守：
- 优先修改根目录 `index.html`
- 不把 `apk-wrapper/www/index.html` 当主编辑目标
- 如果新增资源进 APK，要同步更新 `scripts/sync-apk-www.ps1`

## 3. 当前主要业务模块
`index.html` 当前包含这些核心模块：
- 商品管理
- 商品搜索
- 扫码枪输入识别
- 摄像头扫码
- 商品图片拍照与管理
- 购物车与数量编辑
- 结算与找零
- 历史订单查看
- 历史订单搜索与筛选
- 数据导入
- 手动导出
- 自动导出
- 手动备份
- 应急备份
- 手机端适配布局
- Cordova APK 运行支持

## 4. 数据层结构
当前以 `IndexedDB` 为主存储。

主要运行时数据：
- `products`
- `cart`
- `history`
- `deviceProfile`

IndexedDB 负责保存：
- 商品
- 历史订单
- 应用内备份
- 元信息
- 图片
- 购物车状态

`localStorage` 现在主要用于迁移兼容，不再承担主业务存储。

## 5. 备份与导出的现状
现在必须区分三类能力。

手动备份：
- 仅保存在应用内
- 用于恢复误操作

应急备份：
- 在导入前、恢复前自动创建
- 仅保存在应用内

导出：
- 手动导出在浏览器里走文件下载
- 手动导出在 APK 里走 Android 系统保存窗口
- 自动导出在 APK 里写入 `Downloads/cashier-backups/`

自动导出触发条件：
- 距离上次自动导出已满 15 天
- 并且商品或历史数据发生变化

这意味着：
- 自动机制现在属于“导出”
- 不再属于“应用内备份”

## 6. APK 相关实现
除了前端 JS 以外，当前导出能力还依赖 Android 原生桥。

关键原生文件：
- `apk-wrapper/platforms/android/app/src/main/java/com/cashier/app/MainActivity.java`

它负责：
- 给 WebView 注入 `CashierNativeExporter`
- 手动导出时拉起 Android 系统保存窗口
- 自动导出时写入 Android 下载目录

如果 `platforms/android` 被重建，这部分需要重新检查或恢复。

## 7. UI 结构概览
页面大致分为：
- 左侧商品管理区
- 右侧收银区
- 历史记录区
- 数据管理区

数据管理区相关能力：
- 导出
- 导入
- 备份管理

关键函数包括：
- `exportSimpleData()`
- `importSimpleData()`
- `openBackupModal()`
- `createManualBackup()`
- `restoreFromBackup()`

## 8. 维护时最重要的判断
后续修改时要牢记：
- `index.html` 是唯一主源码
- APK 内导出不再依赖纯前端下载逻辑
- 手动导出和自动导出都带有 Android 原生依赖
- 备份和导出已经不是同一个概念

## 9. 一句话结论
当前 `index.html` 是一个单文件前端收银应用。
它通过 `IndexedDB` 管理应用内数据，通过 Cordova 打包进 APK，并通过 Android 原生桥完成 APK 内的导出能力。
