FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Core dev tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git curl wget unzip zip jq \
    openssh-client ca-certificates gnupg \
    python3 python3-pip python3-venv \
    ripgrep fd-find tree file \
    gh xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Rust (via rustup, available for all users)
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH="/usr/local/cargo/bin:$PATH"
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

# uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Zig (latest stable via ziglang.org index)
RUN ZIG_VERSION=$(curl -fsSL https://ziglang.org/download/index.json | jq -r 'to_entries[] | select(.key != "master") | .key' | sort -V | tail -1) \
    && curl -fsSL "https://ziglang.org/download/${ZIG_VERSION}/zig-x86_64-linux-${ZIG_VERSION}.tar.xz" | tar -xJ -C /usr/local \
    && ln -s /usr/local/zig-x86_64-linux-${ZIG_VERSION}/zig /usr/local/bin/zig

# Copilot CLI
RUN npm install -g @github/copilot

RUN mkdir -p /copilot-home /opt/copilot-env
WORKDIR /copilot-home
COPY sandbox-agents.md /opt/copilot-env/AGENTS.md
VOLUME /copilot-home /root/.copilot

# Build caches on native filesystem to avoid v9fs atomic rename issues
ENV ZIG_LOCAL_CACHE_DIR=/tmp/zig-cache \
    ZIG_GLOBAL_CACHE_DIR=/root/.cache/zig \
    CARGO_TARGET_DIR=/tmp/cargo-target

EXPOSE 8000
ENV COPILOT_CUSTOM_INSTRUCTIONS_DIRS=/opt/copilot-env
ENTRYPOINT ["copilot", "--add-dir", "/copilot-home", "--acp", "--port", "8000"]
