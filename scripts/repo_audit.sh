#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

printf '%s\n' "== repo audit =="

printf '\n[1/9] pwd\n'
pwd

printf '\n[2/9] git status\n'
git status --short || true

printf '\n[3/9] current branch\n'
git branch --show-current || true

printf '\n[4/9] remotes\n'
git remote -v || true

printf '\n[5/9] recent commits\n'
git log --oneline --decorate --max-count=5 || true

printf '\n[6/9] secret scan\n'
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

printf '\n[7/9] shell syntax check\n'
find . -type f \( -name "*.sh" -o -name "init.sh" \) -print0 | while IFS= read -r -d '' file; do
  bash -n "$file" && echo "OK  $file"
done

printf '\n[8/9] executable bits\n'
find . -type f \( -name "*.sh" -o -name "init.sh" \) -exec chmod +x {} \;

printf '\n[9/9] tracked files overview\n'
git ls-files || true

printf '\n== audit complete ==\n'
