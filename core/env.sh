#!/usr/bin/env bash
set -euo pipefail

# Strict PATH lockdown to prevent TOCTOU hijacking
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

_eternum_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ETERNUM_ROOT="${_eternum_root}"
unset _eternum_root

export VERSION="0.1.0"
export ETERNUM_SIGNAL="neuromycelial-pulse"
export SIGNAL_FREQ="${ETERNUM_SIGNAL}"
export ETERNUM_OPERATOR="${USER:-unknown}"

_eternum_hostname="$(hostname -s 2>/dev/null || echo unknown-host)"
export ETERNUM_HOSTNAME="${_eternum_hostname}"
unset _eternum_hostname

_eternum_os="$(uname -s)"
export ETERNUM_OS="${_eternum_os}"
unset _eternum_os

_eternum_boot_ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
export ETERNUM_BOOT_TS="${_eternum_boot_ts}"
unset _eternum_boot_ts

export ETERNUM_ENTROPY_MIN_BITS="${ETERNUM_ENTROPY_MIN_BITS:-512}"
export ETERNUM_HMAC_ALGO="${ETERNUM_HMAC_ALGO:-sha256}"
export ETERNUM_TUI_ENABLED="${ETERNUM_TUI_ENABLED:-1}"

export CYAN='\033[0;36m'
export GREEN='\033[0;32m'
export RED='\033[0;31m'
export YELLOW='\033[0;33m'
export NC='\033[0m'

eternum_log()         { printf "${CYAN}[%s]${NC} %s\n"   "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$*"; }
eternum_die()         { printf "${RED}[FATAL]${NC} %s\n"  "$*" >&2; exit 1; }
eternum_require_cmd() { command -v "$1" >/dev/null 2>&1 || eternum_die "missing required command: $1"; }
log_info()            { printf "${CYAN}[INFO]${NC}  %s\n"  "$*"; }
log_ok()              { printf "${GREEN}[OK]${NC}    %s\n"  "$*"; }
log_crit()            { printf "${RED}[CRIT]${NC}  %s\n"   "$*" >&2; }

if [[ "$ETERNUM_OS" != "Darwin" && "$ETERNUM_OS" != "Linux" ]]; then
  eternum_die "Unsupported OS: $ETERNUM_OS. Alpha targets Darwin/Linux only."
fi
