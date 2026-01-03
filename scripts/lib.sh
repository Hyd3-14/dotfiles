#!/usr/bin/env bash
# helper library for install.sh
# 日本語コメントを多めにして可読性を確保する

set -euo pipefail

# detect_repo_root <script_dir>
# - スクリプトの位置から git のルートを優先して決定し、変数 repo_root を設定する
detect_repo_root() {
  local script_dir="$1"
  if command -v git >/dev/null 2>&1; then
    if git_root=$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true); then
      repo_root="$git_root"
      return 0
    fi
  fi
  if [[ "$(basename "$script_dir")" == "scripts" ]]; then
    repo_root="$(dirname "$script_dir")"
  else
    repo_root="$script_dir"
  fi
}

# echodo: DRY_RUN を尊重して安全にコマンドを実行する
echodo() {
  if [[ ${DRY_RUN:-0} -eq 1 ]]; then
    echo "[DRY-RUN] $*"
  else
    echo "[EXEC] $*"
    "${@}"
  fi
}

# canonicalize: パスを可能な限り絶対正規化する
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
  printf "%s" "$p"
}

# prompt_confirm: 対話確認（ASSUME_YES を尊重）
prompt_confirm() {
  if [[ ${ASSUME_YES:-0} -eq 1 ]]; then
    return 0
  fi
  read -r -p "$1 [y/N]: " reply
  case "$reply" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

# backup_and_link: src -> dest を安全にリンクする
# 必要な変数: DRY_RUN, FORCE, backup_dir, timestamp
backup_and_link() {
  local src="$1"
  local dest="$2"

  src="$(cd "$(dirname "$src")" && pwd)/$(basename "$src")"

  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ -L "$dest" ]]; then
      dest_resolved="$(canonicalize "$dest")"
      src_resolved="$(canonicalize "$src")"
      if [[ "$dest_resolved" == "$src_resolved" ]]; then
        echo "[SKIP] $dest already links to $src"
        return 0
      fi
    fi

    if [[ -L "$dest" && ${FORCE:-0} -eq 1 ]]; then
      if [[ ${DRY_RUN:-0} -eq 1 ]]; then
        echo "[DRY-RUN] rm \"$dest\""
      else
        echo "[REMOVE-SYMLINK] $dest"
        rm "$dest"
      fi
    else
      local base
      base="$(basename "$dest")"
      local dest_backup="${backup_dir}/${base}.${timestamp}"
      if [[ ${DRY_RUN:-0} -eq 1 ]]; then
        echo "[DRY-RUN] mv \"$dest\" \"$dest_backup\""
      else
        echo "[MOVE] $dest -> $dest_backup"
        mv "$dest" "$dest_backup"
      fi
    fi
  fi

  dest_parent="$(dirname "$dest")"
  if [[ ! -d "$dest_parent" ]]; then
    echodo mkdir -p "$dest_parent"
  fi

  echodo ln -s "$src" "$dest"
  echo "[LINK] $dest -> $src"
}

## end of lib
