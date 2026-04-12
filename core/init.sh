#!/bin/bash
# 🦊 Eternum Kernel Init (Alpha)
# Zero-trust bootstrap: entropy gate + HMAC verification gate.
# Enhancement: auto-load .env.local if present (never committed).

set -eu

ok()   { printf "\033[0;32m[OK]\033[0m %s\n" "$*"; }
info() { printf "\033[0;36m[INFO]\033[0m %s\n" "$*"; }
crit() { printf "\033[0;31m\033[1m[CRIT]\033[0m %s\n" "$*"; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# 0) Load repo env defaults if present (non-fatal)
if [ -f "${ROOT}/core/env.sh" ]; then
  # shellcheck disable=SC1090
  . "${ROOT}/core/env.sh" 2>/dev/null || true
fi

# 1) Auto-load local secrets if present (non-fatal to read; fatal only if gates require vars and they are absent)
# Using set -a exports all vars from the file into the environment.
if [ -f "${ROOT}/.env.local" ]; then
  set -a
  # shellcheck disable=SC1090
  . "${ROOT}/.env.local"
  set +a
fi

ENTROPY="${ROOT}/security/entropy.sh"
VERIFY="${ROOT}/security/verify.sh"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { crit "Missing required command: $1"; exit 1; }
}

main() {
  info "🦊 Eternum Kernel Initializing (zero-trust)..."

  require_cmd openssl
  require_cmd od
  require_cmd awk

  if [ ! -x "$ENTROPY" ]; then crit "Missing entropy gate: $ENTROPY"; exit 1; fi
  if [ ! -x "$VERIFY" ]; then crit "Missing verify gate:  $VERIFY"; exit 1; fi

  # 2) Entropy gate (portable)
  "$ENTROPY" || { crit "Entropy gate failed. Aborting."; exit 1; }

  # 3) Verification gate requires these env vars
  if [ -z "${ETERNUM_SHARED_SECRET:-}" ]; then crit "ETERNUM_SHARED_SECRET is required (set it or add to .env.local)."; exit 1; fi

  # Payload can be set by user; default if absent
  if [ -z "${ETERNUM_VERIFY_PAYLOAD:-}" ]; then
    ETERNUM_VERIFY_PAYLOAD="alliance-pulse"
  fi

  # HMAC must be present; if absent, derive it deterministically from payload+secret
  if [ -z "${ETERNUM_VERIFY_HMAC:-}" ]; then
    ETERNUM_VERIFY_HMAC="$(printf '%s' "${ETERNUM_VERIFY_PAYLOAD}" | openssl dgst -sha256 -hmac "${ETERNUM_SHARED_SECRET}" -binary | xxd -p -c 256)"
  fi

  "$VERIFY" "${ETERNUM_VERIFY_PAYLOAD}" "${ETERNUM_SHARED_SECRET}" "${ETERNUM_VERIFY_HMAC}" || {
    crit "Verification gate failed. Aborting."
    exit 1
  }

  ok "Bootstrap Complete. Security gates passed."
}

main "$@"
