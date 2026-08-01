

# Kingdee K3Cloud ERP Skill

[English](README.en.md) | [中文](README.md)

[![CI](https://github.com/adamzhang1987/kingdee-k3cloud-skill/actions/workflows/ci.yml/badge.svg)](https://github.com/adamzhang1987/kingdee-k3cloud-skill/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/adamzhang1987/kingdee-k3cloud-skill)](https://github.com/adamzhang1987/kingdee-k3cloud-skill/releases/latest)

An ERP Skill for Kingdee Cloud Cosmic (K3Cloud) designed for AI Agents that support the Skill mechanism (Claude Code, Openclaw, etc.). It directly injects hard-earned practical knowledge into the Agent—such as "which form uses which field" and "how to query using the fewest tokens"—significantly reducing 500 errors and trial-and-error loops caused by guessing field names.

**Core Value:**
- **Reduce Trial and Error:** Built-in verified field names for various modules (`references/verified-fields.md`) to avoid triggering Kingdee 500 errors from guessing field names.
- **Encapsulate Your Customization Knowledge:** Every Kingdee deployment has unique custom fields (prefixed with `F_`) and business processes. `references/customization-guide.md` teaches the Agent to use `query_metadata` to automatically discover your actual field structure and distill it into reusable knowledge, rather than hardcoding fields for a specific company.
- **Complete Workflows:** Optimal query paths for scenarios like daily business reports, customer queries, sales/inventory analysis, and order tracking are pre-configured.

> **Only using pure MCP clients (Claude Desktop, Cursor, Cline, Cherry Studio, etc., which do not support the Skill mechanism)?** You can still use all 15 tools by directly configuring [kingdee-k3cloud-mcp](https://github.com/adamzhang1987/kingdee-k3cloud-mcp). This Skill is an optional enhancement, not a prerequisite; however, without it, the Agent must rely on repeated trial and error to figure out the correct field names.

## Prerequisites

This Skill requires the Kingdee Cloud Cosmic MCP Server to function, and we recommend [kingdee-k3cloud-mcp](https://github.com/adamzhang1987/kingdee-k3cloud-mcp).

**Overall Architecture:**
```
Skill-compatible Agent (with this Skill installed)
       │ Knowledge Injection (Form IDs, Field Names, Workflows)
       ↓
Agent + MCP Tools (query_bill_json, view_bill, etc.)
       │ Kingdee Web API
       ↓
Kingdee Cloud Cosmic K3Cloud
```

> The MCP Server itself is compatible with all clients that support the MCP protocol (Claude Desktop, Cursor, Cline, Openclaw, etc.). This Skill is designed for AI Agents that support the Skill mechanism (Claude Code, openclaw, hermes, etc.), providing them with additional domain knowledge injection.

- **Skill (This Project)** = Knowledge base + workflow decision tree, enabling the Agent to automatically master correct API usage and avoid field name errors.
- **MCP Server** = Execution engine, providing 15 actual API tools, compatible with all MCP clients.

Both can be used independently, but they work best when combined in a Skill-compatible Agent.

## Installation

### Method 1: Manual Installation (Recommended)

1. Go to the [Releases page](https://github.com/adamzhang1987/kingdee-k3cloud-skill/releases/latest) and download `kingdee-k3cloud.skill`.
2. Place the file in your Agent's skills directory (for Claude Code, this is typically `~/.claude/skills/`).
3. Restart the Agent to activate the skill.

### 🚧 Method 2: Install from Skill Hub (Coming Soon)

Will be enabled once the Anthropic Skill Hub is officially available. At that time, you can search for `kingdee` in Skill Hub-compatible clients and install it with one click.

### Method 3: Install from Source

```bash
git clone https://github.com/adamzhang1987/kingdee-k3cloud-skill.git
cd kingdee-k3cloud-skill
# Package (requires make, or use zip command directly)
make build
# Copy kingdee-k3cloud.skill to the skills directory
cp kingdee-k3cloud.skill ~/.claude/skills/
```

## Quick Start

1. First, configure the MCP Server following the instructions in [kingdee-k3cloud-mcp](https://github.com/adamzhang1987/kingdee-k3cloud-mcp#快速开始) (5 environment variables).
2. Place this Skill in your Agent's skills directory as described in the "Installation" section above, then restart the Agent.
3. Ask questions in natural language. The Agent will automatically consult the `SKILL.md` decision tree to select the correct form IDs and field names, for example:
   - "Generate today's business report."
   - "Check recent orders for customer XX."
   - "Which materials have inventory below the safety level this month?"

No additional configuration is required—Skill triggering is automatic, and the Agent will determine whether to load it based on the request content.

## Directory Structure

```
kingdee-k3cloud/
├── SKILL.md                                  # Main file: Core principles, form quick reference, field rules
└── references/
    ├── verified-fields.md                    # Complete list of verified fields (available/disabled fields per module)
    ├── daily-report-workflow.md               # Standard daily business report query workflow (5-step optimal path)
    ├── customer-query-guide.md                # Customer query guide (templates, ID mapping, birthday filtering)
    ├── common-errors.md                      # Common errors and solutions
    ├── sales-analysis-workflow.md            # Sales analysis workflow
    ├── inventory-analysis-workflow.md        # Inventory analysis workflow
    ├── order-tracking-workflow.md            # Order tracking workflow
    ├── periodic-report-workflow.md           # Periodic report workflow
    └── customization-guide.md               # Customization and extension guide
```

## Covered Scenarios

- **ERP Data Querying:** Sales orders, purchase orders, inventory, materials, customers, suppliers.
- **Daily Business Report Generation:** Standard 5-step query workflow with optimal token path.
- **Customer Information Management:** Customer querying, birthday filtering, category/specialist mapping.
- **Document Operations:** Create, submit, approve, un-approve, push down.
- **Error Troubleshooting:** Field name validation, 500 error handling, data volume control.

## Design Philosophy

Adopts a **Progressive Disclosure** layered design:

| Level | Content | Loading Trigger |
|-------|---------|-----------------|
| Level 1 | Skill name + description | Always in context |
| Level 2 | SKILL.md (~140 lines) | Loaded when Skill is triggered |
| Level 3 | references/ detailed docs | Loaded on demand |

The main file remains concise (<300 lines), while detailed field validation tables, query templates, error handling guides, etc., are placed in `references/` for on-demand reference.

## Contributors

<a href="https://github.com/adamzhang1987/kingdee-k3cloud-skill/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=adamzhang1987/kingdee-k3cloud-skill" alt="Contributors" />
</a>

Made with [contrib.rocks](https://contrib.rocks).

## License

[Apache-2.0](LICENSE) © Adam Zhang

> The ClawHub distribution version uses MIT-0 (compliant with ClawHub registration policy); the source repository remains Apache-2.0.
