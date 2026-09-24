#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf '%s\n' "Использование: $0 [--dry-run] [--yes] [--update] <путь-к-проекту>" \
    "  --dry-run  показать изменения без их применения" \
    "  --yes      создать отсутствующую директорию без вопроса" \
    "  --update   обновить существующий проект, добавив только отсутствующие файлы"
}

DRY_RUN=0
ASSUME_YES=0
UPDATE_MODE=0
TARGET_DIR=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --yes)
      ASSUME_YES=1
      shift
      ;;
    --update)
      UPDATE_MODE=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      printf 'Неизвестная опция: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [ -n "$TARGET_DIR" ]; then
        printf 'Указан более чем один путь: %s\n' "$1" >&2
        exit 1
      fi
      TARGET_DIR="$1"
      shift
      ;;
  esac
done

if [ "$#" -gt 0 ]; then
  if [ -n "$TARGET_DIR" ]; then
    printf 'Указан более чем один путь: %s\n' "$1" >&2
    exit 1
  fi
  TARGET_DIR="$1"
fi

if [ -z "$TARGET_DIR" ]; then
  usage >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
STARTER_KIT_DIR="$(dirname "$SCRIPT_DIR")"

if [ ! -f "$STARTER_KIT_DIR/AGENTS.md" ]; then
  printf 'Не найден AGENTS.md стартер-кита: %s\n' "$STARTER_KIT_DIR" >&2
  exit 1
fi

if [ -e "$TARGET_DIR" ] && [ ! -d "$TARGET_DIR" ]; then
  printf 'Путь существует и не является директорией: %s\n' "$TARGET_DIR" >&2
  exit 1
fi

if [ "$UPDATE_MODE" -eq 1 ] && [ ! -d "$TARGET_DIR" ]; then
  printf 'Режим --update требует существующую директорию проекта: %s\n' "$TARGET_DIR" >&2
  exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    printf 'Dry-run: будет создана директория %s\n' "$TARGET_DIR"
  elif [ "$ASSUME_YES" -eq 1 ]; then
    mkdir -p "$TARGET_DIR"
  elif [ -t 0 ]; then
    printf 'Директория "%s" не существует. Создать? (y/n) ' "$TARGET_DIR"
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
      mkdir -p "$TARGET_DIR"
    else
      printf 'Отменено.\n'
      exit 0
    fi
  else
    printf 'Директория не существует. Используйте --yes для неинтерактивного создания.\n' >&2
    exit 1
  fi
fi

if [ "$DRY_RUN" -eq 0 ]; then
  TARGET_DIR="$(cd "$TARGET_DIR" && pwd -P)"
fi

if [ -e "$TARGET_DIR/AGENTS.md" ] || [ -L "$TARGET_DIR/AGENTS.md" ]; then
  if [ ! -f "$TARGET_DIR/AGENTS.md" ] && [ ! -L "$TARGET_DIR/AGENTS.md" ]; then
    printf 'Путь AGENTS.md существует и не является файлом: %s\n' "$TARGET_DIR/AGENTS.md" >&2
    exit 1
  fi
fi

if [ -e "$TARGET_DIR/CLAUDE.md" ] || [ -L "$TARGET_DIR/CLAUDE.md" ]; then
  if [ ! -f "$TARGET_DIR/CLAUDE.md" ] && [ ! -L "$TARGET_DIR/CLAUDE.md" ]; then
    printf 'Путь CLAUDE.md существует и не является файлом: %s\n' "$TARGET_DIR/CLAUDE.md" >&2
    exit 1
  fi
fi

if [ -e "$TARGET_DIR/docs" ] || [ -L "$TARGET_DIR/docs" ]; then
  if [ ! -d "$TARGET_DIR/docs" ]; then
    printf 'Путь docs существует и не является директорией: %s\n' "$TARGET_DIR/docs" >&2
    exit 1
  fi
fi

for doc in "$STARTER_KIT_DIR/docs/"*.md; do
  [ -f "$doc" ] || continue
  destination="$TARGET_DIR/docs/$(basename "$doc")"
  if [ -e "$destination" ] || [ -L "$destination" ]; then
    if [ ! -f "$destination" ] && [ ! -L "$destination" ]; then
      printf 'Путь документа существует и не является файлом: %s\n' "$destination" >&2
      exit 1
    fi
  fi
done

PROJECT_KIND="greenfield"
for marker in .git AGENTS.md CLAUDE.md README.md README.ru.md docs package.json pnpm-lock.yaml yarn.lock bun.lockb pyproject.toml requirements.txt go.mod Cargo.toml Dockerfile Makefile src app lib tests; do
  if [ -e "$TARGET_DIR/$marker" ]; then
    PROJECT_KIND="brownfield"
    break
  fi
done

printf 'Режим: %s\n' "$([ "$UPDATE_MODE" -eq 1 ] && printf 'обновление' || printf 'инициализация')"
printf 'Трек-кандидат: %s\n' "$PROJECT_KIND"
printf 'Целевой проект: %s\n' "$TARGET_DIR"

copy_if_missing() {
  source_path="$1"
  destination_path="$2"
  destination_name="$(basename "$destination_path")"

  if [ -e "$destination_path" ] || [ -L "$destination_path" ]; then
    printf 'Сохранено: %s\n' "$destination_name"
    return 0
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    printf 'Будет добавлено: %s\n' "$destination_name"
    return 0
  fi

  cp "$source_path" "$destination_path"
  printf 'Добавлено: %s\n' "$destination_name"
}

if [ -e "$TARGET_DIR/CLAUDE.md" ] || [ -L "$TARGET_DIR/CLAUDE.md" ]; then
  if [ -L "$TARGET_DIR/CLAUDE.md" ] && [ "$(readlink "$TARGET_DIR/CLAUDE.md" 2>/dev/null || true)" = "AGENTS.md" ]; then
    printf 'Сохранено: CLAUDE.md -> AGENTS.md\n'
  else
    printf 'Сохранено существующее CLAUDE.md без изменений\n'
  fi
elif [ "$DRY_RUN" -eq 1 ]; then
  printf 'Будет добавлено: CLAUDE.md -> AGENTS.md\n'
else
  if ! ln -s AGENTS.md "$TARGET_DIR/CLAUDE.md"; then
    printf 'Не удалось создать symlink CLAUDE.md -> AGENTS.md. Операция остановлена без копирования файлов.\n' >&2
    exit 1
  fi
  printf 'Добавлено: CLAUDE.md -> AGENTS.md\n'
fi

if [ ! -d "$TARGET_DIR/docs" ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    printf 'Будет создано: docs/\n'
  else
    mkdir -p "$TARGET_DIR/docs"
    printf 'Создано: docs/\n'
  fi
else
  printf 'Сохранено: docs/\n'
fi

copy_if_missing "$STARTER_KIT_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"

for doc in "$STARTER_KIT_DIR/docs/"*.md; do
  [ -f "$doc" ] || continue
  copy_if_missing "$doc" "$TARGET_DIR/docs/$(basename "$doc")"
done

printf '\nПроверьте результат и запустите протокол онбординга агентом:\n'
printf '  1. Изучите docs/onboarding-protocol.md.\n'
printf '  2. Для Brownfield просканируйте манифесты, lockfiles, тесты и документацию.\n'
printf '  3. Для Greenfield ответьте только на вопросы, которые нельзя вывести из файлов.\n'
printf '  4. Попросите агента заполнить AGENTS.md и показать отчёт перед подтверждением.\n'
printf '\nСуществующие проектные файлы не перезаписываются.\n'
