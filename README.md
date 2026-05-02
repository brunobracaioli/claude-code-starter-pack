# Claude Code Starter Pack — B2 Tech Edition

Starter-pack mínimo e opinativo para projetos novos. Cobre os 4 pilares do Claude Code:

- **`.claude/settings.json`** → configuração determinística (permissões, env, attribution)
- **`.claude/hooks/`** → automações que rodam *toda vez, sem exceção* (lint, format, guardrails)
- **`.claude/skills/`** → conhecimento de domínio com progressive disclosure
- **`.claude-plugin/plugin.json`** → empacotamento opcional para distribuir tudo num marketplace privado

## Filosofia

Três regras que guiam tudo aqui:

1. **`settings.json` para o que é determinístico** — permissões, attribution, model. Nunca coloque "NEVER faça X" no `CLAUDE.md` se for possível enforçar via setting/hook.
2. **Hooks para o que precisa rodar 100% das vezes** — formatação, secrets scan, bloqueio de paths. Hooks são deterministas, `CLAUDE.md` é apenas conselho.
3. **Skills para conhecimento sob demanda** — convenções de DDD/VSA, security checklists, padrões de migration. Carregadas só quando relevantes (progressive disclosure).

## Estrutura

```
seu-projeto/
├── .claude/
│   ├── settings.json              ← Compartilhado no git (time inteiro)
│   ├── settings.local.json        ← Gitignored (preferências pessoais)
│   ├── hooks/
│   │   ├── pre-bash-guard.sh      ← Bloqueia comandos perigosos
│   │   ├── post-edit-format.sh    ← Formata após cada edição
│   │   └── pre-commit-secrets.sh  ← Scan de secrets antes de commits
│   └── skills/
│       ├── code-review-b2/
│       │   └── SKILL.md           ← Padrão de revisão da B2 Tech
│       └── security-check/
│           └── SKILL.md           ← Checklist Security by Design
├── .claude-plugin/                ← (Opcional) se for distribuir como plugin
│   └── plugin.json
└── CLAUDE.md                      ← Contexto do projeto (curto, humano)
```

## Quick start

```bash
# Copia o pack pra raiz do seu projeto
cp -r claude-starter-pack/.claude seu-projeto/
cp claude-starter-pack/CLAUDE.md seu-projeto/

# Torna os hooks executáveis
chmod +x seu-projeto/.claude/hooks/*.sh

# Testa
cd seu-projeto && claude
```

## O que NÃO entrou (de propósito)

- **Subagentes (`agents/`)** → adicione conforme necessidade real, evite genéricos.
- **Slash commands (`commands/`)** → use skills, são mais flexíveis e suportam supporting files.
- **MCP servers** → projeto-específico; configure via `.mcp.json` na raiz quando precisar.

## Customização B2 Tech

Os hooks e skills aqui assumem stack Python/Flask + Next.js/TypeScript. Ajuste os comandos
de format/lint nos scripts conforme a stack do projeto (Rust, Go, etc).
