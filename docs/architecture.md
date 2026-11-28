# Project Architecture

> Example architecture with a shared foundation (Skeleton) and replaceable modules (Pluggable Modules). Describe the actual project boundaries during onboarding.
> Methodological foundation: [AI Loves Straight Roads: Why Local Optimization Breaks Complex Systems](https://avpdev.com/en/blog/ai-loves-straight-roads/) and [The Architect of the Future: From Line Reviews to Design Reviews](https://avpdev.com/en/blog/architect-of-the-future/).
> Update when the system undergoes structural changes.
> Changes to stable contracts and transitions between stages are governed by the [lifecycle policy](lifecycle.md).

---

## 1. Architectural Overview (Skeleton + Pluggable Modules)

This approach is suitable for a project in which multiple modules share system contracts. The example illustrates possible components. Choose storage, queues, audit, themes, and other tools according to project requirements.

```
                  ┌────────────────────────────────────────┐
                  │            ARCHITECT (HUMAN)           │
                  │   Invariants, Data Schemas, Contracts  │
                  └───────────────────┬────────────────────┘
                                      │
                                      ▼
                  ┌────────────────────────────────────────┐
                  │                SKELETON                │
                  │  Auth Context │ Event Bus │ DB Schemas │
                  │     Redis/BullMQ │ pgvector Core       │
                  └─────┬────────────────────────────┬─────┘
                        │                            │
        isolated        │                            │ isolated
        contract        ▼                            ▼ contract
  ┌───────────────────────────┐        ┌───────────────────────────┐
  │     PLUGGABLE MODULE A    │        │     PLUGGABLE MODULE B    │
  │      (AI-generated)       │        │      (AI-generated)       │
  │  RAG pipeline / Parsers   │        │  External integrations/API│
  │  Quick to develop /       │        │  Can be regenerated       │
  │  Easy to remove entirely  │        │  if quality degrades     │
  └───────────────────────────┘        └───────────────────────────┘
```

### 1.1. Skeleton
- **Authentication and session context**: a single source of truth about the current user/tenant.
- **Unified database schema**: centralized relational entities, pgvector stores, and transactional boundaries (SSOT).
- **Event bus and background queues**: asynchronous communication (Redis, BullMQ) to isolate heavy workloads.
- **Centralized audit and logging**: end-to-end tracing of requests and errors.
- **Theme-Driven UI Foundation**: a unified contract for semantic design tokens (CSS variables: `--background`, `--foreground`, `--primary`, `--muted`, `--border`, `--radius`) and a style registry (`:root`, `.dark`, `[data-theme="..."]`). Pluggable modules are styled exclusively using the core semantic tokens, enabling themes to be added and switched without editing components.

### 1.2. Pluggable Modules
- Each module solves a narrowly defined application problem (e.g., RAG vector search, webhook processing, report generation).
- A module has a strictly typed input and output contract (DTO / Zod / Pydantic).
- **Data isolation**: modules do not have direct access to other modules' private tables. Shared state is accessed strictly through core services or the event bus.
- **Replaceability (Disposable Modules)**: modules can be updated or replaced through their contracts. When requirements change, choose between a local modification and replacement while considering compatibility, verification, and cost.
- **Orchestration without a separate runtime**: topology selection, handoff, and side research rules are described in [docs/agent-routing.md](agent-routing.md); the standard does not require a dedicated orchestration server.
- **Verification and impact policy**: pre-change impact, positive/negative/security/regression checks, and recovery are described in [docs/verification.md](verification.md).

---

## 2. Example Data Flow

1. **Incoming request**: fail-closed input validation at the API boundary (Zod / Pydantic / Go structs).
2. **Business logic**: execution within an isolated module or domain service.
3. **Storage**: persist database changes within an atomic transaction (Drizzle ORM / PostgreSQL).
4. **Asynchronous tasks and AI**: dispatch background jobs to BullMQ/Redis (vectorization, LLM API calls, long-running inference through ONNX Runtime).
5. **Automated verification**: pass automated gates (type checking, linting, automated tests) before delivery.

---

## 3. Architectural Constraints and Security

- For protected operations, verify access according to the project's access model. Define public operations explicitly.
- Store secrets and API keys in the project's designated storage or environment, outside source code.
- Ensure logging does not leak personally identifiable information (PII) or authorization tokens.
- Isolate vectors and metadata in multi-tenant RAG pipelines: queries never return embeddings or documents belonging to another `tenantId / projectId`.
