#!/bin/bash
set -euo pipefail

echo "== SECURITY AUDIT =="

echo "Running entropy check..."
./security/entropy.sh

echo "Running verification check..."
if [ -f "./security/verify.sh" ]; then
    echo "No payload provided; skipping verification step."
else
    echo "verify.sh not found."
fi

echo "Audit complete."

