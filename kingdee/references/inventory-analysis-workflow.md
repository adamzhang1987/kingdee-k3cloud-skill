# 库存分析工作流

库存状况多维度分析：总览、预警、呆滞识别。涉及 STK_Inventory（库存明细）和 BD_MATERIAL（物料档案）两张表。

> ⚠️ STK_Inventory 不支持嵌套引用字段（如 `FMaterialId.FMaterialGroup.FName` 会报错），物料分组需通过 BD_MATERIAL 单独查询。

---

## 一、库存总览（按仓库）

### 查询
```
query_bill_json(
  form_id="STK_Inventory",
  field_keys="FMaterialId.FNumber,FMaterialId.FName,FBaseQty,FStockId.FName",
  filter_string="FBaseQty > 0",
  top_count=2000
)
```

### 处理逻辑
1. 按 FStockId.FName 分组，统计每个仓库的物料种类数和总数量
2. 主仓库为 `少云色纱`（CK002）和 `少云胚纱`

### 推荐输出
```
📦 库存总览

| 仓库 | 物料种类 | 总数量 |
|------|----------|--------|
| 少云色纱 | 128 | 15,680 |
| 少云胚纱 | 45 | 8,200 |
```

---

## 二、零库存 / 低库存预警

### 零库存物料
```
query_bill_json(
  form_id="STK_Inventory",
  field_keys="FMaterialId.FNumber,FMaterialId.FName,FBaseQty,FStockId.FName",
  filter_string="FBaseQty = 0",
  top_count=500
)
```

### 低库存物料（阈值可调）
```
query_bill_json(
  form_id="STK_Inventory",
  field_keys="FMaterialId.FNumber,FMaterialId.FName,FBaseQty,FStockId.FName",
  filter_string="FBaseQty > 0 AND FBaseQty < 50",
  top_count=500
)
```

> 阈值 `50` 根据实际业务调整。不同物料合理库存量不同，此为简易筛选方案。

### ⚠️ 安全库存限制

系统中安全库存设置在 BD_MATERIAL 的 MaterialStock 子表中，**无法通过 `query_bill_json` 跨表比对**。实用替代方案：
- 使用固定阈值（如 < 50）做简易预警
- 对重点物料用 `view_bill(form_id="BD_MATERIAL", number="物料编号")` 查看其安全库存设置

---

## 三、指定物料库存查询

### 按物料编号精确查询
```
query_bill_json(
  form_id="STK_Inventory",
  field_keys="FMaterialId.FNumber,FMaterialId.FName,FBaseQty,FStockId.FName",
  filter_string="FMaterialId.FNumber = '物料编号'"
)
```

### 按物料名称模糊查询
```
query_bill_json(
  form_id="STK_Inventory",
  field_keys="FMaterialId.FNumber,FMaterialId.FName,FBaseQty,FStockId.FName",
  filter_string="FMaterialId.FName like '%关键词%'"
)
```

---

## 四、库存与物料档案联合分析（两步查询）

当需要物料分组、规格等信息时，STK_Inventory 无法直接获取，需两步：

### Step 1 — 查库存明细
```
query_bill_json(
  form_id="STK_Inventory",
  field_keys="FMaterialId.FNumber,FMaterialId.FName,FBaseQty,FStockId.FName",
  filter_string="FBaseQty > 0",
  top_count=2000
)
```

### Step 2 — 查物料档案补充信息
根据 Step 1 中获取的物料编号列表，批量查询物料档案：
```
query_bill_json(
  form_id="BD_MATERIAL",
  field_keys="FNumber,FName,FSpecification,FMaterialGroup.FName,FForbidStatus",
  filter_string="FNumber in ('编号1','编号2','编号3')",
  top_count=2000
)
```

### 合并逻辑
以 `FMaterialId.FNumber`（库存）= `FNumber`（物料档案）为关联键，合并两次查询结果。

---

## 五、呆滞库存识别思路

### 定义
库存有货（FBaseQty > 0）但近 N 天内无销售出库记录的物料。

### 实现步骤

**Step 1** — 查有库存的物料列表
```
query_bill_json(
  form_id="STK_Inventory",
  field_keys="FMaterialId.FNumber,FMaterialId.FName,FBaseQty",
  filter_string="FBaseQty > 0",
  top_count=2000
)
```

**Step 2** — 查近 N 天有出库的物料
```
query_bill_json(
  form_id="SAL_OUTSTOCK",
  field_keys="FMaterialId.FNumber,FMaterialId.FName",
  filter_string="FCreateDate >= '起始日期' AND FCreateDate < '结束日期'",
  top_count=2000
)
```

> ⚠️ SAL_OUTSTOCK 的物料字段需验证。如报错，改用 `FBillNo` 查列表后用 `view_bill` 逐条查看明细。

**Step 3** — 对比：有库存但不在近期出库列表中的物料 = 呆滞库存

### 推荐输出
```
📦 呆滞库存分析（近90天无出库）

| 物料编号 | 物料名称 | 库存量 | 仓库 |
|----------|----------|--------|------|
| MAT001 | XX纱 | 500 | 少云色纱 |
| MAT002 | YY绒 | 200 | 少云胚纱 |
共 N 种物料，总量 XXX
```

---

## 六、已验证字段速查

### STK_Inventory ✅
| 字段名 | 含义 |
|--------|------|
| `FMaterialId.FNumber` | 物料编号 |
| `FMaterialId.FName` | 物料名称 |
| `FBaseQty` | 库存数量（基本单位） |
| `FStockId.FName` | 仓库名称 |

### STK_Inventory ❌
| 字段名 | 说明 |
|--------|------|
| `FMaterialId.FMaterialGroup.FName` | ❌ 嵌套引用报错，需查 BD_MATERIAL |
| `FNumber` | ❌ 不存在，用 `FMaterialId.FNumber` |
| `FStockQty` | ❌ 不存在，用 `FBaseQty` |

### BD_MATERIAL ✅
| 字段名 | 含义 |
|--------|------|
| `FNumber` | 物料编码 |
| `FName` | 物料名称 |
| `FSpecification` | 规格型号 |
| `FMaterialGroup.FName` | 物料分组 |
| `FForbidStatus` | 启用状态（A=启用, B=禁用） |
