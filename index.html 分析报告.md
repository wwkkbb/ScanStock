# index.html 分析报告

> 更新时间：2026-03-30

## 概览

当前项目是一个单文件收银页面应用，主体仍为 `index.html`，集成了以下能力：

- 商品管理
- 搜索与扫码收银
- 交易记录
- `IndexedDB` 本地持久化
- 自动备份 / 手动备份 / 应急备份
- 商品图片管理
- 可选范围的导入 / 导出

当前版本的关键架构变化：

- 默认使用 `IndexedDB` 作为主存储
- 自动备份规则为“15 天且数据有变化”
- 图片已从商品和备份快照中拆分，改为 `images + imageId`
- 历史订单已加入 `deviceId + orderId`
- 导入时支持“商品覆盖、历史合并”
- 导出时支持“仅商品 / 仅历史 / 商品+历史”

## 当前存储架构

### 1. IndexedDB

数据库名：`cashierDB`

对象仓库：

- `products`
  - 保存当前商品列表
  - 结构：`{ key: 'current', items: [...] }`
- `history`
  - 保存当前交易记录
  - 结构：`{ key: 'current', items: [...] }`
- `backups`
  - 保存备份列表
  - 结构：`{ key: 'list', items: [...] }`
- `meta`
  - 保存系统元数据
  - 典型键：
    - `backupBaseline`
    - `deviceProfile`
    - `imageRefMigration`
    - `historyOrderMigration`
- `images`
  - 保存商品图片实体
  - 商品和备份通过 `imageId` 引用图片

### 2. localStorage 的当前角色

`localStorage` 不再承担主数据存储职责，仅保留迁移辅助用途：

- 首次启动时读取旧版 `products/history/autoBackups`
- 迁移成功后写入 `idbMigrated = 1`

主业务数据、备份数据、订单基线、设备信息都已迁入 `IndexedDB`。

## 数据模型

### 商品

运行时商品对象：

```js
{
  id: number | string,
  name: string,
  price: number,
  code: string,
  barcode: string,
  imageId: string,
  photo: string
}
```

说明：

- `photo` 只在运行时用于页面渲染
- 持久化到 `IndexedDB.products` 时，不再保存 `photo`
- 持久化后只保留 `imageId`

### 图片

`IndexedDB.images` 中的图片对象：

```js
{
  key: 'img_xxx',
  id: 'img_xxx',
  checksum: 'xxx',
  dataUrl: 'data:image/jpeg;base64,...',
  createdAt: 1774851869340,
  lastUsedAt: 1774851869340
}
```

说明：

- 当前图片实体仍以 `dataUrl` 形式保存
- 但图片已不再进入商品持久化记录和备份快照
- 备份仅通过 `imageId` 引用图片

### 交易记录

当前交易记录已不再只是简单历史数组，而是带设备和订单唯一标识：

```js
{
  orderId: string,
  deviceId: string,
  createdAt: number,
  time: 'YYYY-MM-DD HH:mm:ss',
  items: CartItem[],
  total: number,
  payment: number,
  change: number,
  customerName: string
}
```

说明：

- `deviceId` 标识订单来自哪台设备
- `orderId` 唯一标识一笔订单
- 导入历史时按 `orderId` 去重合并

### 设备信息

设备信息保存在：

- `meta > deviceProfile`

结构：

```js
{
  deviceId: 'dev_xxx',
  createdAt: 1774852000000
}
```

说明：

- 首次启动自动生成
- 当前实现未单独提供 `deviceName`
- 导出文件会携带 `deviceProfile`

### 备份

```js
{
  id: string,
  type: 'auto' | 'manual' | 'emergency',
  timestamp: number,
  date: string,
  dateText: 'YYYY-MM-DD HH:mm:ss',
  products: ProductSnapshot[],
  history: HistoryRecord[]
}
```

其中 `products` 快照结构已改为只保存图片引用：

```js
{
  id: number | string,
  name: string,
  price: number,
  code: string,
  barcode: string,
  imageId: string,
  createdAt: number | undefined,
  updatedAt: number | undefined,
  deleted: boolean | undefined
}
```

## 自动备份机制

自动备份触发条件必须同时满足：

1. 距离上次备份时间大于等于 15 天
2. 商品或交易记录的哈希发生变化

基线数据存放在：

- `meta > backupBaseline`

结构：

```js
{
  key: 'backupBaseline',
  value: {
    lastBackupTime: number,
    lastProductsHash: string,
    lastHistoryHash: string
  }
}
```

备份类型：

- `auto`
  - 系统自动创建
- `manual`
  - 用户点击“立即备份”创建
- `emergency`
  - 恢复备份或导入数据前自动创建

## 图片引用迁移

第二阶段已完成图片引用迁移：

- 启动时检查旧商品和旧备份中是否仍包含 `photo`
- 如果存在，则将图片抽取到 `images`
- 商品和备份中的 `photo` 转换为 `imageId`
- 迁移标记写入：
  - `meta > imageRefMigration`

同时已加入孤儿图片清理：

- 当前商品未引用
- 所有备份也未引用

满足以上条件的图片会从 `images` 中删除。

## 历史订单唯一标识与迁移

当前历史订单已完成唯一标识升级：

- 每笔新订单创建时自动生成 `orderId`
- 每条历史记录都带 `deviceId`
- 启动时会将旧历史记录补齐：
  - `orderId`
  - `deviceId`
  - `createdAt`

迁移标记写入：

- `meta > historyOrderMigration`

## 导入 / 导出机制

### 导出

当前导出不再固定全量导出，而是先弹出“导出数据”弹窗，支持 3 种范围：

- `仅商品信息`
- `仅历史数据`
- `商品信息 + 历史数据`

导出文件结构：

```js
{
  products: [],
  history: [],
  deviceProfile: {
    deviceId: 'dev_xxx'
  },
  exportTime: '2026-03-30T08:00:00.000Z',
  version: '1.4',
  source: '店员A导出',
  exportScope: {
    products: true,
    history: false
  },
  summary: {
    productCount: 120,
    historyCount: 0
  }
}
```

说明：

- 商品导出仍带 `photo`，便于跨设备导入时保留图片
- 历史导出携带 `orderId` 和 `deviceId`
- `exportScope` 用于明确文件包含范围
- `summary` 用于导入确认弹窗快速展示

### 导入

当前导入支持按范围选择：

- `导入商品信息`
- `导入历史数据`

规则如下：

- 商品信息
  - 仅当用户勾选且文件中商品不为空时导入
  - 执行方式：覆盖当前商品资料
- 历史数据
  - 仅当用户勾选且文件中历史不为空时导入
  - 执行方式：按 `orderId` 合并去重
- 空数据项
  - 自动跳过
  - 不会清空本地已有数据
- 两项都不选
  - 不允许确认导入

导入前仍会自动创建 `emergency` 备份。

## 当前主要功能模块

### 商品管理

- 新增商品
- 删除商品
- 商品排序
- 拼音首字母简码生成
- 商品图片上传、换图、删图

### 搜索与扫码

- 商品名 / 简码 / 条码搜索
- 扫码枪输入识别
- 摄像头扫码
- 连续扫码模式

### 购物车与结算

- 添加商品到购物车
- 修改数量
- 结算
- 找零计算
- 小票控制台输出

### 数据管理

- 范围导出 JSON
- 范围导入 JSON
- 查看备份
- 手动备份
- 恢复备份
- 删除备份

## 当前实现状态总结

### 已完成

- 默认启动进入本地数据库模式
- `products/history/backups/meta/images` 全部接入 `IndexedDB`
- 自动备份、手动备份、应急备份可用
- 旧 `localStorage` 数据迁移可用
- 旧图片字段迁移到 `images + imageId` 可用
- 历史记录已补齐 `deviceId + orderId`
- 导入规则已升级为“商品覆盖 + 历史合并”
- 导出 / 导入支持范围选择
- 备份时间显示统一为 `YYYY-MM-DD HH:mm:ss`

### 当前仍保留的现实限制

- 图片实体目前仍以 `dataUrl` 形式保存在 `IndexedDB.images`
- 这已经避免了“每份备份重复保存图片”，但图片体积仍大于二进制 `Blob` 方案
- 当前设备信息只有 `deviceId`，尚未增加用户可读的 `deviceName`

## 建议

当前项目已经从“轻量 localStorage 方案”升级为：

- `IndexedDB` 主存储
- 图片引用式备份
- 订单唯一标识
- 可选范围导入 / 导出

如果后续继续演进，建议按这个顺序：

1. 图片从 `dataUrl` 继续迁到 `Blob`
2. 为设备增加可读 `deviceName`
3. 备份管理界面增加存储占用统计
4. 导出时增加“是否包含图片”的明确选项
5. 将 `products/history` 从整表快照进一步细化为更规范的数据访问层
