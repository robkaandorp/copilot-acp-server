# AGENTS.md

This is an Ubuntu 24.04-based development container. The working directory is `/copilot-home`.

## Available Languages & Runtimes

- **Python 3** — `python3`. Use `uv` for package/project management (`uv init`, `uv add`, `uv run`). `pip` and `venv` are also available.
- **Node.js LTS** — `node`, `npm`, `npx`.
- **Rust** — `rustc`, `cargo`, `rustup`. Stable toolchain is installed. Use `rustup` to add components or switch toolchains.
- **Zig** — `zig`. Latest stable release.
- **C/C++** — `gcc`, `g++`, `make`. Provided by `build-essential`.

## Available Tools

- **git** — version control
- **gh** — GitHub CLI (authenticated via `GH_TOKEN` env var)
- **curl**, **wget** — HTTP requests and downloads
- **jq** — JSON processing
- **ripgrep** — fast code search (`rg`). Note: on Ubuntu the binary is installed as `rg`.
- **fd** — fast file finder. Note: on Ubuntu the binary is `fdfind`, not `fd`.
- **tree** — directory tree visualization
- **file** — file type detection
- **zip**, **unzip** — archive handling
- **openssh-client** — SSH and SCP

## Conventions

- All project files go in `/copilot-home` (the working directory).
- Use `uv` over `pip` for Python projects.
- Use `gh` for GitHub operations (issues, PRs, releases) — it is pre-authenticated.
- Build caches are redirected to native filesystems to avoid v9fs limitations:
  - Zig: `ZIG_LOCAL_CACHE_DIR=/tmp/zig-cache`, `ZIG_GLOBAL_CACHE_DIR=/root/.cache/zig`
  - Cargo: `CARGO_TARGET_DIR=/tmp/cargo-target`
  - These are set automatically — no manual configuration needed.
