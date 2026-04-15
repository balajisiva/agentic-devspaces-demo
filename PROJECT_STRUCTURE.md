# Project Structure

```
agenticportal/
│
├── .devfile.yaml                 # OpenShift DevSpaces workspace definition
│                                 # - Defines container image, resources, commands
│                                 # - Configures MCP servers and environment
│                                 # - Sets up postStart automation
│
├── .gitignore                    # Git ignore patterns
│
├── app.py                        # FastAPI hello world application
│                                 # - Demonstrates agentic workspace capabilities
│                                 # - Endpoints: /, /health, /agent-status
│
├── requirements.txt              # Python dependencies
│                                 # - fastapi, uvicorn, anthropic SDK
│
├── mcp-config.json               # MCP server configuration with governance
│                                 # - Defines available MCP servers
│                                 # - Configures governance policies
│                                 # - Sets audit logging, approval gates
│
├── validate-agent-config.sh      # Validation script
│                                 # - Checks MCP configuration
│                                 # - Verifies environment variables
│                                 # - Validates governance setup
│
├── README.md                     # Main documentation
│                                 # - Concept explanation
│                                 # - Architecture overview
│                                 # - Benefits and features
│
├── QUICKSTART.md                 # Getting started guide
│                                 # - Local testing (5 min)
│                                 # - DevSpaces deployment (15 min)
│                                 # - Troubleshooting
│
├── DEPLOYMENT.md                 # Production deployment guide
│                                 # - OpenShift setup
│                                 # - Secret management
│                                 # - RBAC and multi-tenancy
│                                 # - Monitoring and audit
│
└── BUSINESS_VALUE.md             # Executive summary and ROI analysis
                                  # - Problem statement
                                  # - Business benefits
                                  # - Financial analysis
                                  # - Stakeholder talking points
```

## File Purposes

### Core Application Files

**app.py**
- Simple FastAPI application demonstrating the concept
- Shows how pre-configured MCP servers and agent SDK are available
- Provides endpoints to verify agentic workspace status

**requirements.txt**
- Python dependencies for the application
- Includes Anthropic SDK for agent development

### Configuration Files

**.devfile.yaml** (MOST IMPORTANT)
- The heart of the agentic workspace
- Tells OpenShift DevSpaces how to provision the environment
- Includes:
  - Container image and resource limits
  - Environment variables (MCP_SERVERS, ANTHROPIC_API_KEY)
  - Volume mounts for MCP config and audit logs
  - Commands (install deps, setup MCP, run app)
  - postStart events (automatic setup on workspace start)

**mcp-config.json**
- Defines which MCP servers are available (filesystem, git, GitHub, browser)
- Configures governance policies for each server
- Sets audit logging paths and requirements
- Defines approval gates for sensitive operations

### Documentation Files

**README.md** - Start here
- Explains the agentic workspace concept
- Architecture diagram and key features
- Comparison: local vs governed cloud
- Next steps for production

**QUICKSTART.md** - Hands-on guide
- Test locally in 5 minutes
- Deploy to DevSpaces in 15 minutes
- Validation checklist
- Troubleshooting tips

**DEPLOYMENT.md** - Production deployment
- Step-by-step OpenShift setup
- Vault integration for secrets
- RBAC and multi-tenancy configuration
- Monitoring and audit dashboard setup

**BUSINESS_VALUE.md** - Executive pitch
- Problem statement and risks
- Business benefits (security, productivity, ROI)
- Financial analysis (267% ROI)
- Stakeholder talking points (CTO, CISO, CFO)

**PROJECT_STRUCTURE.md** - This file
- Overview of all files and their purposes

### Utility Files

**validate-agent-config.sh**
- Bash script to validate workspace configuration
- Checks MCP servers, environment variables, dependencies
- Verifies governance settings
- Run after workspace starts to confirm everything is working

**.gitignore**
- Standard Python gitignore
- Excludes secrets (.env files)
- Excludes MCP audit logs (sensitive)

## Workflow: How It All Fits Together

### 1. Developer Clicks Workspace Link

```
https://devspaces.apps.cluster.com#https://github.com/org/agenticportal
```

### 2. DevSpaces Reads `.devfile.yaml`

- Provisions container with specified image
- Sets resource limits (memory, CPU)
- Mounts secrets from OpenShift
- Creates volumes for MCP config and audit logs

### 3. postStart Events Execute

```bash
# Automatically runs:
install-dependencies    # pip install -r requirements.txt
setup-mcp-servers      # mkdir .mcp && cp mcp-config.json .mcp/
```

### 4. Developer Gets Terminal

- Python environment ready
- Anthropic SDK installed
- MCP servers configured
- Secrets available as environment variables
- Ready to develop AI agents immediately

### 5. Developer Runs Application

```bash
uvicorn app:app --host 0.0.0.0 --port 8000
```

### 6. Developer Builds AI Agents

- Uses Anthropic SDK to create agents
- Agents use MCP servers (filesystem, git, GitHub)
- All operations governed by policies in `mcp-config.json`
- Audit logs written to `/workspace/.mcp/audit.log`

### 7. Governance Layer Enforces Policies

```
Developer agent attempts: git push --force
  ↓
MCP git server checks: mcp-config.json
  ↓
Policy requires: team_lead approval
  ↓
Notification sent to: team_lead@company.com
  ↓
Team lead approves → Operation executes
Team lead denies → Operation blocked
  ↓
Action logged in: audit.log
```

## Key Concepts

### Devfile
- Open standard for defining development environments
- Used by OpenShift DevSpaces, Eclipse Che, others
- Declarative YAML: "I want this container, these tools, these commands"

### MCP (Model Context Protocol)
- Standard protocol for AI agent tool use
- Servers provide capabilities: filesystem access, git operations, etc.
- Clients (AI agents) invoke servers via standardized API

### Governance Layer
- Policies defined in `mcp-config.json`
- Enforced automatically by MCP servers
- Examples:
  - `"allowed_paths": ["/workspace"]` → Agent can't access /etc/passwd
  - `"require_approval": ["push"]` → Force push requires approval
  - `"audit_logging": true` → All operations logged

### Agentic Workspace
- DevSpaces environment + Agent SDK + MCP servers + Governance
- Pre-wired, zero-config, governed
- Developer productive in minutes, not days

## Customization Points

Want to extend this PoC? Here's where to make changes:

### Add a new MCP server
Edit: `mcp-config.json`
```json
"slack": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-slack"],
  "env": {"SLACK_TOKEN": "${SLACK_TOKEN}"},
  "governance": {"audit_logging": true}
}
```

### Change resource limits
Edit: `.devfile.yaml` → `components.container.memoryLimit`

### Add pre-installed tools
Edit: `.devfile.yaml` → `commands.install-dependencies.commandLine`
```yaml
commandLine: |
  pip install -r requirements.txt
  npm install -g @anthropic-ai/claude-code
  apt-get update && apt-get install -y jq
```

### Add approval gates
Edit: `mcp-config.json` → `governance.require_approval`
```json
"require_approval": ["push", "force-push", "delete_branch"]
```

### Add custom skills
Create: `.claude/skills/` directory
Add skill definitions (see Claude Code documentation)
Reference in: `mcp-config.json` → `skills.pre_installed_skills`

## Testing Locally vs DevSpaces

### Local Testing (Good for development)
- Quick iteration on code
- No OpenShift cluster required
- Governance NOT enforced (just configured)

### DevSpaces Testing (Good for validation)
- Full governance enforcement
- Secrets from Vault/OpenShift
- Network isolation active
- Audit logging to persistent volume
- Realistic production environment

## Next Steps

1. **Read**: `README.md` for concept overview
2. **Try**: `QUICKSTART.md` to test locally
3. **Deploy**: `DEPLOYMENT.md` for production setup
4. **Pitch**: `BUSINESS_VALUE.md` for executive buy-in
5. **Customize**: Edit `.devfile.yaml` and `mcp-config.json` for your needs

## Support and Contributions

- File issues in your organization's repository
- Contribute improvements via pull requests
- Share learnings with the team
- Iterate on governance policies based on real usage

---

This structure is designed to be:
- **Self-documenting**: Each file has a clear purpose
- **Modular**: Change one aspect without affecting others
- **Extensible**: Easy to add new MCP servers, skills, policies
- **Production-ready**: Governance and audit built-in from day one
