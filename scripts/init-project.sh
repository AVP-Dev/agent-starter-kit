#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: init-project.sh
# Purpose: Initialize AI Engineering Standard & Rules in any target repository.
# Ecosystem: Universal AI Coding Agents (Gemini Antigravity, Claude Code, Cursor, Windsurf, Roo Code, Cline, Codex, etc.)
# Usage: ./init-project.sh /path/to/target-project
# ==============================================================================

if [ "$#" -lt 1 ]; then
  echo "Использование: $0 <путь-к-целевому-проекту>"
  echo "Пример: $0 ~/work/my-new-app"
  exit 1
fi

TARGET_DIR="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STARTER_KIT_DIR="$(dirname "$SCRIPT_DIR")"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Директория '$TARGET_DIR' не существует. Создать? (y/n)"
  read -r answer
  if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    mkdir -p "$TARGET_DIR"
  else
    echo "Отмена."
    exit 1
  fi
fi

echo "Инициализация стандартов AI Engineering в: $TARGET_DIR"

# 1. Копируем AGENTS.md (открытый стандарт SSOT)
cp "$STARTER_KIT_DIR/AGENTS.md" "$TARGET_DIR/"

# 2. Создаем симлинк CLAUDE.md -> AGENTS.md для Claude Code
(cd "$TARGET_DIR" && ln -sf AGENTS.md CLAUDE.md)

# 3. Копируем директорию docs/ без перезаписи существующих файлов (POSIX-совместимо)
mkdir -p "$TARGET_DIR/docs"
for doc in "$STARTER_KIT_DIR/docs/"*.md; do
  [ -f "$doc" ] || continue
  doc_name="$(basename "$doc")"
  if [ ! -f "$TARGET_DIR/docs/$doc_name" ]; then
    cp "$doc" "$TARGET_DIR/docs/$doc_name"
  fi
done

echo ""
echo "✅ Успешно инициализировано!"
echo "Файлы добавлены в $TARGET_DIR:"
echo "  ├── AGENTS.md                      # Универсальный открытый стандарт (SSOT для всех агентов)"
echo "  ├── CLAUDE.md -> AGENTS.md         # Симлинк для Claude Code"
echo "  └── docs/"
echo "      ├── onboarding-protocol.md     # Автоматический протокол сканирования и заполнения"
echo "      ├── architecture.md            # Каркас Skeleton + Modules"
echo "      ├── decisions.md               # Реестр ADR"
echo "      ├── state.md                   # Сессионный журнал"
echo "      ├── glossary.md                # Глоссарий"
echo "      └── design-manifest-template.md# Шаблон Zero Vibe Coding"
echo ""
echo "Следующие шаги (Автоматический онбординг):"
echo "Отправьте вашему ИИ-агенту запрос:"
echo "  \"Выполни протокол онбординга из docs/onboarding-protocol.md: просканируй репозиторий, заполни AGENTS.md и согласуй со мной резюме.\""
