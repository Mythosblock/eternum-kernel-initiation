#!/bin/sh
# 🦊 Eternum Shared Environment [Build Phase: Alpha]
# Logic: Provide shared constants and telemetry formatting.

set -euo pipefail

# --- POSIX Visual Constants ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# --- Operational Constants ---
VERSION="1.0.0-alpha"
SIGNAL_FREQ="999"

# --- Shared Telemetry Log ---
log_info() { printf "${CYAN}[INFO]${NC} %s\n" "$1"; }
log_ok() { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
log_crit() { printf "${RED}${BOLD}[CRIT]${NC} %s\n" "$1"; }

# --- Entropy Check ---
check_entropy() {
    _avail=$(cat /proc/sys/kernel/random/entropy_avail 2>/dev/null || echo "N/A (Non-Linux)")
    log_info "Current Entropy Density: $_avail"
}
