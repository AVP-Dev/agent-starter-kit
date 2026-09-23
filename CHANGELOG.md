# Changelog

All notable changes to the **Agent Starter Kit** are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2026.3.0] - 2026-09-23

### Added
- **Theme-Driven Visual Architecture & Hot-Swapping:** Added Section 4.5 in `AGENTS.md` and dedicated specification `docs/theme-tokens.md` establishing the invariant *Zero Hardcoded Colors in Components*. All components consume semantic CSS variables/tokens (`--background`, `--foreground`, `--primary`, `--muted`, `--border`, `--radius`), allowing hot-swapping or adding new themes with zero component edits.
- **Anti-AI-Slop Visual Hierarchy:** Integrated strict UI invariants: max 1 Primary CTA per viewport, explicit element states (`:hover`, `:active`, `:focus-visible`, `:disabled`, loading state), semantic HTML without unstyled `div` clicks, and WCAG AA contrast >= 4.5:1.
- **Grill-Me Architectural Frontier:** Adapted Matt Pocock's questioning methodology into `docs/design-manifest-template.md` (Section 0) and `docs/onboarding-protocol.md`: finding facts is the agent's job; deciding architecture is the human's. Ambiguous forks are resolved via structured rounds with recommended answers prior to code generation.
- **Dual-Track Onboarding (Brownfield vs Greenfield):** Refined `docs/onboarding-protocol.md` with two explicit execution tracks:
  - *Track A (Brownfield):* 100% automated scanning of manifests (`package.json`, `go.mod`, `pyproject.toml`, lockfiles) with zero interrogation.
  - *Track B (Greenfield):* Structured 4-question architectural interview offering the baseline AVPDev reference stack as the default.

---

## [2026.2.0] - 2026-09-23

### Changed
- **Universal Agent Standard Alignment:** Elevated `AGENTS.md` to be clearly identified as the open, vendor-neutral specification (stewarded by the Agentic AI Foundation / Linux Foundation), universally parsed by all modern autonomous coding agents (Gemini Antigravity, Claude Code, Cursor, Windsurf, Roo Code, Cline, Codex, GitHub Copilot, Aider, OpenCode, etc.).
- **Pruned Redundant Symlinks:** Removed `.github/copilot-instructions.md` and `.github/` folder in favor of the unified root `AGENTS.md` open standard.
- **Zero-Friction Auto-Onboarding Clarification:** Explicitly documented that Section 2 (Tech Stack) in `AGENTS.md` is scanned and populated dynamically by the agent from repo lockfiles/manifests, eliminating manual user configuration.
- **Clean Session Ledger:** Converted `docs/state.md` into a pristine, reusable project session ledger template; separated starter kit changelog into root `CHANGELOG.md`.
- **Script Polish:** Streamlined `scripts/init-project.sh` to copy `AGENTS.md`, link `CLAUDE.md`, and copy `docs/` non-destructively.

---

## [2026.1.0] - 2026-09-11

### Added
- **Automated Verification Gates:** Mandatory requirement that iterations are not considered done without `exit code 0` from typecheck, linter, and tests.
- **Safe Remote Sync Protocol:** Pre-flight `git fetch origin && git status -uno` check to detect remote drift before generating code; strict prohibition against blind auto-pull.
- **Pre-Project DESIGN Manifest:** Zero Vibe Coding protocol (`docs/design-manifest-template.md`) requiring failure modes, state machines, and system invariants before implementation.
- **Skeleton + Disposable Modules Architecture:** Architectural standard in `docs/architecture.md` isolating core skeleton from AI-generated replaceable modules.
- **Context7 MCP & Discrepancy Policy:** Live documentation retrieval protocol to prevent hallucinated deprecated APIs.
- **Automated Onboarding Protocol:** 4-phase automated repository scanning algorithm in `docs/onboarding-protocol.md`.
- **Bilingual Documentation:** Complete English (`README.md`) and Russian (`README.ru.md`) documentation.

### Removed
- Deprecated legacy editor-specific rules (`.cursorrules`, `.windsurfrules`).
