# Kingdee K3Cloud ERP Skill

金蝶云星空 ERP 系统的 Claude Code Skill，提供查询、操作最佳实践和常见问题解决方案。

## 目录结构

```
kingdee/
├── SKILL.md                                  # 主文件：核心原则、表单速查、字段规则
└── references/
    ├── verified-fields.md                    # 已验证字段大全（各模块可用/禁用字段）
    ├── daily-report-workflow.md               # 经营日报标准查询流程（5步最优路径）
    ├── customer-query-guide.md                # 客户查询专题（模板、ID映射、生日查询）
    └── common-errors.md                      # 常见错误及解决方案
```

## 覆盖场景

- **ERP 数据查询**：销售订单、采购订单、库存、物料、客户、供应商
- **经营日报生成**：标准 5 步查询流程，最优 token 路径
- **客户信息管理**：客户查询、生日筛选、类别/专员映射
- **单据操作**：创建、提交、审核、反审核、下推
- **错误排查**：字段名验证、500 错误处理、数据量控制

## 安装

将 `kingdee.skill` 文件添加到 Claude Code 的 skills 目录即可。

## 设计理念

采用 **Progressive Disclosure（渐进式披露）** 分层设计：

| 层级 | 内容 | 加载时机 |
|------|------|---------|
| Level 1 | Skill name + description | 始终在上下文中 |
| Level 2 | SKILL.md（140 行） | Skill 触发时加载 |
| Level 3 | references/ 详细文档 | 按需加载 |

主文件保持精简（<300 行），详细的字段验证表、查询模板、错误处理等放在 `references/` 中按需引用。
