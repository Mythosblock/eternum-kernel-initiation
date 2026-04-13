#!/bin/bash
set -euo pipefail
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/core/env.sh"

timing_resistant_compare() {
  [ "${#1}" -eq "${#2}" ] || return 1
  local a="$1" b="$2" i=0 diff=0 oa ob
  while [ "$i" -lt "${#a}" ]; do
    oa=$(printf '%d' "'${a:$i:1}")
    ob=$(printf '%d' "'${b:$i:1}")
    diff=$(( diff | (oa ^ ob) ))
    i=$(( i + 1 ))
  done
  [ "$diff" -eq 0 ]
}

hmac_hex() {
  local data="$1"
  eternum_require_cmd python3
  printf '%s' "$data" | python3 -c '
import hashlib
import hmac
import os
import sys

try:
    digest = getattr(hashlib, os.environ["ETERNUM_HMAC_ALGO"])
except (AttributeError, KeyError) as exc:
    raise SystemExit(
        "unsupported HMAC algorithm: {}".format(os.environ.get("ETERNUM_HMAC_ALGO", exc))
    )

try:
    sys.stdout.write(
        hmac.new(
            os.environ["ETERNUM_SHARED_SECRET"].encode(),
            sys.stdin.buffer.read(),
            digest,
        ).hexdigest()
    )
except KeyError as exc:
    raise SystemExit(f"missing environment variable: {exc.args[0]}")
' || eternum_die "failed to compute HMAC"
}

main() {
  local payload="${1:-}" provided="${2:-}"
  [ -n "$payload" ] || eternum_die "usage: security/verify.sh <payload> <expected_hmac_hex>"
  [ -n "$provided" ] || eternum_die "missing expected hmac"
  [ -n "${ETERNUM_SHARED_SECRET:-}" ] || eternum_die "ETERNUM_SHARED_SECRET is not set"

  local calculated
  calculated="$(hmac_hex "$payload")"

  if timing_resistant_compare "$calculated" "$provided"; then
    eternum_log "verification gate passed"
    exit 0
  fi
  eternum_die "verification gate failed"
}

main "$@"
