#!/bin/sh
# 🦊 Eternum Kernel Init (Alpha)
# Zero-trust bootstrap: entropy gate + HMAC verification gate.

set -eu

. "$(dirname "$0")/env.sh" 2>/dev/null || true

ok()   { printf "\033[0;32m[OK]\033[0m %s\n" "$*"; }
info() { printf "\033[0;36m[INFO]\033[0m %s\n" "$*"; }
crit() { printf "\033[0;31m\033[1m[CRIT]\033[0m %s\n" "$*"; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENTROPY="${ROOT}/security/entropy.sh"
VERIFY="${ROOT}/security/verify.sh"

require_cmd() { command -v "$1" >/dev/null 2>&1 || { crit "Missing required command: $1"; exit 1; }; }

main() {
  info "🦊 Eternum Kernel Initializing (zero-trust)..."

  require_cmd openssl
  require_cmd od
  require_cmd awk

  if [ ! -x "$ENTROPY" ]; then crit "Missing entropy gate: $ENTROPY"; exit 1; fi
  if [ ! -x "$VERIFY" ]; then crit "Missing verify gate:  $VERIFY"; exit 1; fi

  # 1) Entropy gate (portable)
  "$ENTROPY" || { crit "Entropy gate failed. Aborting."; exit 1; }

  # 2) Verification gate: require env vars
  if [ -z "${ETERNUM_SHARED_SECRET:-}" ]; then crit "ETERNUM_SHARED_SECRET is required."; exit 1; fi
  if [ -z "${ETERNUM_VERIFY_PAYLOAD:-}" ]; then crit "ETERNUM_VERIFY_PAYLOAD is required."; exit 1; fi
  if [ -z "${ETERNUM_VERIFY_HMAC:-}" ]; then crit "ETERNUM_VERIFY_HMAC is required."; exit 1; fi

  "$VERIFY" "${ETERNUM_VERIFY_PAYLOAD}" "${ETERNUM_SHARED_SECRET}" "${ETERNUM_VERIFY_HMAC}" || {
    crit "Verification gate failed. Aborting."
    exit 1
  }

  ok "Bootstrap Complete. Security gates passed."
}

main "$@"
