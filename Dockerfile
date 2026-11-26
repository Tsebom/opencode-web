FROM node:20-slim

# Install OpenCode CLI, Playwright (browser automation for the agent)
# and curl for healthchecks
# ca-certificates provides the system root CA bundle (/etc/ssl/certs)
# so git/curl can verify TLS server certificates
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl openssh-client git && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g @opencode/cli playwright @playwright/mcp

# GitHub CLI (gh) from the official apt repository (Debian), see
# https://cli.github.com/ - used by the agent for PRs, issues and API calls
RUN mkdir -p -m 755 /etc/apt/keyrings && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh && \
    rm -rf /var/lib/apt/lists/*

# Headless Chromium for the agent (launched by the playwright MCP server).
# --with-deps installs the required apt dependencies. The browsers are
# installed to a shared world-readable path so the non-root agent user
# can use them.
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/playwright
RUN npx playwright install --with-deps chromium

# Create a non-root user for security with non-standard UID/GID
RUN groupadd -g 1050 agent && useradd -u 1050 -g agent -m -s /bin/bash agent

# Environment variables
ENV HOME=/home/agent
ENV XDG_CONFIG_HOME=/home/agent/.config
ENV XDG_DATA_HOME=/home/agent/.local/share
ENV XDG_CACHE_HOME=/home/agent/.cache

# Create necessary directories and set permissions
# /home/agent/.local/share/opencode and /workspace must exist in the image
# so that the opencode-data and opencode-workspace named volumes are
# initialized with the agent's ownership
# (Docker creates missing volume mount points as root)
RUN mkdir -p /home/agent/.config/opencode /home/agent/.local/share/opencode /workspace && \
    chown -R agent:agent /home/agent /workspace

# Copy and setup entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to the non-root user
USER agent
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# Exec form: no shell, no env interpolation. The container always listens on
# 4096; the host-side port is configured via the ports mapping in
# docker-compose.yaml (OPENCODE_PORT).
CMD ["opencode", "serve", "--hostname", "0.0.0.0", "--port", "4096"]

# Expose the fixed internal port (host mapping is set in docker-compose)
EXPOSE 4096


