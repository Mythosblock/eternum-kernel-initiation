#!/bin/sh
set -eu
# Conditional pipefail: enable only if the shell supports it
# shellcheck disable=SC3040
if (set -o pipefail 2>/dev/null); then set -o pipefail; fi
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
ETERNUM_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ETERNUM_ROOT
cd "${ETERNUM_ROOT}"

printf '\n[1/6] git status\n'
git status --short || true

printf '\n[2/6] secret scan\n'
if grep -RInE '(PRIVATE_KEY|BEGIN [A-Z ]*PRIVATE KEY|API_KEY=|SECRET=|TOKEN=|PASSWORD=)' . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=.venv \
  --exclude='*.png' \
  --exclude='*.jpg' \
  --exclude='*.jpeg' \
  --exclude='*.gif'; then
  echo "Potential secret material detected. Review before push."
else
  echo "No obvious secret material detected."
fi

printf '\n[3/6] shell syntax check\n'
find . -type f \( -name "*.sh" -o -name "init.sh" \) | while IFS= read -r file; do
  sh -n "$file" && echo "OK  $file"
done

printf '\n[4/6] executable bits\n'
find . -type f \( -name "*.sh" -o -name "init.sh" \) -exec chmod +x {} \;

printf '\n[5/6] tracked files overview\n'
git ls-files || true

printf '\n[6/6] ssh origin\n'
git remote -v || true
