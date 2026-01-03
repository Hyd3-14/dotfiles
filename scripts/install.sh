#!/usr/bin/env bash
#
# install.sh - Safe installer for Hyd3-14/dotfiles
#
# 概要（日本語）:
# - リポジトリ内の主要な dotfiles をホームディレクトリ（または XDG 相当）に
#   シンボリックリンクとして配置します。
# - 既存ファイルがあればタイムスタンプ付きバックアップに移動します（上書きしない）。
# - scripts/ 配下の実行可能ファイルは ~/.local/bin にシンボリックリンクします。
#
# 使い方の例:
#   ./scripts/install.sh --dry-run     (変更内容を表示するだけ)
#   ./scripts/install.sh              (対話で確認しながら実行)
#   ./scripts/install.sh --yes --force (全て yes で進め、既存 symlink を置換)
#
# 注意:
# - 実行前に必ずスクリプトの内容を確認してください（ファイル移動が発生します）。
# - シェルの初心者でも分かるように多めにコメントを付けています。

set -euo pipefail

# -----------------------
# オプションとヘルパ関数
# -----------------------
DRY_RUN=0    # 1 なら実行せず表示のみ
FORCE=0      # 1 なら既存の symlink を置換する
ASSUME_YES=0 # 1 ならプロンプトをスキップして自動 "yes"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -n, --dry-run    : 何が行われるか表示する（変更は行わない）
  -f, --force      : 既存 symlink を強制的に置換する
  -y, --yes        : すべての確認を自動的に yes で通す
  -h, --help       : このヘルプを表示
EOF
  exit 1
}

# 引数解析（簡易）
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1; shift ;;
    -f|--force) FORCE=1; shift ;;
    -y|--yes) ASSUME_YES=1; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown argument: $1"; usage ;;
  esac
done

# 各種ヘルパーは scripts/lib.sh に移動しました（echodo, canonicalize, prompt_confirm 等）
# lib.sh を source しているため、ここでは再定義しません。

# -----------------------
# リポジトリルートの検出
# -----------------------
# このスクリプトは通常 scripts/install.sh に置く想定です。
# スクリプトの位置からリポジトリのルートを推定します。
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ユーザのホーム（$HOME 環境変数を尊重）
HOME_DIR="${HOME:-/root}"

# タイムスタンプ付きバックアップディレクトリ名
timestamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="$HOME_DIR/dotfiles_backup_$timestamp"

# XDG 準拠のディレクトリ（無ければ従来の場所）
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME_DIR/.config}"
XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME_DIR/.local/bin}"

# LINKS は links.sh で構築されるが、set -u 対策として先に空で宣言しておく
declare -A LINKS=()

# ライブラリを読み込む（モジュール化）
source "$script_dir/lib.sh"

# detect repo root using helper (lib.sh の detect_repo_root を利用)
detect_repo_root "$script_dir"

# repo_root は detect_repo_root によって設定されるため、
# リンク定義をここで読み込む（links.sh は repo_root に依存する）
source "$script_dir/links.sh" || true

# links.sh によって LINKS が構築される
if [[ ${#LINKS[@]} -eq 0 ]]; then
  echo "No files found to link. Please check repository layout."
  exit 1
fi

# -----------------------
# 計画の表示と確認
# -----------------------
echo "Repository root: $repo_root"
echo "Backup directory will be: $backup_dir"
echo "Planned links:"
# realpath が使えない環境を考慮し、相対表示が不能な場合はフルパスを表示
for src in "${!LINKS[@]}"; do
  src_display="$src"
  if command -v realpath >/dev/null 2>&1; then
    src_display="$(realpath --relative-to="$repo_root" "$src" 2>/dev/null || realpath "$src")"
  fi
  echo "  -> ${src_display}  =>  ${LINKS[$src]}"
done

if ! prompt_confirm "Proceed with the above operations?"; then
  echo "Aborted by user."
  exit 0
fi

# -----------------------
# バックアップディレクトリ作成
# -----------------------
if [[ $DRY_RUN -eq 0 ]]; then
  mkdir -p "$backup_dir"
  mkdir -p "$XDG_BIN_HOME"
fi

# backup_and_link は scripts/lib.sh に実装済み

# 実行: 各マッピングを処理
for src in "${!LINKS[@]}"; do
  dest="${LINKS[$src]}"
  backup_and_link "$src" "$dest"
done

# -----------------------
# scripts/ 配下の実行ファイルを ~/.local/bin にリンク
# - 実行ビット (executable) が立っている単一ファイルを対象
# -----------------------
if [[ -d "$repo_root/scripts" ]]; then
  echo "Processing scripts/ executables -> linking to $XDG_BIN_HOME"
  # find で scripts/ 直下のファイルを走査（サブディレクトリは除外）
  while IFS= read -r -d '' file; do
    # 自分自身（install.sh）をリンクしないようにガード
    if [[ "$(basename "$file")" == "$(basename "${BASH_SOURCE[0]}")" ]]; then
      continue
    fi
    # 実ファイルかつ実行権限があるファイルだけ対象
    if [[ -f "$file" && -x "$file" ]]; then
      target="$XDG_BIN_HOME/$(basename "$file")"
      # 既に同じリンクが張られているかチェック（相対リンクも考慮）
      if [[ -L "$target" ]]; then
        target_resolved="$(canonicalize "$target")"
        file_resolved="$(canonicalize "$file")"
        if [[ "$target_resolved" == "$file_resolved" ]]; then
          echo "[SKIP] $target already links to $file"
          continue
        fi
      fi
      # 既存ファイルがあればバックアップ
      if [[ -e "$target" || -L "$target" ]]; then
        target_backup="$backup_dir/$(basename "$target").$timestamp"
        if [[ $DRY_RUN -eq 1 ]]; then
          echo "[DRY-RUN] mv \"$target\" \"$target_backup\""
        else
          echo "[MOVE] $target -> $target_backup"
          mv "$target" "$target_backup"
        fi
      fi
      echodo ln -s "$file" "$target"
      echo "[LINK] $target -> $file"
    fi
  done < <(find "$repo_root/scripts" -maxdepth 1 -type f -print0 || true)
fi

echo "Done."
if [[ $DRY_RUN -eq 0 ]]; then
  echo "Backups saved to: $backup_dir"
  echo "Ensure $XDG_BIN_HOME is in your PATH, e.g.:"
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

exit 0
