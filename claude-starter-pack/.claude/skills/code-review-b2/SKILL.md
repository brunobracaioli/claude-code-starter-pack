---
name: code-review-b2
description: Revisão de código no padrão B2 Tech. Use quando o usuário pedir "revise o código", "code review", "audite essas mudanças" ou ao final de feature/PR. Aplica checklist de Vertical Slice Architecture, DDD, Security by Design e qualidade da stack Python/Flask + Next.js/TypeScript.
allowed-tools: Read, Grep, Glob, Bash
---

# Code Review — Padrão B2 Tech

Esta skill orienta a revisão de código nos projetos da B2 Tech. Aplique o checklist abaixo
de forma **sistemática e objetiva**, sem inventar problemas. Se algo está bom, diga que está bom.

## Como conduzir a revisão

1. Identifique o **escopo da mudança** (`git diff` ou arquivos modificados).
2. Rode o checklist abaixo, anotando achados como `🔴 BLOCKER`, `🟡 MAJOR`, `🟢 NIT`.
3. No fim, gere um sumário com decisão: **APROVAR**, **APROVAR COM RESSALVAS**, ou **MUDANÇAS NECESSÁRIAS**.

## Checklist

### 1. Arquitetura (Vertical Slice + DDD)

- A mudança está num único slice/feature? Ou cruza fronteiras de forma indevida?
- Domain logic está isolado de infra (sem chamadas a banco/HTTP dentro de entities)?
- Application services orquestram, não implementam regras de domínio.
- Repositórios têm interface no domínio e implementação na infra.
- Sem leakage de detalhes de framework (Flask request, Next.js Request) no core.

### 2. Security by Design

- Inputs externos são validados na borda (Pydantic, Zod, etc).
- Queries usam parametrização (sem string interpolation em SQL).
- Secrets vêm de env/Secret Manager — nunca hardcoded.
- AuthN/AuthZ aplicada antes do business logic, não depois.
- Logs não expoem PII, tokens ou segredos.
- Headers de segurança presentes em endpoints públicos (CSP, HSTS, X-Content-Type-Options).

### 3. Qualidade da stack

**Python/Flask:**
- Type hints em funções públicas.
- `ruff check` passa sem warnings.
- Sem mutable default args.
- Context managers em recursos (DB, files, locks).

**Next.js/TypeScript:**
- Tipos explícitos nas APIs públicas (sem `any`).
- Server Components onde faz sentido (não força "use client" sem necessidade).
- Sem fetch sem error handling.
- Edge cases de loading/error tratados.

### 4. Testes

- Cobre o caso feliz **e** ao menos um edge case por nova função pública.
- Testes lêem como spec (nome do teste descreve o comportamento, não a implementação).
- Sem mocks excessivos (sinal de acoplamento).

### 5. Operacional

- Observabilidade: logs estruturados em pontos de decisão.
- Errors propagam com contexto (não engole exceção sem logar).
- Migrations reversíveis (UP + DOWN).
- Feature flags para mudanças de risco em prod.

## Formato do output

```markdown
## Code Review — <branch/PR>

**Escopo:** <breve descrição em 1 linha>

### 🔴 Blockers
- [arquivo:linha] descrição + sugestão

### 🟡 Major
- [arquivo:linha] descrição + sugestão

### 🟢 Nits
- [arquivo:linha] descrição

### ✅ Pontos positivos
- <o que ficou bem feito>

### Decisão
**APROVAR | APROVAR COM RESSALVAS | MUDANÇAS NECESSÁRIAS**
```

## O que NÃO fazer

- Não invente problemas pra parecer rigoroso.
- Não reescreva o código todo — sugira a mudança mínima.
- Não bloqueie por estilo se prettier/ruff já aceita.
- Não duplique o que linters/typecheck já pegam — foque no que humano precisa ver.

## Referências adicionais

Para regras específicas de stack, consulte:
- `references/python-flask-checklist.md` (se existir)
- `references/nextjs-checklist.md` (se existir)
- `references/security-deep-dive.md` (se existir)
