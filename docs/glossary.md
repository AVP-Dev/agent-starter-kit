# Domain Glossary

> A single vocabulary of project terms. Prevents naming ambiguity across code, database, and documentation.

| Term | Code / Technology | Definition and Usage Context |
|---|---|---|
| **User** | `User` | A registered account with a defined set of roles. |
| **Tenant / Project** | `Tenant / Project` | An isolated workspace or site within a multi-tenant system. |
| **Queued Job** | `Job / Task` | A unit of asynchronous work in a BullMQ / Redis queue. |
| **Contract** | `Contract / DTO` | A strictly typed data structure for an exchange interface (Zod, Pydantic, TypeScript interface). |
| **Invariant** | `Invariant` | A system condition or constraint that must not be violated under any circumstances. |
| **Vector Index** | `pgvector / HNSW` | A PostgreSQL extension and graph index structure (Hierarchical Navigable Small World) for high-speed semantic embedding search in RAG. |
| **Verification Gate** | `Verification Gate` | Mandatory automated execution of `typecheck`, `lint`, and `test` before task completion, requiring exit code 0. |
| **PaaS Deployment** | `Coolify / Dokploy` | Self-hosted container and deployment management platforms based on Docker / Linux. |
| **Documentation Agent** | `Context7 MCP` | A protocol and tool for retrieving current official library documentation to avoid hallucinations of outdated APIs. |
