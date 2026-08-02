# Kingdee K3Cloud ERP Skill

[English](README.en.md) | [中文](README.md)

[![CI](https://github.com/adamzhang1987/kingdee-k3cloud-skill/actions/workflows/ci.yml/badge.svg)](https://github.com/adamzhang1987/kingdee-k3cloud-skill/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/adamzhang1987/kingdee-k3cloud-skill)](https://github.com/adamzhang1987/kingdee-k3cloud-skill/releases/latest)

面向支持 Skill 机制的 AI Agent（Claude Code、Openclaw 等）的金蝶云星空 ERP Skill，把「哪个表单用哪个字段、怎么查最省 token」这类踩坑经验直接注入 Agent，大幅减少字段猜测导致的 500 错误和试错往返。

**核心价值：**
- **减少试错**：内置各模块已验证字段名（`references/verified-fields.md`），避免因猜字段名触发金蝶 500 错误
- **封装你自己的二开知识**：每家金蝶部署都有不同的自定义字段（`F_` 前缀）和业务流程——`references/customization-guide.md` 教 Agent 用 `query_metadata` 自动发现你的实际字段结构，并沉淀成可复用的知识，而不是写死某一家公司的字段
- **完整工作流**：经营日报、客户查询、销售/库存分析、订单追踪等场景的最优查询路径已预置好

> **只用纯 MCP 客户端（Claude Desktop、Cursor、Cline、Cherry Studio 等不支持 Skill 机制）？** 直接配置 [kingdee-k3cloud-mcp](https://github.com/adamzhang1987/kingdee-k3cloud-mcp) 也能用全部 15 个工具——本 Skill 是可选增强，不是前提条件；但少了它，Agent 需要自己反复试错才能摸清字段名。

## 前提条件

本 Skill 需配合金蝶云星空 MCP Server 使用，推荐 [kingdee-k3cloud-mcp](https://github.com/adamzhang1987/kingdee-k3cloud-mcp)。

**整体架构：**
```
支持 Skill 的 Agent（安装本 Skill）
       │ 知识注入（表单ID、字段名、工作流）
       ↓
Agent + MCP 工具（query_bill_json、view_bill 等）
       │ Kingdee Web API
       ↓
金蝶云星空 K3Cloud
```

> MCP Server 本身兼容所有支持 MCP 协议的客户端（Claude Desktop、Cursor、Cline、Openclaw 等）。本 Skill 面向支持 Skill 机制的 AI Agent（Claude Code、openclaw、hermes 等），为其提供额外的领域知识注入。

- **Skill（本项目）** = 知识库 + 工作流决策树，让 Agent 自动掌握正确的 API 用法，避免字段名错误
- **MCP Server** = 执行引擎，提供 15 个实际的 API 工具，适用于所有 MCP 客户端

两者可分别使用，但在支持 Skill 的 Agent 中组合使用效果最佳。

## 安装方式

### 方式一：手动安装（推荐）

1. 前往 [Releases 页面](https://github.com/adamzhang1987/kingdee-k3cloud-skill/releases/latest)，下载 `kingdee-k3cloud.skill`
2. 将文件放入你的 Agent 的 skills 目录（如 Claude Code 通常为 `~/.claude/skills/`）
3. 重启 Agent 使 skill 生效

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

## 快速开始

1. 先按 [kingdee-k3cloud-mcp](https://github.com/adamzhang1987/kingdee-k3cloud-mcp#快速开始) 的说明配置好 MCP Server（5 个环境变量）
2. 按上方「安装方式」把本 Skill 放进 Agent 的 skills 目录，重启 Agent
3. 直接用自然语言提问，Agent 会自动查阅 `SKILL.md` 决策树选用正确的表单 ID 和字段名，例如：
   - 「生成今天的经营日报」
   - 「查一下 XX 客户最近的订单」
   - 「这个月哪些物料库存低于安全线」

无需额外配置——Skill 触发是自动的，Agent 会根据请求内容自行判断是否需要加载。

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

## 贡献者

<a href="https://github.com/adamzhang1987/kingdee-k3cloud-skill/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=adamzhang1987/kingdee-k3cloud-skill" alt="Contributors" />
</a>

Made with [contrib.rocks](https://contrib.rocks).

## License

[Apache-2.0](LICENSE) © Adam Zhang

> ClawHub 分发版本使用 MIT-0（符合 ClawHub 注册政策）；源码仓库维持 Apache-2.0。
