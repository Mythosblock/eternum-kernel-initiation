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
  local key="$1" data="$2"
  eternum_require_cmd python3
  printf '%s' "$data" | _HMAC_KEY="$key" _HMAC_ALGO="${ETERNUM_HMAC_ALGO}" python3 -c "
import hashlib
import hmac
import os
import sys
key = os.environ['_HMAC_KEY'].encode()
algo = os.environ.get('_HMAC_ALGO', 'sha256')
allowed = {'sha256', 'sha384', 'sha512', 'sha3_256', 'sha3_512'}
if algo not in allowed:
    sys.exit('unsupported HMAC algorithm: ' + algo)
data = sys.stdin.buffer.read()
sys.stdout.write(hmac.new(key, data, getattr(hashlib, algo)).hexdigest())
"
}

main() {
  local payload="${1:-}" provided="${2:-}" secret="${ETERNUM_SHARED_SECRET:-}"
  [ -n "$payload" ] || eternum_die "usage: security/verify.sh <payload> <expected_hmac_hex>"
  [ -n "$provided" ] || eternum_die "missing expected hmac"
  [ -n "$secret" ] || eternum_die "ETERNUM_SHARED_SECRET is not set"

  local calculated
  calculated="$(hmac_hex "$secret" "$payload")"

  if timing_resistant_compare "$calculated" "$provided"; then
    eternum_log "verification gate passed"
    exit 0
  fi
  eternum_die "verification gate failed"
}

main "$@"
