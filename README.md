# starship-github-identity

[starship](https://starship.rs/) の `[custom.github_remote]` モジュールから呼び出して、git remote が GitHub のときだけ Nerd Font の GitHub アイコンを prompt に表示するためのシェルスクリプトです。

詳しい使い方は記事 [GitHub repo にいるときだけ GitHub アイコンを出す](https://321dev.org/ja/blog/tips/starship-github-account) を参照してください。

## 使い方

1. このリポジトリの `starship-github-identity.sh` を `~/.config/starship-github-identity.sh` に配置
2. 実行権限を付与: `chmod +x ~/.config/starship-github-identity.sh`
3. `examples/starship.toml` を参考に `~/.config/starship.toml` に `[custom.github_remote]` セクションを追加
4. 新しい terminal を開く（または `exec $SHELL -l` で reload）

## 表示される内容

GitHub に向いた git remote を持つディレクトリに `cd` すると、prompt の git ブランチ表示の手前に、Nerd Font の GitHub アイコン (U+F09B, `nf-fa-github`) が表示されます。

```text
~/workspace/some-repo    main
~/notes                                 # 何も出ない
~/workspace/non-github-repo  main       # GitHub 以外の remote はアイコンなし
```

GitHub 以外の remote / 非 git ディレクトリでは何も表示されません。

## 動作前提

- starship 1.20+
- bash（macOS デフォルト 3.2 / Homebrew 5.x の両方で動作確認）
- `git`
- Nerd Font が読めるターミナル（フォント設定が Nerd Font になっていること）

## 設計メモ

- `--check` 引数のときは表示判定（exit 0 なら表示）だけを返す。`when` から呼ばれる用途
- 引数なしのときは GitHub アイコン 1 文字を stdout に出す。`command` から呼ばれる用途
- 判定と表示を 1 本のスクリプトに同居させ、`when` と `command` の食い違いを構造的に防ぐ
- `set -u` のみ採用、`set -e` は入れない（`git remote get-url` の失敗を `|| continue` で握りたいため）
- bash 3.2 互換のため `[[ ]]` や配列を使わず、`case` と parameter expansion だけで書いている

## License

MIT — see [LICENSE](./LICENSE).
