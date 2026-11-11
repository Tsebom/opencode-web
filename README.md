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

These should be set in your `.env` file.

### Server Settings
- `OPENCODE_PORT`: The port the server will run on (default: `4096`).
- `OPENCODE_PASSWORD`: The password for the Web UI and API. If not set, a random one will be generated and visible in `docker logs opencode-standalone`.

### Config File (`.opencode/opencode.jsonc`)
The configuration file is mounted as **read-only**. To change settings:
1. Edit the local `.opencode/opencode.jsonc`.
2. Restart the container: `docker compose restart`.

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
