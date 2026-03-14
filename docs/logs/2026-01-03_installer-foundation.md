# 2026-01-03 installer foundation

## Metadata

- Date: 2026-01-03
- Written by: Hyd3-14 (User), Codex (GPT-5.3-Codex High)
- Source: `git log --name-only`

## Summary

- README / CONTRIBUTING を追加してドキュメント基盤を整備。
- `install.sh` を導入し、`lib.sh` / `links.sh` へ分割してモジュール化。
- Git と VSCode 設定を微調整。

## Commits

- `0e36d19` `README を追加`
- `18aeb96` `feat(config): .gitconfigにautoStashオプションを追加`
- `597e26f` `docs: CONTRIBUTING.mdを追加`
- `d372188` `feat(scripts): install.shを追加`
- `702cbe0` `feat(scripts): install.shのヘルパー関数をlib.shに移動し、links.shを追加`
- `f201453` `feat(scripts): install.shとlinks.shのモジュール化を改善`
- `6e19050` `feat(config): settings.jsonにcSpellの単語リストを追加`

## Files

- `README.md`
- `docs/CONTRIBUTING.md`
- `git/.gitconfig`
- `scripts/install.sh`
- `scripts/lib.sh`
- `scripts/links.sh`
- `.vscode/settings.json`

## Decisions / Notes

- インストーラの責務分割（entrypoint / helper / mapping）方針を採用。

## Next Actions

- WezTerm や補助スクリプトを追加して実運用に近づける。
