# Manifesto: The Eternum Kernel

> *"The kernel does not ask for your trust. It earns it through reproducible proofs."*

---

## I. Sovereign Computation

The Eternum Kernel exists to demonstrate that software systems do not require  
sprawling runtimes, opaque frameworks, or cloud-managed identity providers  
to be secure, reproducible, and auditable.

A script that requires nothing beyond a POSIX shell is a script that cannot be  
hijacked at the dependency layer. Zero-dependency is not a constraint — it is  
a guarantee.

## II. The Zero-Trust Axiom

Every component of the kernel treats all inputs as hostile until proven otherwise:

- Inputs are validated before use
- Secrets are never stored in plain text; they are derived at runtime via HMAC
- File paths are computed from `$0`, never from environment-injected strings
- The `PATH` is locked at execution start to prevent TOCTOU substitution attacks

Trust is not extended — it is earned through cryptographic proof.

## III. POSIX as a Security Boundary

The POSIX standard is not merely a portability constraint. It is a **threat surface  
reduction** strategy:

- Bash extensions introduce behavioral differences between interpreters
- Behavioral differences are attack surface
- A script that runs identically under `dash`, `ash`, and `sh` is a script  
  whose behavior cannot be subverted by interpreter substitution

This is why `shellcheck --shell=sh` is the law.

## IV. Supply-Chain Integrity

The kernel's CI pipeline enforces:

1. **SHA-pinned actions** — no tag-moving attacks on `actions/checkout`
2. **Full clone depth** — `git diff` has access to complete history for audit
3. **ShellCheck in POSIX mode** — no bash-isms survive to production
4. **Secret scanning** — high-entropy strings in commits trigger CI failure

Every build is a signed, reproducible artifact. Every contributor is a verified  
signatory. No exceptions.

## V. The 1% Vetting

Only operators who demonstrate cryptographic competence are admitted to  
the contributor pool. This is not elitism — it is signal filtering.

The vetting process is described in `governance/CONTRIBUTING.md`.  
It requires no video calls, no social proof, and no trust.  
It requires a GPG key and a correctly signed manifest.

This is the only gate that matters.

---

*Eternum Kernel — Build Phase Alpha*
