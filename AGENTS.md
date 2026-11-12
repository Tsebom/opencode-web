# Project instructions

## Git identity in the container

Commit identity is **not stored in repository files** — it is injected at
container start via the `GIT_USER_NAME` and `GIT_USER_EMAIL` variables
(template in `.env.example`, actual values in `.env`, which is not
committed). `entrypoint.sh` writes them to the container's `git config` on
start, so all agent commits are automatically attributed to the connected
Git account.

- When modifying `entrypoint.sh`, `.env.example`, or `docker-compose.yaml`,
  do not break this mechanism (including the `.opencode/AGENTS.md` mount
  into the container's `~/.config/opencode/AGENTS.md`).
- General git identity rules come from the agent's global AGENTS.md
  (`~/.config/opencode/AGENTS.md` inside the container).
