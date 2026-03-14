# dotfiles

WSL/Ubuntu を前提に、開発環境を再現するための個人用 dotfiles です。  
新しい PC でもこのリポジトリから `install.sh` を実行すれば、主要設定を symlink で復元できます。

詳細セットアップは [docs/SETUP.md](docs/SETUP.md) を参照してください。

## Quick Start (New PC)

```bash
git clone https://github.com/Hyd3-14/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 依存ツール確認（Ubuntu/WSL向け）
./scripts/bootstrap-ubuntu.sh
# 必要ならインストール
./scripts/bootstrap-ubuntu.sh --install --yes

# まずは dry-run
./scripts/install.sh --dry-run --yes

# 問題なければ適用
./scripts/install.sh --yes
```

適用後:

- バックアップ: `~/dotfiles_backup_<timestamp>/`
- コマンドリンク: `~/.local/bin`（PATH に含める）

## What Gets Linked

### Home

- `git/.gitconfig` -> `~/.gitconfig`
- `git/.gitignore_global` -> `~/.gitignore_global`
- `zsh/.zshrc` -> `~/.zshrc`
- `zsh/` -> `~/.zsh`
- `.vscode/` -> `~/.vscode`

### Optional Home Files (存在する場合のみ)

- `bash/.bashrc` -> `~/.bashrc`
- `bash/.profile` -> `~/.profile`
- `fzf/.fzf.bash` -> `~/.fzf.bash`
- `fzf/.fzf.zsh` -> `~/.fzf.zsh`
- `codex/config.toml` -> `~/.codex/config.toml`

### ~/.config

- `config/act/actrc` -> `~/.config/act/actrc`
- `config/atcoder-cli-nodejs/config.json` -> `~/.config/atcoder-cli-nodejs/config.json`
- `config/atcoder-cli-nodejs/cpp/main.cpp` -> `~/.config/atcoder-cli-nodejs/cpp/main.cpp`
- `config/atcoder-cli-nodejs/cpp/template.json` -> `~/.config/atcoder-cli-nodejs/cpp/template.json`
- `config/gh/config.yml` -> `~/.config/gh/config.yml`
- `config/gwq/config.toml` -> `~/.config/gwq/config.toml`
- `config/mise/config.toml` -> `~/.config/mise/config.toml`
- `config/Code/User/mcp.json` -> `~/.config/Code/User/mcp.json`
- `config/Code/User/settings.json` -> `~/.config/Code/User/settings.json`

### scripts/bin

`scripts/bin` 直下の実行ファイルを `~/.local/bin` に symlink します。

## Security Policy

以下は管理しない方針です（`.gitignore` で除外）:

- `config/gh/hosts.yml`
- `config/qiita-cli/credentials.json`
- `config/atcoder-cli-nodejs/session.json`
- `zsh/env.local.zsh`
- `.zsecret`

機密情報は必ずローカル専用ファイルに置いてください。

## Update Workflow

1. ローカルで設定変更
2. dotfiles 側に反映
3. `./scripts/install.sh --dry-run --yes` で確認
4. コミット

詳細な運用は [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) を参照。
