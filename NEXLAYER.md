# Nexlayer — immich

<!-- nexlayer:meta version=1 analyzed=2026-06-20T21:47:25Z repo=https://github.com/armondhonore/immich branch=nexlayer -->

> **For AI agents (Claude Code, Cursor, Gemini CLI, Copilot):**
> This file is the **project context** for this Nexlayer deployment — tech stack, env vars, secrets, live URL.
> For full platform detail (nexlayer.yaml schema, Dockerfile rules, CI/CD, task recipes) read **`nexlayer.skills`** in this repo.
>
> **Critical rules (full detail in `nexlayer.skills`):**
> - Inter-pod refs: `${podName:port}` only — never `localhost` or bare hostnames
> - Docker Hub images: prefix with `mirror.gcr.io/library/` — bare tags fail on the cluster
> - Secrets: set in the Nexlayer dashboard — never commit to `nexlayer.yaml` or Dockerfile
>
> **This file:** `agent-managed` sections update automatically. `user-editable` sections (Local Development Setup, Nexlayer Deployment Plan, Build Notes) are yours — preserved across re-analysis.

## Project Summary
<!-- nexlayer:section agent-managed=project_summary -->
Immich is a high-performance self-hosted photo and video management solution featuring a web interface, mobile app, and machine learning capabilities for asset organization.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| Node.js | language | 24.15.0 | .nvmrc |
| TypeScript | language | 6.0.0 | packages/cli/package.json |
| pnpm | tool | 11.6.0 | package.json |
| NestJS | framework | unknown | pnpm-workspace.yaml |
| Vite | build | 8.0.0 | packages/cli/package.json |
| PostgreSQL | database | unknown | README.md |
| Redis | database | unknown | README.md |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- server/ — NestJS backend API and core logic
- web/ — Frontend user interface
- packages/cli/ — Command line tool for bulk uploads
- packages/plugin-core/ — WASM based plugin architecture
- machine-learning/ — ML models and inference logic
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
Services that must be configured separately (not deployed by Nexlayer):

- PostgreSQL (Persistence)
- Redis (Caching/Queue)
- Typesense/Milvus (Vector Search - implied by ML features)
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- Node.js 24.15.0
- pnpm 11.6.0

### Environment variables

Copy `.env.example` to `.env.local` and fill in:

```
DB_HOSTNAME=localhost
DB_USERNAME=postgres
DB_PASSWORD=password
REDIS_HOSTNAME=localhost
```

### Steps

1. `pnpm install` — Install monorepo dependencies
2. `pnpm run build` — Build all workspace packages
3. `pnpm dev` — Start development environment

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### Pod Environment Variables

| Pod | Variable | Value | Kind |
|-----|----------|-------|------|
| `app` | `NODE_ENV` | `"production"` | plain |
| `app` | `PORT` | `"3000"` | plain |
| `app` | `HOSTNAME` | `"0.0.0.0"` | plain |

### nexlayer.yaml

```yaml
application:
  name: immich
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/immich:9ee7000-fix4"
      path: /
      servicePorts:
        - 3000
      vars:
        NODE_ENV: "production"
        PORT: "3000"
        HOSTNAME: "0.0.0.0"
```

<!-- nexlayer:end -->

## Nexlayer Deployment Plan
<!-- nexlayer:section user-editable=deployment_plan -->
### Pod Topology

| Pod | Image | Port | Role |
|-----|-------|------|------|
| immich-server | mirror.gcr.io/library/node:22-alpine | 3001 | web |
| immich-web | mirror.gcr.io/library/node:22-alpine | 3000 | web |
| immich-ml | nvcr.io/nvidia/cuda:12.0-base | 3003 | worker |
| immich-db | mirror.gcr.io/library/postgres:16-alpine | 5432 | database |
| immich-redis | mirror.gcr.io/library/redis:7-alpine | 6379 | cache |

### Deployment notes

- All services use <podName>.pod dns resolution (e.g., immich-db.pod:5432).
- ML pod requires NVIDIA NGC image for GPU acceleration.
- Database and Redis are isolated in their own pods per Nexlayer rule 4.
- Frontend (web) and Backend (server) are separated into distinct pods per Nexlayer rule 1.

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-06-20T22:17:06Z  
**Live URL:** https://relaxed-weasel-immich.cloud.nexlayer.ai  
**Runtime:**  · **Port:** auto-detected  
**Deploy branch:** nexlayer  

```yaml
application:
  name: immich
  pods:
    - name: app
      image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/immich:9ee7000-fix4"
      path: /
      servicePorts:
        - 3000
      vars:
        NODE_ENV: "production"
        PORT: "3000"
        HOSTNAME: "0.0.0.0"
```
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-06-20T21:47:25Z | analyzed | initial repo analysis |
| 2026-06-20T22:17:06Z | success | deployed https://relaxed-weasel-immich.cloud.nexlayer.ai |
<!-- nexlayer:end -->
