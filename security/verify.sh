#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[ERROR] Required command not found: $1" >&2
    exit 1
  }
}

require_cmd openssl
require_cmd xxd

SHARED_SECRET="${ETERNUM_SHARED_SECRET:-}"
VERIFY_PAYLOAD="${ETERNUM_VERIFY_PAYLOAD:-}"
EXPECTED_HMAC="${ETERNUM_VERIFY_HMAC:-}"

if [ -z "${SHARED_SECRET}" ]; then
  echo "[ERROR] ETERNUM_SHARED_SECRET is not set." >&2
  exit 1
fi

if [ -z "${VERIFY_PAYLOAD}" ]; then
  echo "[ERROR] ETERNUM_VERIFY_PAYLOAD is not set." >&2
  exit 1
fi

if [ -z "${EXPECTED_HMAC}" ]; then
  echo "[ERROR] ETERNUM_VERIFY_HMAC is not set." >&2
  exit 1
fi

COMPUTED_HMAC="$(
  printf '%s' "${VERIFY_PAYLOAD}" \
    | openssl dgst -sha256 -hmac "${SHARED_SECRET}" -binary \
    | xxd -p -c 256
)"

if [ "${COMPUTED_HMAC}" != "${EXPECTED_HMAC}" ]; then
  echo "[ERROR] Token verification failed." >&2
  echo "[INFO] Computed: ${COMPUTED_HMAC}" >&2
  echo "[INFO] Expected: ${EXPECTED_HMAC}" >&2
  exit 1
fi

echo "[OK] Token Verified."
