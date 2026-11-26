# OpenCode Standalone Web Deployment

This repository provides a production-ready Docker deployment for OpenCode in standalone mode. It includes a Web UI for browser-based interaction and support for custom providers and MCP servers.

## 🚀 Quick Start

1. **Clone the repository** (or navigate to the folder).
2. **Configure Environment Variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your API keys and passwords
   nano .env
   ```
3. **Launch the Container**:
   ```bash
   docker compose up -d
   ```
4. **Access the Web UI**:
   Open your browser and go to: `http://localhost:4096` (or the port you specified in `.env`).

## ⚙️ Configuration

### API Keys
The server uses the `opencode.jsonc` file for provider configurations. It looks for the following environment variables to authenticate:
- `WORMSOFT_API_KEY`
- `POLZA_API_KEY`
- `CONTEXT7_API_KEY`
- `TAVILY_API_KEY` (web search provider, see `websearch` in `opencode.jsonc`)

These should be set in your `.env` file.

### Server Settings
- `OPENCODE_PORT`: The host port where the Web UI / API is published (default: `4096`). The container always listens internally on port 4096.
- `OPENCODE_PASSWORD`: The password for the Web UI and API. If not set, a random one will be generated and visible in `docker logs opencode-standalone`.

### Config File (`.opencode/opencode.jsonc`)
The configuration file is mounted as **read-only**. To change settings:
1. Edit the local `.opencode/opencode.jsonc`.
2. Restart the container: `docker compose restart`.

### Git Identity
The agent commits under the identity provided via `GIT_USER_NAME` and `GIT_USER_EMAIL`
in your `.env` file. On every container start the entrypoint applies it to the
container's `git` config and generates the agent's global instructions file
(`~/.config/opencode/AGENTS.md`), so all commits made by the agent are attributed
to your account with no extra setup.
The commit-identity rules are also documented in `AGENTS.md`, which OpenCode loads
automatically for every session in this project.

## 🖥️ VS Code in the browser (code-server)

The container can also serve the workspace through **code-server** — a full VS Code
in the browser, opened on `/workspace`.

1. **Enable it**: set `CODE_SERVER_PASSWORD` in your `.env`. If left empty, code-server
   is not started at all — it must not run without authentication. `CODE_SERVER_PORT`
   (default 8080) controls the published host port.
2. **Rebuild and restart** the container (the image now includes code-server):
   ```bash
   docker compose up -d --build
   ```
3. **Open** `http://localhost:8080` (or your `CODE_SERVER_PORT`) and log in with
   `CODE_SERVER_PASSWORD`. The `/workspace` folder is opened automatically.

Notes:

- On first launch code-server downloads the VS Code server (~100 MB) and caches it
  in the `code-server-data` named volume, so the download happens only once.
- Extensions installed in code-server persist in the same volume across container
  recreations.
- The port is published on all host interfaces. On a remote server, prefer an SSH
  tunnel instead of exposing the port publicly:
  ```bash
  ssh -L 8080:localhost:8080 user@your-server
  ```
- code-server logs are written to `/tmp/code-server.log` inside the container:
  ```bash
  docker exec opencode-standalone tail -n 50 /tmp/code-server.log
  ```

## 🔐 Permissions and SSH Setup

To allow the agent to automatically generate and manage SSH keys, the file permissions on your host machine must match the internal user of the container (UID: 1050, GID: 1050).

**1. Create a corresponding user on your host (one-time setup):**
Run the following commands in your terminal to create a group and user with the specific IDs:
```bash
sudo groupadd -g 1050 agent
sudo useradd -u 1050 -g agent -m agent
```

**2. Set the ownership for the project folder:**
Navigate to the `opencode-standalone-web` directory and run:
```bash
sudo chown -R agent:agent .opencode
```

This ensures that when the container mounts the `.opencode` folder, the `agent` user inside the container has full read and write permissions for the SSH keys and configuration files.

**3. Verify the setup:**
To check if the user `agent` can read the generated keys, you can run commands under this user's context:
```bash
# List the SSH folder contents
sudo -u agent ls -l .opencode/ssh

# View the public key
sudo -u agent cat .opencode/ssh/id_ed25519.pub
```

## 🛠 Maintenance

**Viewing Logs:**
```bash
docker logs -f opencode-standalone
```

**Checking Health:**
The container includes a healthcheck that pings the `/api/info` endpoint. You can check the status with:
```bash
docker ps
```

**Updating:**
```bash
docker compose pull
docker compose up -d
```
