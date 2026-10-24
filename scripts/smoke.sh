#!/usr/bin/env bash
# Smoke test a deployed service. Default target is FEATURE.
# Usage: scripts/smoke.sh [base_url]
set -uo pipefail

base="${1:-https://jsantosc-feature.global.ssl.fastly.net}"
fails=0

# check <path> <expected status> [expected Location]
check() {
  local out status location
  out=$(curl -sS -o /dev/null -w '%{http_code} %{redirect_url}' "$base$1") || { echo "FAIL $1: curl error"; fails=$((fails + 1)); return; }
  status=${out%% *}
  location=${out#* }
  if [[ "$status" != "$2" || ( -n "${3:-}" && "$location" != "$3" ) ]]; then
    echo "FAIL $1: got $status $location, want $2 ${3:-}"
    fails=$((fails + 1))
  else
    echo "ok   $1 -> $status ${3:-}"
  fi
}

check /personal-blog/ 200
check /personal-blog 308 "$base/personal-blog/"
check / 308 "$base/personal-blog/"
check /sitemap.xml 308 "$base/personal-blog/sitemap.xml"
check /test-block 403

exit $((fails > 0))
