# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.5.0] - 2026-09-02

### Changed
- **重写「错误3: 会话信息已丢失」整节**（`references/common-errors.md`）。经三轮实证测试
  （约 240 次只读请求，见 mcp 仓库 `docs/session-auth-experiments.md`）确认，该错误**不是
  会话过期，而是认证失败**（`MsgCode=1`）。原有指引与实测结论直接冲突，且其中一条有害：
  - 删除「自动重试：MCP 服务器应实现自动重连」——重试不可能修复凭据错误；
  - 删除「联系管理员**重启 MCP 服务**」——在改正配置**之前**重启会把偶发问题变成持续问题
    （凭据错误本可被一个仍有效的 SID 掩盖，新进程没有 SID 就必须走凭据校验）；
  - 改为四项凭据核对清单（`KD_USERNAME` / `KD_APP_ID` / `KD_APP_SEC` / `KD_LCID`），
    并区分「改金蝶端无需重启」与「改 .env 必须重启」两条生效路径；
  - 补充说明 `KD_ACCT_ID` 错误表现为 HTTP 非 200、`KD_ORG_NUM` 错误不产生该错误。
- 决策树第 4 条「会话是否过期？→ 重试操作」前提错误，已改为指向错误3 并明确不要重试、
  不要建议重启。
- 记录 MCP Server ≥ 1.4.0 会把该错误包成带诊断的 envelope
  （`{error, message, hint, original}`）。

## [1.4.0] - 2026-08-01

### Added
- `references/common-errors.md`: new "错误7: 权限不足 / 结果异常为空" entry documenting silent data-rule filtering (query succeeds but rows are filtered by the integration user's K3Cloud data permissions, with no error). Instructs the LLM not to assert "no data" on empty results without first checking for permission filtering.
- Troubleshooting checklist: new item for comparing row counts against the K3Cloud web UI when results seem permission-filtered.

## [1.3.1] - 2026-04-22

### Added
- `kingdee-k3cloud/LICENSE`: MIT-0 license file for ClawHub distribution bundle (ClawHub requires MIT-0 for all published skills)
- Dual-licensing note in README.md and README.en.md (Apache-2.0 source / MIT-0 ClawHub bundle)

## [1.3.0] - 2026-04-13

### Changed
- Decision tree updated to cover the four new MCP tools added in `kingdee-k3cloud-mcp` v1.3.0: `count_bill`, `query_bill_all`, `query_bill_to_file`, `query_bill_range`
- Pagination guidance updated to reflect automatic pagination strategies

## [1.2.0] - 2026-04-13

### Added
- Large-batch query decision tree: guidance on choosing between `query_bill_all`, `query_bill_to_file`, and `query_bill_range` based on data volume

## [1.1.1] - 2026-04-12

### Changed
- CI: upgraded `actions/checkout` to v5, opted in to Node.js 24

## [1.1.0] - 2026-04-11

### Changed
- Generalized business-specific data for open-source release
- Added scope annotations to `verified-fields.md` to prevent cross-form misreads
- Added `gl-voucher-guide.md` for `GL_VOUCHER` (accounting voucher) field reference
- Excluded `.claude/` directory from version control

## [1.0.0] - 2026-03-20

### Added
- Initial release: consolidated Kingdee K3Cloud ERP skill package
- `SKILL.md`: core principles, common form IDs, field rules, query decision tree
- `references/verified-fields.md`: verified fields for sales, purchase, inventory, materials, customers
- `references/daily-report-workflow.md`: 5-step optimal daily report query path
- `references/customer-query-guide.md`: customer query templates and ID mapping
- `references/common-errors.md`: common errors and solutions
- `references/sales-analysis-workflow.md`, `inventory-analysis-workflow.md`, `order-tracking-workflow.md`
- `references/periodic-report-workflow.md`, `customization-guide.md`
- GitHub Actions release workflow: packages `.skill` file on tag push

[Unreleased]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/compare/v1.5.0...HEAD
[1.5.0]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/compare/v1.3.1...v1.4.0
[1.3.1]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/releases/tag/v1.0.0
