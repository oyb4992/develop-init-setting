# N8N SERVICE KNOWLEDGE BASE

## OVERVIEW

`services/n8n/` defines a single-container n8n Compose service bound to localhost with host-specific OpenClaw mounts; persistent data and credentials are runtime state.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Runtime definition | `docker-compose.yml` | Pinned n8n image, localhost port, env, and absolute host-specific volume mounts. |
| User docs | `README.md` | Setup, start/stop/update, cleanup, OpenClaw integration notes. |
| Local environment | `.env` | Ignored; contains `N8N_ENCRYPTION_KEY`. |
| Environment template | `.env.example` | Tracked placeholder; copy to `.env` and replace the encryption key before runtime use. |
| Persistent data | `data/n8n/` | SQLite DB, logs, workflows, credentials; do not treat as source. |
| Container home shim | `dummy_home/` | Tracked as an empty bind-mount source; generated contents are ignored. |

## CONVENTIONS

- Edit compose/docs first; runtime files under `data/` should not drive repository guidance.
- Keep UI/webhook binding on localhost unless exposing n8n is a deliberate security decision.
- Preserve `N8N_ENCRYPTION_KEY` as an env-substituted secret, not an inline compose value.
- Compose currently pins `docker.n8n.io/n8nio/n8n:2.23.2`; image changes should be intentional and documented.
- Review every absolute host mount before running on another machine; repository templates do not prove the live OpenClaw deployment layout.

## ANTI-PATTERNS

- Do not commit `.env`, database files, execution logs, workflow backups, or credentials.
- Do not delete `data/` as a cleanup step without confirming the user wants to lose workflows and credentials.
- Do not expose port `5678` beyond `127.0.0.1` without documenting auth, proxy, and cookie implications.
- Do not run this compose file on a new host before correcting or confirming its `/home/ubuntu/.openclaw/workspace/...` bind sources.

## VALIDATION COMMANDS

```bash
docker compose --env-file services/n8n/.env.example -f services/n8n/docker-compose.yml config
```

## MUTATING COMMANDS

Run only after reviewing host mounts and preparing the local `.env`.

```bash
docker compose -f services/n8n/docker-compose.yml up -d
docker compose -f services/n8n/docker-compose.yml down
docker compose -f services/n8n/docker-compose.yml pull
```
