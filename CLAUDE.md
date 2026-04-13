# Claude Code 工作指南 — kingdee-k3cloud-skill

## 项目概述

金蝶云星空 Claude Code Skill，提供查询模板、字段验证、工作流指南。通过 GitHub Release 分发 `.skill` 文件。

## 每次 commit & push 后的版本检查

完成修改并推送后，**必须主动判断**是否需要升版本号和发布，不要等用户询问。

| 变更类型 | 版本策略 | 是否 Release |
|---------|---------|-------------|
| 新增 workflow / 决策树 / 重要操作指南 | minor bump（1.1.x → 1.2.0） | 是 |
| 修正错误字段名 / 修正错误说明 | patch bump（1.2.0 → 1.2.1） | 是 |
| 仅修改排版 / 格式 / 标点 | 不变 | 否 |

### 发布步骤

1. 更新 `registry.json` 中 `version`
2. `git add registry.json && git commit`
3. `git tag vX.Y.Z && git push && git push origin vX.Y.Z`
   → 触发 GitHub Actions release workflow → 打包 `.skill` 并创建 GitHub Release

## 关键文件

| 文件 | 说明 |
|------|------|
| `kingdee-k3cloud/SKILL.md` | 主技能文件，LLM 操作入口 |
| `kingdee-k3cloud/references/` | 各模块详细参考文档 |
| `registry.json` | 版本号，Skill 注册表读取 |

## 与 mcp repo 的关系

`kingdee-k3cloud-mcp` 新增或变更 MCP tool 后，需同步更新本 repo 的 SKILL.md 决策树或 references 文档，并评估是否需要 minor bump。
