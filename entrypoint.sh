#!/bin/bash
set -e

# Configure git identity for commits made by the agent
# (values are provided via environment, see .env.example)
if [ -n "${GIT_USER_NAME}" ] && [ -n "${GIT_USER_EMAIL}" ]; then
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
fi

# Check if SSH key exists
if [ ! -f "/home/agent/.ssh/id_ed25519" ]; then
    # Ensure directory exists with correct permissions
    mkdir -p /home/agent/.ssh
    chmod 700 /home/agent/.ssh
    
    # Generate the key without a passphrase
    ssh-keygen -t ed25519 -f /home/agent/.ssh/id_ed25519 -N ""
fi

# Execute the original command passed as arguments
exec "$@"
