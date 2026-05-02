# <Nome do Projeto>

> Esse arquivo é lido pelo Claude no início de toda conversa.
> **Mantenha curto e humano.** Para regras determinísticas, use `settings.json`.
> Para conhecimento sob demanda, use `.claude/skills/`.

## Stack

- **Backend:** 
- **Frontend:** 
- **Infra:** 
- **Padrão:** 

## Comandos essenciais

```bash
# Setup
make install            # instala deps Python + Node
make dev                # sobe dev server (ambos)

# Qualidade
make lint               # ruff + eslint
make typecheck          # mypy + tsc
make test               # pytest + vitest

# Deploy
make deploy-staging
make deploy-prod        # roda smoke tests primeiro
```

## Convenções

- **Branches:** `feat/<slice>-<short-desc>`, `fix/<short-desc>`, `chore/<short-desc>`
- **Commits:** Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`)
- **PRs:** Sempre referencie a issue, descreva o "porquê", não só o "o quê"
- **Tests:** TDD onde a complexidade pede; testes lêem como spec

## Estrutura

```

```

## Quando pedir ajuda

- Para revisão: invoque a skill `code-review-b2`.
- Para auditoria de segurança: invoque a skill `security-check`.
- Para regras determinísticas (formatação, secrets, comandos perigosos): já há hooks rodando.

## O que NÃO fazer

- Não criar arquivos `.env*` — use Secret Manager / Supabase secrets.
- Não usar `any` em TypeScript sem comentário justificando.
- Não fazer `git push --force` em `main`.
- Não adicionar deps sem rodar audit primeiro.
