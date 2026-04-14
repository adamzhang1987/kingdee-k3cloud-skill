# Kingdee K3Cloud ERP Skill

[English](README.en.md) | [中文](README.md)

[![CI](https://github.com/adamzhang1987/kingdee-k3cloud-skill/actions/workflows/ci.yml/badge.svg)](https://github.com/adamzhang1987/kingdee-k3cloud-skill/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)
![Language](https://img.shields.io/badge/language-zh--CN-red.svg)

A Claude Code Skill for Kingdee K3Cloud ERP. Injects form field knowledge, query patterns, and workflow guidance into Claude Code, significantly reducing trial and error.

> **Using a different AI client?** This Skill is a Claude Code-exclusive knowledge enhancement plugin. If you use Claude Desktop, Cursor, Cline, Cherry Studio, Openclaw, or any other MCP-compatible client, simply configure [kingdee-k3cloud-mcp](https://github.com/adamzhang1987/kingdee-k3cloud-mcp) directly — no Skill installation required.

## Prerequisites

This Skill requires a Kingdee K3Cloud MCP Server. The recommended server is [kingdee-k3cloud-mcp](https://github.com/adamzhang1987/kingdee-k3cloud-mcp).

**Overall architecture:**
```
Claude Code (with this Skill installed)
       │ Knowledge injection (form IDs, field names, workflows)
       ↓
Claude Code + MCP tools (query_bill_json, view_bill, etc.)
       │ Kingdee Web API
       ↓
Kingdee K3Cloud
```

> The MCP Server is compatible with all MCP-enabled clients (Claude Desktop, Cursor, Cline, Openclaw, etc.). This Skill is Claude Code-only and provides extra domain knowledge injection.

- **Skill (this project)** = Knowledge base + workflow decision trees (Claude Code exclusive) — Claude automatically uses the correct API patterns, avoiding field name errors
- **MCP Server** = Execution engine with 15 real API tools, compatible with all MCP clients

Both can be used independently, but work best together in Claude Code.

## Installation

### Option 1: Manual Installation (Recommended)

1. Go to the [Releases page](https://github.com/adamzhang1987/kingdee-k3cloud-skill/releases/latest) and download `kingdee-k3cloud.skill`
2. Place the file in Claude Code's skills directory (usually `~/.claude/skills/`)
3. Restart Claude Code to activate the skill

### 🚧 Option 2: Install from Skill Hub (Coming Soon)

Will be enabled once Anthropic Skill Hub launches officially. You'll be able to search for `kingdee` in supported clients and install with one click.

### Option 3: Build from Source

```bash
git clone https://github.com/adamzhang1987/kingdee-k3cloud-skill.git
cd kingdee-k3cloud-skill
# Build (requires make, or use zip directly)
make build
# Copy to skills directory
cp kingdee-k3cloud.skill ~/.claude/skills/
```

## Directory Structure

```
kingdee-k3cloud/
├── SKILL.md                                  # Main file: core principles, form quick-ref, field rules
└── references/
    ├── verified-fields.md                    # Verified fields reference (usable/forbidden per module)
    ├── daily-report-workflow.md               # Daily business report workflow (5-step optimal path)
    ├── customer-query-guide.md                # Customer query guide (templates, ID mapping, birthday queries)
    ├── common-errors.md                      # Common errors and solutions
    ├── sales-analysis-workflow.md            # Sales analysis workflow
    ├── inventory-analysis-workflow.md        # Inventory analysis workflow
    ├── order-tracking-workflow.md            # Order tracking workflow
    ├── periodic-report-workflow.md           # Periodic report workflow
    └── customization-guide.md               # Customization and extension guide
```

## Covered Scenarios

- **ERP data queries**: sales orders, purchase orders, inventory, materials, customers, suppliers
- **Daily business report generation**: standard 5-step query process, optimal token path
- **Customer information management**: customer queries, birthday filtering, category/representative mapping
- **Bill operations**: create, submit, audit, unaudit, push-down
- **Error troubleshooting**: field name validation, 500 error handling, data volume control

## Design Philosophy

Uses **Progressive Disclosure** layered design:

| Level | Content | Load timing |
|-------|---------|-------------|
| Level 1 | Skill name + description | Always in context |
| Level 2 | SKILL.md (~140 lines) | Loaded when skill is triggered |
| Level 3 | references/ detailed docs | Loaded on demand |

The main file stays concise (<300 lines). Detailed field validation tables, query templates, and error handling guides live in `references/` and are loaded on demand.

## Contributors

<a href="https://github.com/adamzhang1987/kingdee-k3cloud-skill/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=adamzhang1987/kingdee-k3cloud-skill" alt="Contributors" />
</a>

Made with [contrib.rocks](https://contrib.rocks).

## License

[Apache-2.0](LICENSE) © Adam Zhang
