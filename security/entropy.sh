#!/bin/sh
# 🦊 Eternum Entropy Monitor [Build Phase: Alpha]
# Logic: Verify cryptographic foundation before operations.

set -euo pipefail

# Safely source environment if available
. "$(dirname "$0")/../core/env.sh" 2>/dev/null || true

# Minimum required entropy for secure cryptographic operations
MIN_ENTROPY=256

verify_entropy() {
    avail=$(cat /proc/sys/kernel/random/entropy_avail 2>/dev/null || echo "0")
    
    if [ "$avail" -ge "$MIN_ENTROPY" ]; then
        printf "\033[0;32m[OK]\033[0m Entropy Pool Sufficient: %s (Threshold: %s)\n" "$avail" "$MIN_ENTROPY"
        return 0
    else
        printf "\033[0;31m\033[1m[CRIT]\033[0m Entropy Depleted: %s (Threshold: %s). Operations unsafe.\n" "$avail" "$MIN_ENTROPY"
        return 1
    fi
}

# Auto-execute if run directly
if [ "$(basename "$0")" = "entropy.sh" ]; then
    verify_entropy
fi
