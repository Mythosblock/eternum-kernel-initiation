#!/bin/sh
# env.sh — must be sourced; ETERNUM_ROOT must be exported by the caller.
set -eu
# Conditional pipefail: enable only if the shell supports it
# shellcheck disable=SC3040
if (set -o pipefail 2>/dev/null); then set -o pipefail; fi

# Strict PATH lockdown to prevent TOCTOU hijacking
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# ETERNUM_ROOT is set by each calling script before sourcing this file.
# Validate it is present.
[ -n "${ETERNUM_ROOT:-}" ] || { printf '[FATAL] ETERNUM_ROOT not set before sourcing env.sh\n' >&2; exit 1; }

export ETERNUM_SIGNAL="neuromycelial-pulse"
export ETERNUM_OPERATOR="${USER:-unknown}"
ETERNUM_HOSTNAME="$(hostname -s 2>/dev/null || echo unknown-host)"
export ETERNUM_HOSTNAME
ETERNUM_OS="$(uname -s)"
export ETERNUM_OS
ETERNUM_BOOT_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
export ETERNUM_BOOT_TS

export ETERNUM_ENTROPY_MIN_BITS="${ETERNUM_ENTROPY_MIN_BITS:-512}"
export ETERNUM_HMAC_ALGO="${ETERNUM_HMAC_ALGO:-sha256}"
export ETERNUM_TUI_ENABLED="${ETERNUM_TUI_ENABLED:-1}"

export CYAN='\033[0;36m'
export GREEN='\033[0;32m'
export RED='\033[0;31m'
export NC='\033[0m'

eternum_log() { printf "${CYAN}[%s]${NC} %s\n" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$*"; }
eternum_die() { printf "${RED}[FATAL]${NC} %s\n" "$*" >&2; exit 1; }
eternum_require_cmd() { command -v "$1" >/dev/null 2>&1 || eternum_die "missing required command: $1"; }

case "${ETERNUM_OS}" in
  Darwin|Linux) ;;
  *) eternum_die "Unsupported OS: ${ETERNUM_OS}. Alpha targets Darwin/Linux only." ;;
esac
