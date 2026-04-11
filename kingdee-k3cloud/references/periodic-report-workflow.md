# 周期性报表生成工作流

周报、月报的标准生成流程，包含日期计算、对比分析模板和输出格式建议。

---

## 一、日期区间参考

### 常用日期表达式

以当前日期 `2026-03-02`（周一）为例：

| 区间 | 起始日期 | 结束日期（不含） | 说明 |
|------|----------|-----------------|------|
| 本周 | 2026-03-02 | 2026-03-09 | 周一到周日 |
| 上周 | 2026-02-23 | 2026-03-02 | |
| 本月 | 2026-03-01 | 2026-04-01 | |
| 上月 | 2026-02-01 | 2026-03-01 | |
| 去年同月 | 2025-03-01 | 2025-04-01 | 用于同比 |
| 本季度 | 2026-01-01 | 2026-04-01 | Q1 |

> 所有日期过滤使用半开区间：`FDate >= '起始' AND FDate < '结束'`

---

## 二、周报模板

### 数据采集（4 次查询）

**查询 1 — 本周销售订单**
```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FBillNo,FDate,FCustId.FName,FSalerId.FName,FAllAmount,FDocumentStatus",
  filter_string="FDate >= '本周起始' AND FDate < '本周结束' AND FDocumentStatus = 'C'",
  top_count=1000
)
```

**查询 2 — 本周销售出库**
```
query_bill_json(
  form_id="SAL_OUTSTOCK",
  field_keys="FBillNo,FCreateDate,FDocumentStatus,FCreatorId.FName,FStockId.FName",
  filter_string="FCreateDate >= '本周起始' AND FCreateDate < '本周结束'",
  top_count=1000
)
```

**查询 3 — 本周采购入库**
```
query_bill_json(
  form_id="STK_InStock",
  field_keys="FBillNo,FDate,FDocumentStatus",
  filter_string="FDate >= '本周起始' AND FDate < '本周结束'",
  top_count=500
)
```

**查询 4 — 上周销售订单（用于对比）**
```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FBillNo,FDate,FCustId.FName,FAllAmount,FDocumentStatus",
  filter_string="FDate >= '上周起始' AND FDate < '上周结束' AND FDocumentStatus = 'C'",
  top_count=1000
)
```

### 推荐周报格式
```
📊 周报（2026-02-23 ~ 2026-03-01）

一、销售概况
- 本周新增订单 XX 笔，含税总额 ¥XXX（上周 YY 笔，¥YYY，环比 +ZZ%）
- Top 3 客户：A（¥xx）、B（¥xx）、C（¥xx）

二、出库情况
- 本周出库 XX 笔
- 按仓库：主仓库 XX 笔，辅仓库 YY 笔（替换为实际仓库名称）

三、采购入库
- 本周入库 XX 笔

四、待办提醒
- 待审核销售订单 X 笔
- 待审核采购订单 Y 笔
```

---

## 三、月报模板

### 数据采集（6 次查询）

在周报 4 次查询基础上，增加：

**查询 5 — 上月销售订单（环比）**
```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FBillNo,FDate,FCustId.FName,FSalerId.FName,FAllAmount,FDocumentStatus",
  filter_string="FDate >= '上月起始' AND FDate < '上月结束' AND FDocumentStatus = 'C'",
  top_count=2000
)
```

**查询 6 — 去年同月销售订单（同比）**
```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FBillNo,FDate,FCustId.FName,FAllAmount,FDocumentStatus",
  filter_string="FDate >= '去年同月起始' AND FDate < '去年同月结束' AND FDocumentStatus = 'C'",
  top_count=2000
)
```

### 推荐月报格式
```
📊 月报（2026年2月）

一、销售总览
| 指标 | 本月 | 上月 | 环比 | 去年同月 | 同比 |
|------|------|------|------|----------|------|
| 订单数 | XX | XX | +X% | XX | +X% |
| 含税总额 | ¥XX | ¥XX | +X% | ¥XX | +X% |
| 客户数 | XX | XX | +X% | XX | +X% |

二、客户排名 Top 10
| 排名 | 客户 | 订单数 | 含税金额 |
|------|------|--------|----------|
| 1 | ... | ... | ¥... |

三、业务员排名
| 排名 | 业务员 | 订单数 | 含税金额 |
|------|--------|--------|----------|
| 1 | ... | ... | ¥... |

四、产品销量 Top 10
| 排名 | 产品 | 数量 | 含税金额 |
|------|------|------|----------|
| 1 | ... | ... | ¥... |

五、库存预警
- 零库存物料 X 种
- 低库存物料 Y 种（< 50）

六、异常提醒
- 未关闭销售订单 X 笔
- 逾期交货 Y 笔
- 待审核单据 Z 笔
```

---

## 四、Top N 排名通用模板

### 客户 Top N
```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FBillNo,FCustId.FName,FAllAmount",
  filter_string="FDate >= '起始' AND FDate < '结束' AND FDocumentStatus = 'C'",
  top_count=2000
)
```
处理：按 FBillNo 去重 → 按 FCustId.FName 分组求和 → 降序取 Top N

### 业务员 Top N
```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FBillNo,FSalerId.FName,FAllAmount",
  filter_string="FDate >= '起始' AND FDate < '结束' AND FDocumentStatus = 'C'",
  top_count=2000
)
```
处理：按 FBillNo 去重 → 按 FSalerId.FName 分组求和 → 降序取 Top N

### 产品 Top N
```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FMaterialId.FName,FQty,FAllAmount",
  filter_string="FDate >= '起始' AND FDate < '结束' AND FDocumentStatus = 'C'",
  top_count=2000
)
```
处理：按 FMaterialId.FName 分组，FQty 和 FAllAmount 分别求和 → 降序取 Top N

---

## 五、数据输出建议

| 数据量 | 推荐格式 | 说明 |
|--------|---------|------|
| ≤ 5 行 | 文本列表 | 直接在聊天中展示 |
| 6 ~ 20 行 | Markdown 表格 | 结构清晰 |
| > 20 行 | Excel 文件 | 创建 .xlsx 文件，数据可二次分析 |
| 多维度汇总 | 文本 + 表格混合 | 总览用文本，明细用表格 |

---

## 六、报表生成注意事项

1. **FAllAmount 去重**：客户/业务员维度统计时，必须先按 FBillNo 去重，详见 sales-analysis-workflow.md
2. **排除内部采购单**：追加 `AND FCustId.FName not like '%内部客户关键词%'`（替换为实际的内部客户名称特征）
3. **只统计已审核**：始终加 `FDocumentStatus = 'C'`
4. **数据量控制**：月度数据建议 `top_count=2000`，超过时分段查询
5. **出库单日期**：SAL_OUTSTOCK 用 `FCreateDate` 而非 `FDate`
