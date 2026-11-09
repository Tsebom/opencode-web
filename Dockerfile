FROM node:20-slim

# Install OpenCode CLI globally and curl for healthchecks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/* && \
    npm install -g @opencode/cli

# Create a non-root user for security
RUN groupadd -r opencode && useradd -r -g opencode -m -s /bin/bash opencode

# Create necessary directories and set permissions
RUN mkdir -p /home/opencode/.config/opencode && \
    chown -R opencode:opencode /home/opencode

# Switch to the non-root user
USER agent
WORKDIR /home/opencode

# Expose the port (actual port is set via CMD)
EXPOSE 4096

# Start the server in standalone mode
# We use shell form here to allow environment variable expansion if needed, 
# but for clarity and signal handling in Docker, we use the array form.
# Note: The port is passed via environment variable in the compose file.
CMD ["sh", "-c", "opencode serve --hostname 0.0.0.0 --port ${OPENCODE_PORT:-4096}"]
