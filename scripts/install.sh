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

# echodo: dry-run 時はコマンドを表示するだけ、通常時は実行するラッパー
# echodo: コマンドを実行するヘルパ。引数を配列で受け取り eval を使わずに安全に実行する。
# - DRY_RUN=1 のときは実行せずに何をするか表示するだけにする（安全のため）
echodo() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[DRY-RUN] $*"
  else
    echo "[EXEC] $*"
    # 引数をそのまま実行（空白や特殊文字を安全に扱う）
    "${@}"
  fi
}

# canonicalize: 引数のパスを可能な限り絶対正規化して返す関数
# - realpath/readlink -f/python のいずれかを使って symlink を解決する
# - 相対リンクやシンボリックリンクの比較に使う
canonicalize() {
  local p="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath -m "$p" 2>/dev/null && return 0
  fi
  if readlink -f "$p" >/dev/null 2>&1; then
    readlink -f "$p" 2>/dev/null && return 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$p" 2>/dev/null && return 0
  fi
  if command -v python >/dev/null 2>&1; then
    python -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$p" 2>/dev/null && return 0
  fi
  # どうしても解決できない場合は入力をそのまま返す
  printf "%s" "$p"
}

# prompt_confirm: ユーザに確認。ASSUME_YES=1 の場合は自動 yes。
prompt_confirm() {
  if [[ $ASSUME_YES -eq 1 ]]; then
    return 0
  fi
  # read -r は改行を含む入力でも安全に扱うための指定
  read -r -p "$1 [y/N]: " reply
  case "$reply" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

# -----------------------
# リポジトリルートの検出
# -----------------------
# このスクリプトは通常 scripts/install.sh に置く想定です。
# スクリプトの位置からリポジトリのルートを推定します。
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Try to detect repository root via git if available (more robust inside clones)
if command -v git >/dev/null 2>&1; then
  if git_root=$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true); then
    repo_root="$git_root"
  else
    if [[ "$(basename "$script_dir")" == "scripts" ]]; then
      repo_root="$(dirname "$script_dir")"
    else
      repo_root="$script_dir"
    fi
  fi
else
  if [[ "$(basename "$script_dir")" == "scripts" ]]; then
    repo_root="$(dirname "$script_dir")"
  else
    repo_root="$script_dir"
  fi
fi

# ユーザのホーム（$HOME 環境変数を尊重）
HOME_DIR="${HOME:-/root}"

# タイムスタンプ付きバックアップディレクトリ名
timestamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="$HOME_DIR/dotfiles_backup_$timestamp"

# XDG 準拠のディレクトリ（無ければ従来の場所）
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME_DIR/.config}"
XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME_DIR/.local/bin}"

# -----------------------
# シンボリックリンク対象のマッピング
# -----------------------
# LINKS は "リンク元（絶対パス）" -> "リンク先（絶対パス）" の連想配列
declare -A LINKS

# ここでは典型的なファイルを自動で追加する実装にしています。
# 必要ならこの部分を編集してカスタマイズしてください。

# git/.gitconfig が存在するなら ~/.gitconfig にリンク
if [[ -e "$repo_root/git/.gitconfig" ]]; then
  LINKS["$repo_root/git/.gitconfig"]="$HOME_DIR/.gitconfig"
fi

# zsh/.zshrc が存在するなら ~/.zshrc にリンク
if [[ -e "$repo_root/zsh/.zshrc" ]]; then
  LINKS["$repo_root/zsh/.zshrc"]="$HOME_DIR/.zshrc"
fi

# zsh ディレクトリ全体を ~/.zsh にリンク（ディレクトリリンク）
if [[ -d "$repo_root/zsh" ]]; then
  LINKS["$repo_root/zsh"]="$HOME_DIR/.zsh"
fi

# .vscode ディレクトリをホーム直下にコピーする運用ならここでリンク
if [[ -d "$repo_root/.vscode" ]]; then
  LINKS["$repo_root/.vscode"]="$HOME_DIR/.vscode"
fi

# ここに他のマッピングを追加可能（例: tmux, vim, neovim 等）
# 例:
# if [[ -e "$repo_root/tmux/.tmux.conf" ]]; then
#   LINKS["$repo_root/tmux/.tmux.conf"]="$HOME_DIR/.tmux.conf"
# fi

# マッピングが無ければ警告して終了
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

# -----------------------
# バックアップとリンク作成の関数
# -----------------------
# backup_and_link src dest
# - src: リポジトリ内の実ファイルまたはディレクトリ（絶対パス）
# - dest: ホーム側の設置先パス（絶対パス）
backup_and_link() {
  local src="$1"
  local dest="$2"

  # src を絶対パスにする（安全のため）
  src="$(cd "$(dirname "$src")" && pwd)/$(basename "$src")"

  # dest が既に存在する場合の処理
  if [[ -e "$dest" || -L "$dest" ]]; then
    # 既に同じリンクが張られているか確認
      if [[ -L "$dest" ]]; then
        # 既存のシンボリックリンク先と src を正規化して比較する
        dest_resolved="$(canonicalize "$dest")"
        src_resolved="$(canonicalize "$src")"
        if [[ "$dest_resolved" == "$src_resolved" ]]; then
          echo "[SKIP] $dest already links to $src"
          return 0
        fi
      fi
    # 既存が symlink で --force 指定なら上書き（削除）して置き換える
    if [[ -L "$dest" && $FORCE -eq 1 ]]; then
      if [[ $DRY_RUN -eq 1 ]]; then
        echo "[DRY-RUN] rm \"$dest\""
      else
        echo "[REMOVE-SYMLINK] $dest"
        rm "$dest"
      fi
    else
      # バックアップ名（目的: 同名ファイルの履歴保持）
      local base
      base="$(basename "$dest")"
      local dest_backup="$backup_dir/${base}.$timestamp"

      if [[ $DRY_RUN -eq 1 ]]; then
        echo "[DRY-RUN] mv \"$dest\" \"$dest_backup\""
      else
        echo "[MOVE] $dest -> $dest_backup"
        mv "$dest" "$dest_backup"
      fi
    fi
  fi

  # リンク先の親ディレクトリが存在しない場合は作る（例: ~/.config など）
  dest_parent="$(dirname "$dest")"
  if [[ ! -d "$dest_parent" ]]; then
    echodo mkdir -p "$dest_parent"
  fi

  # 実際にシンボリックリンクを作成
  echodo ln -s "$src" "$dest"
  echo "[LINK] $dest -> $src"
}

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
