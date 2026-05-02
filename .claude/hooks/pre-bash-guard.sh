#!/usr/bin/env bash
# pre-bash-guard.sh
# Bloqueia comandos destrutivos ou inseguros antes de executar.
# Comunicação com Claude Code:
#   - exit 0  → permite
#   - exit 2  → bloqueia e envia stderr de volta pro Claude
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Patterns proibidos. Cada linha é um regex (POSIX ERE — usado com grep -E).
# Cuidado ao alterar: padrões frouxos geram falso-positivo; ancore o destino
# do comando (espaço ou fim de linha) sempre que possível.
DANGEROUS_PATTERNS=(
  'rm -rf +/([[:space:]]|$)'        # `rm -rf /` literal, não `rm -rf /tmp/...`
  'rm -rf +\*([[:space:]]|$)'
  'rm -rf +~([[:space:]]|$)'
  '> +/dev/sd[a-z]'
  'dd .*of=/dev/sd[a-z]'
  'mkfs\.'
  ':\(\)\{ *:\|: *& *\};:'           # fork bomb
  'curl [^|]* \| *(sh|bash)'
  'wget [^|]* \| *(sh|bash)'
  'chmod -R 777 +/([[:space:]]|$)'
  '\bDROP DATABASE\b'
  '\bDROP TABLE\b'
  '\bTRUNCATE TABLE\b'
  'git push +(--force|-f) +origin +(main|master|production)\b'
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "🚫 Comando bloqueado pelo pre-bash-guard: padrão '$pattern' detectado." >&2
    echo "Se for intencional, execute manualmente no terminal." >&2
    exit 2
  fi
done

# Avisa (não bloqueia) sobre comandos sensíveis em paths protegidos.
# Ancora `rm` no início de um comando (após start, ;, &, |) e só inspeciona
# argumentos até o próximo separador, evitando falso-positivo quando o nome
# sensível aparece em outro comando da mesma linha.
if echo "$COMMAND" | grep -qE '(^|[;&|]) *rm [^;&|]*(\.env(\.|$|[[:space:]/])|/secrets/|/credentials(\.|/))'; then
  echo "⚠️  Tentativa de remover arquivo sensível. Confirme se é intencional." >&2
  exit 2
fi

exit 0
