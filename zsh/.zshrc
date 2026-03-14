# --- 1. Path & Envs (最優先) ---
export ZSH="$HOME/.oh-my-zsh"
export LANG=en_US.UTF-8
export EDITOR='nvim' # vimよりnvimを推奨
export PATH="$HOME/bin:$PATH"
export PIP_REQUIRE_VIRTUALENV=true

alias marp='pnpm exec marp --allow-local-files' # プロジェクトローカルのmarpがあればそれを、なければグローバル(もしあれば)を使うエイリアス
alias glabel="~/src/github.com/Hyd3-14/my-toolbox/github/labels/sync-labels.sh"

for f in ~/dotfiles/zsh/functions/*; do
  [ -f "$f" ] && source "$f"
done

# Mise (ここが重要。ツールのパスを通す)
eval "$(~/.local/bin/mise activate zsh)"

# .zsecret: APIキー等の機密情報の保管庫．
# .zsecret が存在する場合のみ読み込む（エラー回避のため）
if [ -f "$HOME/.zsecret" ]; then
    source "$HOME/.zsecret"
fi

# --- 2. Oh My Zsh Settings ---
ZSH_THEME="robbyrussell"
# ssh-agentプラグインを追加し、手動設定を削除
plugins=(git zsh-autosuggestions zsh-syntax-highlighting ssh-agent)

# SSH Agent Plugin設定 (id_ed25519を自動ロード)
zstyle :omz:plugins:ssh-agent identities id_ed25519
zstyle :omz:plugins:ssh-agent agent-forwarding on

source $ZSH/oh-my-zsh.sh

# --- 3. Custom Functions & Aliases ---
# 外部ファイル化した設定があればここで source する
# [ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

# GitHub CLI helper
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# --- 4. Project Specifics ---
# 便利エイリアス
alias win='cd ~/win'
alias ii='explorer.exe .'
alias open='wslview'
alias mbuild='/home/tantan/src/github.com/Hid3-14/research-note/mbuild.sh'

# pnpm
export PNPM_HOME="/home/tantan/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# --- 5. Key Bindings ---
# ghq-fzf
function ghq-fzf() {
  local selected_dir=$(ghq list | fzf --preview "ls -laTp $(ghq root)/{}" --reverse --height=50%)
  if [ -n "$selected_dir" ]; then
    BUFFER="cd $(ghq root)/$selected_dir"
    zle accept-line
  fi
  zle clear-screen
}
zle -N ghq-fzf
bindkey '^t' ghq-fzf
