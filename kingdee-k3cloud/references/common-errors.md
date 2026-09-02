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

## 错误3: 会话信息已丢失，请重新登录（实为**认证失败**）

**错误信息：**
```json
{"ErrorCode": 500, "MsgCode": 1, "Message": "会话信息已丢失，请重新登录"}
```

MCP Server ≥ 1.4.0 会把它包成带诊断的 envelope：
```json
{"error": "authentication_failed", "message": "...", "hint": "...", "original": {...}}
```

**⚠️ 这句文案严重误导：它讲的不是会话过期，而是认证失败。**

经实证测试确认（三轮约 240 次只读请求，见 mcp 仓库 `docs/session-auth-experiments.md`）：

- 服务端**有有效 SID 时根本不校验凭据**；只有无会话时才回落到凭据校验，失败才报此错
- 真正的会话过期是**无感**的——服务端静默换发新 SID，请求照常成功（闲置 90 分钟无一次报错）
- 空 SID、无效 SID、多客户端并发、Web 端登录**都无法**触发此错误

**原因：** 凭据或第三方登录授权配置错误。

**解决方案（重试无效；先改配置，再让改动生效）：**
1. ❌ **重试无效** —— 凭据错就是错，重试一万次还是同一个错
2. ❌ **别急着重启** —— 在改正配置**之前**重启没有意义，反而会让问题从偶发变成持续：
   凭据错误本可被一个仍有效的 SID 长期掩盖，重启后新进程没有 SID，必须走凭据校验，问题立刻固化
3. ✅ **第一步：核对四项配置**与金蝶端「第三方系统登录授权」是否逐字一致、授权是否处于启用状态：
   `KD_USERNAME` · `KD_APP_ID` · `KD_APP_SEC` · `KD_LCID`
4. ✅ **第二步：让改动生效** —— 取决于改的是哪一边：
   - 改**金蝶端**（重新启用授权、把用户加回登录列表）→ **无需重启**，
     下一次调用会用当前凭据重新认证并自动恢复
   - 改 **`.env` 的值** → **必须重启** MCP Server，`.env` 只在启动时读取一次，
     进程内存中的凭据不会自行更新
5. `KD_ACCT_ID` 配置错误**不会**产生本错误，它表现为 HTTP 非 200
   （`Fail to verify thirty passport`），会以异常形式抛出
6. `KD_ORG_NUM` 配置错误也不会产生本错误（参与签名但服务端不校验其有效性）

**给用户的话术：** 这是服务端凭据/授权配置问题，需要管理员核对上述四项配置，
不是临时故障，等待或重启都不会自行恢复。

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

**方案2 — 检查截断标志并翻页：**

`query_bill_json` / `query_bill` 的返回结果现在带有分页元数据：
```json
{
  "rows": [...],
  "row_count": 2000,
  "truncated": true,
  "next_start_row": 2000,
  "hint": "返回行数已达上限..."
}
```

翻页模板：
```python
start = 0
all_rows = []
while True:
    result = query_bill_json(..., top_count=2000, start_row=start)
    all_rows.extend(result["rows"])
    if not result["truncated"]:
        break
    start = result["next_start_row"]
```

跨月分片（更推荐，避免单月也超限）：
```python
for month_filter in ["FDate >= '2025-01-01' AND FDate < '2025-02-01'", ...]:
    # 对每个月执行上述翻页逻辑
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

## 错误7: 权限不足 / 结果异常为空

MCP Server 不实现数据权限，所有查询都以 `.env` 中配置的集成用户（`KD_USERNAME`）身份执行，能看到什么数据完全由该用户在金蝶云星空中的权限决定。权限问题有两种表现，**必须分开判断**：

**表现1：显式报错（功能权限不足）**
```json
{"ErrorCode": 500, "Message": "您没有该功能的操作权限"}
```
容易识别，按信息提示用户联系管理员为集成用户补齐对应表单/操作权限即可。

**表现2：静默过滤（数据权限限制），不报错**

`count_bill` / `query_bill*` 正常返回，但行数比预期少，甚至为 0 —— 这是金蝶数据规则（按组织/部门/业务员等过滤）在生效，**服务端不会返回任何错误提示**。

⚠️ **对 LLM 的重要提示：查询结果为空或行数明显偏少时，不要直接向用户断言"该时间段无单据"或"无相关数据"。** 应先说明这也可能是集成用户的数据权限限制导致，并建议用户用同一账号登录金蝶云星空 Web 端执行相同条件查询，对比行数以确认是否为权限过滤（而非真实无数据）。

---

## 故障排查清单

遇到问题时按以下顺序检查：

1. ✅ **表单ID 是否正确？** → 查 SKILL.md 表单速查表
2. ✅ **字段名是否正确？** → 查 verified-fields.md，注意大小写和 `.FName` 后缀
3. ✅ **数据量是否过大？** → 减少字段 / 分页 / 分步查询
4. ✅ **报「会话信息已丢失」？** → 这是**认证失败**不是会话过期，见错误3；
   不要重试、不要建议重启，直接让管理员核对凭据与第三方登录授权配置
5. ✅ **单据状态是否正确？** → 检查 FDocumentStatus，按流程操作
6. ✅ **必填字段是否完整？** → 参考已有单据的数据结构
7. ✅ **结果为空是否因数据权限？** → 用同一集成用户账号登录金蝶云星空 Web 端比对行数，不要直接断言无数据
