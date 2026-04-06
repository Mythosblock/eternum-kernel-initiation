# 🦊 SECURITY — Eternum Kernel

**Model:** Zero-Trust  
**Scope:** All scripts and configuration under this repository

---

## Reporting a Vulnerability

If you discover a security vulnerability, **do not open a public issue**.

1. Open a **GitHub Security Advisory** via the repository's *Security → Advisories → New draft security advisory* page.
2. Include a clear description of the vulnerability, affected file(s), and reproduction steps.
3. A maintainer will acknowledge the report within 72 hours.

## Scope

| Area | File | Risk Level |
|------|------|------------|
| HMAC verification | `security/verify.sh` | Critical |
| Entropy gate | `security/entropy.sh` | High |
| Network probe | `network/listener.sh` | Medium |
| Bootstrap logic | `core/init.sh` | Medium |
| TUI display | `ui/tui.sh` | Low |

## Security Invariants

- `ETERNUM_SHARED_SECRET` must never be stored in the repository or logged.
- All secret comparisons must use `timing_resistant_compare` to prevent timing attacks.
- `PATH` must be locked to `/usr/bin:/bin:/usr/sbin:/sbin` at the top of every script.
- The entropy gate (`security/entropy.sh`) must run before the verification gate.

## Out of Scope

- Issues in third-party tools invoked by the scripts (`openssl`, `awk`, etc.)
- Theoretical attacks requiring physical access to the operator's machine
