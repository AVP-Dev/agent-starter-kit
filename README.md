# Agent Starter Kit: AI Engineering Standard (2026 Edition)

**English** | [Русская версия](README.ru.md)

[![Verification Gate](https://github.com/AVP-Dev/agent-starter-kit/actions/workflows/verification.yml/badge.svg)](https://github.com/AVP-Dev/agent-starter-kit/actions/workflows/verification.yml)

The starter kit helps adapt engineering guidance and automated checks to new and existing projects. The templates are written in Russian and can be localized during onboarding.

- [AGENTS.md](https://agents.md/) is the primary instruction file. Loading and precedence depend on the client and settings.
- Claude Code v2.1.277 and later supports direct loading. For configurations that require `CLAUDE.md`, install the optional `@AGENTS.md` import with `--with-claude`. [Claude Code documentation](https://code.claude.com/docs/en/memory#agentsmd)

---

## 📖 Deep-Dive Article Series

This starter kit is the practical implementation of the AI engineering methodology published in the essay series:
👉 **[Code Got Cheap. Engineering Thought Did Not (AVPDev Blog)](https://avpdev.com/ru/blog/control-ideas-not-code/)**

- **Part 1:** [Code Got Cheap. Engineering Thought Did Not](https://avpdev.com/ru/blog/control-ideas-not-code/) — Shifting from syntax-level coding to architectural control, system invariants, and intent management.
- **Part 2:** [AI Loves Straight Roads: Why Local Optimization Breaks Complex Systems](https://avpdev.com/ru/blog/ai-loves-straight-roads/) — Why removing architectural fences, queues, and boundaries creates technical debt even when local tests are green.
- **Part 3:** [Architect of the Future: From Line-by-Line Review to Design Review](https://avpdev.com/ru/blog/architect-of-the-future/) — The `Skeleton + Pluggable Modules` pattern, `DESIGN.md` / Design Review, delegation boundaries, and the architect’s responsibility for system integrity.

---

## 🎯 Starter Kit Directory Layout

```
agent-starter-kit/
├── AGENTS.md                      # Single Source of Truth for rules, stack, and gates
├── .gitignore                     # Cross-stack local/secret artifact baseline
├── .github/workflows/verification.yml # CI Verification Gate for push/PR
├── docs/                          # Architectural core documentation
│   ├── onboarding-protocol.md     # ⚡ Automated repository scanning & onboarding protocol
│   ├── architecture.md            # System architecture (Skeleton + Pluggable Modules)
│   ├── theme-tokens.md            # 🎨 Semantic design tokens spec & hot-swappable themes
│   ├── decisions.md               # Architecture Decision Records (ADR registry)
│   ├── state.md                   # Session ledger (Done / In Progress / Tech Debt)
│   ├── glossary.md                # Domain terminology glossary
│   ├── agent-routing.md            # Adaptive agent routing and context containment
│   ├── project-structure.md        # File hygiene, ownership and project boundaries
│   ├── verification.md             # Impact, safety and test-coverage policy
│   ├── verification-profile.example.tsv # Profile template; adapt per project
│   └── design-manifest-template.md# Zero Vibe Coding pre-project design manifest
├── scripts/
│   ├── init-project.sh            # One-click non-destructive setup script
│   ├── verify-project.sh          # Project-local verification profile dispatcher
│   ├── security-scan.sh           # Dependency-free secret baseline scanner
│   └── verification-profile.tsv   # This kit's runnable gate; not copied to targets
├── CHANGELOG.md                   # Kit version history and releases
├── README.md                      # English documentation (this file)
└── README.ru.md                   # Russian documentation
```

---

## Engineering Guidance

- **Apply project conventions.** Preserve existing architecture and practices. Consider [Skeleton + Pluggable Modules](docs/architecture.md) when its boundaries fit. Use the existing design system for UI changes.
- **Match design work to the risk.** For a local change, capture the goal, invariant, and check. Use relevant parts of the [DESIGN manifest](docs/design-manifest-template.md) for contract changes or complex failures. Get confirmation before changing data ownership, access rights, security contracts, or taking an irreversible action.
- **Verify what changed.** Run checks for the affected behavior and compare with the starting state. Report new regressions, existing failures, and checks blocked by the environment. [Verification guide](docs/verification.md)
- **Keep Git operations explicit.** Check remote state when integration depends on it. Local analysis can continue if the remote is unavailable. Follow the project’s commit process, stage explicit paths, and avoid a blind pull.
- **Check version-specific documentation.** Use Context7 or official documentation for the installed dependency version. Get approval if the requested work requires a breaking migration.
- **Organize work around the task.** Delegate independent work when it helps. Save a checkpoint at a meaningful milestone, handoff, or pause. Treat line counts and report length as guidance. [Agent routing](docs/agent-routing.md) · [Project structure](docs/project-structure.md)

---

## ⚡ Automated Onboarding (Zero-Friction Setup)

You **do not need to write project descriptions manually**. The agent inspects your repository and synthesizes the necessary standards following [docs/onboarding-protocol.md](docs/onboarding-protocol.md). The same protocol supports manual completion, automatic brownfield discovery, and greenfield interviewing.

### Scenario A: Standalone Kit on Your Machine

Open a new or existing repository in your IDE or terminal and prompt your agent:

> **Copy & Paste Prompt:**
> ```text
> Read /path/to/agent-starter-kit/docs/onboarding-protocol.md.
> Inspect the current project, classify it as Brownfield or Greenfield,
> extract discoverable facts, preserve existing documentation, and prepare
> the non-destructive onboarding update. Ask only questions that cannot be
> answered from the repository and present a summary before applying changes.
> ```

### Scenario B: Setup via `init-project.sh`

The script only adds missing files, never overwrites existing project data, and copies the baseline `.gitignore` only when it is absent:

```bash
/path/to/agent-starter-kit/scripts/init-project.sh --yes /path/to/new-project
/path/to/agent-starter-kit/scripts/init-project.sh /path/to/your-project
/path/to/agent-starter-kit/scripts/init-project.sh --dry-run /path/to/your-project
/path/to/agent-starter-kit/scripts/init-project.sh --update /path/to/your-project
/path/to/agent-starter-kit/scripts/init-project.sh --with-claude /path/to/your-project
```

Then run the onboarding prompt from the protocol. Brownfield projects are scanned automatically; greenfield projects receive only the minimum necessary interview. The target receives the generic dispatcher, secret scanner and profile template, while the active profile is generated from its manifests. The kit workflow applies to this repository. Integrate target checks through its own CI. `--update` is intended only for an existing project and never creates a new target directory.

### Scenario C: Manual or Incremental Update

The agent preserves project-specific sections in `AGENTS.md`, adds only applicable guidance, and reports every preserved or created file. Existing documents, tests, configuration, secrets, and manual values are never silently replaced.

---

## Example Technology Choices

For a new project, choose tools to fit its needs and verify supported versions. For an existing project, read the manifests and lockfiles.

- **Runtimes & Languages:** Node.js / Bun / Python / Go / TypeScript
- **Frontend:** Next.js (App Router) / React / Astro / Tailwind CSS
- **Backend & Background:** Next.js Server Actions / FastAPI / Go microservices / WebSockets / BullMQ (Redis)
- **Databases & Vector:** PostgreSQL, Drizzle ORM, Redis, pgvector + HNSW indexes
- **AI & Inference:** LLM APIs (Anthropic Claude, OpenAI GPT, Gemini), ONNX Runtime, Agent Orchestration
- **Infra & DevOps:** Docker, Coolify / Dokploy (self-hosted PaaS), GitHub Actions (CI/CD), Linux (Bash, Nginx)

---

<div align="center">
<sub>AVPdev · Software Development &amp; Automation · <a href="https://avpdev.com/">avpdev.com</a></sub>
</div>
