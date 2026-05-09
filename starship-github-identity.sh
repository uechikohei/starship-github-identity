#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# starship-github-identity.sh
#
# starship の [custom.github_remote] モジュールから呼び出して、
# git remote が GitHub のときだけ Nerd Font の GitHub icon と
# `git config user.name` を prompt に表示するためのスクリプト。
#
# 詳しい使い方: https://321dev.org/ja/blog/tips/starship-github-account
#
# 使い方:
#   --check : 表示判定のみ (exit 0 で表示する)。starship の `when` から呼ぶ
#   (引数なし)  : 表示文字列を stdout に出力する。starship の `command` から呼ぶ

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
    *:*)
      # host:path 形式 (古い scp 風)
      rest="${url%%:*}"
      case "$rest" in
        */*|"")
          host=""
          ;;
        *)
          host="$rest"
          ;;
      esac
      ;;
    *)
      host=""
      ;;
  esac

  printf '%s\n' "$host"
}

# Host alias を ssh -G で実ホスト名に解決する
ssh_hostname() {
  local host="$1"

  ssh -G "$host" 2>/dev/null | awk '
    tolower($1) == "hostname" {
      print tolower($2)
      exit
    }
  '
}

# host が GitHub の本物のホスト名か (alias なら ssh -G で解決して再判定)
is_github_host() {
  local host="$1"
  local resolved

  case "$host" in
    github.com|ssh.github.com)
      return 0
      ;;
    "")
      return 1
      ;;
  esac

  resolved="$(ssh_hostname "$host")"
  case "$resolved" in
    github.com|ssh.github.com)
      return 0
      ;;
  esac

  return 1
}

# origin など主要 remote を順に見て、最初の GitHub remote の URL を返す
github_remote_url() {
  local remote url host

  for remote in origin upstream $(git remote 2>/dev/null); do
    [ -n "$remote" ] || continue

    url="$(git remote get-url "$remote" 2>/dev/null)" || continue
    host="$(remote_host "$url")"
    if is_github_host "$host"; then
      printf '%s\n' "$url"
      return 0
    fi
  done

  return 1
}

main() {
  local name

  github_remote_url >/dev/null || return 1

  if [ "${1-}" = "--check" ]; then
    return 0
  fi

  name="$(git config --get user.name 2>/dev/null || true)"
  if [ -n "$name" ]; then
    # 先頭の文字は Nerd Font の nf-fa-github (U+F09B)
    printf ' %s' "$name"
  else
    printf ''
  fi
}

main "$@"
