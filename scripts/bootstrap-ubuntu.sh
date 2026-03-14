#!/usr/bin/env bash
#
# bootstrap-ubuntu.sh
# - Ubuntu / WSL(Ubuntu) 向けの最低限セットアップ
# - 依存コマンドの確認と apt インストールを行う
#

set -euo pipefail

DRY_RUN=0
ASSUME_YES=0
DO_INSTALL=0

usage() {
  cat <<'EOF'
Usage: scripts/bootstrap-ubuntu.sh [options]

Options:
  -n, --dry-run   : 変更内容のみ表示（実行しない）
  -y, --yes       : 確認プロンプトをスキップ
  -i, --install   : 不足パッケージを apt でインストール
  -h, --help      : このヘルプを表示
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1; shift ;;
    -y|--yes) ASSUME_YES=1; shift ;;
    -i|--install) DO_INSTALL=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1"; usage; exit 1 ;;
  esac
done

run_cmd() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[DRY-RUN] $*"
  else
    "$@"
  fi
}

confirm() {
  if [[ $ASSUME_YES -eq 1 ]]; then
    return 0
  fi
  read -r -p "$1 [y/N]: " reply
  case "$reply" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get が見つかりません。Ubuntu/WSL(Ubuntu) 以外では手動セットアップしてください。"
  exit 1
fi

packages=(
  git
  zsh
  curl
  fzf
  gh
  jq
  build-essential
  unzip
)

missing=()
for pkg in "${packages[@]}"; do
  if ! dpkg -s "$pkg" >/dev/null 2>&1; then
    missing+=("$pkg")
  fi
done

echo "Missing apt packages: ${missing[*]:-(none)}"

if [[ ${#missing[@]} -gt 0 ]]; then
  if [[ $DO_INSTALL -eq 0 ]]; then
    echo "不足パッケージがあります。インストールするには --install を付けて再実行してください。"
    echo "  scripts/bootstrap-ubuntu.sh --install"
  else
    if confirm "apt で不足パッケージをインストールしますか?"; then
      run_cmd sudo apt-get update
      run_cmd sudo apt-get install -y "${missing[@]}"
    else
      echo "インストールを中止しました。"
      exit 1
    fi
  fi
fi

if ! command -v ghq >/dev/null 2>&1; then
  echo "ghq が未インストールです。例:"
  echo "  go install github.com/x-motemen/ghq@latest"
fi

if ! command -v mise >/dev/null 2>&1; then
  echo "mise が未インストールです。例:"
  echo "  curl https://mise.run | sh"
fi

echo "bootstrap check finished."
