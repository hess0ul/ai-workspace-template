# AI Workspace Template

> Un espace de travail clé en main pour la **production assistée par IA** — une base de connaissances que tes agents savent vraiment parcourir, une documentation humaine reproductible, et une discipline git professionnelle dès le premier jour.

**🇬🇧 [English version](README.md)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-ready-blueviolet)](https://code.claude.com)
[![AGENTS.md](https://img.shields.io/badge/AGENTS.md-compatible-blue)](https://agents.md)
[![gitleaks](https://img.shields.io/badge/secrets-gitleaks%20guarded-green)](https://github.com/gitleaks/gitleaks)

La plupart des « second brains » sont pensés pour des humains et noient les agents IA sous le contexte ; la plupart des setups IA sont des dossiers de prompts sans discipline de mémoire. Ce template est la voie du milieu, distillée de ce qui converge réellement dans l'écosystème (context engineering d'Anthropic, Cline Memory Bank, Agent OS, le pattern LLM-wiki de Karpathy) et de benchmarks publiés sur la notation économe en tokens — pas de l'intuition.

## Les trois piliers

```text
ton-workspace/
├── CLAUDE.md            # routeur mince (importe AGENTS.md) — la carte toujours chargée
├── AGENTS.md            # guide agents canonique (standard Linux Foundation)
├── .claude/             # rules (par chemin), skills, sous-agents, hooks
├── brain/               # 🧠 SAVOIR — registre dense, machine-first
├── docs/                # 📖 DOCS HUMAINES — fonctionnement + runbooks versionnés
└── code/                # 🏭 PRODUCTION — tes projets
```

| Pilier | Répond à | Registre |
|---|---|---|
| `brain/` | *« Qu'est-ce qui est vrai maintenant, et pourquoi ? »* | Télégraphique v2, 1 ligne = 1 fait |
| `docs/` | *« Comment comprendre / reproduire ? »* | Prose pédagogique + runbooks numérotés |
| `code/` | *« Où vit le travail ? »* | Ce que le projet demande |

Une seule source de vérité par fait : l'état vit dans le brain, les étapes dans les runbooks, et ils se référencent au lieu de se dupliquer.

## Ce que tu obtiens

- **Un brain navigable par agents** — divulgation progressive à trois niveaux (index maître → hub d'aire → note atomique), un seul saut max, noms de fichiers kebab-case = clés de recherche. Pas de base vectorielle : le filesystem *est* l'index de récupération.
- **Le registre v2** — format télégraphique révisé sur benchmarks (~40-45 % d'économie de tokens) : une ligne = un fait, verbatim absolu pour identifiants/commandes en code fences, marqueurs de statut (`OK:` `FAIL:` `WARN:` `CRIT:`) au lieu d'émojis (qui coûtent *plus* de tokens), vocabulaire fermé pour que la compression ne devienne jamais de l'ambiguïté.
- **Un retriever borné** (`brain.sh`) — `map`, `find` classé, `recent`, `gather`, `audit`. Sortie plafonnée par construction : aussi léger à 100 notes qu'à 10 000.
- **Le protocole post-action** — après chaque modif : note → index → log d'aire → `state.md` du chantier. Critère de réussite : *une IA sans aucun contexte, avec les seuls fichiers, sait où on en est et quoi faire ensuite.* Un hook Stop ancre l'habitude.
- **Runbooks versionnés** — chaque commande de mise en service capturée en direct dans `docs/<app>/runbook/v1/` ; un changement majeur d'architecture ouvre `v2/` et supersède (sans jamais supprimer) l'ancien.
- **Discipline git professionnelle** — `main` protégé, conventional commits, branche + merge `--no-ff` pour tout sauf les ajouts courants du brain. Fonctionne en solo ; passe aux merge requests le jour où tu ajoutes un remote.
- **Sécurité par défaut** — hook pre-commit gitleaks (bloquant, testé), lectures de fichiers secrets interdites aux agents, convention pointeur-vault (`vault kv get ...`) pour qu'aucun secret n'entre jamais dans une note ou un runbook.
- **Filet CI inclus** — pipeline prête à l'emploi (`.gitlab-ci.yml`, adaptable ailleurs) : link-check des liens relatifs (`scripts/link-check.sh`), audit d'hygiène du brain en mode strict (`BRAIN_AUDIT_STRICT=1`), gitleaks sur l'historique complet, et une config markdownlint éprouvée où chaque règle désactivée est justifiée.
- **Natif Claude Code, portable par design** — skills (`brain`, `brain-search`, `runbook`), trois sous-agents (`brain-librarian`, `brain-curator`, `doc-writer`), rules par chemin ; les autres outils lisent le même `AGENTS.md`.

## Démarrage rapide

```bash
# 1. Récupérer le template
git clone <ce-repo> mon-workspace && cd mon-workspace
rm -rf .git && git init -b main

# 2. Activer les hooks
git config core.hooksPath .githooks
# installer gitleaks : winget install Gitleaks.Gitleaks | brew install gitleaks

# 3. Premier commit
git add -A && git commit -m "chore: scaffold workspace from ai-workspace-template"

# 4. Ouvrir avec ton agent (ex. Claude Code) et dire :
#    « Lis AGENTS.md et brain/meta/conventions.md, puis crée ma première aire : <sujet>. »
```

Checklist de première session : créer ta première aire (le skill `brain` la scaffolde), supprimer `brain/example/` une fois le format vu, démarrer le journal avec `brain/journal/<aaaa-mm>.md`.

## Comment ça marche

### Divulgation progressive — tu ne paies que ce que tu lis

```text
brain/index.md          ~1 ligne par aire          } toujours léger
  └── <aire>/index.md   « chemin — quoi — quand »  } chargé à l'entrée
        └── note.md     300-1200 tokens, atomique  } chargé à la demande
```

Un agent qui répond à *« quelle est l'IP du service X ? »* lit 3 petits fichiers, pas l'œuvre d'une vie. Ce qui est sous le point d'entrée coûte **zéro** tant que non ouvert — c'est pour ça que découper bat compresser.

### La boucle mémoire

```text
     ┌──────────── le travail se fait ──────────┐
     ▼                                          │
  capture (note v2) ──► index ──► log ──► state.md ──► journal
     ▲                                          │
     └──── rituel de consolidation (mensuel) ◄──┘
```

Mémoire sémantique = notes (éditées en place, supersédées jamais supprimées). Épisodique = logs append-only + journal (grep `brain/journal/` pour savoir *quand* un sujet a bougé). Procédurale = `procedures/` + skills. L'agent `brain-curator` replie périodiquement l'épisodique dans le sémantique pour que le brain ne pourrisse pas.

### Garantie de reprise à froid

Tout est conçu autour d'un test : ouvrir une session neuve sans contexte, la pointer sur un chantier, et elle doit énoncer ce qui a été fait et ce qui reste — depuis `state.md`, le journal et les logs seuls. Si ce test échoue, le protocole post-action a été sauté.

## Les conventions en un coup d'œil

| Règle | Valeur |
|---|---|
| Nommage | `kebab-case` ASCII, nom de fichier = clé grep |
| Noms réservés | `index.md` (hub) · `log.md` · `state.md` · `CLAUDE.md` |
| Taille de note | ~300-1200 tokens ; hub < 500 lignes ; TOC si > 100 |
| Liens | Markdown relatifs, un saut, fil d'Ariane en bas |
| Frontmatter | `type` (requis), `description`, `tags`, `status`, `modified` |
| Obsolescence | `status: superseded` + `superseded_by:` — jamais de suppression |
| Commits | Conventionnels (`feat:` `fix:` `docs:` `brain:` `chore:`) |
| Secrets | Pointeurs vault uniquement ; gitleaks bloque le reste |

Détail complet : [`brain/meta/conventions.md`](brain/meta/conventions.md) — la source de vérité unique.

## Sync multi-appareils (optionnel)

Conçu pour la **cohabitation Git + Syncthing** : versionne sur ta forge (GitLab/GitHub), synchronise l'arbre de travail avec Syncthing, et empêche-les de se battre — `.stignore-shared` (versionné) exclut `.git` de la sync ; le `.stignore` de chaque appareil se réduit à `#include .stignore-shared`. Les commits se font sur une machine ; les autres consomment les fichiers ou clonent depuis la forge.

## Sources de conception

Les choix d'ici sont des décisions documentées, pas des habitudes :

- **Anthropic** — [Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents), [leçons multi-agents](https://www.anthropic.com/engineering/multi-agent-research-system), [skill authoring](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) → routeur mince + corpus paresseux, références à un saut, sous-agents qui retournent des chemins pas des payloads.
- **Chroma — [Context Rot](https://www.trychroma.com/research/context-rot)** → doublons et notes périmées sont des distracteurs mesurables ; d'où supersede + rituel de consolidation.
- **Telegraph English ([arXiv 2605.04426](https://arxiv.org/abs/2605.04426))** → la compression télégraphique structurée bat la compression par suppression ; la perte se concentre sur les faits fins → règle du verbatim.
- **Benchmarks tokenizer** → les émojis coûtent 1-3 tokens contre 1 pour un mot → le set de marqueurs sans émojis.
- **[AGENTS.md](https://agents.md)** (Linux Foundation), **[Cline Memory Bank](https://docs.cline.bot/best-practices/memory-bank)**, **[Agent OS](https://buildermethods.com/agent-os)**, **pattern LLM-wiki de Karpathy** → le split en piliers, la discipline d'index, l'inbox.

## FAQ

**Pourquoi pas de base vectorielle / RAG ?**
À l'échelle d'un workspace personnel, noms de fichiers descriptifs + grep classé (`brain.sh find`) récupèrent mieux que des embeddings, ne coûtent rien à maintenir et restent inspectables. Ajoute de la recherche sémantique plus tard si tu dépasses cette échelle.

**Pourquoi le brain est-il si sec ? C'est dur à lire.**
Le brain est pour les agents ; *toi* tu lis `docs/`. C'est tout l'intérêt du split — chaque public a son registre, et aucun fait n'est stocké deux fois.

**Ça ne marche qu'avec Claude Code ?**
Les skills/hooks/sous-agents sont natifs Claude Code, mais le contrat du workspace vit dans `AGENTS.md` (standard cross-vendor) et du Markdown pur — Codex CLI, Cursor, Gemini CLI & co le lisent très bien.

**Où vont les secrets ?**
Dans ton gestionnaire de secrets (HashiCorp Vault, Infisical, …). Le repo ne contient que des *pointeurs* (`vault kv get -field=token kv/app/nom`). gitleaks bloque les accidents au commit.

## Licence

[MIT](LICENSE) — prends-le, adapte-le, approprie-toi-le.
