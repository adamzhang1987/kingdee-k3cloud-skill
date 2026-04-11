# 已验证字段大全

所有字段均经过实际测试验证。标记 ✅ 的可直接使用，标记 ❌ 的会触发 500 错误，**禁止使用**。

> **字段不确定时**：调用 `query_metadata(form_id)` 实时验证。返回结果中 `Key` = 可用字段名，`MustInput=1` = 必填，`IsViewVisible=false` = 已废弃/隐藏，`Extends` = 枚举合法值。本文件记录的是已验证的常用字段子集，不是全量字段。

---

## 目录

1. [销售订单 SAL_SaleOrder](#一销售订单-sal_saleorder)
2. [销售订单明细字段（表体）](#二销售订单明细字段表体)
3. [销售出库单 SAL_OUTSTOCK](#三销售出库单-sal_outstock)
4. [采购入库单 STK_InStock](#四采购入库单-stk_instock)
5. [采购订单 PUR_PurchaseOrder](#五采购订单-pur_purchaseorder)
6. [库存查询 STK_Inventory](#六库存查询-stk_inventory)
7. [客户 BD_Customer](#七客户-bd_customer)
8. [物料 BD_MATERIAL](#八物料-bd_material)

---

## 一、销售订单 SAL_SaleOrder

### ✅ 已验证可用字段

| 字段名 | 含义 | 备注 |
|--------|------|------|
| `FBillNo` | 单据编号 | 格式取决于部署配置，如 `XSDD2602000001` |
| `FDate` | 单据日期 | 业务日期，手填 |
| `FCreateDate` | 创建时间 | 系统自动，精确到毫秒 |
| `FDocumentStatus` | 单据状态 | Z=暂存, A=创建, B=审核中, C=已审核, D=重新审核 |
| `FAllAmount` | 含税合计 | ⚠️ **行级字段**，同一单号多行会重复 |
| `FAmount` | 未税金额 | 表头级 |
| `FTaxAmount` | 税额 | 表头级 |
| `FCustId.FName` | 客户名称 | 关联字段 |
| `FCustId.FNumber` | 客户编号 | 关联字段 |
| `FSalerId.FName` | 业务员名称 | 关联字段 |
| `FSaleDeptId.FName` | 销售部门 | 关联字段 |
| `FSaleOrgId.FName` | 销售组织 | 关联字段 |
| `FLocalCurrId.FName` | 本位币 | |
| `FCreatorId.FName` | 创建人 | |
| `FApproverId.FName` | 审核人 | |
| `FApproveDate` | 审核日期 | |

### ❌ 禁用字段（会触发 500）

| 错误字段名 | 正确替代 |
|-----------|---------|
| `FCustomerID` | `FCustId.FName` 或 `FCustId.FNumber` |
| `FCustomerId` | 同上（大小写也不对） |
| `FSaleAmount` | `FAllAmount`（行级）或 `FAmount`（表头） |
| `FApproveStatus` | `FDocumentStatus` |
| `FSaleOrderEntry` | 非字段名，明细通过行级重复记录体现 |
| `FTotalAmount` | 不存在，需按 FBillNo 分组自行汇总 |

### ⚠️ FAllAmount 重要说明

`FAllAmount` 是行级字段：同一订单有多行商品时，每行都会返回该行的金额。查询结果中同一 FBillNo 会出现多条记录。

**正确做法：** 按 FBillNo 分组，对同一单号的行金额求和得到订单总额，而非直接将所有行金额相加。

---

## 二、销售订单明细字段（表体）

以下字段在 `query_bill_json` 中直接使用，返回行级展开数据：

| 字段名 | 含义 | 备注 |
|--------|------|------|
| `FSeq` | 行号 | |
| `FMaterialId.FNumber` | 物料编码 | |
| `FMaterialId.FName` | 物料名称 | |
| `FMaterialId.FSpecification` | 规格型号 | |
| `FQty` | 数量 | |
| `FUnitId.FName` | 计量单位 | |
| `FPrice` | 未税单价 | |
| `FTaxPrice` | 含税单价 | |
| `FAmount` | 行未税金额 | |
| `FTaxAmount` | 行税额 | |
| `FAllAmount` | 行含税金额 | |
| `FLot.FNumber` | 批次号 | |
| `FStockId.FName` | 仓库名称 | |
| `FStockLocId.FNumber` | 库位编码 | |
| `FDeliveryDate` | 交货日期 | |

---

## 三、销售出库单 SAL_OUTSTOCK

> ⚠️ 表单ID 是 `SAL_OUTSTOCK`，**不是** `STK_OutStock`（后者会报"业务对象不存在"）

### ✅ 已验证可用字段

| 字段名 | 含义 | 备注 |
|--------|------|------|
| `FBillNo` | 出库单编号 | 格式取决于部署配置 |
| `FDate` | 出库单据日期 | 手填日期 |
| `FCreateDate` | 系统创建时间 | 精确到毫秒，反映真实开单时间 |
| `FDocumentStatus` | 状态 | A/B/C |
| `FCreatorId.FName` | 开单人姓名 | 关联字段 |
| `FStockId.FName` | 仓库名称 | 关联字段 |

### ❌ 禁用字段

| 错误字段名 | 说明 |
|-----------|------|
| `FAllQty` | 不存在，出库总数量不在表头层 |
| `FCustId.FName` | 在 SAL_OUTSTOCK 中**不存在**，客户信息需从关联销售订单获取 |

### ⚠️ FDate 与 FCreateDate 差异

- `FDate` 过滤"今天"可能**遗漏**部分单据（单据日期填昨天但今天才创建）
- `FCreateDate` 更完整，反映真实的今日开单情况
- **推荐**：按开单人/工作量统计时优先使用 `FCreateDate`

---

## 四、采购入库单 STK_InStock

> ✅ 表单ID `STK_InStock` 正确。注意：`PUR_ReceiveBill`（采购收货单）测试返回空。

### ✅ 已验证可用字段

| 字段名 | 含义 |
|--------|------|
| `FBillNo` | 入库单编号 |
| `FDate` | 入库日期 |
| `FDocumentStatus` | 状态 A/B/C |

---

## 五、采购订单 PUR_PurchaseOrder

### ✅ 已验证可用字段

| 字段名 | 含义 |
|--------|------|
| `FBillNo` | 采购订单编号 |
| `FDate` | 单据日期 |
| `FDocumentStatus` | 状态（B = 待审核） |

---

## 六、库存查询 STK_Inventory

> ⚠️ `STK_Inventory` 是**库存明细视图**，不是物料档案。字段与 `BD_MATERIAL` 完全不同。

### ✅ 已验证可用字段

| 字段名 | 含义 | 备注 |
|--------|------|------|
| `FMaterialId.FNumber` | 物料编号 | 关联字段 |
| `FMaterialId.FName` | 物料名称 | 关联字段 |
| `FBaseQty` | 基本单位数量（库存数） | 核心字段 |
| `FStockId.FName` | 仓库名称 | 关联字段 |

### ❌ 禁用字段

| 错误字段名 | 说明 |
|-----------|------|
| `FNumber` | 不存在，物料编号是 `FMaterialId.FNumber` |
| `FStockQty` | 不存在，库存量用 `FBaseQty` |
| `FLowStockQty` | 不存在 |
| `FForbidStatus` | 不存在 |
| `FMinStockQty` | 不存在（安全库存不在这张表） |

### ⚠️ 安全库存说明

- 安全库存设置在物料档案 `BD_MATERIAL.MaterialStock` 子表，无法通过 `query_bill_json` 跨表比对
- **实用替代**：查 `FBaseQty = 0` 或 `FBaseQty < N` 识别零库存/低库存物料
- 系统中没有直接可查的"低于安全库存"视图

---

## 七、客户 BD_Customer

### ✅ 基础信息字段

| 字段名 | 含义 | 备注 |
|--------|------|------|
| `FName` | 客户名称 | 支持 `like '%xx%'` |
| `FNumber` | 客户编号 | 唯一标识，如 `CTM-0536` |
| `FShortName` | 简称 | 常为空 |
| `FCreateDate` | 创建日期 | |
| `FModifyDate` | 最后修改日期 | |
| `FAddress` | 地址 | 常为空 |
| `FMobile` | 手机 | 常为空（实际手机号通常存在自定义字段中） |
| `FEmail` | 邮箱 | 常为空 |
| `FDescription` | 描述 | 常为空 |
| `FCurrencyId` | 货币ID | |
| `FCreateOrgId` | 创建组织ID | |
| `FUseOrgId` | 使用组织ID | |

### ✅ 自定义扩展字段（示例，各部署不同）

> 以下为自定义字段示例，字段名以公司内部前缀区分（如 `F_JR_`）。你的部署中前缀可能不同。
> 使用前先调用 `query_metadata(form_id="BD_Customer")` 查看实际可用的自定义字段。

| 字段名（示例） | 含义 | 备注 |
|--------|------|------|
| `F_XX_LXR` | 联系人姓名 | 各部署前缀不同 |
| `F_XX_DH` | 联系电话 | 标准 `FMobile` 常为空，实际手机号可能在自定义字段 |
| `F_XX_DZ` | 联系地址 | 标准 `FAddress` 常为空，实际地址可能在自定义字段 |
| `F_XX_KHSR` | 客户生日（日期） | 含年份，格式 `1990-03-24T00:00:00` |
| `F_XX_KHSRYF` | 客户生日月份 | **按月筛选用这个**，值为字符串如 `'3'` |
| `FKHLB` | 客户类别 | 返回 ID，需映射（见下方示例） |
| `FFWZY` | 服务专员 | 返回 ID，需映射 |
| `FSOCIALCRECODE` | 统一社会信用代码 | |

**发现自定义字段的方法：**
```
query_metadata(form_id="BD_Customer")
```
从返回结果中找以 `F_` 开头的字段，`IsViewVisible=false` 表示已废弃。

### ❌ 废弃/不存在字段

| 字段名 | 说明 |
|--------|------|
| 旧版自定义字段 | 若元数据中 `IsViewVisible=false` 则已废弃，改用对应的新字段（如 `FFWZY`、`FKHLB`） |
| `FContact` | 不存在，联系人在自定义字段中 |
| `FPhone` | 不存在，手机号在自定义字段中 |
| `FIsArchive` | 不存在 |
| `FSaleOrgId` | 不存在 |
| `FID` | 不存在（内码用 `view_bill` 的 id 参数查） |

### ID 映射（动态发现方法）

`FKHLB`（客户类别）、`FFWZY`（服务专员）等关联字段返回的是内部 ID，需要映射到名称。

**发现 ID 映射的步骤：**
1. 查询客户列表时带上 `FKHLB,FFWZY` 字段，记录返回的 ID 值
2. 用 `view_bill(form_id="BD_Customer", number="某客户编号")` 查看完整记录
3. 从返回的嵌套 JSON 对象中读取 ID 对应的名称
4. 将映射关系记录下来，后续复用

> 建立映射表后，将常用 ID 记录在此处供后续查询使用。

---

## 八、物料 BD_MATERIAL

### ✅ 已验证可用字段

| 字段名 | 含义 | 备注 |
|--------|------|------|
| `FNumber` | 物料编码 | 唯一编码 |
| `FName` | 物料名称 | |
| `FSpecification` | 规格型号 | |
| `FMaterialGroup.FName` | 物料分组 | |
| `FBaseUnitId.FName` | 基本计量单位 | |
| `FCreateOrgId.FName` | 创建组织 | |
| `FUseOrgId.FName` | 使用组织 | |
| `FForbidStatus` | 启用状态 | A=启用, B=禁用 |
