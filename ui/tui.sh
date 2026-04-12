#!/bin/bash
set -euo pipefail
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/core/env.sh"

draw_line() {
  printf '%*s\n' "${1:-64}" '' | tr ' ' '='
}

render() {
  clear || true
  draw_line 72
  printf ' ETERNUM ALLIANCE TELEMETRY :: %s\n' "${ETERNUM_SIGNAL}"
  draw_line 72
  printf ' Operator   : %s\n' "${ETERNUM_OPERATOR}"
  printf ' Host       : %s\n' "${ETERNUM_HOSTNAME}"
  printf ' Boot Time  : %s\n' "${ETERNUM_BOOT_TS}"
  printf ' Entropy Min: %s bits\n' "${ETERNUM_ENTROPY_MIN_BITS}"
  printf ' HMAC Algo  : %s\n' "${ETERNUM_HMAC_ALGO}"
  printf ' Repo Root  : %s\n' "${ETERNUM_ROOT}"
  draw_line 72
  printf ' Status     : LOCKED\n'
  printf ' Alignment  : 100%%\n'
  printf ' Phase      : BUILD PHASE ALPHA\n'
  draw_line 72
}

main() {
  render
  if [ "${ETERNUM_TUI_ENABLED}" = "1" ]; then
    while :; do
      sleep 5
    done
  fi
}

main "$@"
