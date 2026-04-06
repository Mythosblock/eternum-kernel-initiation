# 🦊 CONTRIBUTING — Eternum Kernel

**Standard:** POSIX Strict / Zero-Trust  
**Signal:** `neuromycelial-pulse`

---

## Ground Rules

1. **POSIX First.** All shell scripts must target POSIX sh or explicitly declare `#!/usr/bin/env bash` when bash-specific features are required. Avoid bashisms in files with a `#!/bin/sh` shebang.
2. **Zero-Trust.** Never assume the environment is clean. Validate all inputs. Lock `PATH` at the top of every script.
3. **Zero-Dependency.** Do not add external runtime dependencies. The kernel must bootstrap from standard POSIX utilities (`awk`, `openssl`, `xxd`).
4. **Constant-Time Comparisons.** Security-sensitive string comparisons must use the `timing_resistant_compare` pattern in `security/verify.sh`.
5. **No Secrets in Source.** Credentials, keys, and tokens must never appear in committed code. Use environment variables prefixed with `ETERNUM_`.

## Pull Request Requirements

- Title must describe the gate being modified (e.g. `fix(core): align init bootstrap with env contract`).
- Description must include the 🦊 signal.
- All `.sh` files must pass `shellcheck` with no errors before opening a PR.
- Commits must be atomic and scoped to a single logical change.

## Script Conventions

```
export PATH=/usr/bin:/bin:/usr/sbin:/sbin   # always first
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/..." && pwd)"
source "${ROOT_DIR}/core/env.sh"             # single source of truth
```

- Use `eternum_die` for fatal errors.
- Use `log_info` / `log_ok` / `log_crit` for user-facing messages.
- Use `eternum_require_cmd` to assert required binaries at startup.

## ShellCheck

Run before every commit. ShellCheck infers the dialect from each file's shebang (`#!/bin/sh` → POSIX sh, `#!/usr/bin/env bash` → bash):

```sh
find . -type f -name '*.sh' -exec shellcheck {} +
```

> **Note:** The CI workflow (`coherence.yml`) passes `--shell=sh` as the *default* dialect for files that lack a shebang. All scripts in this repo carry an explicit shebang, so ShellCheck uses that; however, running without `--shell=sh` locally catches the same issues without spurious POSIX-mode warnings for bash scripts.
