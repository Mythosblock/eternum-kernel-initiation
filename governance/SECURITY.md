# Security Policy: Eternum Kernel

## Supported Versions

| Version | Supported |
|---|---|
| Build Phase Alpha (current) | ✅ |

---

## Reporting a Vulnerability

The Eternum Kernel follows **responsible disclosure**.

**Do not open a public GitHub issue for security vulnerabilities.**

### Disclosure Process

1. **Encrypt your report** using the project maintainer's GPG public key,  
   available at `https://keys.openpgp.org`.

2. **Submit via GitHub Security Advisories** (private):  
   Navigate to `Security → Advisories → New draft security advisory`  
   in this repository.

3. Include in your report:
   - Affected component (e.g., `security/verify.sh`, `core/env.sh`)
   - Reproduction steps (minimum reproducible example in POSIX sh)
   - Proposed severity (CVSS v3 if possible)
   - Any suggested remediation

4. You will receive acknowledgement within **72 hours**.

5. A coordinated disclosure timeline will be agreed upon before any  
   public announcement. Reporters who follow this process will be  
   credited in the release notes unless they request anonymity.

---

## Security Architecture

### Threat Model

| Threat | Mitigation |
|---|---|
| Dependency confusion / supply chain | Zero-dependency policy; no package managers |
| Interpreter substitution | POSIX-strict scripts; `shellcheck --shell=sh` CI gate |
| Secret leakage in commits | Automated high-entropy string scanning in CI |
| Tag-moving attacks on CI actions | SHA-pinned `actions/checkout` |
| TOCTOU PATH hijacking | `export PATH=/usr/bin:/bin:/usr/sbin:/sbin` in all scripts |
| Timing side-channels in HMAC comparison | Constant-time character comparison in `verify.sh` |
| Social engineering of contributors | GPG-signed Ritual Manifest; no off-platform vetting |

### Authentication

The verification gate in `security/verify.sh` uses:

- **HMAC-SHA256** over a caller-provided payload
- A shared secret supplied via the `ETERNUM_SHARED_SECRET` environment variable
  (never stored in the repository)
- A **constant-time string comparison** to prevent timing oracle attacks

The expected HMAC is provided externally via `ETERNUM_VERIFY_HMAC`.

---

## Hall of Recognition

Contributors who responsibly disclose valid vulnerabilities will be listed here  
(with their consent):

*(none yet — be the first)*
