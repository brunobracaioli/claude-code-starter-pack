#!/usr/bin/env bash
# pre-bash-guard.sh
# Bloqueia comandos destrutivos ou inseguros antes de executar.
# Comunicação com Claude Code:
#   - exit 0  → permite
#   - exit 2  → bloqueia e envia stderr de volta pro Claude
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Patterns proibidos. Cada linha é um regex (POSIX BRE).
# Adicione/remova conforme o contexto do projeto.
DANGEROUS_PATTERNS=(
  'rm -rf /'
  'rm -rf \*'
  'rm -rf ~'
  '> /dev/sda'
  'dd if=.* of=/dev/'
  'mkfs\.'
  ':\(\)\{ :\|:& \};:'   # fork bomb
  'curl .* \| sh'
  'curl .* \| bash'
  'wget .* \| sh'
  'wget .* \| bash'
  'chmod -R 777 /'
  'DROP DATABASE'
  'DROP TABLE'
  'TRUNCATE TABLE'
  'git push --force origin (main|master|production)'
  'git push -f origin (main|master|production)'
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "🚫 Comando bloqueado pelo pre-bash-guard: padrão '$pattern' detectado." >&2
    echo "Se for intencional, execute manualmente no terminal." >&2
    exit 2
  fi
done

# Avisa (não bloqueia) sobre comandos sensíveis em paths protegidos.
if echo "$COMMAND" | grep -qE 'rm .*\.env|rm .*secrets|rm .*credentials'; then
  echo "⚠️  Tentativa de remover arquivo sensível. Confirme se é intencional." >&2
  exit 2
fi

exit 0
