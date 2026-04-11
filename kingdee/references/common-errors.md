# 常见错误及解决方案

---

## 错误1: 元数据中标识为 XXX 的字段不存在（500）

**错误信息：**
```json
{"ErrorCode": 500, "Message": "元数据中标识为FCustomerID的字段不存在"}
```

**原因：** 字段名拼写错误、大小写错误或该表中不存在此字段

**解决方案：**
1. 查阅 `verified-fields.md` 确认正确字段名
2. 确保大小写正确（金蝶字段以 F 开头，驼峰命名）
3. 关联字段必须加 `.FName` 或 `.FNumber` 后缀

**高频错误字段汇总：**

| 错误写法 | 正确写法 | 所属表 |
|---------|---------|-------|
| `FCustomerID` / `FCustomerId` | `FCustId.FName` | SAL_SaleOrder |
| `FSaleAmount` / `FTotalAmount` | `FAllAmount`（行级） | SAL_SaleOrder |
| `FApproveStatus` | `FDocumentStatus` | 所有单据 |
| `FNumber`（库存表中） | `FMaterialId.FNumber` | STK_Inventory |
| `FStockQty` | `FBaseQty` | STK_Inventory |
| `FMinStockQty` / `FLowStockQty` | 不存在，需手动设阈值 | STK_Inventory |
| `FCustId.FName`（出库单中） | 不存在，从关联订单获取 | SAL_OUTSTOCK |
| `FAllQty`（出库单中） | 不存在 | SAL_OUTSTOCK |
| `FContact` / `FPhone` | 不存在，联系人/电话在自定义字段中（用 query_metadata 确认） | BD_Customer |
| `FIsArchive` / `FSaleOrgId` / `FID` | 不存在 | BD_Customer |

---

## 错误2: 业务对象不存在（500）

**错误信息：**
```json
{"ErrorCode": 500, "Message": "业务对象不存在"}
```

**原因：** 表单ID 错误

**常见错误对照：**

| 业务场景 | 错误ID | 正确ID |
|---------|--------|--------|
| 销售出库单 | `STK_OutStock` | `SAL_OUTSTOCK` |
| 采购入库 | `PUR_ReceiveBill`（返回空） | `STK_InStock` |

---

## 错误3: 会话信息已丢失，请重新登录

**错误信息：**
```json
{"ErrorCode": 500, "Message": "会话信息已丢失，请重新登录"}
```

**原因：** MCP 服务器的登录 token 过期或网络中断

**解决方案：**
1. 自动重试：MCP 服务器应实现自动重连
2. 告知用户稍后重试，或联系管理员重启 MCP 服务
3. 预防：MCP 服务器端实现 token 刷新机制

---

## 错误4: 数据量过大（超过 1MB）

**错误信息：**
```
Tool result is too large. Maximum size is 1MB.
```

**解决方案：**

**方案1 — 减少字段：**
```
# 精简到必要字段
field_keys: "FBillNo,FDate,FCustId.FName,FAmount"
```

**方案2 — 分页查询：**
```
# 第一页
start_row: 0, top_count: 100
# 第二页
start_row: 100, top_count: 100
```

**方案3 — 分步查询：**
```
# 先查编号列表
field_keys: "FBillNo,FDate"
# 再逐个查详情
view_bill(form_id=..., number=...)
```

---

## 错误5: 单据状态不允许此操作

**错误信息：**
```json
{"Message": "单据已审核，不允许修改"}
```

**原因：** 单据状态不符合操作要求

**状态流转规则：**
```
暂存(A) → 提交(B) → 审核(C)
```

**解决方案：**
- 修改已审核单据：先 `unaudit_bill` 反审核，再修改
- 审核未提交单据：先 `submit_bill` 提交，再 `audit_bill` 审核
- 操作前先查 `FDocumentStatus` 确认当前状态

---

## 错误6: 必录字段未填写

**错误信息：**
```json
{"Message": "字段[客户]是必录字段"}
```

**常见必填字段：**

| 单据类型 | 必填字段 |
|---------|---------|
| 销售订单 | 单据类型(FBillTypeID)、销售组织(FSaleOrgId)、客户(FCustId)、日期(FDate) |
| 明细行 | 物料(FMaterialId)、数量(FQty)、单价(FPrice) |

**解决方案：** 通过 `view_bill` 查看同类型已有单据，参考其数据结构填写必填项。

---

## 故障排查清单

遇到问题时按以下顺序检查：

1. ✅ **表单ID 是否正确？** → 查 SKILL.md 表单速查表
2. ✅ **字段名是否正确？** → 查 verified-fields.md，注意大小写和 `.FName` 后缀
3. ✅ **数据量是否过大？** → 减少字段 / 分页 / 分步查询
4. ✅ **会话是否过期？** → 重试操作
5. ✅ **单据状态是否正确？** → 检查 FDocumentStatus，按流程操作
6. ✅ **必填字段是否完整？** → 参考已有单据的数据结构
