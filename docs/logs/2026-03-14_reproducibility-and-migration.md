# 2026-03-14 reproducibility and migration

## Metadata

- Date: 2026-03-14
- Written by: Hyd3-14 (User), Codex (GPT-5.3-Codex High)
- Source: `git log --name-only`

## Summary

- `~/.config` の主要設定を dotfiles 管理に移行。
- installer/link 定義を修正し、新PC復元フローを強化。
- `bootstrap`/`import` スクリプトとドキュメントを追加。
- secrets 除外ルールを拡充。

## Commits

- `f96b156` `fix(config): ghqのルートパスを修正`
- `2f0bb68` `docs(README): README.mdのフォーマットを整形し、説明を追加`
- `05c6f08` `feat(dev): dev関数とghq-path関数を追加`
- `5194b92` `fix(zsh): zsh設定ファイルで関数を一括読み込みするように修正`
- `8e9e57b` `fix(zsh): functionsディレクトリ内のスクリプトを全てsourceする行を追加`
- `f746b22` `fix(config): Gitの設定を修正`
- `850f201` `fix(config): .gitignoreに秘密情報の除外ルールを追加`
- `cfb74e7` `feat(config): Atcoder CLIとGHの設定ファイルを追加`
- `e33f81e` `fix(install): installerとリンク定義の再現性を改善`
- `c84e6be` `feat(scripts): bootstrapとimportの補助スクリプトを追加`
- `8cf964c` `docs(setup): 新PC復元と移行手順を整理`
- `f75ca77` `chore(git): codex状態ファイルの除外ルールを追加`

## Files

- `config/act/actrc`
- `config/atcoder-cli-nodejs/*`
- `config/gh/config.yml`
- `config/gwq/config.toml`
- `config/mise/config.toml`
- `scripts/install.sh`
- `scripts/lib.sh`
- `scripts/links.sh`
- `scripts/bootstrap-ubuntu.sh`
- `scripts/import-home-config.sh`
- `README.md`
- `docs/SETUP.md`
- `docs/CONTRIBUTING.md`
- `.gitignore`

## Decisions / Notes

- 「新PC復元を最短化する」方針で、インストール導線と docs を優先整備。
- 機密情報は管理対象から明示的に除外。

## Next Actions

- `docs/logs` 運用を継続し、変更ごとにテンプレートで追記する。
- 必要に応じて `scripts/links.sh` の管理対象を拡張する。
