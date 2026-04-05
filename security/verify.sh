#!/bin/sh
set -euo pipefail
verify_token() {
    token="$1"
    secret="$2"
    expected=$(printf "%s" "$token" | openssl dgst -sha256 -hmac "$secret" -binary | od -An -v -tx1 | tr -d ' \n')
    awk -v a="$token" -v b="$expected" 'BEGIN {
        if (length(a) != length(b)) { exit 1 }
        res = 0
        for (i=1; i<=length(a); i++) { res += (substr(a, i, 1) != substr(b, i, 1)) }
        exit (res != 0)
    }'
}
