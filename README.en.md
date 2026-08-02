# Kingdee K3Cloud ERP Skill

[English](README.en.md) | [中文](README.md)

[![CI](https://github.com/adamzhang1987/kingdee-k3cloud-skill/actions/workflows/ci.yml/badge.svg)](https://github.com/adamzhang1987/kingdee-k3cloud-skill/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/adamzhang1987/kingdee-k3cloud-skill)](https://github.com/adamzhang1987/kingdee-k3cloud-skill/releases/latest)

A Skill for Kingdee K3Cloud ERP, for any Skill-capable AI agent (Claude Code, Openclaw, etc.). Injects the "which form, which field, how to query efficiently" know-how directly into the agent, cutting down on field-guessing 500 errors and trial-and-error round trips.

**Core value:**
- **Fewer failed calls**: ships with verified field names per module (`references/verified-fields.md`), avoiding K3Cloud 500 errors from guessed field names
- **Encodes your own customizations**: every K3Cloud deployment has different custom fields (`F_` prefix) and business processes — `references/customization-guide.md` teaches the agent to discover your actual field structure via `query_metadata` and turn it into reusable knowledge, instead of hardcoding one company's fields
- **Ready-made workflows**: optimal query paths for daily reports, customer lookups, sales/inventory analysis, order tracking, and more are already built in

> **Using a plain MCP client (Claude Desktop, Cursor, Cline, Cherry Studio, etc. without Skill support)?** Configuring [kingdee-k3cloud-mcp](https://github.com/adamzhang1987/kingdee-k3cloud-mcp) directly gives you all 15 tools — this Skill is an optional enhancement, not a prerequisite. Without it, the agent just has to feel its way through field names by trial and error.

## Prerequisites

This Skill requires a Kingdee K3Cloud MCP Server. The recommended server is [kingdee-k3cloud-mcp](https://github.com/adamzhang1987/kingdee-k3cloud-mcp).

**Overall architecture:**
```
Skill-capable agent (with this Skill installed)
       │ Knowledge injection (form IDs, field names, workflows)
       ↓
Agent + MCP tools (query_bill_json, view_bill, etc.)
       │ Kingdee Web API
       ↓
Kingdee K3Cloud
```

> The MCP Server is compatible with all MCP-enabled clients (Claude Desktop, Cursor, Cline, Openclaw, etc.). This Skill is for any Skill-capable AI agent (Claude Code, openclaw, hermes, etc.) and provides extra domain knowledge injection.

- **Skill (this project)** = Knowledge base + workflow decision trees — the agent automatically uses the correct API patterns, avoiding field name errors
- **MCP Server** = Execution engine with 15 real API tools, compatible with all MCP clients

Both can be used independently, but work best together in a Skill-capable agent.

## Installation

### Option 1: Manual Installation (Recommended)

1. Go to the [Releases page](https://github.com/adamzhang1987/kingdee-k3cloud-skill/releases/latest) and download `kingdee-k3cloud.skill`
2. Place the file in your agent's skills directory (e.g. Claude Code uses `~/.claude/skills/`)
3. Restart the agent to activate the skill

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

## Quick Start

1. Set up the MCP Server first, following [kingdee-k3cloud-mcp](https://github.com/adamzhang1987/kingdee-k3cloud-mcp#quick-start) (5 environment variables)
2. Install this Skill into your agent's skills directory as described above, then restart the agent
3. Just ask in natural language — the agent consults the `SKILL.md` decision tree to pick the right form ID and field names automatically, e.g.:
   - "Generate today's business report"
   - "Show me recent orders from customer XX"
   - "Which materials are below the safety stock threshold this month?"

No extra configuration needed — the Skill triggers automatically based on the request.

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

> The bundle published to ClawHub is distributed under MIT-0 (per ClawHub's registry policy); the source repository remains Apache-2.0.
