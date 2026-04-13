#!/bin/sh
set -eu
# Conditional pipefail: enable only if the shell supports it
# shellcheck disable=SC3040
if (set -o pipefail 2>/dev/null); then set -o pipefail; fi

# Source the environment
ETERNUM_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ETERNUM_ROOT
. "${ETERNUM_ROOT}/core/env.sh"

trap 'log_crit "Signal Interrupted."; exit 0' INT TERM

log_info "🦊 Eternum Kernel v${VERSION} Initializing..."
log_ok "Frequency Locked: ${SIGNAL_FREQ}"

CORES=$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
log_info "Synchronizing on ${CORES} CPU cores."

log_ok "Bootstrap Complete. Awaiting Security Gate."
