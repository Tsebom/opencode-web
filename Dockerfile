FROM node:20-slim

# Install OpenCode CLI globally and curl for healthchecks
RUN apt-get update && apt-get install -y --no-install-recommends curl openssh-client git && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g @opencode/cli

# Create a non-root user for security with non-standard UID/GID
RUN groupadd -g 1050 agent && useradd -u 1050 -g agent -m -s /bin/bash agent

# Environment variables
ENV HOME=/home/agent
ENV XDG_CONFIG_HOME=/home/agent/.config
ENV XDG_DATA_HOME=/home/agent/.local/share
ENV XDG_CACHE_HOME=/home/agent/.cache

# Create necessary directories and set permissions
# /home/agent/.local/share/opencode must exist in the image so that the
# opencode-data named volume is initialized with the agent's ownership
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


