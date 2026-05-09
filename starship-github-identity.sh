#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# starship-github-identity.sh
#
# starship の [custom.github_remote] モジュールから呼び出して、
# git remote が GitHub のときだけ Nerd Font の GitHub アイコンを
# prompt に表示するためのスクリプト。
#
# 詳しい使い方: https://321dev.org/ja/blog/tips/starship-github-account
#
# 使い方:
#   --check : 表示判定のみ (exit 0 で表示する)。starship の `when` から呼ぶ
#   (引数なし)  : GitHub アイコンを stdout に出力する。starship の `command` から呼ぶ

set -u

# remote URL からホスト名部分を抜き出す
remote_host() {
  local url="$1"
  local rest host

  case "$url" in
    *://*)
      # https://user@host/path or ssh://git@host:port/path
      rest="${url#*://}"
      rest="${rest%%/*}"
      rest="${rest##*@}"
      host="${rest%%:*}"
      ;;
    *@*:*)
      # git@host:owner/repo.git の形式
      rest="${url#*@}"
      host="${rest%%:*}"
      ;;
    *)
      host=""
      ;;
  esac

  printf '%s\n' "$host"
}

# host が GitHub のホスト名か
is_github_host() {
  case "$1" in
    github.com|ssh.github.com) return 0 ;;
    *) return 1 ;;
  esac
}

# origin など主要 remote を順に見て、最初の GitHub remote が見つかったら 0 を返す
github_remote_found() {
  local remote url host

  for remote in origin upstream $(git remote 2>/dev/null); do
    [ -n "$remote" ] || continue

    url="$(git remote get-url "$remote" 2>/dev/null)" || continue
    host="$(remote_host "$url")"
    is_github_host "$host" && return 0
  done

  return 1
}

main() {
  github_remote_found || return 1

  if [ "${1-}" = "--check" ]; then
    return 0
  fi

  # GitHub icon (Nerd Font の nf-fa-github, U+F09B)
  printf ''
}

main "$@"
