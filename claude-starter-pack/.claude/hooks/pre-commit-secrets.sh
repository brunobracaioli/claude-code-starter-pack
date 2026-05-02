#!/usr/bin/env bash
# pre-commit-secrets.sh
# Roda apenas em comandos `git commit` / `git push`.
# Bloqueia se detectar padrões de secrets nos arquivos staged.
set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Ativa só pra git commit/push (early return em qualquer outra coisa)
if ! echo "$COMMAND" | grep -qE '^git (commit|push)'; then
  exit 0
fi

# Padrões de secrets (regex). Mantenha conservador pra evitar falsos positivos.
SECRET_PATTERNS=(
  '-----BEGIN (RSA|OPENSSH|EC|DSA|PGP) PRIVATE KEY-----'
  'AKIA[0-9A-Z]{16}'                              # AWS Access Key
  'aws_secret_access_key\s*=\s*[A-Za-z0-9/+=]{40}' # AWS Secret
  'ghp_[A-Za-z0-9]{36}'                            # GitHub PAT
  'gho_[A-Za-z0-9]{36}'                            # GitHub OAuth
  'sk-ant-api[0-9]{2}-[A-Za-z0-9_-]{90,}'          # Anthropic API key
  'sk-[A-Za-z0-9]{48}'                             # OpenAI key (legado)
  'xox[baprs]-[A-Za-z0-9-]{10,}'                   # Slack tokens
  'EAA[A-Za-z0-9]{50,}'                            # Meta/FB long-lived tokens
)

# Pega arquivos staged
STAGED=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)
[ -z "$STAGED" ] && exit 0

found=""
while IFS= read -r file; do
  [ ! -f "$file" ] && continue
  # Pula binários
  if file "$file" 2>/dev/null | grep -q 'binary'; then continue; fi

  for pattern in "${SECRET_PATTERNS[@]}"; do
    if grep -qE "$pattern" "$file" 2>/dev/null; then
      found+="  • $file (padrão: $pattern)\n"
      break
    fi
  done
done <<< "$STAGED"

if [ -n "$found" ]; then
  echo "🚨 Possíveis secrets detectados nos arquivos staged:" >&2
  echo -e "$found" >&2
  echo "Remova os secrets ou mova-os para .env antes de commitar." >&2
  echo "Se for falso positivo, faça o commit manualmente fora do Claude." >&2
  exit 2
fi

exit 0
