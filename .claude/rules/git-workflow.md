# Professional Git workflow

- **Protected `main`**: no direct commit, one exception — routine `brain/` writes (new notes, log, journal, state, index) commit directly (`brain(<area>): <what>`).
- **Branches**: `feat/<slug>`, `fix/<slug>`, `docs/<app>-<slug>`, `brain/<area>-<slug>` (structural), `chore/<slug>`.
- **Conventional commits** mandatory: `feat: fix: docs: brain: chore: refactor:` — atomic, message = the why.
- **Merge**: self-review before merging (link-check, `brain.sh audit` if brain touched) → `git merge --no-ff` into main (merge request once a remote exists). Squash if the branch is noise.
- **Milestones**: tags `v0-scaffold`, `v1-<milestone>`, …
- **Writing subagents**: each on its own branch (worktree if parallel), one writer per file, the orchestrator merges.
- Never `--force` on main, never `--no-verify` (the gitleaks pre-commit hook exists for a reason).
