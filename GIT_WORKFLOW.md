# Git Commit Governance

This repository treats commit management as a continuous part of development, not a step at the end. Read this before starting a task and again before and after every implementation task.

The policy has four layers:

| Layer | Sections | Scope |
|-------|----------|-------|
| 1. Global Git policy | 1–8 | Conventional Commits, lifecycle, safety, reporting — applies to any repo |
| 2. Repository policy | 9 | cmdforge scopes, validation commands, generated specs, exclusions |
| 3. Git integrity | 10–12 | Task boundaries, recovery, dependency and artifact integrity |
| 4. Quality gates | 13 | Two-tier validation and final commit verification |

`AGENTS.md` tells agents to follow this document. `script/presubmit` enforces what can be checked automatically. Instructions here cover what automation cannot decide: what belongs in which commit.

---

# Layer 1 — Global Git Policy

## 1. Core Principles

- Follow the Conventional Commits specification.
- Create multiple commits based on logical changes.
- Each commit must represent one responsibility.
- Keep commits atomic, focused, and independently understandable.
- Never combine unrelated changes into one commit.
- Preserve the existing Git history.
- Never amend, rebase, reset, or force-push unless explicitly authorized.
- Never commit secrets, credentials, generated temporary files, or unrelated user changes.
- Do not commit broken or incomplete functionality unless explicitly requested.

### Commit independence

Every commit should leave the repository in a coherent state. Prefer commits that build and pass relevant tests independently. When changes are inherently dependent, use the smallest logical commit unit that preserves correctness. Do not artificially split changes merely to increase commit count.

A chain of commits where only the last one compiles is not a good history. Two coherent commits that build beat six that do not.

## 2. Conventional Commit Format

`<type>(<scope>): <description>`

| Type | Use for |
|------|---------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation |
| `style` | Formatting without logic changes |
| `refactor` | Restructuring without behavior changes |
| `perf` | Performance improvements |
| `test` | Adding or updating tests |
| `build` | Build system, dependencies, tooling that builds or packages the project |
| `ci` | CI/CD configuration |
| `chore` | Maintenance not covered above |
| `revert` | Reverting a previous commit |

Breaking changes use `feat(api)!: change public API contract` and include a `BREAKING CHANGE:` trailer in the body explaining the migration path.

## 3. Software Development Commit Lifecycle

Stages are guidelines, not mandatory commits. Only commit actual changes.

| Stage | Covers | Example |
|-------|--------|---------|
| 1. Initialization | Scaffolding, directory structure, base config, manifests, dev environment | `chore(init): initialize project structure` |
| 2. Build infrastructure | Build system, dependency management, compiler and toolchain config | `build(core): configure build infrastructure` |
| 3. Core implementation | Core modules, internal architecture, shared utilities, business logic | `feat(core): implement core processing engine` |
| 4. Features | Individual features, APIs, CLI commands, integrations | `feat(cli): add command execution support` |
| 5. Fixes and refactoring | Bug fixes, code quality, error handling, optimization | `fix(parser): handle malformed input` |
| 6. Testing | Unit, integration, end-to-end tests, fixtures | `test(core): add integration coverage` |
| 7. Documentation | README, API docs, architecture docs, usage examples | `docs(api): document public interfaces` |
| 8. CI/CD and release | Pipelines, release config, version bumps, packaging, deployment | `ci(workflows): add automated test workflow` |

## 4. Execution Workflow

Before creating commits:

1. Inspect `git status`.
2. Inspect the current branch.
3. Review recent commit history.
4. Inspect all changed and untracked files.
5. Review the actual diffs, not just file names.
6. Identify unrelated or pre-existing changes (see Section 10).
7. Group changes into logical commit units.
8. Determine the correct type and scope for each group.
9. Verify each group is independently meaningful.

Then, per logical change:

1. Stage only the files belonging to that change.
2. Review `git diff --cached`.
3. Run the checks appropriate to that change (Section 13).
4. Create the commit.
5. Verify with `git show --stat`.
6. Proceed to the next change.
7. Repeat until all intended changes are committed.

## 5. Commit Message Quality

Messages must:

- Use the imperative mood.
- Use a lowercase description.
- Be concise and specific.
- Say what changed and why, not that something changed.

Reject vague messages: `update code`, `fix stuff`, `changes`, `wip`, `misc`, and `initial commit` (except a genuine first commit of a new repository).

Good: `feat(auth): add JWT authentication`
Good: `fix(config): handle missing environment variables`
Good: `refactor(storage): extract repository interface`
Good: `test(api): cover invalid request handling`

A commit body is optional. Add one when the change needs justification: non-obvious tradeoffs, migration notes, or a link to the issue being fixed. Do not restate the diff.

## 6. Safety Rules

- Never use `git add .` or `git add -A` without first reviewing exactly what they would stage.
- Never include unrelated user modifications.
- Never commit `.env`, private keys, tokens, or credentials.
- Never skip a failing test without documenting why in the commit body or the final report.
- Never create empty commits.
- Never force-push.
- Never rewrite existing history.
- Ask for permission before pushing to a remote.
- If a change cannot be safely separated, explain why before proceeding.

## 7. Final Verification

After all commits:

- Confirm the working tree is clean, or explain every remaining change.
- Inspect the new history with `git log --stat`.
- Verify ordering and messages.
- Confirm which validation actually ran and passed (Section 13).
- List any files intentionally left uncommitted.

## 8. Final Report

Report:

1. Number of commits created.
2. Hash and message of each commit.
3. Files in each commit.
4. Checks run, and their results — per command, not as a blanket claim.
5. Anything skipped or blocked, and why.
6. Remaining uncommitted changes.

---

# Layer 2 — Repository Policy (cmdforge)

## 9. Repository-Specific Notes

### Validation commands

CI (`.github/workflows/ci.yml`) runs four checks. `script/presubmit` mirrors them locally:

```bash
./script/presubmit
```

| Step | Command | Auto-fix |
|------|---------|----------|
| JSON formatting | `npm run format:check` | `npm run format` |
| Rust formatting | `cargo fmt -p cognix-cmdforge -p cognix-completion-metadata --check` | `cargo fmt -p cognix-cmdforge -p cognix-completion-metadata` |
| Lints | `cargo clippy -p cognix-cmdforge -p cognix-completion-metadata --all-targets --all-features -- -D warnings` | — (fix by hand) |
| Tests | `cargo test --verbose` | — |

Prettier covers `cmdforge/json/**/*.json` but `.prettierignore` excludes `cmdforge/json/autogenerated/`, so generated output is not format-checked. Any spec edit needs the JSON format check. Any Rust edit needs `fmt`, `clippy`, and `test`. See Section 13 for when the full presubmit is required versus a targeted check.

### Scope vocabulary

Use these scopes. Do not invent synonyms.

| Scope | Applies to |
|-------|-----------|
| `cmdforge` | `cmdforge/src/lib.rs`, `assets.rs`, `overrides.rs`, crate manifest |
| `metadata` | `completion-metadata/` |
| `generators` | `cmdforge/src/generators/` |
| `powershell` | `cmdforge/src/powershell_autogenerator/`, `cmdforge/json/autogenerated/powershell/`, `cmdforge/json/overrides/powershell/` |
| `specs` | `cmdforge/json/*.json` hand-written specs |
| `assets` | `cmdforge/src/assets.rs` embedding logic |
| `deps` | `Cargo.toml`, `package.json`, `package-lock.json` |
| `workflows` | `.github/workflows/` |
| `script` | `script/` |
| `readme` | `README.md` |
| `contributing` | `CONTRIBUTING.md` |
| `workflow` | `GIT_WORKFLOW.md` |
| `agents` | `AGENTS.md`, `.agents/skills/` |

A command or command family may replace the scope when a change is confined to one spec and its generator, for example `feat(terraform): add workspace completions` or `fix(brew): handle empty formula list`. Do not use `git` as a scope: it is a command family here and would collide with Git-tooling changes, which use `workflow`.

### Generated specs

Autogenerated output lives in `cmdforge/json/autogenerated/powershell/` and is reproduced with:

```bash
cargo run --bin autogenerate_powershell
```

Regeneration requires `pwsh` on `PATH`; the installed PowerShell version affects the emitted specs. Record the `pwsh --version` used when a regeneration changes output. Never hand-edit files under `autogenerated/`; hand-written augmentation belongs in `json/overrides/powershell/`.

Bulk regeneration is its own commit so reviewers can skip it. See Section 12 for the required ordering.

### Exclusions

Never commit: `target/`, `node_modules/`, `.env`, editor and OS metadata, or `Cargo.lock` (intentionally untracked — see Section 12).

### Example history for a spec-plus-generator feature

```
feat(specs): add vendor spec skeleton
feat(generators): implement vendor package listing
feat(specs): wire vendor generator into spec
test(generators): cover malformed vendor metadata
docs(readme): document vendor completions
ci(workflows): cache cargo artifacts
```

---

# Layer 3 — Git Integrity

## 10. Task Boundary and Working Tree Protection

Before starting implementation:

1. Capture the initial state: `git status --short` and `git rev-parse --abbrev-ref HEAD`.
2. Note pre-existing modified, staged, and untracked files.
3. Treat every pre-existing change as user-owned.
4. Track which files the current task actually modifies.

Rules:

- Never overwrite, discard, stash, or commit pre-existing changes without authorization.
- Never stage files outside the current task, even if they are already modified.
- When a file contains both user changes and task changes, inspect the hunks and stage only the task's hunks (`git add -p`).
- If safe separation is impossible, stop and ask.
- Do not "clean up" a dirty tree as a side effect of an unrelated task.

A dirty tree is the normal state of a working repository. Your task is to add to it, not to normalize it.

## 11. Commit Integrity and Recovery

Every commit must:

- Represent one coherent logical change.
- Carry an accurate Conventional Commit message.
- Contain only the intended changes.
- Pass the relevant checks (Section 13).
- Preserve consistency between code, specs, and generated output.

When something goes wrong:

- If staging is wrong, unstage only this task's paths: `git restore --staged <path>`. Never `git reset --hard`, never `git checkout -- .`.
- If validation fails, do not commit the failing change unless explicitly authorized; report the failure instead.
- If a commit fails, read the error and retry safely.
- Never amend or reset to recover. Prefer a new corrective commit (`fix(...)` or `revert(...)`).
- If an incorrect commit already exists, stop and request authorization before rewriting history.
- Never discard user modifications as part of recovery.

## 12. Dependency and Generated Artifact Integrity

### Dependencies

- Commit dependency manifest changes with the lockfile that corresponds to them.
- `package.json` and `package-lock.json` change together.
- Avoid unrelated upgrades inside a feature or fix commit; a dependency bump is its own `build(deps)` commit.
- State why a new dependency is needed in the commit body.
- Do not regenerate lockfiles with a different toolchain or package manager version without saying so.

**This repository's `Cargo.lock` is intentionally untracked.** `.gitignore` ignores it because both crates are libraries, and upstream guidance is to leave the lockfile for applications. Consequences to respect:

- A dependency change touches `cmdforge/Cargo.toml`, `completion-metadata/Cargo.toml`, or the root `Cargo.toml` only — there is no Rust lockfile diff to review.
- CI resolves the dependency graph fresh on every run, so a version bump can change CI results without any diff showing it. Say so explicitly in the commit body when adjusting a version requirement.
- Never add `Cargo.lock` to a commit. If tracking it becomes desirable for reproducible CI, that is a deliberate policy change in a `build(deps)` commit that also updates `.gitignore`, not something to do incidentally.

### Generated artifacts

- Commit the generator logic and hand-written configuration before the output they produce.
- Output must be reproducible from committed code plus a documented toolchain.
- Regeneration is its own commit that contains only generated files.
- Never hand-edit generated files unless that is the explicit intent, and state it if so.

For PowerShell, the required order within a change set is:

1. `build(powershell): ...` — generator or autogenerator logic.
2. `feat(powershell): ...` / `fix(powershell): ...` — hand-written overrides in `json/overrides/powershell/`.
3. `build(powershell): regenerate cmdlet specs` — the regenerated output in `json/autogenerated/powershell/`, nothing else.

If regeneration is impractical (for example `pwsh` is unavailable), commit steps 1 and 2 only, and report that the generated output is stale rather than committing a partial or hand-edited regeneration.

---

# Layer 4 — Quality Gates

## 13. Validation and Commit Quality Gates

Two tiers. Do not run the full suite before every commit; do not skip it at the boundaries.

### Tier 1 — per logical change

- Run the tests that cover the change: `cargo test -p cognix-cmdforge <filter>` where practical, or the specific crate.
- Run the format and lint checks for the files touched (Section 9 table).
- Inspect the staged diff.
- Confirm the commit contains only intended changes.

### Tier 2 — full repository validation

Run `./script/presubmit`:

- before the first implementation commit when practical, so you know the starting state;
- after the last implementation change, before reporting completion;
- again if a later commit changes shared infrastructure (workspace manifests, `assets.rs`, `mod.rs`, generator registration) after an earlier full run.

### Reporting rules

- Never claim a check passed unless the command completed successfully. Quote the command and its exit status.
- If a check fails for a pre-existing reason, report it as pre-existing and do not fix unrelated code to make the suite green.
- If a check cannot run (missing `pwsh`, no network, toolchain unavailable), report it as not run — never as passed.
- Distinguish pre-existing failures from regressions introduced by the task.
- A commit that intentionally leaves the tree non-building (for example a documented import) must say so in the commit body and the final report.
