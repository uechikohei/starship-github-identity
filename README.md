# starship-github-identity

[starship](https://starship.rs/) の `[custom.github_remote]` モジュールから呼び出して、git remote が GitHub のときだけ Nerd Font の GitHub icon と `git config user.name` を prompt に表示するためのシェルスクリプトです。

詳しい使い方と設計の意図は記事 [GitHub repo にいるときだけ starship に GitHub icon と user.name を出す](https://321dev.org/ja/blog/tips/starship-github-account) を参照してください。

## 使い方

1. このリポジトリの `starship-github-identity.sh` を `~/.config/starship-github-identity.sh` に配置
2. 実行権限を付与: `chmod +x ~/.config/starship-github-identity.sh`
3. `examples/starship.toml` を参考に `~/.config/starship.toml` に `[custom.github_remote]` セクションを追加
4. 新しい terminal を開く（または `exec $SHELL -l` で reload）

## 表示される内容

GitHub に向いた git remote を持つディレクトリに `cd` すると、prompt の git ブランチ表示の手前に、Nerd Font の GitHub icon (U+F09B, `nf-fa-github`) と `git config user.name` が表示されます。

```text
~/workspace/private/some-repo  uechikohei  main
~/workspace/work/another-repo  [work]  feature/x
~/workspace/note-repo  main
```

GitHub 以外の remote / 非 git ディレクトリでは何も表示されません。

`~/.ssh/config` で Host alias を切っている場合（`git@github-private:owner/repo.git` のような remote URL）も、`ssh -G` で alias を解決して GitHub 判定に通します。

## 動作前提

- starship 1.20+（手元では 1.24.2 で動作確認）
- bash（macOS デフォルト 3.2 / Homebrew 5.x の両方で動作確認）
- `git`、`ssh`、`awk`（POSIX）
- Nerd Font が読めるターミナル（フォント設定が Nerd Font になっていること）

## 設計メモ

- `--check` 引数のときは表示判定（exit 0 なら表示）だけを返す。`when` から呼ばれる用途
- 引数なしのときは GitHub icon と `user.name` を stdout に出す。`command` から呼ばれる用途
- 判定と出力を 1 本のスクリプトに同居させ、`when` と `command` の食い違いを構造的に防ぐ
- `set -u` のみ採用、`set -e` は入れない（`git remote get-url` の失敗を `|| continue` で握りたいため）
- bash 3.2 互換のため `[[ ]]` や配列を使わず、`case` と parameter expansion だけで書いている

## License

MIT — see [LICENSE](./LICENSE).
