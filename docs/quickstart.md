---
layout: default
title: Quick Start Guide
---

---
layout: default
title: Quick Start Guide
---

# Quick Start Guide

## Test Locally (5 minutes)

### 1. Install dependencies

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Set environment variables

```bash
export MCP_SERVERS="filesystem,git,github"
export AGENT_WORKSPACE_TYPE="local"  # Change to "governed-cloud" in DevSpaces
export ANTHROPIC_API_KEY="your-key-here"  # Optional for local testing
```

### 3. Setup MCP configuration

```bash
mkdir -p .mcp
cp mcp-config.json .mcp/config.json
```

### 4. Run the application

```bash
uvicorn app:app --reload
```

### 5. Test the endpoints

```bash
# Basic hello world
curl http://localhost:8000/

# Health check
curl http://localhost:8000/health

# Agent status
curl http://localhost:8000/agent-status
```

### 6. Validate configuration

```bash
chmod +x validate-agent-config.sh
./validate-agent-config.sh
```

## Deploy to OpenShift DevSpaces (15 minutes)

### Prerequisites
- OpenShift cluster with DevSpaces installed
- Git repository with this code
- Anthropic API key

### Steps

1. **Create secrets in OpenShift:**
   ```bash
   oc create secret generic agentic-secrets \
     --from-literal=ANTHROPIC_API_KEY='sk-ant-...' \
     -n your-namespace

   oc label secret agentic-secrets \
     controller.devfile.io/mount-as=env \
     controller.devfile.io/watch-secret=true
   ```

2. **Push code to Git:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit: Agentic DevSpaces PoC"
   git remote add origin <your-git-url>
   git push -u origin main
   ```

3. **Create workspace in DevSpaces:**
   - Navigate to DevSpaces dashboard: `https://devspaces.apps.<your-cluster>/`
   - Click "Create Workspace"
   - Enter Git URL
   - Click "Create & Open"

4. **Wait for automatic setup** (postStart events in devfile will):
   - Install Python dependencies
   - Setup MCP servers
   - Configure governance

5. **Run the application:**
   ```bash
   # In DevSpaces terminal
   uvicorn app:app --host 0.0.0.0 --port 8000
   ```

6. **Access the application:**
   - DevSpaces will provide a public URL
   - Click the endpoint URL in the workspace UI
   - Or find it via: `oc get routes -n <workspace-namespace>`

## What You Get

### In Local Mode
- Simple hello world app
- Basic MCP configuration (not enforced)
- Agent SDK installed
- Manual secret management

### In DevSpaces Mode (Governed Cloud)
- Same hello world app
- **Governed MCP servers** with audit logging
- **Centralized secret management** (no `.env` files)
- **Network isolation** and policy enforcement
- **Automatic workspace setup** (zero configuration)
- **Consistent environment** across all developers

## Key Differences: Local vs DevSpaces

| Feature | Local | DevSpaces (Governed) |
|---------|-------|---------------------|
| Setup time | Manual install | Automatic (postStart) |
| Secrets | `.env` file | Vault/K8s secrets |
| MCP governance | None | Audit + policies |
| Network | Full internet | Cluster-isolated |
| Approval gates | None | Configured per operation |
| Onboarding | Hours | Minutes |
| Consistency | "Works on my machine" | Standardized |

## Architecture in DevSpaces

```
Developer clicks workspace URL
         ↓
DevSpaces provisions container from .devfile.yaml
         ↓
postStart event: install-dependencies
         ↓
postStart event: setup-mcp-servers
         ↓
Secrets mounted from OpenShift
         ↓
MCP servers start with governance policies
         ↓
Developer terminal ready with full agentic setup
         ↓
Build, test, iterate on AI agents in governed environment
```

## Validation Checklist

After workspace starts, verify:

```bash
# ✓ Python dependencies installed
python3 -c "import anthropic; print(anthropic.__version__)"

# ✓ MCP config in place
cat .mcp/config.json

# ✓ Environment variables set
echo $MCP_SERVERS

# ✓ Application runs
uvicorn app:app --host 0.0.0.0 --port 8000 &
curl http://localhost:8000/agent-status

# ✓ All checks pass
./validate-agent-config.sh
```

## Troubleshooting

### "ModuleNotFoundError: No module named 'fastapi'"
Run: `pip install -r requirements.txt`

### "MCP config not found"
Run: `mkdir -p .mcp && cp mcp-config.json .mcp/config.json`

### "ANTHROPIC_API_KEY not set"
In DevSpaces: Check secret exists with `oc get secret agentic-secrets`
Locally: `export ANTHROPIC_API_KEY='your-key'`

### Workspace fails to start in DevSpaces
Check operator logs: `oc logs -n openshift-operators -l app=devspaces-operator`

## Next Steps

1. **Explore the code**: Read `app.py`, `.devfile.yaml`, `mcp-config.json`
2. **Customize governance**: Edit MCP policies in `mcp-config.json`
3. **Add skills**: Create `.claude/skills/` directory with reusable capabilities
4. **Extend the app**: Add more endpoints, integrate with Claude API
5. **Production deployment**: Follow `DEPLOYMENT.md` for full setup

## Support

- Issues: File in your organization's support channel
- Documentation: See `README.md` for architecture details
- Deployment: See `DEPLOYMENT.md` for production setup
