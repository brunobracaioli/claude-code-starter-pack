#!/usr/bin/env bash
# post-edit-format.sh
# Roda formatação + lint após Write/Edit/MultiEdit.
# Roda em paralelo onde possível e silencioso quando passa.
# Se algo falhar, escreve mensagem objetiva no stderr pro Claude se auto-corrigir.
set -uo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# Sai cedo se não tem path (algumas variantes de Edit não passam path)
[ -z "$FILE_PATH" ] && exit 0

# Sai cedo se arquivo não existe (pode ter sido renomeado/removido)
[ ! -f "$FILE_PATH" ] && exit 0

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$PROJECT_DIR"

ext="${FILE_PATH##*.}"
errors=""

case "$ext" in
  ts|tsx|js|jsx|mjs|cjs)
    # JS/TS stack — usa pnpm se disponível, senão npm, senão npx direto
    if command -v pnpm >/dev/null 2>&1 && [ -f "pnpm-lock.yaml" ]; then
      pnpm prettier --write "$FILE_PATH" 2>/dev/null || true
      pnpm eslint --fix "$FILE_PATH" 2>/dev/null || errors+="eslint falhou em $FILE_PATH\n"
    elif [ -f "package.json" ]; then
      npx --no-install prettier --write "$FILE_PATH" 2>/dev/null || true
      npx --no-install eslint --fix "$FILE_PATH" 2>/dev/null || errors+="eslint falhou em $FILE_PATH\n"
    fi
    ;;

  py)
    # Python stack — ruff (rápido) + mypy só se config existir
    if command -v ruff >/dev/null 2>&1; then
      ruff format "$FILE_PATH" 2>/dev/null || true
      ruff check --fix "$FILE_PATH" 2>/dev/null || errors+="ruff falhou em $FILE_PATH\n"
    fi
    ;;

  json)
    # JSON valido?
    if command -v jq >/dev/null 2>&1; then
      jq empty "$FILE_PATH" 2>/dev/null || errors+="JSON inválido em $FILE_PATH\n"
    fi
    ;;

  go)
    command -v gofmt >/dev/null 2>&1 && gofmt -w "$FILE_PATH" 2>/dev/null || true
    ;;

  rs)
    command -v rustfmt >/dev/null 2>&1 && rustfmt "$FILE_PATH" 2>/dev/null || true
    ;;
esac

# Se houve erro de lint, retorna 2 pra Claude saber que precisa corrigir
if [ -n "$errors" ]; then
  echo -e "$errors" >&2
  exit 2
fi

exit 0
