# The Law: Contributing to Eternum Kernel

**Architecture:** Zero-Trust, POSIX-Strict, Zero-Dependency  
**Vetting:** 1% — only operators who prove cryptographic competence are admitted.

---

## The Ritual Manifest (Contributor Vetting)

There are no video calls, no social proofs, no vibes-based trust.  
Entry is granted by **cryptographic proof of work**.

### Step 1 — Forge Your Key

Generate a GPG key whose email matches your GitHub-verified email address:

```sh
gpg --full-generate-key
# Key type: RSA 4096 (or Ed25519 if GPG ≥ 2.1)
# Email: must match your GitHub verified email exactly
```

Export and publish your public key to a keyserver:

```sh
gpg --keyserver hkps://keys.openpgp.org --send-keys <YOUR_KEY_ID>
```

### Step 2 — Sign the Ritual Manifest

Clone the repository, then sign the manifest file at the project root:

```sh
gpg --armor --detach-sign --output ritual-manifest.asc MANIFEST
```

### Step 3 — Submit the Signed Manifest

Open a Pull Request that adds your signature file to `governance/seals/`:

```
governance/seals/<github-username>.asc
```

The file must contain a valid GPG detached signature over the `MANIFEST` file.  
CI will verify the signature and reject any PR where it does not validate.

### Verification Command (reproducible locally)

```sh
gpg --verify governance/seals/<github-username>.asc MANIFEST
```

This replaces all off-platform vetting meetings. If you can sign the manifest,  
you understand the tools. The kernel does not negotiate on this.

---

## Code Standards

### 1. POSIX-Strict

All scripts **must** pass `shellcheck --shell=sh`:

```sh
find . -type f -name '*.sh' -exec shellcheck --shell=sh {} +
```

- No bash arrays (`arr=(...)`) — use positional parameters (`set -- a b c`)
- No `[[...]]` — use `[...]` or `case`
- No `source` — use `.`
- No `local` — use subshell scoping `func() ( ... )`
- No `BASH_SOURCE` — use `$0` for executed scripts
- No `pipefail` directly — use the conditional check pattern:

```sh
# shellcheck disable=SC3040
if (set -o pipefail 2>/dev/null); then set -o pipefail; fi
```

### 2. Zero-Dependency

Scripts may only invoke tools present in a base POSIX environment:  
`sh`, `printf`, `awk`, `cut`, `find`, `grep`, `date`, `hostname`, `uname`,  
`openssl`, `xxd`, `getconf`.

No `jq`, `curl`, `python3`, `node`, or runtime-installed packages in core paths.

### 3. ETERNUM_ROOT Contract

Every executable script (not sourced libraries) must set and export `ETERNUM_ROOT`  
before sourcing `core/env.sh`:

```sh
ETERNUM_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ETERNUM_ROOT
. "${ETERNUM_ROOT}/core/env.sh"
```

### 4. Signal Hygiene

Any script containing an infinite loop or long-running process **must** include  
a trap for clean teardown:

```sh
trap 'printf "\033[0m\n"; printf "Initiation Interrupted\n" >&2; exit 0' INT TERM
```

---

## Branch & Commit Protocol

- All commits must be GPG-signed: `git config commit.gpgsign true`
- Branch naming: `operator/<github-username>/<feature-slug>`
- Commit messages: imperative mood, ≤72 characters on the first line

---

## Rejected Patterns

The following patterns will cause automatic CI rejection:

| Pattern | Reason |
|---|---|
| `#!/usr/bin/env bash` in core scripts | Non-POSIX shebang |
| `${BASH_SOURCE[0]}` | Bash-specific |
| `set -o pipefail` without conditional guard | SC3040 |
| Hardcoded secrets or tokens | Supply-chain hygiene |
| Off-platform identity verification | Social engineering vector |
