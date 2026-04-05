#!/bin/sh
set -euo pipefail

# Source the environment
. "$(dirname "$0")/env.sh"

trap 'log_crit "Signal Interrupted."; exit 0' INT TERM

log_info "🦊 Eternum Kernel v${VERSION} Initializing..."
log_ok "Frequency Locked: ${SIGNAL_FREQ}"

CORES=$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
log_info "Synchronizing on ${CORES} CPU cores."

log_ok "Bootstrap Complete. Awaiting Security Gate."
