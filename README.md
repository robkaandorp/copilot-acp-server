# Copilot ACP Server

A Docker-based setup that runs the [GitHub Copilot CLI](https://docs.github.com/copilot/concepts/agents/about-copilot-cli) as an ACP (Agent Communication Protocol) server. This allows external tools and clients to interact with the Copilot coding agent over HTTP.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)
- A GitHub account with an [active Copilot subscription](https://github.com/features/copilot/plans)
- A GitHub Personal Access Token (PAT) with the **Copilot Requests** permission

## Setup

### 1. Create a GitHub token

Generate a fine-grained PAT at https://github.com/settings/personal-access-tokens/new with the **Copilot Requests** permission enabled.

### 2. Configure your token

Create a `.env` file in the project root:

```env
GH_TOKEN=your_token_here
```

> **Do not** put your token in `default.env` — that file is tracked by git. The `.env` file is gitignored.

### 3. Create the sandbox directory

The container mounts a local `sandbox/` directory for persistent state. Create the required structure:

```bash
mkdir -p sandbox/home sandbox/.copilot
```

- `sandbox/home/` — The agent's working directory (mounted at `/copilot-home`). Place any files here that you want the agent to work with.
- `sandbox/.copilot/` — Copilot CLI config, logs, and cached packages (mounted at `/root/.copilot`).

The `sandbox/` directory is gitignored. You can point to a different location by setting `COPILOT_SANDBOX` in your `.env` file:

```env
COPILOT_SANDBOX=/path/to/your/sandbox
```

### 4. Build and run

```bash
docker compose up --build
```

The ACP server will be available at `http://localhost:8000`.

## Configuration

Environment variables can be set in `.env` (secrets) or `default.env` (non-sensitive defaults):

| Variable | Default | Description |
|---|---|---|
| `GH_TOKEN` | *(required)* | GitHub PAT with Copilot permissions |
| `COPILOT_MODEL` | `claude-opus-4.6` | Model for the Copilot agent to use |
| `COPILOT_AUTO_UPDATE` | `true` | Automatically update the Copilot CLI package |
| `COPILOT_SANDBOX` | `./sandbox` | Path to the sandbox directory |

## Common Commands

```bash
# Start the server (rebuilds if Dockerfile changed)
docker compose up --build

# Start in the background
docker compose up -d --build

# View logs when running in the background
docker compose logs -f

# Stop the server
docker compose down

# Full rebuild (e.g. after changing base packages)
docker compose build --no-cache
```

## Connecting with acpx

[acpx](https://www.npmjs.com/package/acpx) is a headless CLI client for the Agent Client Protocol. It only supports stdio-based agents, so a relay script is included to bridge stdio to the TCP server.

```bash
# Install acpx globally
npm install -g acpx

# One-shot prompt
acpx --agent "node tcp-relay.js" exec "what can you do?"

# Interactive session
acpx --agent "node tcp-relay.js" sessions new
acpx --agent "node tcp-relay.js" "fix the tests"
```

To connect to a remote host or non-default port:

```bash
acpx --agent "node tcp-relay.js 192.168.1.50 8000" exec "hello"
```

You can also configure it permanently in `.acpxrc.json` (project-level) or `~/.acpx/config.json` (global):

```json
{
  "agents": {
    "copilot-remote": {
      "command": "node tcp-relay.js"
    }
  }
}
```

Then use it by name:

```bash
acpx copilot-remote exec "summarize this repo"
```

## Resetting State

To start fresh, delete the sandbox directory and recreate it:

```bash
rm -rf sandbox
mkdir -p sandbox/home sandbox/.copilot
```

This clears all cached Copilot CLI packages, logs, and working files.
