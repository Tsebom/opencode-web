#!/bin/bash
set -e

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
