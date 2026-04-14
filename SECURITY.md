# Security Policy

## Reporting a Vulnerability

Please **do not** report security vulnerabilities through public GitHub issues.

Instead, email **adamzhang1987@gmail.com** with:
- A description of the vulnerability
- Steps to reproduce
- Potential impact

You should receive a response within 48 hours. If you do not, please follow up to ensure the message was received.

## Scope

This project is a documentation-only Claude Code Skill — it contains no runtime code and handles no credentials. Key points:

- **No credential handling**: this package contains only Markdown files; it does not store, transmit, or process any credentials
- **No network access**: the Skill itself makes no API calls; all K3Cloud communication goes through the separate `kingdee-k3cloud-mcp` server
- Security-sensitive configuration (API keys, server URLs) is managed entirely by the MCP server — see [kingdee-k3cloud-mcp SECURITY.md](https://github.com/adamzhang1987/kingdee-k3cloud-mcp/blob/main/SECURITY.md)
