---
name: security-check
description: Auditoria de segurança Security by Design. Use quando o usuário pedir "audite a segurança", "security review", "verifique vulnerabilidades", ou antes de subir feature pra produção. Cobre OWASP Top 10, gestão de secrets, AuthN/AuthZ, supply chain e logs.
allowed-tools: Read, Grep, Glob, Bash
---

# Security Check — Security by Design

Auditoria pragmática de segurança. Evita teatro: foca em ameaças reais para a stack
do projeto (Python/Flask, Next.js/TS, GCP/Cloudflare/Supabase).

## Modo de operação

1. Comece perguntando (ou inferindo) o **superfície de ataque**: API pública? Login? Pagamentos? Upload?
2. Rode o checklist priorizado (ameaças mais prováveis primeiro).
3. Classifique findings como **CRÍTICO** (bloqueia deploy), **ALTO**, **MÉDIO**, **INFO**.
4. Para cada finding: descreva ameaça → impacto → fix concreto.

## Checklist priorizado

### 🔥 CRÍTICO — sempre verificar

**Secrets management**
- [ ] Nenhum secret hardcoded (grep por `api_key`, `password`, `secret`, `token` em código).
- [ ] `.env` no `.gitignore` e nunca commitado (`git log --all --full-history -- .env`).
- [ ] Secrets em runtime vêm de Secret Manager / env vars, não de arquivos no repo.
- [ ] Rotação documentada para secrets de produção.

**Injeção (SQLi, XSS, Command Injection)**
- [ ] Queries SQL parametrizadas (`?` ou named params), nunca f-string/template literal.
- [ ] User input nunca concatenado em comandos shell (`subprocess` com lista, não string).
- [ ] React/Next renderizando user content com escape automático (sem `dangerouslySetInnerHTML` sem sanitização).
- [ ] Headers `Content-Type` e `X-Content-Type-Options: nosniff` em respostas.

**AuthN/AuthZ**
- [ ] Toda rota não-pública tem middleware de auth aplicado.
- [ ] Authorization checa permissão *do recurso específico*, não só "está logado".
- [ ] JWT com expiração curta + refresh token; assinatura verificada com chave pública/HMAC server-side.
- [ ] Senhas com bcrypt/argon2 (cost ≥ 12), nunca MD5/SHA1.
- [ ] MFA disponível para contas privilegiadas.

### 🟠 ALTO

**Inputs e validação**
- [ ] Schema validation na borda (Pydantic, Zod) — incluindo tamanho máximo de strings/arrays.
- [ ] Rate limiting em endpoints sensíveis (login, signup, password reset).
- [ ] CSRF tokens em forms server-rendered (ou SameSite=Strict cookies).
- [ ] CORS configurado restritivamente (não `*` em prod).

**Sessões e cookies**
- [ ] Cookies de sessão: `HttpOnly`, `Secure`, `SameSite=Lax/Strict`.
- [ ] Logout invalida sessão server-side (não só apaga cookie).
- [ ] Session fixation: novo session ID após login.

**File upload / Storage**
- [ ] Whitelist de tipos MIME (verificada no servidor, não só no cliente).
- [ ] Tamanho máximo enforced.
- [ ] Arquivos servidos de domínio separado ou com `Content-Disposition: attachment`.
- [ ] Não executa nada do que foi uploaded.

### 🟡 MÉDIO

**Supply chain**
- [ ] Lockfiles commitados (`package-lock.json`, `pnpm-lock.yaml`, `requirements.lock`).
- [ ] Dependências auditadas (`npm audit`, `pip-audit`) — sem CVE crítica/alta.
- [ ] Dependabot/Renovate ativo.

**Logs e observabilidade**
- [ ] Logs **não** contêm: tokens, senhas, PII completa, payment info.
- [ ] Eventos de segurança logados: login fail, permission denied, password change.
- [ ] Logs estruturados (JSON) com correlation ID.

**Infra (GCP/Cloudflare)**
- [ ] Cloud Run/Functions com IAM mínimo (não Editor/Owner).
- [ ] Cloud SQL com IP privado, não público.
- [ ] WAF (Cloudflare) ativo nas APIs públicas.
- [ ] HTTPS enforced (redirect 301 de HTTP).

### 🔵 INFO

- [ ] Header `Strict-Transport-Security` (HSTS) em domínios de produção.
- [ ] Header `Content-Security-Policy` mesmo que permissivo no início.
- [ ] `robots.txt` e `security.txt` configurados.
- [ ] Mensagens de erro genéricas para o usuário, detalhe só nos logs internos.

## Output esperado

```markdown
## Security Audit — <projeto/feature>

### Resumo executivo
- Findings críticos: N
- Findings altos: N
- Findings médios: N
- Status: ✅ OK PRA DEPLOY | ⚠️ DEPLOY COM RESSALVAS | 🛑 NÃO FAZER DEPLOY

### Findings

#### 🔥 CRÍTICO-01: <título curto>
**Onde:** `path/file.py:42`
**Ameaça:** <atacante consegue X>
**Impacto:** <dano concreto: vazamento de Y, escalada de privilégio, etc>
**Fix:**
```python
# antes
query = f"SELECT * FROM users WHERE id = {user_id}"
# depois
query = "SELECT * FROM users WHERE id = %s"
cursor.execute(query, (user_id,))
```

(repetir por finding)

### Próximos passos
1. <ação imediata>
2. <ação backlog>
```

## O que NÃO fazer

- Não recomende solução genérica ("use HTTPS") — verifique se já está aplicada.
- Não infle severidade. CRÍTICO é o que **realmente bloqueia deploy**.
- Não duplique o que SAST/DAST tools já pegariam — foque em logic flaws e config.
- Não pergunte demais antes de começar. Faça a varredura inicial e refine depois.
