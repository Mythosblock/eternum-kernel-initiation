#!/bin/sh
set -eu
# Conditional pipefail: enable only if the shell supports it
# shellcheck disable=SC3040
if (set -o pipefail 2>/dev/null); then set -o pipefail; fi
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
ETERNUM_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ETERNUM_ROOT
. "${ETERNUM_ROOT}/core/env.sh"

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
  trap 'printf "\033[0m\n"; printf "Initiation Interrupted\n" >&2; exit 0' INT TERM
  render
  if [ "${ETERNUM_TUI_ENABLED}" = "1" ]; then
    while :; do
      sleep 5
    done
  fi
}

main "$@"
