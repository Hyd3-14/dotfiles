#!/usr/bin/env bash
# links.sh: リンク対象のマッピングを定義するモジュール
# - このファイルは `install.sh` から source され、
#   `repo_root` と `HOME_DIR` が定義されていることを前提とします。

# safety guard: repo_root が未定義で読み込まれた場合は何もしない（無限エラーを防ぐ）
if [[ -z "${repo_root:-}" ]]; then
  return 0
fi

# LINKS は associative array として populate される
declare -g -A LINKS

# git/.gitconfig が存在するなら ~/.gitconfig にリンク
if [[ -e "$repo_root/git/.gitconfig" ]]; then
  LINKS["$repo_root/git/.gitconfig"]="$HOME_DIR/.gitconfig"
fi

# zsh の個別ファイルとディレクトリ
if [[ -e "$repo_root/zsh/.zshrc" ]]; then
  LINKS["$repo_root/zsh/.zshrc"]="$HOME_DIR/.zshrc"
fi
if [[ -d "$repo_root/zsh" ]]; then
  LINKS["$repo_root/zsh"]="$HOME_DIR/.zsh"
fi

# VSCode 設定（運用によっては除外したい）
if [[ -d "$repo_root/.vscode" ]]; then
  LINKS["$repo_root/.vscode"]="$HOME_DIR/.vscode"
fi

# 追加の候補: tmux, nvim 等はここに追記する
