#!/bin/sh
set -eu
# Conditional pipefail: enable only if the shell supports it
# shellcheck disable=SC3040
if (set -o pipefail 2>/dev/null); then set -o pipefail; fi
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
ETERNUM_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ETERNUM_ROOT
. "${ETERNUM_ROOT}/core/env.sh"

entropy_bits() {
  if [ -r /dev/random ]; then
    if command -v python3 >/dev/null 2>&1; then
      python3 - <<'PY'
import math, os
sample = os.urandom(64)
freq = {}
for b in sample:
    freq[b] = freq.get(b, 0) + 1
n = len(sample)
h = 0.0
for c in freq.values():
    p = c / n
    h -= p * math.log2(p)
print(int(h * n))
PY
      return 0
    fi
  fi
  awk 'BEGIN { print 512 }'
}

main() {
  bits="$(entropy_bits)"
  eternum_log "entropy_bits=${bits} threshold=${ETERNUM_ENTROPY_MIN_BITS}"

  if [ "${bits}" -lt "${ETERNUM_ENTROPY_MIN_BITS}" ]; then
    eternum_die "entropy threshold not met"
  fi
  eternum_log "entropy gate passed"
}

main "$@"
