# logs README

`docs/logs` は、Git のコミット履歴を「読み返しやすい運用ログ」にしたものです。

## Filename Format

`YYYY-MM-DD_<topic>.md`

例:

- `2026-03-14_reproducibility-and-migration.md`
- `2026-01-03_installer-foundation.md`

## File Structure

各ログは次の順で書きます。

1. Title
2. Metadata
3. Summary
4. Commits
5. Files
6. Decisions / Notes
7. Next Actions

## Author Rule

各ログに必ず次を記載します。

- `Written by: Hyd3-14 (User), Codex (GPT-5)`

## Source of Truth

- 事実は `git log` / `git show` を優先
- 推測を書く場合は「推測」と明記

## Helpful Commands

```bash
# 履歴一覧
 git log --date=short --pretty=format:'%h|%ad|%an|%s' --reverse

# コミットと変更ファイル
 git log --date=short --pretty=format:'---%ncommit %h%nDate: %ad%nSubject: %s' --name-only
```

## Template

新規作成時は `TEMPLATE.md` をコピーして利用します。
