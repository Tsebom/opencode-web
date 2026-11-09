FROM node:20-slim

# Install OpenCode CLI globally and curl for healthchecks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/* && \
    npm install -g @opencode/cli

# Create a non-root user for security with non-standard UID/GID
RUN groupadd -g 1050 agent && useradd -u 1050 -g agent -m -s /bin/bash agent

# Environment variables
ENV HOME=/home/agent
ENV XDG_CONFIG_HOME=/home/agent/.config
ENV XDG_DATA_HOME=/home/agent/.local/share
ENV XDG_CACHE_HOME=/home/agent/.cache

# Create necessary directories and set permissions
RUN mkdir -p /home/agent/.config/opencode /workspace && \
    chown -R agent:agent /home/agent /workspace

# Switch to the non-root user
USER agent
WORKDIR /workspace

# Expose the port (actual port is set via CMD)
EXPOSE 4096

# Start the server in standalone mode
# We use shell form here to allow environment variable expansion if needed, 
# but for clarity and signal handling in Docker, we use the array form.
# Note: The port is passed via environment variable in the compose file.
CMD ["sh", "-c", "opencode serve --hostname 0.0.0.0 --port ${OPENCODE_PORT:-4096}"]
