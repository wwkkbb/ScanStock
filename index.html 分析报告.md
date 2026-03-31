# index.html 分析报告

更新时间：2026-03-31

## 1. 文件定位

当前项目的核心业务几乎都在根目录的 `index.html` 中完成。

它同时包含：
- 页面结构 HTML
- 主要样式 CSS
- 前端业务逻辑 JavaScript
- 本地存储、订单、备份、导入导出、扫码、拍照等功能

后续维护时，要把它当作单文件前端应用入口，而不是普通静态首页。

## 2. 源码与 APK 的关系

根目录 `index.html` 是唯一主源码。

Cordova 打包时真正进入 APK 的页面副本在：
- `apk-wrapper/www/index.html`

这份副本由脚本自动同步：
- `scripts/sync-apk-www.ps1`

因此后续改页面时应遵守：
- 优先改根目录 `index.html`
- 不把 `apk-wrapper/www/index.html` 当成主编辑目标
- 如果新增根目录资源要打进 APK，需要同步更新 `scripts/sync-apk-www.ps1`

## 3. 当前页面功能概览

`index.html` 现在已经不是简单收银页，而是一个完整的本地化收银单页应用，主要包含这些模块：

- 商品管理
- 商品搜索
- 扫码枪输入识别
- 摄像头扫码
- 商品拍照与图片管理
- 购物车与数量编辑
- 结算与找零
- 历史订单查看
- 历史订单搜索筛选
- 数据导出 / 导入
- 自动备份 / 手动备份 / 应急备份
- 手机端适配布局
- Cordova APK 内运行支持

## 4. UI 结构梳理

页面大致分成这些区域：

### 4.1 左侧商品管理区

主要职责：
- 展示商品列表
- 新增商品
- 维护商品名称、价格、简码、条码
- 管理商品图片

常见关联函数：
- `renderProductList()`
- `addProduct()`
- `saveProducts()`

### 4.2 右侧收银区

主要职责：
- 搜索商品
- 加入购物车
- 展示购物车条目
- 支持加减数量与直接编辑数量
- 发起结算

常见关联函数：
- `addToCart()`
- `updateCart()`
- `openCheckout()`
- `checkout()`

### 4.3 交易记录区

当前能力：
- 查看历史订单
- 列表中显示交易时间、客户姓名、商品件数、总金额
- 点进单条记录后查看完整交易详情
- 支持历史搜索

当前搜索维度：
- 关键词搜索
- 金额范围搜索
- 时间范围搜索

核心函数：
- `showHistory()`
- `showHistoryDetail(index)`

### 4.4 数据管理区

页面左下角有数据管理入口按钮。

当前入口命名：
- `💾 数据`

桌面端行为：
- 点击后展开本地数据操作区

手机端行为：
- 点击后弹出独立数据面板

相关能力：
- 导出
- 导入
- 备份管理

核心函数：
- `toggleDataManager()`
- `openDataPanelModal()`
- `closeDataPanelModal()`
- `exportSimpleData()`
- `importSimpleData()`
- `openBackupModal()`

## 5. 数据层结构

当前项目以 `IndexedDB` 为主存储，不再依赖 `localStorage` 承担核心业务数据。

### 5.1 主要运行时变量

脚本中较关键的全局状态包括：

- `products`
- `cart`
- `history`
- `deviceProfile`

这些变量分别代表：
- 商品列表
- 当前购物车
- 历史订单
- 当前设备身份信息

### 5.2 IndexedDB 的角色

当前数据库负责保存：
- 商品
- 历史订单
- 备份
- 元信息
- 图片
- 购物车状态

从业务角度看，`index.html` 已经实现了一个完整的前端本地数据库应用。

### 5.3 localStorage 的角色

`localStorage` 现在主要用于迁移兼容或辅助逻辑，不再是主存储。

## 6. 订单与历史记录设计

历史订单记录中，当前重点字段包括：

- `orderId`
- `deviceId`
- `createdAt`
- `time`
- `items`
- `total`
- `payment`
- `change`
- `customerName`

这意味着当前订单体系已经支持：
- 唯一订单标识
- 多设备来源区分
- 客户姓名记录
- 金额统计
- 后续按时间和金额做筛选

历史列表页现在已经支持：
- 列表层显示客户姓名
- 详情层显示客户姓名
- 关键词 / 金额 / 时间范围筛选

## 7. 数据导入导出与备份

当前数据管理能力已经比较完整：

- 导出商品
- 导出历史订单
- 导出商品 + 历史订单
- 导入商品
- 导入历史订单
- 查看自动备份
- 创建手动备份
- 导入前自动创建应急备份
- 恢复备份

维护这里时要特别注意：
- 导入逻辑不要误清空现有数据
- 历史订单要按 `orderId` 合并去重
- 备份恢复前要先创建应急备份

## 8. 手机端适配现状

当前页面已经做过多轮手机端适配，重点包括：

- 响应式字号与间距
- 结算区缩放
- 交易记录按钮位置优化
- 历史详情弹窗压缩
- 数据管理入口与独立面板分离

尤其要注意：
- 手机端和桌面端的数据管理交互逻辑不同
- 手机端使用独立弹窗，桌面端使用左下角展开
- `isMobileLayout()` 不只是样式判断，也会影响交互行为

## 9. 与 APK 打包直接相关的事实

当前 Web 页面会通过 Cordova 打包进入 Android APK。

关键事实：
- 主源码：`index.html`
- 同步目标：`apk-wrapper/www/index.html`
- 构建命令：`npm run build:android`
- 输出 APK：`apk-wrapper/platforms/android/app/build/outputs/apk/debug/app-debug.apk`

因此只改 `index.html` 还不够，最终要经过：
- 同步
- 构建
- 产物确认

## 10. 后续维护建议

如果下次继续让 Codex 接手，建议它先读：
- `APK_BUILD_GUIDE.md`
- `index.html 分析报告.md`
- `package.json`
- `scripts/build-android.ps1`
- `scripts/sync-apk-www.ps1`
- `apk-wrapper/config.xml`
- `apk-wrapper/platforms/android/gradle/wrapper/gradle-wrapper.properties`

后续如果继续迭代，这个文件建议重点更新三类内容：
- 新增了哪些业务模块
- 哪些入口在手机端和桌面端行为不同
- 哪些功能已经依赖 IndexedDB、备份、订单唯一标识等机制

## 11. 一句话结论

当前 `index.html` 已经是这个项目的前端主应用文件。

维护这个项目时，不应该把它看成单纯的页面，而应该把它看成：
- 一个单文件前端应用
- 一个本地数据库驱动的收银系统
- 一个需要同步到 Cordova 包装层并最终打进 APK 的业务入口
