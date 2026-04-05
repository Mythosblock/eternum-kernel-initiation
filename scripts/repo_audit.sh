#!/bin/sh
set -eu

printf '%s\n' "== repo audit =="

printf '%s\n' "-- pwd --"
pwd

printf '%s\n' "-- git status --"
git status --short || true

printf '%s\n' "-- current branch --"
git branch --show-current || true

printf '%s\n' "-- remotes --"
git remote -v || true

printf '%s\n' "-- recent commits --"
git log --oneline --decorate --max-count=5 || true

printf '%s\n' "-- tracked top-level paths --"
find . -maxdepth 2 -type f | sort

printf '%s\n' "== audit complete =="
