# Core Activation Hardening

This file records the operating principles for hardened activation behavior.

## Guardrails
- fail closed where validation is incomplete
- require explicit review before activation-related changes
- minimize implicit behavior
- preserve auditability of branch, diff, and commit state

## Commit Discipline
Activation-related changes must be:
- isolated on a feature branch
- reviewed unstaged and staged
- committed with precise scope
- pushed only after ahead-of-main verification
