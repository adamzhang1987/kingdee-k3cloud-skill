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
  field_keys="FName,FNumber,F_JR_LXR,F_JR_DH,FKHLB,FFWZY,F_JR_KFYWY",
  filter_string="FName like '%张三%' or FNumber like '%张三%'"
)
```

### 3. 查询某月生日的所有客户（含两个生日字段）

```
query_bill_json(
  form_id="BD_Customer",
  field_keys="FName,FNumber,F_JR_KHSR,F_JR_KHSRYF,F_JR_KHSR2,F_JR_KHSR2YF,F_JR_LXR,F_JR_DH,F_JR_KFYWY,FKHLB,FFWZY",
  filter_string="F_JR_KHSRYF = '3' or F_JR_KHSR2YF = '3'",
  top_count=2000
)
```

> 月份用字符串，如 `'3'` 代表3月，`'12'` 代表12月。注意同时查两个生日月份字段（F_JR_KHSRYF 和 F_JR_KHSR2YF）。

### 4. 推荐的通用客户信息查询字段组合

```
FName,FNumber,FShortName,FCreateDate,FModifyDate,F_JR_LXR,F_JR_DH,F_JR_DZ,F_JR_KFYWY,FKHLB,FFWZY,FKHQY
```

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

- 系统有两组生日字段：`F_JR_KHSR` / `F_JR_KHSRYF` 和 `F_JR_KHSR2` / `F_JR_KHSR2YF`
- 按月筛选时必须同时匹配两组（用 `or` 连接）
- 月份字段值为字符串类型，如 `'3'`、`'12'`
- `F_JR_KHSR` 含完整年份，格式为 `1990-03-24T00:00:00`

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

| 场景 | 正确字段 | 常见错误 |
|------|---------|---------|
| 查客户手机号 | `F_JR_DH` | `FMobile`（常为空）、`FPhone`（不存在） |
| 查联系人 | `F_JR_LXR` | `FContact`（不存在） |
| 查地址 | `F_JR_DZ` | `FAddress`（常为空） |
