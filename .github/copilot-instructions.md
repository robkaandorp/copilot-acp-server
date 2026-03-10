# Copilot Instructions

## Project Overview

This repository packages the GitHub Copilot CLI as a Docker container running in ACP (Agent Communication Protocol) mode. It exposes the Copilot CLI agent over HTTP on port 8000, allowing external clients to interact with it via the ACP protocol.

## Architecture

- **Dockerfile** — Ubuntu-based image that installs Node.js (LTS) and `@github/copilot` globally, then runs `copilot --acp --port 8000` as the entrypoint.
- **compose.yaml** — Orchestrates the container with volume mounts and environment configuration.
- **sandbox/** — Persistent state directory mounted into the container:
  - `sandbox/home/` → `/copilot-home` (the agent's working directory)
  - `sandbox/.copilot/` → `/root/.copilot` (Copilot CLI config, logs, and cached packages)
- **default.env** — Checked-in defaults (`COPILOT_MODEL`, `COPILOT_AUTO_UPDATE`). `GH_TOKEN` must be supplied separately.
- **.env** — Gitignored file for secrets (primarily `GH_TOKEN`).

## Running

```bash
# Build and start the ACP server
docker compose up --build

# Rebuild after Dockerfile changes
docker compose build --no-cache

# Stop and remove the container
docker compose down
```

The server listens on `http://localhost:8000`.

## Environment Variables

| Variable | Purpose | Where to set |
|---|---|---|
| `GH_TOKEN` | GitHub PAT with Copilot permissions | `.env` (never commit) |
| `COPILOT_MODEL` | Model to use (default: `claude-opus-4.6`) | `default.env` or `.env` |
| `COPILOT_AUTO_UPDATE` | Auto-update the CLI package | `default.env` or `.env` |
| `COPILOT_SANDBOX` | Override sandbox path (default: `./sandbox`) | `.env` |

## Conventions

- **No application source code exists in this repo** — it is purely Docker infrastructure for hosting the Copilot CLI. Changes are limited to `Dockerfile`, `compose.yaml`, and environment config.
- **Never commit `.env`** — it contains the `GH_TOKEN` secret. Use `default.env` for non-sensitive defaults.
- The `sandbox/` directory is gitignored and holds runtime state. It can be deleted to reset the container's persistent data.
