#!/bin/bash
set -e

# Configure git identity for commits made by the agent
# (values are provided via environment, see .env.example)
if [ -n "${GIT_USER_NAME}" ] && [ -n "${GIT_USER_EMAIL}" ]; then
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"

    # Generate the global agent instructions from the connected account
    mkdir -p /home/agent/.config/opencode
    cat > /home/agent/.config/opencode/AGENTS.md <<EOF
# Global instructions

## Git identity (all projects)

Connected Git account for this machine/container:
- Name: $GIT_USER_NAME
- Email: $GIT_USER_EMAIL

Rules:

- Commits and tags are made under the identity from git config
  (user.name / user.email) - that is the connected account.
- Before the first commit of a session, check git config user.name and
  git config user.email. If a value is empty, matches the agent built-in
  default identity, or clearly does not belong to the connected account,
  ask the user for the correct name/email and set it repo-locally with
  git config user.name "<name>" / git config user.email "<email>".
- Never use the agent built-in default identity or any other default
  identity.
- Never commit under personal/foreign accounts unrelated to the task.

Do not write account names or emails into repository files (AGENTS.md,
README, configs) - keep them only in .env, git config, and this global
file, which is generated at container start and is not part of any
repository.
EOF
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
