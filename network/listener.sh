#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/core/env.sh"

trap 'log_crit "Listener interrupted."; exit 0' INT TERM

probe_port() {
  local host="$1" port="$2"
  if (exec 3<>"/dev/tcp/${host}/${port}") 2>/dev/null; then
    exec 3>&-
    return 0
  fi
  return 1
}

listener_check() {
  local host="${1:-127.0.0.1}" port="${2:-}"
  [ -n "$port" ] || eternum_die "listener_check: port argument required"
  if probe_port "$host" "$port"; then
    log_ok "Port ${port} on ${host}: OPEN"
  else
    log_info "Port ${port} on ${host}: CLOSED/FILTERED"
  fi
}

main() {
  log_info "Network listener gate initializing"
  log_info "Operator : ${ETERNUM_OPERATOR}"
  log_info "Host     : ${ETERNUM_HOSTNAME}"
  log_info "Signal   : ${ETERNUM_SIGNAL}"

  if [ "${#}" -gt 0 ]; then
    listener_check "$@"
  else
    log_ok "Listener gate active — no probe target specified"
  fi
}

main "$@"
