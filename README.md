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
