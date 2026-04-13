#!/bin/sh
set -eu
# Conditional pipefail: enable only if the shell supports it
# shellcheck disable=SC3040
if (set -o pipefail 2>/dev/null); then set -o pipefail; fi
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
ETERNUM_ROOT="$(cd "$(dirname "$0")" && pwd)"
export ETERNUM_ROOT
. "${ETERNUM_ROOT}/core/env.sh"

eternum_require_cmd bash
eternum_require_cmd awk
eternum_require_cmd openssl
eternum_require_cmd xxd

"${ETERNUM_ROOT}/security/entropy.sh"

if [ -n "${ETERNUM_VERIFY_PAYLOAD:-}" ] && [ -n "${ETERNUM_VERIFY_HMAC:-}" ]; then
  "${ETERNUM_ROOT}/security/verify.sh" "${ETERNUM_VERIFY_PAYLOAD}" "${ETERNUM_VERIFY_HMAC}"
else
  eternum_log "verification gate skipped (set ETERNUM_VERIFY_PAYLOAD and ETERNUM_VERIFY_HMAC to enable)"
fi

if [ "${ETERNUM_TUI_ENABLED}" = "1" ]; then
  "${ETERNUM_ROOT}/ui/tui.sh"
else
  eternum_log "tui disabled"
fi
