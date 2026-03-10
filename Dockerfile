FROM ubuntu

# Set timezone environment variables before installing tzdata
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Amsterdam

RUN apt-get update && apt-get install -y build-essential locales file python3 python3-pip git curl gh ca-certificates gnupg
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get install -y nodejs && node -v && npm -v
RUN npm install -g @github/copilot

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /copilot-home
WORKDIR /copilot-home
VOLUME /copilot-home /root/.copilot

EXPOSE 8000
ENTRYPOINT ["copilot", "--add-dir", "/copilot-home", "--acp", "--port", "8000"]
