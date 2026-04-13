#!/bin/sh
# 🦊 Eternum Stateless Verification [Build Phase: Alpha]
# Constant-time HMAC gate (portable macOS/Linux).
# Usage:
#   ./security/verify.sh "<payload>" "<shared_secret>" "<provided_hmac_hex>"
#
# Notes:
# - provided_hmac_hex must be lowercase hex (we normalize).
# - This is a *verification gate*: fail closed on any parsing/compute error.

set -eu

# Safely source environment if available
# shellcheck source=core/env.sh
. "$(dirname "$0")/../core/env.sh" 2>/dev/null || true

ok()   { printf "\033[0;32m[OK]\033[0m %s\n" "$*"; }
crit() { printf "\033[0;31m\033[1m[CRIT]\033[0m %s\n" "$*"; }

to_hex() {
  # stdin -> hex (no spaces/newlines)
  # od is POSIX; tr removes spaces/newlines.
  od -An -v -tx1 | tr -d ' \n'
}

norm_hex() {
  # normalize hex string: strip whitespace, lowercase
  printf '%s' "$1" | tr -d ' \t\r\n' | tr '[:upper:]' '[:lower:]'
}

ct_eq_hex() {
  # constant-time-ish compare for same-length hex strings using awk
  a="$(norm_hex "$1")"
  b="$(norm_hex "$2")"

  # must be same length and non-empty
  if [ -z "$a" ] || [ -z "$b" ]; then return 1; fi
  if [ "${#a}" -ne "${#b}" ]; then return 1; fi

  awk -v a="$a" -v b="$b" 'BEGIN{
    res=0
    for(i=1;i<=length(a);i++){
      res += (substr(a,i,1) != substr(b,i,1))
    }
    exit(res!=0)
  }'
}

expected_hmac_hex() {
  payload="$1"
  secret="$2"

  # openssl prints binary digest, convert to hex
  # If openssl fails, propagate failure (set -e)
  printf '%s' "$payload" | openssl dgst -sha256 -hmac "$secret" -binary | to_hex
}

verify_token() {
  payload="$1"
  secret="$2"
  provided="$3"

  if [ -z "$payload" ] || [ -z "$secret" ] || [ -z "$provided" ]; then
    crit "Missing required input (payload/secret/provided_hmac)."
    return 1
  fi

  exp="$(expected_hmac_hex "$payload" "$secret")"
  prov="$(norm_hex "$provided")"

  if ct_eq_hex "$exp" "$prov"; then
    ok "Token Verified."
    return 0
  fi

  crit "Token Rejected."
  return 1
}

# Allow direct execution
if [ "$#" -eq 3 ]; then
  verify_token "$1" "$2" "$3"
  exit $?
fi

crit "Usage: $0 <payload> <shared_secret> <provided_hmac_hex>"
exit 2
