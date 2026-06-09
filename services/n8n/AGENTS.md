# N8N SERVICE KNOWLEDGE BASE

## OVERVIEW

`services/n8n/` defines a local single-container n8n service; persistent data and credentials are local runtime state.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Runtime definition | `docker-compose.yml` | Pinned n8n image, localhost port, env, and volume mounts. |
| User docs | `README.md` | Setup, start/stop/update, cleanup, OpenClaw integration notes. |
| Local environment | `.env` | Ignored; contains `N8N_ENCRYPTION_KEY`. |
| Persistent data | `data/n8n/` | SQLite DB, logs, workflows, credentials; do not treat as source. |
| Container home shim | `dummy_home/` | Used by compose mounts for n8n runtime permissions. |

## CONVENTIONS

- Edit compose/docs first; runtime files under `data/` should not drive repository guidance.
- Keep UI/webhook binding on localhost unless exposing n8n is a deliberate security decision.
- Preserve `N8N_ENCRYPTION_KEY` as an env-substituted secret, not an inline compose value.
- Compose currently pins `docker.n8n.io/n8nio/n8n:2.23.4`; image changes should be intentional and documented.
- README mentions `.env.example`, but `.env.example` is ignored and not present; reconcile that before relying on the documented copy step.

## ANTI-PATTERNS

- Do not commit `.env`, database files, execution logs, workflow backups, or credentials.
- Do not delete `data/` as a cleanup step without confirming the user wants to lose workflows and credentials.
- Do not expose port `5678` beyond `127.0.0.1` without documenting auth, proxy, and cookie implications.

## COMMANDS

```bash
docker compose -f services/n8n/docker-compose.yml config
docker compose -f services/n8n/docker-compose.yml up -d
docker compose -f services/n8n/docker-compose.yml down
docker compose -f services/n8n/docker-compose.yml pull
```
