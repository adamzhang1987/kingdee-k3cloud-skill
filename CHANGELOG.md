# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/adamzhang1987/kingdee-k3cloud-skill/releases/tag/v1.0.0
