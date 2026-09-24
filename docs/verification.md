# Verification, Safety и Impact Policy

> **Назначение:** определить, что проверять до и после изменения, как обнаруживать риск до правки и когда передавать задачу более глубокой проверке.
>
> **Граница:** это политика для агента и проектного checklist, а не универсальный test runner. Команды lint, typecheck, test и security tooling определяются манифестами конкретного проекта.

## 1. Что означает coverage в Ките

Coverage — это не только процент строк. Для каждого изменения фиксируется, какие уровни проверки покрыты:

- **Static:** types, schemas, imports, formatting и dependency boundaries.
- **Positive:** основной успешный сценарий.
- **Negative:** невалидные входы, границы, отказ сервиса, timeout, duplicate и partial failure.
- **Security:** auth, permissions, tenant isolation, secrets, untrusted input и безопасная обработка внешних данных.
- **Regression:** существующие тесты и пользовательские инварианты, которые нельзя сломать.
- **Integration:** контракты, БД, очереди, API, workers и внешние адаптеры.
- **Acceptance:** конкретные acceptance invariants из DESIGN-манифеста.

## 2. Pre-change Impact Gate

До редактирования кода агент обязан пройти короткий impact-check:

1. Перечислить затронутые файлы, модули, контракты и потребителей.
2. Прочитать текущие инварианты и существующие тесты рядом с изменением.
3. Определить, может ли изменение повлиять на auth, data, API, queues, UI, migrations или external integrations.
4. Зафиксировать baseline: какие проверки проходят до изменения.
5. Определить rollback или безопасный revert для изменения.
6. Сформулировать negative и security-сценарии до написания решения.
7. Остановиться и спросить человека, если scope или риск неясны.

Impact-check не должен превращаться в чтение всего репозитория. Он ограничен изменяемым dependency surface и зоной риска.

## 3. Что проверять по классу задачи

| Scope | Минимальный набор |
|---|---|
| Zone 1, чистая функция или локальный UI | positive, boundary/negative, regression |
| Zone 1, parser/DTO/validator | positive, malformed input, boundary, regression |
| Zone 2, endpoint/worker/integration | positive, negative, security, integration, idempotency |
| Изменение shared contract | все затронутые consumers, schema compatibility, regression |
| Изменение UI | positive, negative states, keyboard/a11y, responsive regression |
| Zone 3 или необратимое действие | human Confirmation Gate, security, rollback/stop plan, post-action evidence |

Если проект не может запустить слой проверки, это фиксируется как ограничение, а не silently считается успешным.

## 4. Negative и security scenarios

Базовый список для анализа изменений:

- пустой, `null`, неверный тип и boundary value;
- malformed JSON, schema mismatch и неожиданный формат;
- duplicate request, retry, race и конкурентная запись;
- timeout, network failure, partial response и недоступный dependency;
- stale cache, stale artifact и конфликт версий;
- недостаточная роль, чужой tenant/project и доступ к чужому ресурсу;
- untrusted document, prompt injection и вредоносный внешний input;
- secret в логах, error message, артефакте или checkpoint;
- rollback после неудачной миграции или необратимой операции.

Проверка должна доказывать инвариант, а не только отсутствие исключения.

## 5. Безопасная симуляция до изменения

Если изменение трудно проверить напрямую, сначала используется минимальный безопасный probe:

- schema validation на синтетическом payload;
- dry-run или plan без записи;
- контрактный тест с mock/fake dependency;
- проверка на временной fixture или изолированной базе;
- reverse-diff и impact analysis;
- проверка rollback-команды без её выполнения.

Probe не должен менять production, реальные платежи, права доступа или пользовательские данные. Если безопасный probe невозможен, требуется human approval или split task.

## 6. Контекст и budget проверки

Агент сначала выполняет детерминированные и локальные проверки, затем точечно расширяет контекст:

1. Сначала проверить изменённый scope.
2. Затем проверить непосредственных consumers.
3. Затем запустить связанные integration/regression tests.
4. Только при подтверждённом impact переходить к широкому сканированию.

Нельзя загружать весь лог, весь репозиторий или все соседние сессии без причины. В checkpoint записываются проверенные факты, evidence и оставшийся budget. При достижении лимита циклов, токенов или времени работа блокируется и эскалируется.

## 7. Когда нужна более глубокая проверка

Повысить глубину проверки нужно, если:

- гипотеза не подтверждена;
- найдено противоречие между документами и кодом;
- меняется shared contract или Skeleton;
- затрагиваются auth, permissions, tenant isolation или data ownership;
- есть concurrency, retry, partial failure или rollback;
- тест неожиданно проходит или неожиданно падает;
- агент не может объяснить, почему изменение безопасно;
- результат worker-а не проходит независимую проверку.

Действия: targeted probe, side-research, независимый reviewer, повышение reasoning, обновление DESIGN-манифеста или human gate. Нельзя просто повторять тот же цикл.

## 8. Evidence и результат

Каждый gate должен оставить структурированный результат:

- command или проверка;
- scope и commit/revision;
- результат `passed`, `failed` или `blocked`;
- negative/security сценарии;
- ссылка на evidence;
- причина failure и следующий шаг;
- для нетривиальной работы — `Measured outcome` с 1–2 метриками.

В `state.md` и task ledger хранится ссылка на результат, а не полный transcript тестового процесса.

## 9. Что фиксируется в DESIGN-манифесте

Для нетривиальной задачи фиксируются:

- `Pre-change impact check`;
- `Verification layers`;
- `Rollback / stop plan`;
- `Context budget / escalation trigger`;
- `Measured outcome`.

Для Lightweight задачи достаточно трёх строк: цель, инвариант, команда проверки.

## 10. Итоговый checklist

- [ ] Проверки определены до изменения.
- [ ] Есть positive, negative и regression coverage.
- [ ] Security риски явно рассмотрены.
- [ ] Есть safe probe или dry-run, если изменение рискованное.
- [ ] Известен rollback/stop path.
- [ ] Контекст проверки ограничен impact surface.
- [ ] При сомнении запущена targeted deep check.
- [ ] Результат имеет evidence и измеримый outcome.
- [ ] Push и commit не происходят при красном или неясном результате.
