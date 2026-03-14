# Setup Guide (WSL/Ubuntu)

このドキュメントは「新PCでの復元」と「既存PCからの移行」をまとめた手順です。

## 1. 新PCで復元

```bash
git clone https://github.com/Hyd3-14/dotfiles.git ~/dotfiles
cd ~/dotfiles

./scripts/bootstrap-ubuntu.sh
./scripts/bootstrap-ubuntu.sh --install --yes

./scripts/install.sh --dry-run --yes
./scripts/install.sh --yes
```

## 2. 既存PCから `~/.config` を取り込む

取り込み対象:

- `act/actrc`
- `atcoder-cli-nodejs/config.json`
- `atcoder-cli-nodejs/cpp/main.cpp`
- `atcoder-cli-nodejs/cpp/template.json`
- `gh/config.yml`
- `gwq/config.toml`
- `mise/config.toml`

```bash
cd ~/dotfiles
set -euo pipefail

reles=(
  "act/actrc"
  "atcoder-cli-nodejs/config.json"
  "atcoder-cli-nodejs/cpp/main.cpp"
  "atcoder-cli-nodejs/cpp/template.json"
  "gh/config.yml"
  "gwq/config.toml"
  "mise/config.toml"
)

for rel in "${reles[@]}"; do
  mkdir -p "config/$(dirname "$rel")"
  cp -av "$HOME/.config/$rel" "config/$rel"
done
```

## 3. 既存PCからホーム設定を取り込む（任意）

```bash
cd ~/dotfiles
set -euo pipefail

migrate=(
  "$HOME/.bashrc:bash/.bashrc"
  "$HOME/.profile:bash/.profile"
  "$HOME/.fzf.bash:fzf/.fzf.bash"
  "$HOME/.fzf.zsh:fzf/.fzf.zsh"
  "$HOME/.codex/config.toml:codex/config.toml"
)

for item in "${migrate[@]}"; do
  src="${item%%:*}"
  dst="${item##*:}"
  [[ -f "$src" ]] || continue
  mkdir -p "$(dirname "$dst")"
  cp -av "$src" "$dst"
done
```

## 4. 移行後の適用

```bash
cd ~/dotfiles
./scripts/install.sh --dry-run --yes
./scripts/install.sh --yes
```

## 5. 機密情報の扱い

次は **絶対に** リポジトリに入れない:

- `~/.config/gh/hosts.yml`
- `~/.config/qiita-cli/credentials.json`
- `~/.config/atcoder-cli-nodejs/session.json`
- `~/.zsecret`
- `~/dotfiles/zsh/env.local.zsh`
