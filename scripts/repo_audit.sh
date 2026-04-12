#!/bin/bash
set -euo pipefail
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

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
find . -type f \( -name "*.sh" -o -name "init.sh" \) -print0 | while IFS= read -r -d '' file; do
  bash -n "$file" && echo "OK  $file"
done

printf '\n[4/6] executable bits\n'
find . -type f \( -name "*.sh" -o -name "init.sh" \) -exec chmod +x {} \;

printf '\n[5/6] tracked files overview\n'
git ls-files || true

printf '\n[6/6] ssh origin\n'
git remote -v || true
