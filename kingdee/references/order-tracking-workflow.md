# 订单全生命周期追踪

销售和采购订单从创建到完结的全流程查询，包括逾期预警和未关闭订单追踪。

> ⚠️ 不同单据的客户/供应商字段名不同，务必核对本文件中的字段名。

---

## 一、销售全流程追踪

### 流程链
```
销售订单(SAL_SaleOrder) → 发货通知(SAL_DELIVERYNOTICE) → 销售出库(SAL_OUTSTOCK) → 收款(AR_receiveBill)
```

### Step 1 — 查销售订单
```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FBillNo,FDate,FCustId.FName,FSalerId.FName,FAllAmount,FDocumentStatus,FCloseStatus,FDeliveryDate",
  filter_string="FDate >= '起始日期' AND FDate < '结束日期'",
  top_count=500
)
```

- **FCloseStatus**: `A` = 未关闭（流程未完结），`B` = 已关闭（流程完结）
- **FDocumentStatus**: `C` = 已审核

### Step 2 — 查发货通知
```
query_bill_json(
  form_id="SAL_DELIVERYNOTICE",
  field_keys="FBillNo,FDate,FDocumentStatus,FCustomerID.FName",
  filter_string="FDate >= '起始日期' AND FDate < '结束日期'",
  top_count=500
)
```

> ⚠️ 发货通知客户字段是 **`FCustomerID.FName`**，不是 `FCustId.FName`！

### Step 3 — 查销售出库
```
query_bill_json(
  form_id="SAL_OUTSTOCK",
  field_keys="FBillNo,FCreateDate,FDocumentStatus,FCreatorId.FName,FStockId.FName",
  filter_string="FCreateDate >= '起始日期' AND FCreateDate < '结束日期'",
  top_count=500
)
```

> 出库单推荐用 `FCreateDate` 过滤。注意：SAL_OUTSTOCK 中**无** `FCustId.FName` 字段。

### Step 4 — 查收款单
```
query_bill_json(
  form_id="AR_receiveBill",
  field_keys="FBillNo,FDate,FDocumentStatus,FContactUnit.FName,FRECTOTALAMOUNTFOR",
  filter_string="FDate >= '起始日期' AND FDate < '结束日期'",
  top_count=500
)
```

- **FContactUnit.FName**: 往来单位名称（客户）
- **FRECTOTALAMOUNTFOR**: 收款总金额

---

## 二、采购全流程追踪

### 流程链
```
采购订单(PUR_PurchaseOrder) → 采购入库(STK_InStock) → 付款(AP_PAYBILL)
```

### Step 1 — 查采购订单
```
query_bill_json(
  form_id="PUR_PurchaseOrder",
  field_keys="FBillNo,FDate,FDocumentStatus,FSupplierId.FName,FMaterialId.FName,FQty,FAllAmount,FCloseStatus",
  filter_string="FDate >= '起始日期' AND FDate < '结束日期'",
  top_count=500
)
```

### Step 2 — 查采购入库
```
query_bill_json(
  form_id="STK_InStock",
  field_keys="FBillNo,FDate,FDocumentStatus",
  filter_string="FDate >= '起始日期' AND FDate < '结束日期'",
  top_count=500
)
```

### Step 3 — 查付款单
```
query_bill_json(
  form_id="AP_PAYBILL",
  field_keys="FBillNo,FDate,FDocumentStatus,FCONTACTUNIT.FName,FPAYTOTALAMOUNTFOR",
  filter_string="FDate >= '起始日期' AND FDate < '结束日期'",
  top_count=500
)
```

- **FCONTACTUNIT.FName**: 往来单位名称（供应商）
- **FPAYTOTALAMOUNTFOR**: 付款总金额

---

## 三、未关闭订单追踪

### 销售订单未关闭（待发货/待收款）
```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FBillNo,FDate,FCustId.FName,FSalerId.FName,FAllAmount,FDocumentStatus,FCloseStatus,FDeliveryDate",
  filter_string="FCloseStatus = 'A' AND FDocumentStatus = 'C'",
  top_count=500
)
```

> `FCloseStatus = 'A'` + `FDocumentStatus = 'C'`：已审核但未关闭的订单，即流程未走完。

### 采购订单未关闭（待入库/待付款）
```
query_bill_json(
  form_id="PUR_PurchaseOrder",
  field_keys="FBillNo,FDate,FSupplierId.FName,FMaterialId.FName,FQty,FDocumentStatus,FCloseStatus",
  filter_string="FCloseStatus = 'A' AND FDocumentStatus = 'C'",
  top_count=500
)
```

---

## 四、逾期交货预警

查找已审核、未关闭、且交货日期已过期的销售订单：

```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FBillNo,FDate,FCustId.FName,FSalerId.FName,FDeliveryDate,FAllAmount,FCloseStatus",
  filter_string="FCloseStatus = 'A' AND FDocumentStatus = 'C' AND FDeliveryDate < '当前日期'",
  top_count=500
)
```

### 推荐输出
```
⚠️ 逾期交货预警（截至 2026-03-02）

| 订单号 | 客户 | 业务员 | 交货日期 | 逾期天数 | 金额 |
|--------|------|--------|----------|----------|------|
| XSDD... | XX | 高姨 | 2026-02-20 | 10天 | ¥25,000 |
共 N 笔订单逾期，涉及金额 ¥XXX
```

---

## 五、待审核单据汇总

一次性查询各模块待审核单据，适合做每日工作待办提醒：

```
# 销售订单待审核
filter_string="FDocumentStatus = 'B'"

# 采购订单待审核
filter_string="FDocumentStatus = 'B'"
```

> `FDocumentStatus = 'B'` = 审核中（已提交待审核）

---

## 六、字段差异速查

不同单据中"客户/供应商"字段名不同，极易混淆：

| 单据 | 客户/供应商字段 | 金额字段 |
|------|----------------|----------|
| SAL_SaleOrder | `FCustId.FName` | `FAllAmount`（行级） |
| SAL_DELIVERYNOTICE | `FCustomerID.FName` | — |
| SAL_OUTSTOCK | ❌ 无客户字段 | — |
| AR_receiveBill | `FContactUnit.FName` | `FRECTOTALAMOUNTFOR` |
| PUR_PurchaseOrder | `FSupplierId.FName` | `FAllAmount`（行级） |
| STK_InStock | — | — |
| AP_PAYBILL | `FCONTACTUNIT.FName` | `FPAYTOTALAMOUNTFOR` |

### ⚠️ 高频易错点
1. **发货通知**用 `FCustomerID.FName`，**不是** `FCustId.FName`
2. **销售出库**中**没有**客户字段，客户信息需从关联销售订单获取
3. **收款/付款**的金额字段是 `FRECTOTALAMOUNTFOR` / `FPAYTOTALAMOUNTFOR`，不是 `FAmount` 或 `FAllAmount`
