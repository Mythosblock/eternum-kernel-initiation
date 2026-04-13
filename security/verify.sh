#!/bin/sh
set -eu
# Conditional pipefail: enable only if the shell supports it
# shellcheck disable=SC3040
if (set -o pipefail 2>/dev/null); then set -o pipefail; fi
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
ETERNUM_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ETERNUM_ROOT
. "${ETERNUM_ROOT}/core/env.sh"

timing_resistant_compare() (
  [ "${#1}" -eq "${#2}" ] || return 1
  a="$1" b="$2" i=1 diff=0
  while [ "$i" -le "${#a}" ]; do
    ca=$(printf '%s' "$a" | cut -c"${i}")
    cb=$(printf '%s' "$b" | cut -c"${i}")
    oa=$(printf '%d' "'${ca}")
    ob=$(printf '%d' "'${cb}")
    diff=$(( diff | (oa ^ ob) ))
    i=$(( i + 1 ))
  done
  [ "$diff" -eq 0 ]
)

hmac_hex() (
  key="$1" data="$2"
  eternum_require_cmd openssl
  printf '%s' "$data" | openssl dgst "-${ETERNUM_HMAC_ALGO}" -hmac "$key" -binary | xxd -p -c 256
)

main() {
  payload="${1:-}" provided="${2:-}" secret="${ETERNUM_SHARED_SECRET:-}"
  [ -n "$payload" ] || eternum_die "usage: security/verify.sh <payload> <expected_hmac_hex>"
  [ -n "$provided" ] || eternum_die "missing expected hmac"
  [ -n "$secret" ] || eternum_die "ETERNUM_SHARED_SECRET is not set"

  calculated="$(hmac_hex "$secret" "$payload")"

  if timing_resistant_compare "$calculated" "$provided"; then
    eternum_log "verification gate passed"
    exit 0
  fi
  eternum_die "verification gate failed"
}

main "$@"
