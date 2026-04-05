#!/bin/sh
set -euo pipefail
trap 'echo "Signal interrupted."; exit 0' INT TERM
CORES=$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
nodes="alpha beta gamma"
for node in $nodes; do
    printf "[INIT] Syncing %s on %s cores...\n" "$node" "$CORES"
done
