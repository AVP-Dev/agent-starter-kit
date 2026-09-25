# Agent Starter Kit: Инженерный стандарт разработки с ИИ (2026)

[English Version](README.md) | **Русская версия**

[![Verification Gate](https://github.com/AVP-Dev/agent-starter-kit/actions/workflows/verification.yml/badge.svg)](https://github.com/AVP-Dev/agent-starter-kit/actions/workflows/verification.yml)

> [!NOTE]
> **Язык и локализация:** По умолчанию рабочие файлы правил (`AGENTS.md` и документация в `docs/`) составлены на русском языке. При этом стандарт **абсолютно языконезависим**: если вы или ваша команда работаете на английском (или любом другом языке), достаточно отправить агенту одну команду при онбординге:
> *«Переведи все правила и документацию стартер-кита на английский язык и адаптируй под наш проект»*. Агент сделает это за считанные секунды.

Готовый универсальный, вендор-нейтральный стартовый набор инженерных правил, архитектурной документации и автоматических протоколов для разработки проектов с участием **любых автономных кодинг-агентов**:
- **Универсальный открытый стандарт:** Построен на открытой спецификации `AGENTS.md` (развиваемой под эгидой Agentic AI Foundation / Linux Foundation) и нативно распознается всеми современными ИИ-агентами: **Gemini Antigravity**, **Claude Code**, **Cursor**, **Windsurf**, **Roo Code**, **Cline**, **Codex**, **GitHub Copilot**, **Aider**, **OpenCode** и др.
- **Совместимость с Claude Code:** Прозрачная поддержка через симлинк `CLAUDE.md -> AGENTS.md` без дублирования правил.
- **100% агент- и языконезависимость:** Строгие архитектурные контракты, системные инварианты и Zero Vibe Coding применимы к любому стеку, среде разработки и языку программирования.

---

## 📖 Философия и цикл статей

Этот стартер-кит — практическая реализация методологии осознанного AI-инжиниринга, подробно описанной в цикле статей:
👉 **[Код стал дешёвым. Инженерное мышление — нет (Блог AVPDev)](https://avpdev.com/ru/blog/control-ideas-not-code/)**

- **Часть 1:** [Код стал дешёвым. Инженерное мышление — нет](https://avpdev.com/ru/blog/control-ideas-not-code/) — Переход от ручного кодинга к системному контролю инвариантов и архитектуры.
- **Часть 2:** [AI любит прямые дороги: почему локальная оптимизация рушит сложные системы](https://avpdev.com/ru/blog/ai-loves-straight-roads/) — Почему удаление архитектурных «заборов», очередей и границ создаёт технический долг даже при зелёных локальных тестах.
- **Часть 3:** [Архитектор будущего: от построчного ревью к Design Review](https://avpdev.com/ru/blog/architect-of-the-future/) — Паттерн `Skeleton + Pluggable Modules`, `DESIGN.md` / Design Review, границы делегирования и ответственность архитектора за целостность системы.

---

## 🎯 Что входит в стартер-кит

```
agent-starter-kit/
├── AGENTS.md                      # Единый SSOT правил разработки, стека и верификации
├── .gitignore                     # Базовый ignore для локальных и секретных артефактов
├── .github/workflows/verification.yml # CI Verification Gate для push/PR
├── CLAUDE.md                      # Симлинк на AGENTS.md (для Claude Code)
├── docs/                          # Архитектурное ядро документации
│   ├── onboarding-protocol.md     # ⚡ Автоматический протокол сканирования и онбординга проекта
│   ├── architecture.md            # Каркас системы (Skeleton + Pluggable Modules)
│   ├── theme-tokens.md            # 🎨 Контракт семантических дизайн-токенов и тем оформления
│   ├── decisions.md               # Реестр архитектурных решений (ADR registry)
│   ├── state.md                   # Журнал состояния сессий (Что сделано / в работе / техдолг)
│   ├── glossary.md                # Единый глоссарий доменных терминов
│   ├── agent-routing.md            # Адаптивная маршрутизация и контроль контекста
│   ├── project-structure.md        # Гигиена файлов, ownership и границы проекта
│   ├── verification.md             # Impact, safety и политика test coverage
│   ├── verification-profile.example.tsv # Шаблон профиля для адаптации
│   └── design-manifest-template.md# Шаблон предпроектного манифеста (Zero Vibe Coding)
├── scripts/
│   ├── init-project.sh            # Скрипт быстрой безопасной установки в целевой проект
│   ├── verify-project.sh          # Dispatcher project-local verification profile
│   ├── security-scan.sh           # Dependency-free baseline scanner секретов
│   └── verification-profile.tsv   # Запускаемый gate Кита; не копируется в цели
├── CHANGELOG.md                   # История изменений и релизов стартер-кита
├── README.md                      # Документация на английском языке
└── README.ru.md                   # Документация на русском языке (этот файл)
```

---

## 🛡️ Ключевые инженерные стандарты

1. **Skeleton + Pluggable Modules (Каркас и сменные блоки):**
   Разделение проекта на нерушимый каркас (БД, Auth, брокер очередей, события) и изолированные сменные модули (Disposable Modules), генерируемые ИИ. При изменении требований модуль перегенерируется с нуля без рефакторинга ядра.
2. **Матрица делегирования (Delegation Matrix):**
   * **Зона 1 (100% AI):** чистые функции, DTO, утилиты, верстка по дизайн-системе, юнит-тесты.
   * **Зона 2 (50/50 AI + Человек):** бизнес-эндпоинты, воркеры очередей, внешние интеграции (строго после фиксации манифеста сбоев).
   * **Зона 3 (0% AI / Архитектор):** схема БД, финансовые операции, модель прав (RBAC/ABAC), безопасность (только через Confirmation Gate).
3. **Предпроектный DESIGN-манифест (Zero Vibe Coding):**
   Перед написанием любой нетривиальной логики агент фиксирует инварианты, конечный автомат (State Machine) и сценарии сбоев (Failure Modes: сетевые таймауты, дубликаты, идемпотентность).
4. **Automated Verification Gate (Автоматическая верификация):**
   Агент **не считает задачу завершенной**, пока не запустит проверочные команды (`typecheck`, `lint`, `test`) с получением Exit Code 0. Каждая итерация обязана содержать тесты негативных и краевых сценариев.
   * `./scripts/verify-project.sh` запускает только подтверждённые onboarding-команды из локального профиля; `./scripts/security-scan.sh` выполняет dependency-free baseline-поиск секретов.
   * CI workflow `.github/workflows/verification.yml` запускает тот же Gate на push в `main`, pull request в `main` и ручном запуске; он использует read-only permissions, не сохраняет checkout credentials и проверяет локальные Markdown-ссылки.
5. **Безопасная синхронизация Git (Safe Remote Sync):**
   Проверка удаленной ветки (`git fetch origin && git status -uno`) перед началом работ. Если локальная ветка отстает — агент **останавливается и предупреждает пользователя** (запрет слепого авто-пулла). Каждая успешная итерация фиксируется атомарным коммитом (Conventional Commits).
6. **Context7 & Discrepancy Policy:**
   * Проверка актуальных версий библиотек и сигнатур SDK через Context7 MCP во избежание галлюцинаций устаревших API. Согласование с человеком только при критических breaking changes.
7. **Adaptive Agent Routing:**
   * Существующие Delegation Zones 1/2/3 отвечают за ответственность и риск.
   * Для нетривиальной работы основной агент выступает оркестратором: определяет контракт, делегирует содержательную работу worker-агентам, проверяет evidence, запускает gates, интегрирует и принимает результат.
   * По умолчанию используется `orchestrated`; `single` остаётся для тривиальных задач и явного fallback, а `fixed-pipeline`, `side-research`, `parallel` и `hierarchical` описывают специализированные формы работы.
   * В длительных сессиях хранится task ledger и checkpoint после каждого gate; сырые транскрипты не накапливаются в основном контексте.
   * Checkpoint не равен commit: commit создаётся только после зелёного gate, одной атомарной задачей, а push и PR остаются отдельными действиями.
   * Verification & Safety добавляет pre-change impact checks, positive/negative/security/regression слои, безопасные probes и targeted escalation.
   * Vendor-specific runtime-сервер не требуется; оркестрация остаётся документированной ролью.
   * Выбор конкретных моделей в стандарт не входит.
   * Подробности: [docs/agent-routing.md](docs/agent-routing.md) и [docs/verification.md](docs/verification.md).

---

## ⚡ Максимально автоматический онбординг (Zero-Friction)

Вам **не нужно вручную описывать проект** или заполнять спецификации. Агент сделает это по протоколу [docs/onboarding-protocol.md](docs/onboarding-protocol.md) в автоматическом, полуавтоматическом или ручном режиме.

### Сценарий А: Автоматический brownfield

Отправьте агенту:

> **Промпт для агента:**
> ```text
> Выполни протокол онбординга из docs/onboarding-protocol.md.
> Изучи текущий репозиторий, определи Brownfield, извлеки фактический стек,
> структуру, команды проверки и существующие документы.
> Подготовь неразрушающее обновление AGENTS.md и docs/.
> Не задавай вопросы о фактах, которые видно из файлов.
> Покажи отчёт о найденном, сохранённом, добавленном и требующем решения.
> ```

### Сценарий Б: Новый greenfield-проект

> **Промпт для агента:**
> ```text
> Выполни протокол онбординга для нового проекта.
> Определи неизвестные развилки, задай только необходимые вопросы с
> рекомендациями, затем заполни документацию подтверждёнными значениями.
> Покажи итоговое резюме перед применением необратимых изменений.
> ```

### Сценарий В: Безопасная подготовка через `init-project.sh`

```bash
/path/to/agent-starter-kit/scripts/init-project.sh --yes /путь/к/новому-проекту
/path/to/agent-starter-kit/scripts/init-project.sh --dry-run /путь/к/проекту
/path/to/agent-starter-kit/scripts/init-project.sh --update /путь/к/существующему-проекту
```

Скрипт добавляет только отсутствующие файлы, не перезаписывает существующие `AGENTS.md`, `CLAUDE.md`, `.gitignore`, `docs/*` и инструменты в `scripts/`, а затем передаёт проект агенту для сканирования и заполнения. В целевой проект попадают универсальный dispatcher, baseline scanner и шаблон профиля; активный профиль агент создаёт по манифестам. `--update` предназначен только для существующего проекта и не создаёт новый каталог.

### Сценарий Г: Ручной режим

Агент может подготовить поля для ручного заполнения. Ручные значения имеют приоритет и не заменяются автоматически.

---

## 🛠️ Базовый эталонный стек (Редакция 2026)

- **Среда выполнения:** Node.js 24 LTS / Node.js 26 Current (ожидается LTS в октябре 2026) / Bun 1.3+ / Python 3.13–3.14 / Go 1.27+ / TypeScript 5.8+
- **Фронтенд:** React / Next.js (App Router) / Astro / Tailwind CSS
- **Бэкенд:** Next.js Server Actions / FastAPI / Go microservices / WebSockets / BullMQ (Redis)
- **Базы данных:** PostgreSQL, Drizzle ORM, Redis
- **AI & RAG:** LLM APIs (Anthropic Claude, OpenAI GPT, Gemini), pgvector + HNSW, ONNX Runtime
- **Инфраструктура:** Docker, Coolify / Dokploy (PaaS), GitHub Actions (CI/CD), Linux (Bash, Nginx)

---

<div align="center">
  <p>
    <a href="https://avpdev.com/"><strong>Aliaksei Patskevich (AVPDev)</strong></a><br />
    <small>AI SOLUTIONS ARCHITECT &bull; <a href="https://github.com/AVP-Dev">GITHUB</a> &bull; <a href="https://t.me/AVP_Dev">TELEGRAM</a></small>
  </p>
</div>

