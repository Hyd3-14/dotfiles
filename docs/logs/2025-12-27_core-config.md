# 2025-12-27 core config updates

## Metadata

- Date: 2025-12-27
- Written by: Hyd3-14 (User), Codex (GPT-5.3-Codex High)
- Source: `git log --name-only`

## Summary

- Git のユーザー情報・alias を拡張。
- `.gitignore` と Zsh 関数周りを改善。
- VSCode の Copilot コミットメッセージ設定を追加。

## Commits

- `7e75bae` `Update username and name in .gitconfig`
- `8a88e6b` `Update dotfiles: enhance .gitignore, fix user name in .gitconfig, add new aliases and functions in .zshrc, and implement error handling in msp function`
- `e3f91aa` `Add GitHub Copilot commit message generation settings`
- `2159b27` `feat(config): .gitconfigにcleanupエイリアスを追加`

## Files

- `.gitignore`
- `.vscode/settings.json`
- `git/.gitconfig`
- `git/.gitignore_global`
- `zsh/.zshrc`
- `zsh/functions/gi`
- `zsh/functions/msp`

## Decisions / Notes

- VSCode 連携やコミット品質向上の方向性を採用。

## Next Actions

- セットアップ自動化のための installer を追加。
