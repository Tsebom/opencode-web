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

You work as a contributor through your own personal Git account
(created specifically for you, the agent). It is YOUR account:
- Name: $GIT_USER_NAME
- Email: $GIT_USER_EMAIL

Rules:

- Use the personal account for all git operations: commits, tags,
  pushes, pull requests, and GitHub API calls. Commits and tags are
  made under the identity from git config (user.name / user.email).
- Before the first commit of a session, check git config user.name and
  git config user.email. If a value is empty, matches the agent built-in
  default identity, or clearly does not belong to the personal account,
  ask the user for the correct name/email and set it repo-locally with
  git config user.name "<name>" / git config user.email "<email>".
- Never use the agent built-in default identity or any other default
  identity; never commit under foreign accounts.

Do not write account names or emails into repository files (AGENTS.md,
README, configs) - keep them only in .env, git config, and this global
file, which is generated at container start and is not part of any
repository.
EOF
fi

# SSH bootstrap: ensure the directory and key exist.
# /home/agent/.ssh is a bind mount (.opencode/ssh on the host). If the host
# volume is not owned by the container user (UID 1050), chmod/keygen fail -
# warn and continue instead of crash-looping the container.
mkdir -p /home/agent/.ssh 2>/dev/null || true
if ! chmod 700 /home/agent/.ssh 2>/dev/null; then
    echo "WARN: cannot chmod /home/agent/.ssh - host volume is not owned by UID 1050."
    echo "Fix on the host: sudo chown -R 1050:1050 .opencode/ssh"
fi

if [ ! -f "/home/agent/.ssh/id_ed25519" ]; then
    # Generate the key without a passphrase
    if ! ssh-keygen -t ed25519 -f /home/agent/.ssh/id_ed25519 -N ""; then
        echo "WARN: could not generate SSH key - .opencode/ssh is not writable by UID 1050."
        echo "Fix on the host: sudo chown -R 1050:1050 .opencode/ssh"
    fi
fi

# Execute the original command passed as arguments
exec "$@"
