# Security Hardening Review

## Objective
Establish a stricter activation-path review standard for the repository.

## Controls
- explicit branch isolation from main
- no blind staging
- staged diff review before commit
- signed commit verification where available
- no PR creation unless branch is ahead of main

## Zero-Trust Commit Protocol
1. fetch and fast-forward main
2. create fresh feature branch from updated main
3. make only intended changes
4. inspect unstaged diff
5. stage only intended files
6. inspect staged diff
7. commit with precise scope
8. verify branch is ahead of main
9. push branch
10. create PR only when a real diff exists

## Notes
This document tracks the hardening posture introduced for issue 1.
