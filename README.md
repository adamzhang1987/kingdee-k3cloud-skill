# Kingdee K3Cloud ERP Skill

[![CI](https://github.com/adamzhang1987/kingdee-k3cloud-skill/actions/workflows/ci.yml/badge.svg)](https://github.com/adamzhang1987/kingdee-k3cloud-skill/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)
![Language](https://img.shields.io/badge/language-zh--CN-red.svg)

金蝶云星空 ERP 系统的 Claude Code Skill，为 Claude Code 注入表单字段、查询模式和工作流知识，大幅减少试错次数。

> **使用其他 AI 客户端？** 本 Skill 是 Claude Code 专属的知识增强插件。如果你使用 Claude Desktop、Cursor、Cline、Cherry Studio、Openclaw 等其他支持 MCP 协议的客户端，直接配置 [kingdee-k3cloud-mcp](https://github.com/adamzhang1987/kingdee-k3cloud-mcp) 即可使用全部工具，无需安装本 Skill。

## 前提条件

本 Skill 需配合金蝶云星空 MCP Server 使用，推荐 [kingdee-k3cloud-mcp](https://github.com/adamzhang1987/kingdee-k3cloud-mcp)。

**整体架构：**
```
Claude Code（安装本 Skill）
       │ 知识注入（表单ID、字段名、工作流）
       ↓
Claude Code + MCP 工具（query_bill_json、view_bill 等）
       │ Kingdee Web API
       ↓
金蝶云星空 K3Cloud
```

> MCP Server 本身兼容所有支持 MCP 协议的客户端（Claude Desktop、Cursor、Cline、Openclaw 等）。本 Skill 仅面向 Claude Code，为其提供额外的领域知识注入。

- **Skill（本项目）** = 知识库 + 工作流决策树（Claude Code 专属），让 Claude 自动掌握正确的 API 用法，避免字段名错误
- **MCP Server** = 执行引擎，提供 15 个实际的 API 工具，适用于所有 MCP 客户端

两者可分别使用，但在 Claude Code 中组合使用效果最佳。

## 安装方式

### 方式一：手动安装（推荐）

1. 前往 [Releases 页面](https://github.com/adamzhang1987/kingdee-k3cloud-skill/releases/latest)，下载 `kingdee-k3cloud.skill`
2. 将文件放入 Claude Code 的 skills 目录（通常为 `~/.claude/skills/`）
3. 重启 Claude Code 使 skill 生效

### 🚧 方式二：从 Skill Hub 安装（即将支持）

待 Anthropic Skill Hub 正式上架后启用。届时可在支持 Skill Hub 的客户端中搜索 `kingdee` 并一键安装。

### 方式三：从源码安装

```bash
git clone https://github.com/adamzhang1987/kingdee-k3cloud-skill.git
cd kingdee-k3cloud-skill
# 打包（需要 make，或直接使用 zip 命令）
make build
# 将 kingdee-k3cloud.skill 复制到 skills 目录
cp kingdee-k3cloud.skill ~/.claude/skills/
```

## 目录结构

```
kingdee-k3cloud/
├── SKILL.md                                  # 主文件：核心原则、表单速查、字段规则
└── references/
    ├── verified-fields.md                    # 已验证字段大全（各模块可用/禁用字段）
    ├── daily-report-workflow.md               # 经营日报标准查询流程（5步最优路径）
    ├── customer-query-guide.md                # 客户查询专题（模板、ID映射、生日查询）
    ├── common-errors.md                      # 常见错误及解决方案
    ├── sales-analysis-workflow.md            # 销售分析工作流
    ├── inventory-analysis-workflow.md        # 库存分析工作流
    ├── order-tracking-workflow.md            # 订单追踪工作流
    ├── periodic-report-workflow.md           # 周期性报表工作流
    └── customization-guide.md               # 自定义与扩展指南
```

## 覆盖场景

- **ERP 数据查询**：销售订单、采购订单、库存、物料、客户、供应商
- **经营日报生成**：标准 5 步查询流程，最优 token 路径
- **客户信息管理**：客户查询、生日筛选、类别/专员映射
- **单据操作**：创建、提交、审核、反审核、下推
- **错误排查**：字段名验证、500 错误处理、数据量控制

## 设计理念

采用 **Progressive Disclosure（渐进式披露）** 分层设计：

| 层级 | 内容 | 加载时机 |
|------|------|---------|
| Level 1 | Skill name + description | 始终在上下文中 |
| Level 2 | SKILL.md（140 行） | Skill 触发时加载 |
| Level 3 | references/ 详细文档 | 按需加载 |

主文件保持精简（<300 行），详细的字段验证表、查询模板、错误处理等放在 `references/` 中按需引用。

## License

[Apache-2.0](LICENSE) © Adam Zhang
