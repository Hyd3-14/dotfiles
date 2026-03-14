#!/usr/bin/env bash
#
# import-home-config.sh
# - 現在のホーム設定から、dotfiles に管理すべきファイルだけを取り込む
# - 秘密情報を含むファイルは対象外
#

set -euo pipefail

DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: scripts/import-home-config.sh [options]

Options:
  -n, --dry-run  : 何をコピーするかだけ表示（変更なし）
  -h, --help     : このヘルプを表示
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1"; usage; exit 1 ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

copy_into_repo() {
  local src="$1"
  local rel_dest="$2"
  local dest="$repo_root/$rel_dest"
  if [[ ! -f "$src" ]]; then
    echo "[SKIP] missing: $src"
    return 0
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[DRY-RUN] mkdir -p \"$(dirname "$dest")\""
    echo "[DRY-RUN] cp -av \"$src\" \"$dest\""
  else
    mkdir -p "$(dirname "$dest")"
    cp -av "$src" "$dest"
  fi
}

# ~/.config の管理対象
copy_into_repo "$HOME/.config/act/actrc" "config/act/actrc"
copy_into_repo "$HOME/.config/atcoder-cli-nodejs/config.json" "config/atcoder-cli-nodejs/config.json"
copy_into_repo "$HOME/.config/atcoder-cli-nodejs/cpp/main.cpp" "config/atcoder-cli-nodejs/cpp/main.cpp"
copy_into_repo "$HOME/.config/atcoder-cli-nodejs/cpp/template.json" "config/atcoder-cli-nodejs/cpp/template.json"
copy_into_repo "$HOME/.config/gh/config.yml" "config/gh/config.yml"
copy_into_repo "$HOME/.config/gwq/config.toml" "config/gwq/config.toml"
copy_into_repo "$HOME/.config/mise/config.toml" "config/mise/config.toml"
copy_into_repo "$HOME/.config/Code/User/mcp.json" "config/Code/User/mcp.json"
copy_into_repo "$HOME/.config/Code/User/settings.json" "config/Code/User/settings.json"

# ホーム直下の管理対象（任意）
copy_into_repo "$HOME/.bashrc" "bash/.bashrc"
copy_into_repo "$HOME/.profile" "bash/.profile"
copy_into_repo "$HOME/.fzf.bash" "fzf/.fzf.bash"
copy_into_repo "$HOME/.fzf.zsh" "fzf/.fzf.zsh"
copy_into_repo "$HOME/.codex/config.toml" "codex/config.toml"

echo "Import finished."
echo "次に確認:"
echo "  git status --short"
echo "  ./scripts/install.sh --dry-run --yes"
