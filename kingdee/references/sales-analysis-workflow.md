# 销售分析工作流

按客户、业务员、产品等维度对销售数据进行多角度分析的标准流程。

> 所有字段均经 MCP 实测验证。FAllAmount 是行级字段，**必须按 FBillNo 去重后汇总**，详见 daily-report-workflow.md。

---

## 一、通用查询模板

所有销售分析的基础查询：

```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FBillNo,FDate,FCustId.FName,FSalerId.FName,FSaleDeptId.FName,FAllAmount,FMaterialId.FName,FQty,FDocumentStatus,FCloseStatus",
  filter_string="FDate >= '起始日期' AND FDate < '结束日期' AND FDocumentStatus = 'C'",
  top_count=2000
)
```

> 加 `FDocumentStatus = 'C'` 只统计已审核订单，避免草稿和待审核干扰金额统计。

---

## 二、按客户分析

### 目标
Top N 客户排名、客户销售额分布

### 查询
```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FBillNo,FDate,FCustId.FName,FAllAmount",
  filter_string="FDate >= '2026-02-01' AND FDate < '2026-03-01' AND FDocumentStatus = 'C'",
  top_count=2000
)
```

### 处理逻辑
1. 按 FBillNo 分组，每组 FAllAmount 求和 = 订单总额
2. 按 FCustId.FName 再次分组，汇总每个客户的订单总额和订单数
3. 按金额降序排列，输出 Top N

### 推荐输出
```
📊 2026年2月客户销售排名（已审核订单）

| 排名 | 客户 | 订单数 | 含税金额 |
|------|------|--------|----------|
| 1 | XX客户 | 15 | ¥128,000 |
| 2 | YY客户 | 8 | ¥85,000 |
| ... | ... | ... | ... |
合计：XX 个客户，YY 笔订单，¥ZZ 总额
```

---

## 三、按业务员分析

### 查询
```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FBillNo,FDate,FSalerId.FName,FSaleDeptId.FName,FAllAmount",
  filter_string="FDate >= '2026-02-01' AND FDate < '2026-03-01' AND FDocumentStatus = 'C'",
  top_count=2000
)
```

### 处理逻辑
1. 按 FBillNo 去重得到订单级金额
2. 按 FSalerId.FName 分组，统计每人的订单数和总金额
3. 可同时按 FSaleDeptId.FName 做部门级汇总

### 推荐输出
```
📊 2026年2月业务员业绩排名

| 排名 | 业务员 | 部门 | 订单数 | 含税金额 |
|------|--------|------|--------|----------|
| 1 | 高姨 | 销售内勤 | 42 | ¥168,000 |
| 2 | 小戴 | 销售内勤 | 38 | ¥145,000 |
```

---

## 四、按产品分析

### 查询
```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FBillNo,FDate,FMaterialId.FName,FQty,FAllAmount",
  filter_string="FDate >= '2026-02-01' AND FDate < '2026-03-01' AND FDocumentStatus = 'C'",
  top_count=2000
)
```

### 处理逻辑
1. 按 FMaterialId.FName 分组（注意：这里直接按行汇总即可，不需要按 FBillNo 去重，因为每行是独立的产品明细）
2. 统计每种产品的总数量（FQty 之和）和总金额（FAllAmount 之和）
3. 按金额或数量降序排列

### ⚠️ FAllAmount 在产品分析中的特殊性
产品分析中，FAllAmount 是**行级金额**（该行产品的含税金额），直接按产品分组求和即可，无需按 FBillNo 去重。这与客户/业务员分析不同。

---

## 五、期间对比分析

### 环比（本月 vs 上月）

分两次查询，分别统计后对比：

```
# 本月
filter_string="FDate >= '2026-02-01' AND FDate < '2026-03-01' AND FDocumentStatus = 'C'"

# 上月
filter_string="FDate >= '2026-01-01' AND FDate < '2026-02-01' AND FDocumentStatus = 'C'"
```

### 同比（本月 vs 去年同月）

```
# 本月
filter_string="FDate >= '2026-02-01' AND FDate < '2026-03-01' AND FDocumentStatus = 'C'"

# 去年同月
filter_string="FDate >= '2025-02-01' AND FDate < '2025-03-01' AND FDocumentStatus = 'C'"
```

### 对比计算
- **环比增长率** = (本期 - 上期) / 上期 × 100%
- **同比增长率** = (本期 - 去年同期) / 去年同期 × 100%

### 推荐输出
```
📊 2026年2月销售对比分析

| 指标 | 本月 | 上月 | 环比 | 去年同月 | 同比 |
|------|------|------|------|----------|------|
| 订单数 | 120 | 98 | +22.4% | 85 | +41.2% |
| 含税总额 | ¥580,000 | ¥450,000 | +28.9% | ¥380,000 | +52.6% |
| 客户数 | 45 | 38 | +18.4% | 32 | +40.6% |
```

---

## 六、排除规则

- **少云自购单**：追加过滤条件 `AND FCustId.FName not like '%SYZG少云自购%'`
- **未审核单据**：始终加 `FDocumentStatus = 'C'` 仅统计已审核
- **关闭状态**：如只统计有效订单，追加 `AND FCloseStatus = 'A'`（未关闭）

---

## 七、数据量控制

| 时间跨度 | 建议 top_count | 备注 |
|----------|---------------|------|
| 单日 | 200 | 通常够用 |
| 单周 | 500 | |
| 单月 | 2000 | 接近上限时考虑分段查询 |
| 跨月 | 分月查询 | 避免超过 1MB 限制 |

> 超过 10 行结果建议创建 Excel 文件输出。
