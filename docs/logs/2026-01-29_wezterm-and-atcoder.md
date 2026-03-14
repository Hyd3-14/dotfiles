# 2026-01-29 wezterm and atcoder updates

## Metadata

- Date: 2026-01-29
- Written by: Hyd3-14 (User), Codex (GPT-5.3-Codex High)
- Source: `git log --name-only`

## Summary

- WezTerm 設定を本格導入。
- 競プロ補助スクリプト `acs` を改善（`oj -N`）。

## Commits

- `3d3fa09` `feat(scripts): ojコマンドに-Nオプションを追加`
- `f12b4f6` `feat(config): weztermの設定ファイルを追加`

## Files

- `scripts/bin/acs`
- `scripts/bin/act`
- `wezterm/keybinds.lua`
- `wezterm/wezterm.lua`
- `.gitattributes`

## Decisions / Notes

- ターミナル設定を dotfiles 管理下に明確化。

## Next Actions

- インストール時のリンク範囲と安全性を見直す。
