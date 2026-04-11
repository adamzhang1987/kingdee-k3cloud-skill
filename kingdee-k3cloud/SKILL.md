---
name: kingdee
description: "Use this skill whenever working with Kingdee K3Cloud ERP system (金蝶云星空). Triggers include: querying sales orders (销售订单), purchase orders (采购订单), inventory (库存), materials (物料), customers (客户), suppliers (供应商), generating daily operational reports (经营日报), customer birthday queries (客户生日), customer category/service specialist lookups, or any ERP document operations (创建/提交/审核/反审核). Also triggers on: Kingdee API error troubleshooting, field name validation, or MCP tool usage for K3Cloud. Keywords: 金蝶, 金蝶云星空, K3Cloud, ERP, 单据, 审核, 提交, 日报, 客户查询, 库存预警."
---

# 金蝶云星空 ERP 操作技能

通过 MCP 工具与金蝶云星空 API 交互的核心指南。查询前务必先查阅本文件确认表单ID和字段命名规则，避免 500 错误。

> **前提条件**：本 Skill 需配合金蝶云星空 MCP Server 使用，推荐 [kingdee-k3cloud-mcp](https://github.com/adamzhang1987/kingdee-k3cloud-mcp)。确保 Claude Code 已配置好 MCP Server 并可访问 `query_bill_json`、`view_bill` 等工具。

---

## 核心原则

1. **分步查询**：先用 `query_bill_json` 查列表（关键字段），再用 `view_bill` 看单条详情
2. **日期过滤**：半开区间 `FDate >= 'YYYY-MM-DD' AND FDate < 'YYYY-MM-DD+1'`
3. **FDate vs FCreateDate**：`FDate` 是业务日期（手填），`FCreateDate` 是系统创建时间。按"今天开的单"统计用 `FCreateDate`
4. **单据状态码**：`Z` = 暂存草稿，`A` = 创建，`B` = 审核中，`C` = 已审核，`D` = 重新审核
5. **控制数据量**：`top_count` 限制行数，只查必要字段，超过10行数据考虑创建 Excel
6. **字段不确定时**：先调用 `query_metadata(form_id)` 验证字段是否存在，避免试错浪费 token

---

## 表单ID速查表

### 基础数据
| 中文名称 | 表单ID | 备注 |
|---------|--------|------|
| 物料 | `BD_MATERIAL` | |
| 客户 | `BD_Customer` | 详见 references/customer-query-guide.md |
| 供应商 | `BD_Supplier` | |
| 组织 | `ORG_Organizations` | |
| 部门 | `BD_Department` | |
| 员工 | `BD_Empinfo` | |

### 销售模块
| 中文名称 | 表单ID | 备注 |
|---------|--------|------|
| 销售订单 | `SAL_SaleOrder` | |
| 销售出库单 | `SAL_OUTSTOCK` | **不是** STK_OutStock |
| 发货通知单 | `SAL_DELIVERYNOTICE` | |

### 采购模块
| 中文名称 | 表单ID | 备注 |
|---------|--------|------|
| 采购订单 | `PUR_PurchaseOrder` | |
| 采购入库单 | `STK_InStock` | 非 PUR_ReceiveBill（该ID返回空） |
| 采购申请单 | `PUR_Requisition` | |

### 库存/财务
| 中文名称 | 表单ID | 备注 |
|---------|--------|------|
| 库存明细 | `STK_Inventory` | 非物料档案，字段不同 |
| 其他入库单 | `STK_InStock` | |
| 其他出库单 | `STK_OutStock` | 注意：销售出库是 SAL_OUTSTOCK |
| 调拨单 | `STK_TransferDirect` | |
| 凭证 | `GL_VOUCHER` | |
| 收款单 | `AR_receiveBill` | |
| 付款单 | `AP_PAYBILL` | |

---

## 字段命名规则

- **所有字段以 `F` 开头**，区分大小写
- **关联字段**加后缀获取属性：`FCustId.FName`（名称）、`FCustId.FNumber`（编码）
- **表体明细**：`query_bill_json` 返回行级展开数据，同一 FBillNo 可能出现多行
- **自定义字段**：以 `F_` + 前缀开头（各部署不同），可用 `query_metadata` 发现，详见 references/verified-fields.md

### 通用字段（所有单据可用）
| 字段名 | 含义 |
|--------|------|
| `FBillNo` | 单据编号 |
| `FDate` | 单据业务日期 |
| `FCreateDate` | 系统创建时间 |
| `FDocumentStatus` | 状态（Z/A/B/C/D） |
| `FCreatorId.FName` | 创建人 |
| `FApproverId.FName` | 审核人 |
| `FApproveDate` | 审核日期 |

---

## 常用操作速查

### 查询元数据（验证字段名）
```
query_metadata(form_id="SAL_SaleOrder")
```
从返回结果中提取：`Key` = 可用字段名，`MustInput=1` = 必填字段，`IsViewVisible=false` = 已废弃/隐藏字段，`Extends` = 枚举合法值。

### 查询列表
```
query_bill_json(form_id="SAL_SaleOrder", field_keys="FBillNo,FDate,FCustId.FName,FDocumentStatus", filter_string="FDate >= '2026-03-01' AND FDate < '2026-03-02'", top_count=50)
```

### 查看单据详情
```
view_bill(form_id="SAL_SaleOrder", number="XSDD2602000001")  # 替换为实际单号
```

### 创建 → 提交 → 审核
```
save_bill(form_id, model_data)    # 1. 保存
submit_bill(form_id, numbers)     # 2. 提交
audit_bill(form_id, numbers)      # 3. 审核
```

### 批量审核（逗号分隔）
```
audit_bill(form_id="SAL_SaleOrder", numbers="XSDD001,XSDD002,XSDD003")
```

---

## 关键避坑提醒

| 陷阱 | 说明 |
|------|------|
| `STK_OutStock` 当销售出库用 | 销售出库单是 `SAL_OUTSTOCK`，STK_OutStock 会报"业务对象不存在" |
| `FAllAmount` 直接求和 | FAllAmount 是**行级字段**，同一订单多行会重复，需按 FBillNo 去重 |
| `FCustomerID` / `FCustomerId` | 不存在，正确写法是 `FCustId` |
| `SAL_OUTSTOCK` 中用 `FCustId.FName` | 该表中不存在此字段，会报 500 |
| `STK_Inventory` 中用 `FNumber` | 不存在，物料编号是 `FMaterialId.FNumber` |
| `PUR_ReceiveBill` 查采购入库 | 返回空，应使用 `STK_InStock` |
| 查询不加 `top_count` | 可能返回数据过大超过 1MB 限制 |

---

## References 指引

查询具体模块的字段时，**必须先查阅对应 reference 文件**确认字段名：

| 场景 | 参考文件 |
|------|---------|
| 首次使用、发现自定义字段和仓库配置 | `references/customization-guide.md` |
| 查任意模块的已验证/禁用字段 | `references/verified-fields.md` |
| 生成经营日报 | `references/daily-report-workflow.md` |
| 查询客户信息、生日、类别 | `references/customer-query-guide.md` |
| 遇到 500 错误或其他异常 | `references/common-errors.md` |
| 按客户/业务员/产品分析销售 | `references/sales-analysis-workflow.md` |
| 库存总览、预警、呆滞分析 | `references/inventory-analysis-workflow.md` |
| 订单全流程追踪、逾期预警 | `references/order-tracking-workflow.md` |
| 生成周报/月报、期间对比 | `references/periodic-report-workflow.md` |

---

## 自定义配置指南

每个金蝶云星空部署都有自己的业务特征，使用前需要了解：

- **单号规律**：用 `query_bill_json` 查几条样本单据，从 `FBillNo` 字段识别前缀规律
- **仓库名称**：查 `STK_Inventory` 时先确认 `FStockId.FName` 的实际值
- **内部单排除**：如有内部采购/调拨客户，用 `FCustId.FName not like '%内部客户关键词%'` 过滤
- **自定义字段**：用 `query_metadata(form_id="BD_Customer")` 找以 `F_` 开头的扩展字段（见 `references/verified-fields.md` 中的示例）
- **DocumentStatus 完整状态**：Z=暂存草稿 → A=创建 → B=审核中 → C=已审核（终态），D=重新审核

> 首次使用时建议先调用 `query_metadata` 探索各表单的实际字段，再参考本 Skill 的字段清单。
