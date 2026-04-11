# 客户（BD_Customer）查询专题

## 核心原则

1. **批量查询**用 `query_bill_json`，返回 JSON 更易读
2. **单条详情**用 `view_bill`，字段最全
3. **查询前先核对字段名**，详见 verified-fields.md 中的客户章节

---

## 常用查询模板

### 1. 按编号查询单个客户（最全字段）

```
view_bill(form_id="BD_Customer", number="CTM-0536")
```

### 2. 按名称模糊查询

```
query_bill_json(
  form_id="BD_Customer",
  field_keys="FName,FNumber,FKHLB,FFWZY",
  filter_string="FName like '%张三%' or FNumber like '%张三%'"
)
```

> 如有自定义字段（联系人、电话等），用 `query_metadata(form_id="BD_Customer")` 查询后追加到 field_keys 中。

### 3. 查询某月生日的所有客户（含两个生日字段示例）

以下以某部署的自定义生日字段为例，实际字段名通过 `query_metadata` 确认：

```
query_bill_json(
  form_id="BD_Customer",
  field_keys="FName,FNumber,F_XX_KHSR,F_XX_KHSRYF,F_XX_KHSR2,F_XX_KHSR2YF,FKHLB,FFWZY",
  filter_string="F_XX_KHSRYF = '3' or F_XX_KHSR2YF = '3'",
  top_count=2000
)
```

> 月份用字符串，如 `'3'` 代表3月，`'12'` 代表12月。如系统有两个生日字段，需用 `or` 同时匹配。

### 4. 推荐的通用客户信息查询字段组合

基础字段（所有部署通用）：
```
FName,FNumber,FShortName,FCreateDate,FModifyDate,FKHLB,FFWZY,FSOCIALCRECODE
```

> 联系人、电话、地址等信息通常在自定义字段中，需先通过 `query_metadata` 确认实际字段名后追加。

---

## ID 解析方法

`FKHLB`（客户类别）、`FFWZY`（服务专员）等关联字段在 `query_bill_json` 中只返回 ID 数字。

**解析步骤：**

1. 先查 `verified-fields.md` 中的 ID 映射字典
2. 字典没有时，用 `view_bill` 查一条含该 ID 的客户记录
3. 从返回的嵌套 JSON 对象中读取名称
4. 将新映射补充到映射字典中

---

## 生日查询注意事项

- 生日字段通常为自定义字段，字段名因部署而异，先用 `query_metadata` 确认
- 部分系统有两组生日字段（如主生日和备用生日），按月筛选时需用 `or` 同时匹配
- 月份字段值通常为字符串类型，如 `'3'`、`'12'`
- 日期字段含完整年份，格式为 `1990-03-24T00:00:00`

---

## 字段选择建议

| 需求 | 推荐方式 |
|------|---------|
| 查看单个客户完整信息 | `view_bill`（无需指定字段） |
| 批量查客户列表 | `query_bill_json`（指定需要的字段） |
| 需要关联字段名称（非ID） | `view_bill` 返回嵌套对象含名称 |
| 大量客户筛选 | `query_bill_json` + `top_count=2000` |

---

## 常见电话/联系人字段混淆

| 场景 | 正确做法 | 常见错误 |
|------|---------|---------|
| 查客户手机号 | 用 `query_metadata` 找自定义字段 | `FMobile`（常为空）、`FPhone`（不存在） |
| 查联系人 | 用 `query_metadata` 找自定义字段 | `FContact`（不存在） |
| 查地址 | 用 `query_metadata` 找自定义字段 | `FAddress`（常为空） |
