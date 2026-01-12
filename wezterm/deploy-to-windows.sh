#!/usr/bin/env bash
set -euo pipefail

# Windowsの USERPROFILE を WSLパスに変換
WIN_USERPROFILE="$(cmd.exe /c echo %USERPROFILE% 2>/dev/null | tr -d '\r')"
WIN_HOME="$(wslpath "$WIN_USERPROFILE")"

DEST_DIR="$WIN_HOME/.config/wezterm"
SRC_DIR="$HOME/dotfiles/wezterm"

mkdir -p "$DEST_DIR"

# main
cp -f "$SRC_DIR/wezterm.lua" "$DEST_DIR/wezterm.lua"

# 分割ファイルも使うなら一緒に
if [ -f "$SRC_DIR/keybinds.lua" ]; then
  cp -f "$SRC_DIR/keybinds.lua" "$DEST_DIR/keybinds.lua"
fi

echo "Deployed to: $DEST_DIR"
