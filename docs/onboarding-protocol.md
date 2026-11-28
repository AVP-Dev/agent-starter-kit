# Automated Project Onboarding Protocol (Agent Onboarding Protocol)

> **Purpose:** Integrate or update the AI Engineering Standard in a new, existing, or already updating project without deleting or silently overwriting project data.
>
> **Boundary:** The protocol does not create its own runtime orchestrator. It manages scanning, documentation completion, and the safe addition of missing files.

## 1. Operating Modes

The protocol supports three modes:

- **Automatic:** The agent extracts facts from manifests, lockfiles, configuration, tests, and documentation; it asks questions only about decisions that cannot be inferred from the repository.
- **Semi-automatic:** The agent fills in the facts it discovers and leaves disputed or architectural decisions to the user with a recommendation.
- **Manual:** The user fills in or corrects fields manually; the agent does not overwrite manual values without confirmation.

For a brownfield project, the actual repository state takes precedence. For a greenfield project, the user's confirmed decision takes precedence over the agent's assumptions. Independent checks may be delegated if doing so speeds up the work or improves report quality.

## 2. Safe Preparation with the Script

The `scripts/init-project.sh` script only prepares the structure, identifies a heuristic track candidate, and adds missing standard files. It does not perform deep project analysis or make architectural decisions.

```bash
./scripts/init-project.sh /path/to/project
./scripts/init-project.sh --dry-run /path/to/project
./scripts/init-project.sh --yes /path/to/new-project
./scripts/init-project.sh --update /path/to/existing-project
./scripts/init-project.sh --with-claude /path/to/project
```

Options:

- `--dry-run` — show what will be added without making changes;
- `--yes` — create a missing target directory without an interactive prompt;
- `--update` — update an existing project: safely add only missing files and report which existing files were preserved. This mode rejects nonexistent paths.

The script preserves existing `AGENTS.md`, `CLAUDE.md`, `.gitignore`, `docs/*`, and tools in `scripts/`. It relies on `AGENTS.md` by default. The `--with-claude` flag adds a missing `CLAUDE.md` with an `@AGENTS.md` import for older versions or environments where direct loading is disabled. Symlinks to the `docs/` and `scripts/` directories are rejected. Configure the target project's CI separately.

## 3. Agent Prompts

### Automatic Brownfield

```text
Follow the onboarding protocol in docs/onboarding-protocol.md.
Inspect the current repository, identify it as Brownfield, and extract the actual
stack, structure, verification commands, and existing documents.
Prepare a non-destructive update to AGENTS.md and docs/.
Do not ask questions about facts visible in the files. Show a concise report of
what was found, preserved, added, and remains to be decided.
```

### Automatic Greenfield

```text
Follow the onboarding protocol in docs/onboarding-protocol.md for a new project.
Identify the facts already established, ask only about unresolved decisions
with recommendations, then complete the documentation with confirmed values.
Do not create unnecessary code, runtimes, or platform adapters.
Show a final summary before applying irreversible changes.
```

### Manual Mode

```text
Prepare templates and a list of fields to fill in manually.
Do not analyze the architecture or make assumptions without explicit permission.
After manual completion, check AGENTS.md and docs/ for consistency.
```

### Updating an Existing Project

```text
Update the AI Engineering Standard according to docs/onboarding-protocol.md.
Read the existing AGENTS.md, CLAUDE.md, README, and docs/ first.
Preserve user rules and engineering documents.
Add only missing standard sections and templates.
Do not delete, rename, or overwrite existing files.
```

## 4. Phase 0. Safety Check

Before changing files, the agent must:

1. Identify the project root and repository boundaries.
2. Check `git status` for uncommitted changes.
3. Do not pull, reset, checkout, delete, or overwrite files.
4. Do not copy secrets, `.env` files, keys, tokens, or private data into documentation.
5. Determine whether `AGENTS.md`, `CLAUDE.md`, and `docs/` already exist.
6. Record the list of files that will be created or preserved.

If the project already contains changes, the agent must not silently overwrite them. It reports them and proposes a safe scanning mode that does not modify files.

## 5. Phase 1. Track Identification

### Brownfield

Indicators of an existing project:

- It contains `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, or similar manifests;
- It contains a lockfile, Dockerfile, CI configuration, source code, or tests;
- It has confirmed architectural decisions or active project contracts.

The agent extracts:

- Runtimes and languages;
- Package managers and lockfiles;
- Frontend, backend, and infrastructure components;
- Typecheck, lint, test, build, and security check commands;
- The baseline of existing checks and environment constraints;
- The actual operational stage, real data, public contracts, and recovery conditions;
- Directory structure and existing modules;
- Existing rules, documentation, and restrictions;
- The actual directory map, module ownership, dependency directions, and potentially oversized or catch-all files.

The agent does not ask the user about facts that can be read from the files.

### Greenfield

Indicators of a new project:

- The directory is empty or contains only basic files such as `.git`, `.gitignore`, and a README with a heading;
- There are no dependency manifests, source code, or checks;
- There is no actual stack to identify.

The agent asks only necessary questions:

1. What is the product's purpose and project type?
2. What is the minimum stack to choose?
3. If the project handles data from multiple organizations, what are the isolation requirements?
4. What checks and constraints must be established before development begins?

For each question, the agent provides a recommended option and explains the tradeoff. The user's answers are recorded as manual values and take precedence over defaults.

## 6. Phase 2. Safe Integration of the Standard

1. Run `init-project.sh` in dry-run mode if changes need to be reviewed first.
2. Add a missing `AGENTS.md` only if it does not exist.
3. Determine whether compatibility through `--with-claude` is needed. Check the installed version and Project instructions settings against the [Claude Code documentation](https://code.claude.com/docs/en/memory#agentsmd): direct reading of `AGENTS.md` depends on support and the presence of Claude files in the current and parent directories. If direct reading is unavailable, add the `@AGENTS.md` import to `CLAUDE.md` while preserving its existing content. After integration, check the loaded instructions in a new session using `/context all`.
4. Copy a missing `.gitignore`; preserve an existing `.gitignore` and have the agent supplement it only after reviewing its rules.
5. For manual integration, select the applicable documents. The installation script adds the set of missing documents and the profile template from `docs/`, preserving files with the same names.
6. For an existing `AGENTS.md`, preserve project rules and add only applicable links or instructions.
7. Do not create `.cursorrules`, `.windsurfrules`, or other duplicate rules without an explicit request.
8. Do not create an active `scripts/verification-profile.tsv` blindly. Add the universal `scripts/verify-project.sh`, `scripts/security-scan.sh`, and profile template, then have the agent build a profile only from confirmed commands for the specific project.

## 7. Phase 3. Synthesis and Completion

### `AGENTS.md`

The agent fills in:

- The project name and purpose;
- The actual stack;
- The repository structure;
- The actual Automated Verification Gate commands;
- Concise links to the routing policy and project documents;
- The actual operational stage and the conditions for reconsidering it.

If the file already contains project rules, the agent preserves them verbatim and adds only applicable instructions missing from the project.

### `docs/agent-routing.md`

If the file is missing, it is added from the starter kit. In a brownfield project, the agent may adapt examples to actual module boundaries without creating a new architecture.

### `docs/project-structure.md`

If the file is missing, it is added from the starter kit. In a brownfield project, the agent completes the actual map of ownership, shared contracts, dependency directions, and exceptions for large files. Large-scale refactoring is a separate task requiring confirmation.

### `docs/verification.md`

If the file is missing, it is added from the starter kit. In a brownfield project, the agent fills in actual verification commands, baseline, risk classification, security checks, and targeted deep check rules. The universal dispatcher and baseline scanner are copied as infrastructure, but the active profile is created only after reviewing manifests and environment constraints.

### `docs/architecture.md`

Update only if the project has an actual architecture that the current document does not reflect. Do not delete existing architectural documentation.

### `docs/lifecycle.md`

Determine the stage from actual risk and consumers, and record it along with reconsideration triggers in AGENTS.md. Preserve existing migration, recovery, and decommissioning rules. If operational constraints are unknown, clarify them before changing real data.

### `docs/glossary.md`

Supplement only with specific terms confirmed by code or documentation. Do not duplicate general terminology.

### `docs/state.md`

Complete after onboarding: the discovered stack, commands, preserved documents, known constraints, and next step.

## 8. Phase 4. Report and Confirmation

Before applying changes that affect existing documents, the agent shows:

1. Brownfield or Greenfield.
2. The discovered stack and commands.
3. Files created.
4. Existing files preserved.
5. Changes that require confirmation.
6. Remaining unknowns and risks.
7. The exact next step.

Confirmation is mandatory for:

- Deleting or overwriting project documents;
- Changing data schemas or migrations;
- Changing auth, RBAC, or security;
- Irreversible actions;
- Changing the meaning of an already agreed contract.

## 9. Versioning and Subsequent Updates

When updating the starter kit:

- Read the current `AGENTS.md` and `docs/` first;
- Compare new requirements with existing ones;
- Add only missing rules;
- Record architectural changes in `docs/decisions.md`;
- Update `docs/state.md` after successful verification;
- Do not change other people's decisions or mark them obsolete without explicit justification.

If the old and new formats conflict, safety invariants, explicit user decisions, and preservation of project data take precedence. Record disputed decisions in an ADR and request confirmation.

## 10. Onboarding Completion Criteria

Onboarding is complete when:

- The project is classified as Brownfield or Greenfield;
- The actual stack is confirmed or greenfield questions are resolved;
- `AGENTS.md` contains current links and commands;
- The `.gitignore` baseline is present or existing project rules have been reviewed;
- Applicable documents are added or already exist;
- No existing documents have been lost;
- The existing `CLAUDE.md` is preserved, and when compatibility is requested, the import is added if the file did not yet exist;
- The user has received a report of what was found and changed;
- The Verification Gate has been run for the available project commands;
- `scripts/verification-profile.tsv` has been created from confirmed commands or constraints are explicitly recorded as `blocked`;
- The operational stage is defined; the full Acceptance Gate contains at least one confirmed required check. If this is impossible, the verification result remains blocked.
