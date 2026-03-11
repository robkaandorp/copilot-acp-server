# Copilot ACP Server

A Docker-based setup that runs the [GitHub Copilot CLI](https://docs.github.com/copilot/concepts/agents/about-copilot-cli) as a server in two modes:

- **ACP mode** (default) — Agent Communication Protocol over HTTP, for [acpx](https://www.npmjs.com/package/acpx) and other ACP clients.
- **Headless mode** — JSON-RPC over TCP, for the [Copilot SDKs](https://github.com/github/copilot-sdk) (Node.js, Python, Go, .NET).

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

To run in headless mode (for Copilot SDK clients):

```bash
COPILOT_MODE=headless docker compose up --build
```

Or set it in your `.env` file:

```env
COPILOT_MODE=headless
```

## Configuration

Environment variables can be set in `.env` (secrets) or `default.env` (non-sensitive defaults):

| Variable | Default | Description |
|---|---|---|
| `GH_TOKEN` | *(required)* | GitHub PAT with Copilot permissions |
| `COPILOT_MODEL` | `claude-opus-4.6` | Model for the Copilot agent to use |
| `COPILOT_AUTO_UPDATE` | `true` | Automatically update the Copilot CLI package |
| `COPILOT_ALLOW_ALL` | `true` | Auto-approve all tool/permission requests (safe — the container is a sandbox) |
| `COPILOT_MODE` | `acp` | Server mode: `acp` (HTTP/ACP) or `headless` (TCP/JSON-RPC for SDKs) |
| `COPILOT_PORT` | `8000` | Port the server listens on |
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

## Connecting with Copilot SDKs (headless mode)

When running in headless mode (`COPILOT_MODE=headless`), the server speaks JSON-RPC over TCP and is compatible with the [Copilot SDKs](https://github.com/github/copilot-sdk).

```python
# Python
from github_copilot_sdk import CopilotClient

client = CopilotClient(cli_url="tcp://localhost:8000")
```

```typescript
// Node.js / TypeScript
import { CopilotClient } from "@github/copilot-sdk";

const client = new CopilotClient({ cliUrl: "tcp://localhost:8000" });
```

```csharp
// .NET
using GitHub.Copilot.SDK;

var client = new CopilotClient(new() { CliUrl = "tcp://localhost:8000" });
```

```go
// Go
import "github.com/github/copilot-sdk/go"

client, _ := copilot.NewClient(copilot.WithCliURL("tcp://localhost:8000"))
```

See the [Copilot SDK docs](https://github.com/github/copilot-sdk/blob/main/docs/getting-started.md#connecting-to-an-external-cli-server) for full details on connecting to an external CLI server.

## Connecting with acpx (ACP mode)

[acpx](https://www.npmjs.com/package/acpx) is a headless CLI client for the Agent Client Protocol. It only supports stdio-based agents, so a relay script is included to bridge stdio to the TCP server.

> **Note:** Only one-shot mode (`exec`) is supported. Persistent sessions rely on acpx's local cwd-based session routing, which is incompatible with a remote TCP server where the client and agent have different filesystems.

```bash
# Install acpx globally
npm install -g acpx

# One-shot prompt
acpx --agent "node tcp-relay.js" exec "what can you do?"
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
