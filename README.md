<div align="center">

<img src="claude-lendo.png" alt="Claude lendo" width="180">

# 🧰 Claude Code Starter Pack

### *B2 Tech Edition*

**Base mínima, opinativa e segura para começar qualquer projeto com Claude Code.**

Permissões determinísticas · Hooks que rodam 100% das vezes · Skills sob demanda · Empacotável como plugin.

<br>

![Claude Code](https://img.shields.io/badge/Claude_Code-v2.1%2B-D97757?style=for-the-badge&logo=anthropic&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-3FB950?style=for-the-badge)
![Stack](https://img.shields.io/badge/stack-Python_·_Next.js_·_GCP-1F6FEB?style=for-the-badge)
![Status](https://img.shields.io/badge/version-2.0-8957E5?style=for-the-badge)

</div>

---

## 📑 Índice

- [Por que existe](#-por-que-existe)
- [Os 4 pilares](#-os-4-pilares)
- [Filosofia](#-filosofia)
- [Estrutura](#-estrutura)
- [Quick start](#-quick-start)
- [Hooks](#-hooks)
- [Skills](#-skills)
- [Agents](#-agents)
- [Permissões](#-permissões-settingsjson)
- [Distribuir como plugin](#-distribuir-como-plugin)
- [Novidades da 2.0](#-novidades-da-20)
- [Decisões de escopo](#-decisões-de-escopo)

---

## 🎯 Por que existe

Todo projeto novo repete a mesma configuração de Claude Code: definir o que ele
pode rodar sem perguntar, garantir que segredos nunca vazem, padronizar formatação
e ensinar as convenções do time. Este pack entrega isso pronto — **copie para a raiz
do projeto e comece com guardrails de segurança e qualidade desde o primeiro prompt.**

---

## 🏛️ Os 4 pilares

| Pilar | Arquivo | Papel |
|-------|---------|-------|
| ⚙️ **Configuração** | `.claude/settings.json` | Permissões, env e attribution — o que é **determinístico**. |
| 🪝 **Hooks** | `.claude/hooks/*.sh` | Automações que rodam *toda vez, sem exceção* (lint, format, guardrails). |
| 🧠 **Skills** | `.claude/skills/*/SKILL.md` | Conhecimento de domínio com *progressive disclosure* — carregado só quando relevante. |
| 📦 **Plugin** | `.claude-plugin/plugin.json` | Empacotamento opcional para distribuir tudo num marketplace privado. |

---

## 💡 Filosofia

> Três regras guiam cada decisão deste pack:

1. **`settings.json` para o determinístico.** Permissões, attribution, model.
   Nunca escreva *"NEVER faça X"* no `CLAUDE.md` se dá pra enforçar via setting ou hook.
2. **Hooks para o que precisa rodar 100% das vezes.** Formatação, secrets scan,
   bloqueio de paths. Hooks são determinísticos; `CLAUDE.md` é apenas conselho.
3. **Skills para conhecimento sob demanda.** Convenções de DDD/VSA, checklists de
   segurança, padrões de commit. Carregadas só quando o contexto pede.

---

## 🗂️ Estrutura

```
seu-projeto/
├── .claude/
│   ├── settings.json                  # ✅ Versionado no git — vale pro time inteiro
│   ├── settings.local.json.example    # 👤 Modelo de preferências pessoais (gitignored)
│   ├── hooks/
│   │   ├── pre-bash-guard.sh           # 🛡️  Bloqueia comandos destrutivos
│   │   ├── pre-commit-secrets.sh       # 🔍 Escaneia secrets antes de commit/push
│   │   ├── post-edit-format.sh         # 🎨 Formata + lint após cada edição
│   │   └── block-secrets.sh            # 🔒 Guard extra p/ paths sensíveis (opcional)
│   ├── skills/
│   │   ├── code-review-b2/SKILL.md     # 👀 Revisão padrão B2 Tech (VSA + DDD)
│   │   ├── security-check/SKILL.md     # 🔐 Auditoria Security by Design (OWASP)
│   │   ├── commit/SKILL.md             # ✍️  Conventional commits assistidos
│   │   └── frontend-design/SKILL.md    # 🎭 Frontend distinto, sem "AI slop"
│   └── agents/
│       └── web-researcher.md           # 🔎 Pesquisa técnica na web (docs, CVEs, libs)
├── .claude-plugin/
│   └── plugin.json                     # 📦 Metadados do plugin b2tech-starter
├── .mcp.json                           # 🔌 MCP servers do projeto (vazio por padrão)
├── .gitignore
└── CLAUDE.md                           # 📝 Contexto do projeto (curto, humano)
```

---

## 🚀 Quick start

```bash
# 1. Clone o pack
git clone https://github.com/brunobracaioli/claude-code-starter-pack.git

# 2. Copie a config para a raiz do seu projeto
cp -r claude-code-starter-pack/.claude         seu-projeto/
cp -r claude-code-starter-pack/.claude-plugin  seu-projeto/   # opcional (plugin)
cp    claude-code-starter-pack/.mcp.json       seu-projeto/   # opcional (MCP)
cp    claude-code-starter-pack/CLAUDE.md       seu-projeto/

# 3. Torne os hooks executáveis
chmod +x seu-projeto/.claude/hooks/*.sh

# 4. (Opcional) Crie suas preferências locais a partir do exemplo
cp seu-projeto/.claude/settings.local.json.example \
   seu-projeto/.claude/settings.local.json

# 5. Rode
cd seu-projeto && claude
```

> 🐧 **Dependência:** os hooks usam [`jq`](https://jqlang.github.io/jq/) para ler o
> JSON do stdin. Instale com `sudo apt install jq` (Debian/Ubuntu/WSL) ou `brew install jq`.

> 📝 **Customize o `CLAUDE.md`:** ele vem como template (`# <Nome do Projeto>`).
> Preencha stack, comandos e estrutura — mantenha curto e humano.

---

## 🪝 Hooks

Automações wired em `settings.json`. Todas seguem o mesmo contrato: leem JSON do
stdin, **`exit 0` permite**, **`exit 2` bloqueia** e devolve o stderr ao Claude
como contexto para auto-correção.

| Hook | Evento | Matcher | O que faz |
|------|--------|---------|-----------|
| `pre-bash-guard.sh` | `PreToolUse` | `Bash` | Bloqueia `rm -rf /`, fork bombs, `mkfs`, `DROP/TRUNCATE`, `curl \| sh`, `git push --force` em `main`, e remoção de arquivos sensíveis. |
| `pre-commit-secrets.sh` | `PreToolUse` | `Bash` | Em `git commit`/`push`, escaneia arquivos *staged* por chaves AWS/GitHub/OpenAI/Anthropic/Slack/Meta e private keys. |
| `post-edit-format.sh` | `PostToolUse` | `Write \| Edit \| NotebookEdit` | Formata e dá lint após edições: Prettier+ESLint (JS/TS), Ruff (Python), `jq` (JSON), `gofmt` (Go), `rustfmt` (Rust). |
| `block-secrets.sh` | — | — | **Não wired por padrão.** Guard mais agressivo: bloqueia qualquer tool tocando `.env`, `secrets/`, chaves SSH, `~/.aws`, `~/.config/gcloud`, etc. |

<details>
<summary><b>Como ativar o <code>block-secrets.sh</code></b></summary>

<br>

É um guard opcional, mais amplo que os defaults. Para ativá-lo em operações de
arquivo, adicione-o ao bloco `PreToolUse` do `settings.json`:

```jsonc
{
  "matcher": "Write|Edit|Read",
  "hooks": [
    {
      "type": "command",
      "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-secrets.sh",
      "timeout": 10
    }
  ]
}
```

</details>

---

## 🧠 Skills

Carregadas via *progressive disclosure* — o Claude lê o `SKILL.md` só quando o
contexto da conversa bate com a `description`.

| Skill | Quando invocar | Cobre |
|-------|----------------|-------|
| 👀 **`code-review-b2`** | *"revise o código"*, *"code review"*, fim de feature/PR | Vertical Slice + DDD, Security by Design, qualidade Python/Flask + Next.js/TS, testes. Output com `🔴 Blocker` / `🟡 Major` / `🟢 Nit` + decisão. |
| 🔐 **`security-check`** | *"audite a segurança"*, antes de subir pra prod | OWASP Top 10, secrets, AuthN/AuthZ, supply chain, logs. Findings `🔥 CRÍTICO`→`🔵 INFO` com ameaça → impacto → fix. |
| ✍️ **`commit`** | `/commit` (ou peça pra commitar) | Stage + mensagem em Conventional Commits a partir do diff. **Não dá push** — você decide quando. |
| 🎭 **`frontend-design`** | *"crie um componente/página/UI"* | Frontend distinto e production-grade, fugindo da estética genérica de IA. |

---

## 🔎 Agents

Subagentes rodam em contexto isolado, com tools restritas e system prompt focado —
ideais para tarefas delimitadas que não devem poluir o contexto principal.

| Agent | Quando invocar | Cobre |
|-------|----------------|-------|
| 🔎 **`web-researcher`** | *"pesquise"*, *"procure docs"*, *"compare libraries"*, *"tem package para"*, *"busque CVE"* — ou quando precisa de contexto externo ao codebase | Docs & APIs oficiais, best practices, comparação de libs (manutenção, bundle, licença), CVEs e troubleshooting. Cruza ≥2 fontes e devolve summary → findings → recommendation → sources. |

> ⚙️ Roda no **`sonnet`** com tools mínimas (`WebSearch`, `WebFetch`, `Read`, `Grep`,
> `Glob`), `maxTurns: 20` e `memory: project` — checa pesquisas anteriores antes de
> buscar de novo e salva achados reutilizáveis.

---

## 🔐 Permissões (`settings.json`)

Defense in depth desde o primeiro prompt — três níveis de permissão:

```
✅ allow  →  roda sem perguntar
   read/glob/grep, git status|diff|log|branch, lint/typecheck/test, ruff, mypy, pytest

❓ ask    →  pede confirmação
   git push, git commit, npm/pnpm publish, WebFetch

🚫 deny   →  bloqueado sempre
   ler/editar .env e .env.*, secrets/**, *.pem, *.key, credentials.json,
   service-account*.json · sudo, rm -rf /, curl|sh, wget|sh, ssh
```

Outros defaults: `cleanupPeriodDays: 14`, `enableAllProjectMcpServers: false`,
e tráfego não-essencial desligado (`CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`).

> 👤 **Preferências pessoais** (spinner verbs, output style, permissões extras)
> vão em `settings.local.json` — gitignored. Use o `.example` como ponto de partida.

---

## 📦 Distribuir como plugin

O `.claude-plugin/plugin.json` empacota hooks e skills como o plugin
**`b2tech-starter`**, pronto para um marketplace privado do time. Assim, em vez de
copiar arquivos manualmente, cada projeto instala o pack com um comando.

---

## ✨ Novidades da 2.0

Mapeado direto dos commits desde o `first commit`:

- 🆕 **Skill `commit`** — Conventional Commits assistidos a partir do diff.
- 🆕 **Skill `frontend-design`** — UIs distintas, sem estética genérica de IA.
- 🆕 **Agent `web-researcher`** — pesquisa técnica na web (docs, CVEs, comparação de libs) em contexto isolado.
- 🆕 **Hook `block-secrets.sh`** — guard opcional, mais agressivo, para paths sensíveis.
- 🆕 **`.mcp.json`** — ponto de entrada para MCP servers do projeto.
- 🔧 **`settings.json` revisado** — permissões `allow`/`ask`/`deny` mais granulares,
  `autoMemory`/`autoDream` ligados, env de privacidade.
- 🔧 **`pre-bash-guard.sh` refinado** — padrões ancorados para reduzir falso-positivo
  (`rm -rf /` literal não bloqueia `rm -rf /tmp/...`).
- 🗂️ **Reorganização** — arquivos movidos do subdiretório para a raiz do repositório.

---

## 🧭 Decisões de escopo

O que ficou **de fora de propósito**, e por quê:

- **Subagentes genéricos (`agents/`)** → o pack inclui só o `web-researcher` (caso
  de uso claro e reutilizável); adicione outros conforme necessidade real, evite genéricos.
- **Slash commands dedicados (`commands/`)** → skills são mais flexíveis e suportam
  *supporting files*.
- **MCP servers configurados** → projeto-específico; `.mcp.json` vem vazio, pronto
  para você preencher.

> **Stack-aware, não stack-locked.** Os hooks e skills assumem Python/Flask +
> Next.js/TypeScript em GCP, mas o `post-edit-format.sh` já cobre Go e Rust. Ajuste
> os comandos de lint/format conforme a stack do seu projeto.

---

<div align="center">

**[Bruno Bracaioli](https://b2tech.io)** · MIT License

*Feito para começar projetos com segurança e qualidade desde o primeiro prompt.*

</div>
