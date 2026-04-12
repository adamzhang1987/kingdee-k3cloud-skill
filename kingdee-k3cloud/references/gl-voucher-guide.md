# 凭证查询指南 GL_VOUCHER

> ⚠️ 以下规则仅适用于 GL_VOUCHER（总账凭证）

凭证是总账模块的核心单据，记录财务借贷分录。与业务单据不同，凭证有自己的字段体系，且行级字段（分录）与表头字段需分开理解。

---

## 常用字段

### 表头字段

| 字段名 | 含义 | 备注 |
|--------|------|------|
| `FVoucherID` | 凭证内码 | 唯一标识 |
| `FNumber` | 凭证编号 | 如 `记-0001` |
| `FDate` | 凭证日期 | 会计期间内的业务日期 |
| `FPeriod` | 会计期间 | 格式 `YYYYMM`，如 `202601` |
| `FYear` | 会计年度 | 如 `2026` |
| `FVoucherGroupID.FName` | 凭证字号 | 记账凭证/收款凭证/付款凭证等 |
| `FDocumentStatus` | 凭证状态 | A=创建, B=已提交, C=已审核 |
| `FAttachments` | 附件张数 | |
| `FCreatorId.FName` | 制单人 | |
| `FApproverId.FName` | 审核人 | |
| `FApproveDate` | 审核日期 | |

### 分录行字段（表体）

> 凭证每行对应一条借贷分录，同一凭证编号会返回多行。

| 字段名 | 含义 | 备注 |
|--------|------|------|
| `FEntryID` | 分录内码 | |
| `FSeq` | 行序号 | |
| `FAccountID.FNumber` | 科目编码 | 如 `1002`（银行存款） |
| `FAccountID.FName` | 科目名称 | |
| `FExplanation` | 摘要 | |
| `FDebit` | 借方金额 | 为 0 时表示贷方分录 |
| `FCredit` | 贷方金额 | 为 0 时表示借方分录 |
| `FCurrencyID.FName` | 币别 | |
| `FExchangeRate` | 汇率 | 本位币时为 1 |
| `FLocalDebit` | 本位币借方 | |
| `FLocalCredit` | 本位币贷方 | |

---

## 查询示例

### 查询某期间凭证列表

```
query_bill_json(
    form_id="GL_VOUCHER",
    field_keys="FNumber,FDate,FPeriod,FDocumentStatus,FCreatorId.FName,FApproverId.FName",
    filter_string="FPeriod='202601'",
    order_string="FNumber ASC",
    top_count=200
)
```

### 查询凭证分录明细（含借贷金额）

```
query_bill_json(
    form_id="GL_VOUCHER",
    field_keys="FNumber,FDate,FSeq,FAccountID.FNumber,FAccountID.FName,FExplanation,FDebit,FCredit",
    filter_string="FPeriod='202601' and FDocumentStatus='C'",
    order_string="FNumber ASC, FSeq ASC",
    top_count=500
)
```

### 按科目查询借贷发生额

```
query_bill_json(
    form_id="GL_VOUCHER",
    field_keys="FNumber,FDate,FAccountID.FNumber,FAccountID.FName,FExplanation,FDebit,FCredit",
    filter_string="FPeriod='202601' and FAccountID.FNumber like '1002%'",
    order_string="FDate ASC"
)
```

---

## 注意事项

- **借贷平衡**：每张凭证的借方合计应等于贷方合计，若查询结果不平衡，说明过滤条件截断了部分分录行
- **按凭证汇总**：分录是行级字段，需按 `FNumber` 分组后才能得到凭证级别的金额合计
- **FPeriod 格式**：过滤会计期间时使用 `'YYYYMM'` 字符串格式，如 `FPeriod='202601'`
- **未审核凭证**：`FDocumentStatus='A'` 表示草稿，`'C'` 表示已审核，财务报表统计通常只计 `'C'`

---

## ❌ 禁用字段

| 错误字段名 | 说明 |
|-----------|------|
| `FBillNo` | 不存在，凭证编号用 `FNumber` |
| `FAmount` | 不存在，金额用 `FDebit` / `FCredit` |
| `FTotalDebit` | 不存在，借方合计需按 FNumber 分组求和 |
| `FSubsidiaryID` | 不存在，辅助核算信息在分录扩展字段中 |
