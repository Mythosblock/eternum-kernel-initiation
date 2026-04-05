#!/bin/sh
# 🦊 Eternum Stateless Verification [Build Phase: Alpha]
# Constant-time HMAC gate using awk and openssl.

set -euo pipefail

# Safely source environment if available
. "$(dirname "$0")/../core/env.sh" 2>/dev/null || true

verify_token() {
    token="$1"
    secret="$2"
    
    # Generate expected HMAC, convert to hex using POSIX 'od'
    expected=$(printf "%s" "$token" | openssl dgst -sha256 -hmac "$secret" -binary | od -An -v -tx1 | tr -d ' \n')
    
    # Constant-time comparison simulation in awk to prevent timing attacks
    awk -v a="$token" -v b="$expected" 'BEGIN {
        if (length(a) != length(b)) { exit 1 }
        res = 0
        for (i=1; i<=length(a); i++) {
            res += (substr(a, i, 1) != substr(b, i, 1))
        }
        exit (res != 0)
    }'
}

# Allow direct execution testing
if [ "$#" -eq 2 ]; then
    if verify_token "$1" "$2"; then
        printf "\033[0;32m[OK]\033[0m Token Verified.\n"
        exit 0
    else
        printf "\033[0;31m\033[1m[CRIT]\033[0m Token Rejected.\n"
        exit 1
    fi
fi
