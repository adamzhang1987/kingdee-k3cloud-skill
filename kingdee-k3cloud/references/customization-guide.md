# 自定义配置指南

每个金蝶云星空部署都有自己的业务特征，本指南帮助你发现自己系统的字段，将本 Skill 的通用知识与实际部署对齐。

---

## 一、发现自定义字段

### 查询任意表单的元数据
```
query_metadata(form_id="BD_Customer")
```

从返回结果中识别：
- `Key` = 字段名（直接可用于 `field_keys` 参数）
- `Caption` = 字段中文名称
- 以 `F_` 开头的字段 = 自定义扩展字段（你的公司特有）
- `IsViewVisible=false` = 已废弃/隐藏字段，**禁止使用**
- `MustInput=1` = 保存时必填字段
- `Extends` 数组 = 枚举字段的合法值

### 建议：首次使用时的探索步骤

```
# 1. 获取客户表单的所有字段
query_metadata(form_id="BD_Customer")

# 2. 查几条样本客户，了解实际数据
query_bill_json(form_id="BD_Customer", field_keys="FName,FNumber", top_count=5)

# 3. 查看单条客户完整记录（含所有自定义字段）
view_bill(form_id="BD_Customer", number="某客户编号")
```

---

## 二、建立 ID 映射表

关联字段（如客户类别 `FKHLB`、服务专员 `FFWZY`）返回内部 ID，需要映射到可读名称。

### 发现 ID 对应的名称
```
# 查一条含该 ID 的客户记录
view_bill(form_id="BD_Customer", number="某客户编号")
```

从返回的嵌套 JSON 对象中找到字段对应的名称（`FName`、`FNumber` 等）。

建立映射表后记录在此，后续查询时直接引用：

| 字段 | ID | 名称 |
|------|-----|------|
| FKHLB | （你的实际值） | （对应名称） |
| FFWZY | （你的实际值） | （对应名称） |

---

## 三、识别单号规律

不同部署的单号前缀不同，查几条样本单据识别规律：

```
query_bill_json(
  form_id="SAL_SaleOrder",
  field_keys="FBillNo,FDate",
  top_count=5
)
```

从返回的 `FBillNo` 值中提取前缀规律（如 `XSDD`、`SO` 等），后续过滤时使用：
```
filter_string="FBillNo like 'XSDD%'"
```

---

## 四、确认仓库名称

查询仓库列表，记录实际名称用于后续过滤和展示：

```
query_bill_json(
  form_id="STK_Inventory",
  field_keys="FStockId.FName,FBaseQty",
  filter_string="FBaseQty > 0",
  top_count=10
)
```

从 `FStockId.FName` 字段获取实际仓库名称。

---

## 五、识别内部客户/排除规则

查询客户列表，找出需要在统计时排除的内部客户：

```
query_bill_json(
  form_id="BD_Customer",
  field_keys="FName,FNumber",
  filter_string="FName like '%内部%' or FName like '%自购%'",
  top_count=20
)
```

记录实际的内部客户名称特征，后续统计时用 `not like` 排除：
```
filter_string="... AND FCustId.FName not like '%实际关键词%'"
```

---

## 六、常见配置记录模板

首次探索后，将关键配置记录在这里（或添加到你的 CLAUDE.md 中）：

```
# 本系统配置

## 仓库
- 主仓库：（实际名称）
- 辅仓库：（实际名称）

## 单号前缀
- 销售订单：XSDD（示例，替换为实际）
- 销售出库：XSCKD
- 采购入库：CGRK
- 采购订单：CGDD

## 内部客户关键词
- 排除过滤：FCustId.FName not like '%（关键词）%'

## 自定义字段（BD_Customer）
- 联系人：F_XX_LXR（替换为实际字段名）
- 电话：F_XX_DH
- 地址：F_XX_DZ
- 生日：F_XX_KHSR / F_XX_KHSRYF

## ID 映射
### FKHLB（客户类别）
| ID | 名称 |
|----|------|
|    |      |

### FFWZY（服务专员）
| ID | 名称 |
|----|------|
|    |      |
```

> 建议将上述配置放入项目根目录的 `CLAUDE.md` 文件，Claude Code 会自动读取，无需每次说明。
