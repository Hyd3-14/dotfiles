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
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME_DIR/.config}"

add_link() {
  local src="$1"
  local dest="$2"
  if [[ -e "$src" ]]; then
    LINKS["$src"]="$dest"
  fi
}

# 基本 dotfiles
add_link "$repo_root/git/.gitconfig" "$HOME_DIR/.gitconfig"
add_link "$repo_root/git/.gitignore_global" "$HOME_DIR/.gitignore_global"
add_link "$repo_root/zsh/.zshrc" "$HOME_DIR/.zshrc"

if [[ -d "$repo_root/zsh" ]]; then
  LINKS["$repo_root/zsh"]="$HOME_DIR/.zsh"
fi

# ホーム直下の追加設定（存在するものだけリンク）
add_link "$repo_root/bash/.bashrc" "$HOME_DIR/.bashrc"
add_link "$repo_root/bash/.profile" "$HOME_DIR/.profile"
add_link "$repo_root/fzf/.fzf.bash" "$HOME_DIR/.fzf.bash"
add_link "$repo_root/fzf/.fzf.zsh" "$HOME_DIR/.fzf.zsh"
add_link "$repo_root/codex/config.toml" "$HOME_DIR/.codex/config.toml"

# VSCode 設定
if [[ -d "$repo_root/.vscode" ]]; then
  LINKS["$repo_root/.vscode"]="$HOME_DIR/.vscode"
fi

# ~/.config 配下の管理対象
config_files=(
  "act/actrc"
  "atcoder-cli-nodejs/config.json"
  "atcoder-cli-nodejs/cpp/main.cpp"
  "atcoder-cli-nodejs/cpp/template.json"
  "gh/config.yml"
  "gwq/config.toml"
  "mise/config.toml"
  "Code/User/mcp.json"
  "Code/User/settings.json"
)

for rel in "${config_files[@]}"; do
  add_link "$repo_root/config/$rel" "$XDG_CONFIG_HOME/$rel"
done
