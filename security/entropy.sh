#!/bin/sh
# 🦊 Eternum Entropy Monitor [Build Phase: Alpha]
# Zero-trust rule: fail closed if we cannot prove minimum entropy.

set -eu

# Source environment if available (never hard-fail on missing file)
# shellcheck source=core/env.sh
. "$(dirname "$0")/../core/env.sh" 2>/dev/null || true

# Configurable minimum bits (default 256)
MIN_ENTROPY="${ETERNUM_ENTROPY_MIN_BITS:-256}"

# --- helpers ---
is_uint() { case "$1" in (*[!0-9]*|'') return 1;; (*) return 0;; esac; }

ok()   { printf "\033[0;32m[OK]\033[0m %s\n" "$*"; }
crit() { printf "\033[0;31m\033[1m[CRIT]\033[0m %s\n" "$*"; }

# Convert hex string length to bits (2 hex chars = 1 byte = 8 bits)
hex_bits() {
  h="$1"
  # strip whitespace/newlines
  h="$(printf '%s' "$h" | tr -d ' \t\r\n')"
  n="$(printf '%s' "$h" | wc -c | tr -d ' ')"
  # if odd length or empty -> 0 bits
  if ! is_uint "$n" || [ "$n" -eq 0 ] || [ $((n % 2)) -ne 0 ]; then
    printf '%s' "0"
    return 0
  fi
  printf '%s' "$(( (n / 2) * 8 ))"
}

verify_entropy_linux_proc() {
  if [ -r /proc/sys/kernel/random/entropy_avail ]; then
    avail="$(cat /proc/sys/kernel/random/entropy_avail 2>/dev/null || printf '0')"
    if ! is_uint "$avail"; then avail="0"; fi

    if [ "$avail" -ge "$MIN_ENTROPY" ]; then
      ok "Entropy Pool Sufficient (Linux /proc): ${avail} (Threshold: ${MIN_ENTROPY})"
      return 0
    fi
    crit "Entropy Depleted (Linux /proc): ${avail} (Threshold: ${MIN_ENTROPY}). Operations unsafe."
    return 1
  fi
  return 2
}

verify_entropy_portable() {
  # Portable proof-of-entropy for macOS and other environments:
  # require a minimum-bit cryptographic value present in env, preferring HMAC
  if [ -n "${ETERNUM_VERIFY_HMAC:-}" ]; then
    bits="$(hex_bits "${ETERNUM_VERIFY_HMAC}")"
    if [ "$bits" -ge "$MIN_ENTROPY" ]; then
      ok "Entropy Proof Sufficient (HMAC): ${bits} bits (Threshold: ${MIN_ENTROPY})"
      return 0
    fi
    crit "Entropy Proof Insufficient (HMAC): ${bits} bits (Threshold: ${MIN_ENTROPY}). Operations unsafe."
    return 1
  fi

  # fallback: shared secret length in bytes -> bits (better than nothing, still explicit)
  if [ -n "${ETERNUM_SHARED_SECRET:-}" ]; then
    bytes="$(printf '%s' "${ETERNUM_SHARED_SECRET}" | wc -c | tr -d ' ')"
    if ! is_uint "$bytes"; then bytes="0"; fi
    bits="$((bytes * 8))"
    if [ "$bits" -ge "$MIN_ENTROPY" ]; then
      ok "Entropy Proof Sufficient (shared secret length): ${bits} bits (Threshold: ${MIN_ENTROPY})"
      return 0
    fi
    crit "Entropy Proof Insufficient (shared secret length): ${bits} bits (Threshold: ${MIN_ENTROPY}). Operations unsafe."
    return 1
  fi

  crit "Entropy check failed: no entropy source detected (ETERNUM_VERIFY_HMAC / ETERNUM_SHARED_SECRET missing)."
  return 1
}

verify_entropy() {
  # Validate MIN_ENTROPY
  if ! is_uint "$MIN_ENTROPY" || [ "$MIN_ENTROPY" -le 0 ]; then
    crit "Invalid MIN_ENTROPY: ${MIN_ENTROPY}"
    return 1
  fi

  # Try Linux proc method first if available; otherwise portable proof
  verify_entropy_linux_proc && return 0
  rc=$?
  if [ "$rc" -eq 2 ]; then
    verify_entropy_portable
    return $?
  fi
  return "$rc"
}

# Auto-execute if run directly
if [ "$(basename "$0")" = "entropy.sh" ]; then
  verify_entropy
fi
