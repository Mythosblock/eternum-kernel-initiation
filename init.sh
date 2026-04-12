#!/bin/bash
set -euo pipefail
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${ROOT_DIR}/core/env.sh"

eternum_require_cmd bash
eternum_require_cmd awk
eternum_require_cmd openssl
eternum_require_cmd xxd

"${ROOT_DIR}/security/entropy.sh"

if [ -n "${ETERNUM_VERIFY_PAYLOAD:-}" ] && [ -n "${ETERNUM_VERIFY_HMAC:-}" ]; then
  "${ROOT_DIR}/security/verify.sh" "${ETERNUM_VERIFY_PAYLOAD}" "${ETERNUM_VERIFY_HMAC}"
else
  eternum_log "verification gate skipped (set ETERNUM_VERIFY_PAYLOAD and ETERNUM_VERIFY_HMAC to enable)"
fi

if [ "${ETERNUM_TUI_ENABLED}" = "1" ]; then
  "${ROOT_DIR}/ui/tui.sh"
else
  eternum_log "tui disabled"
fi
