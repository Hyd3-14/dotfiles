# docs Overview

このディレクトリは、dotfiles の運用手順と履歴ドキュメントを管理します。

## Structure

- `SETUP.md`
  - 新PCでの復元手順と既存PCからの移行手順
- `CONTRIBUTING.md`
  - 変更時の運用ルール
- `logs/`
  - コミット履歴ベースの作業ログ

## Logs の運用方針

1. 変更をまとめてコミットしたら、`docs/logs/` にログを追加する。
2. ファイル名は `YYYY-MM-DD_<topic>.md` 形式にする。
3. 各ログには以下を必ず書く。
   - 作成者（User + Codexモデル）
   - 対象コミット
   - 変更概要
   - 次にやること
4. テンプレートは `docs/logs/TEMPLATE.md` を使う。

ログ運用の詳細は `docs/logs/README.md` を参照。
