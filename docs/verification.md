# Verification, Safety и Impact Policy

> **Назначение:** определить, что проверять до и после изменения, как обнаруживать риск до правки и когда передавать задачу более глубокой проверке.
>
> **Граница:** это политика для агента и проектного checklist. Универсальный dispatcher запускает только явно описанные project-local команды; команды lint, typecheck, test и security tooling определяются манифестами конкретного проекта.

## 1. Что означает coverage в Ките

Критичные инварианты связывай с проверяемым evidence: например, import-boundary checks для границ модулей, contract tests для API, constraints и transaction tests для целостности, integration tests для изоляции, migration smoke tests для схем. Автоматизируемые красные линии должны иметь обязательные проверки; если автоматизация невозможна, укажи явную процедуру ручной проверки и результат. Отсутствие evidence не считается успешной проверкой. Не меняй required=1 на required=0 ради прохождения gate.

Coverage — это не только процент строк. Для каждого изменения фиксируется, какие уровни проверки покрыты:

- **Static:** types, schemas, imports, formatting и dependency boundaries.
- **Positive:** основной успешный сценарий.
- **Negative:** невалидные входы, границы, отказ сервиса, timeout, duplicate и partial failure.
- **Security:** auth, permissions, tenant isolation, secrets, untrusted input и безопасная обработка внешних данных.
- **Regression:** существующие тесты и пользовательские инварианты, которые нельзя сломать.
- **Integration:** контракты, БД, очереди, API, workers и внешние адаптеры.
- **Acceptance:** конкретные acceptance invariants из DESIGN-манифеста.

## 2. Pre-change Impact Gate

Перед изменением оцени его влияние. Для локальной правки достаточно посмотреть затронутый код или документ и выбрать проверку. Для рискованной работы используй применимые шаги:

1. Перечислить затронутые файлы, модули, контракты и потребителей.
2. Прочитать текущие инварианты и существующие тесты рядом с изменением.
3. Определить, может ли изменение повлиять на auth, data, API, queues, UI, migrations или external integrations.
4. Зафиксировать baseline: какие проверки проходят до изменения.
5. Определить rollback или безопасный revert для изменения.
6. Сформулировать negative и security-сценарии до написания решения.
7. Уточнить область и риск локальной проверкой. Запросить решение, если остаётся существенная развилка в контракте, правах или последствиях.

Impact-check не должен превращаться в чтение всего репозитория. Он ограничен изменяемым dependency surface и зоной риска.

## 3. Что проверять по классу задачи

| Scope | Релевантные проверки |
|---|---|
| Документация | ссылки и соответствие описания фактическому поведению |
| Zone 1, чистая функция или локальный UI | positive, boundary/negative, regression |
| Zone 1, parser/DTO/validator | positive, malformed input, boundary, regression |
| Zone 2, endpoint/worker/integration | positive, negative, security, integration, idempotency |
| Изменение shared contract | все затронутые consumers, schema compatibility, regression |
| Изменение UI | positive, negative states, keyboard/a11y, responsive regression |
| Zone 3 или необратимое действие | human Confirmation Gate, security, rollback/stop plan, post-action evidence |

Сравни результаты с baseline. Исправь новые регрессии в рамках задачи. Укажи исходные падения, недоступные проверки и причину. Добавляй тесты, когда они нужны для изменённого поведения, регрессии или выполнения проектного требования.

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

Ограничивай чтение областью проверки. Повторяй попытку при новых данных, временном сбое или другом подходе. Если рабочий бюджет исчерпан, измени формат или отдай подтверждённый результат с указанием оставшегося пробела. Жёсткий согласованный лимит или ограничение среды останавливает затронутую операцию.

Длина отчёта, комментария и diff служит ориентиром. Сохраняй существенные выводы и доказательства. Если площадка ограничивает комментарий, помести в него итог и ссылку на подробный отчёт либо разбей ответ на части, если формат это допускает.

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

Кратко укажи, что проверено, с каким результатом и что осталось. Для важных проверок пригодятся следующие сведения:

- command или проверка;
- scope и commit/revision;
- результат `passed`, `failed` или `blocked`;
- negative/security сценарии;
- ссылка на evidence;
- причина failure и следующий шаг;
- для нетривиальной работы — `Measured outcome` с 1–2 метриками.

В `state.md` и task ledger хранится ссылка на результат, а не полный transcript тестового процесса.

## 9. Что фиксируется в DESIGN-манифесте

Для задачи со значимым риском выбери применимые поля:

- `Pre-change impact check`;
- `Verification layers`;
- `Rollback / stop plan`;
- `Context budget / escalation trigger`;
- `Measured outcome`.

Для Lightweight задачи достаточно трёх строк: цель, инвариант, команда проверки.

## 10. Project-local verification profile

Стартер-кит добавляет универсальный dispatcher, но не угадывает команды конкретного проекта. В корне Кита есть собственный `scripts/verification-profile.tsv` для его smoke-gate; он не копируется в целевой проект. После чтения манифестов агент создаёт в целевом проекте отдельный `scripts/verification-profile.tsv` на основе `docs/verification-profile.example.tsv`.

Формат TSV: `name<TAB>layer<TAB>required<TAB>command`.

- `name` — уникальное имя проверки без пробелов;
- `layer` — `static`, `positive`, `negative`, `security`, `regression`, `integration` или `build`;
- `required` — `1` для blocking gate или `0` для предупреждения;
- `command` — команда без табов и секретов, запускаемая из корня проекта.

Dispatcher запускает команды из профиля через `bash -c`, не наследует скрытые аргументы и не меняет права доступа:

```bash
./scripts/verify-project.sh --list
./scripts/verify-project.sh --only static,security
./scripts/verify-project.sh --dry-run
./scripts/verify-project.sh
```

`--list` и `--dry-run` показывают имя, layer и command до запуска, чтобы review не зависел от догадок.

Диспетчер валидирует весь профиль до запуска команд. При отсутствующем или невалидном профиле он возвращает код `2`. Падение любой выбранной команды с `required=1` даёт код `1`, а падение необязательной проверки — предупреждение. Итог включает число успешных обязательных проверок.

Полный Acceptance Gate — запуск всего активного профиля без фильтра, с минимум одной обязательной проверкой и успешным прохождением всех обязательных команд. Если обязательных проверок в выбранном наборе нет, обычный запуск возвращает код `2`. Для диагностики предусмотрен `--diagnostic`; частичный `--only`, диагностика, `--list` и `--dry-run` не подтверждают полную приёмку.

`scripts/security-scan.sh` — dependency-free baseline для tracked и неигнорируемых untracked файлов, включая tracked generated artifacts: private key material, AWS/GCP key patterns, credentialed database URLs, вероятные sensitive assignments и `.env`-файлы. Сканер не печатает найденные значения, только `path:line` и категорию; ошибка чтения или перечисления файлов завершает сканирование с кодом `2`. Он не заменяет SAST, dependency audit, container scan или DAST; утверждённые проектные инструменты добавляются отдельными строками `security` в профиль.

Профиль не должен содержать токены, пароли или приватные ключи. Если команда может раскрыть секрет, она не включается в verification gate до отдельного решения и безопасного способа маскирования.

## 11. Онбординг verification profile

1. Прочитать manifests, lockfiles, CI и существующие scripts.
2. Выбрать команды, которые уже подтверждены проектом; не устанавливать инструменты молча.
3. Создать `scripts/verification-profile.tsv` и заполнить примеры для фактического stack.
4. Добавить baseline secret scan и доступные security checks с явными `required` и failure semantics.
5. Запустить `./scripts/verify-project.sh --dry-run`, затем полный gate.
6. Зафиксировать baseline, ограничения окружения и evidence в DESIGN-манифесте и `state.md` целевого проекта.

Если проект не может запустить слой проверки, агент фиксирует его как `blocked` с причиной в DESIGN-манифесте и `state.md`; отсутствующая команда не добавляется в профиль как фиктивная успешная проверка.

## 12. CI и release gate

Workflow стартер-кита `.github/workflows/verification.yml` запускает локальный профиль на push в `main`, pull request в `main` и ручном запуске. Workflow использует `contents: read`, `pull_request` без trusted-base secrets, checkout без persistent credentials, проверяет Markdown-ссылки и чистоту рабочего дерева. Установщик не переносит workflow в целевые проекты. Подключай подтверждённые команды через CI проекта.

Release sequence: зелёный Gate → Conventional Commit → push → подтверждённый CI check → annotated tag вида `vYYYY.N.P` → push tag. Непустой или красный Gate блокирует tag; GitHub Release создаётся из уже проверенного tag.

## 13. Итоговый checklist

Definition of Done: подтверждены применимые инварианты, выполнены обязательные проверки, обновлены затронутые документы и зафиксирован результат. Заблокированная обязательная проверка означает blocked, а не accepted; исходные несвязанные падения сообщаются отдельно.

- [ ] Проверки определены до изменения.
- [ ] Есть positive, negative и regression coverage.
- [ ] Security риски явно рассмотрены.
- [ ] Создан project-local verification profile с подтверждёнными командами.
- [ ] Выполнен secret baseline и добавлены доступные SAST/SCA проверки.
- [ ] Есть safe probe или dry-run, если изменение рискованное.
- [ ] Известен rollback/stop path.
- [ ] Контекст проверки ограничен impact surface.
- [ ] При сомнении запущена targeted deep check.
- [ ] Результат имеет evidence и измеримый outcome.
- [ ] Для интеграции или релиза проверены принятые в проекте обязательные гейты.
