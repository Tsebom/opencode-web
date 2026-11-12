# Project instructions

## Git identity in the container

Commit identity is **not stored in repository files** — it is provided at
container start via the `GIT_USER_NAME` and `GIT_USER_EMAIL` variables
(template in `.env.example`, actual values in `.env`, which is not
committed). On every start `entrypoint.sh` writes them to the container
`git config` and generates the global agent instructions file
`~/.config/opencode/AGENTS.md`, so all agent commits are automatically
attributed to the connected Git account.

- When modifying `entrypoint.sh`, `.env.example`, or `docker-compose.yaml`,
  do not break this mechanism (the env vars must reach the container, and
  the entrypoint must keep setting git config and generating the global
  AGENTS.md).
- General git identity rules come from the agent's global AGENTS.md
  (`~/.config/opencode/AGENTS.md` inside the container).
