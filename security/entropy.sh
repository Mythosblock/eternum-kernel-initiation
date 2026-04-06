#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

MIN_BITS="${ETERNUM_ENTROPY_MIN_BITS:-256}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[ERROR] Required command not found: $1" >&2
    exit 1
  }
}

require_cmd openssl
require_cmd wc
require_cmd tr

entropy_hex="${1:-${ETERNUM_ENTROPY_HEX:-}}"

if [ -z "${entropy_hex}" ]; then
  echo "[ERROR] No entropy provided." >&2
  echo "Usage: $0 <hex-string>" >&2
  echo "   or: export ETERNUM_ENTROPY_HEX='<hex>' && $0" >&2
  exit 1
fi

clean_hex="$(printf '%s' "${entropy_hex}" | tr -d '[:space:]')"

case "${clean_hex}" in
  *[!0-9a-fA-F]*)
    echo "[ERROR] Entropy must be hex." >&2
    exit 1
    ;;
esac

hex_len="$(printf '%s' "${clean_hex}" | wc -c | tr -d ' ')"
if [ "${hex_len}" -eq 0 ]; then
  echo "[ERROR] Entropy is empty." >&2
  exit 1
fi

if [ $((hex_len % 2)) -ne 0 ]; then
  echo "[ERROR] Hex length must be even." >&2
  exit 1
fi

bit_len=$((hex_len * 4))

if [ "${bit_len}" -lt "${MIN_BITS}" ]; then
  echo "[ERROR] Entropy Proof Insufficient: ${bit_len} bits (Threshold: ${MIN_BITS})" >&2
  exit 1
fi

fingerprint="$(printf '%s' "${clean_hex}" | openssl dgst -sha256 | awk '{print $NF}')"

echo "[OK] Entropy Proof Sufficient: ${bit_len} bits (Threshold: ${MIN_BITS})"
echo "[INFO] Entropy Fingerprint (SHA-256): ${fingerprint}"
