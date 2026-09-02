# Security & secrets

- **Forbidden in the repo** (files, brain notes, runbooks, commits, messages): passwords, tokens, API keys, private keys, certificates, `.env` contents, seeds, sensitive numbers.
- **Reference, never value**: a secret is designated by its vault path — e.g. `vault kv get -field=<field> kv/<app>/<name>` (HashiCorp Vault; adapt to your secret manager). Runbooks write `export X=$(vault kv get ...)`, never the value.
- **Expiry lives in metadata, not in memory**: a token with an expiration date fails **silently** once it passes. Record the real expiry (and the token's name at the provider, for rotation) as metadata next to the secret in your secret manager — never rely on someone remembering it.
- Versioned config file that requires a secret → provide a `<name>.example` with a placeholder, the real file in `.gitignore`.
- The **gitleaks** pre-commit hook blocks leaks; never bypass it (`--no-verify` forbidden). Confirmed false positive → targeted allowlist in `.gitleaks.toml` with a justifying comment.
- Never read or print `.env*`, `*.key`, `*.pem` & co, even "just to check" — the deny permissions block them by design.
- A committed leak = a **burned** secret: rotate immediately in the vault + purge history before any push.
