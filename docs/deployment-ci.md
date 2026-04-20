---
layout: default
title: CI/CD Deployment Guide
---

---
layout: default
title: CI/CD Deployment Guide
---

# CI/CD Deployment Guide - Tiered MCP Configurations

This guide helps field teams choose the right tier for their use case and deploy with minimal friction.

## Quick Decision Matrix

| Use Case | Tier | Tokens Required | Use This When |
|----------|------|-----------------|---------------|
| **Basic CI pipelines** | Minimal | None | File operations, local git commits, diffs |
| **CI with GitHub integration** | Standard | GITHUB_TOKEN | Need to create PRs, read repos, GitHub API access |
| **Developer workspaces** | Full | ANTHROPIC_API_KEY + GITHUB_TOKEN | Full governance, audit logging, approval gates |

## Tier Comparison

### Tier 1: CI-Minimal (Zero Tokens)

**What you get:**
- ✅ Filesystem MCP (read/write files in workspace)
- ✅ Git MCP (local operations: commit, diff, branch, log)
- ✅ Works out of the box, no configuration needed
- ✅ Perfect for basic CI pipelines

**What you DON'T get:**
- ❌ GitHub integration (can't create PRs, read repos via API)
- ❌ Anthropic API (no Claude SDK features)
- ❌ Governance/audit logging

**When to use:**
- CI pipelines that need to read/modify code and create local commits
- Development environments where GitHub access happens via git CLI with existing credentials
- Quick prototypes and testing

**Files:**
- `.devfile-ci-minimal.yaml`
- `mcp-config-ci-minimal.json`

**Setup:**
```bash
# Option 1: Copy the devfile
cp .devfile-ci-minimal.yaml .devfile.yaml

# Option 2: Use helper script
./setup-ci.sh --tier minimal

# Option 3: Direct DevSpaces factory URL
https://devspaces.example.com/#https://github.com/your-org/repo?devfilePath=.devfile-ci-minimal.yaml
```

---

### Tier 2: CI-Standard (GITHUB_TOKEN Required)

**What you get:**
- ✅ Everything from Tier 1
- ✅ GitHub MCP (create PRs, read repos, manage issues, GitHub API access)
- ✅ Suitable for automated PR workflows

**What you DON'T get:**
- ❌ Anthropic API (no Claude SDK features)
- ❌ Governance/audit logging (lightweight for CI)

**Tokens required:**
- `GITHUB_TOKEN` - GitHub personal access token or org-wide shared token

**When to use:**
- CI pipelines that need to create pull requests automatically
- Workflows that read/write GitHub metadata (issues, labels, releases)
- Automated code review bots

**Files:**
- `.devfile-ci-standard.yaml`
- `mcp-config-ci-standard.json`

**Setup:**

1. **Create OpenShift secret with GitHub token:**
   ```bash
   oc create secret generic ci-github-token \
     --from-literal=GITHUB_TOKEN='ghp_xxxxxxxxxxxx' \
     -n your-namespace

   # Label it so DevSpaces auto-mounts it
   oc label secret ci-github-token \
     controller.devfile.io/mount-as=env \
     -n your-namespace
   ```

2. **Use the devfile:**
   ```bash
   cp .devfile-ci-standard.yaml .devfile.yaml
   # OR
   ./setup-ci.sh --tier standard
   ```

**Org-wide shared token approach:**
```bash
# Platform team creates once at org level
oc create secret generic org-ci-tokens \
  --from-literal=GITHUB_TOKEN='<read-only-or-scoped-token>' \
  -n ci-pipelines

# All teams inherit it automatically
```

---

### Tier 3: Full Governance (All Tokens Required)

**What you get:**
- ✅ Everything from Tier 2
- ✅ Anthropic API integration (Claude SDK, agentic features)
- ✅ Full governance: audit logging, approval gates, policy enforcement
- ✅ Browser MCP (headless browser automation)
- ✅ Claude Code skills support

**Tokens required:**
- `ANTHROPIC_API_KEY` - Anthropic API key for Claude SDK
- `GITHUB_TOKEN` - GitHub token

**When to use:**
- Developer workspaces (not CI pipelines)
- Environments where you need full audit trails
- Governed cloud development with approval workflows
- AI-powered development with Claude Code

**Files:**
- `.devfile-ci-full.yaml`
- `mcp-config-ci-full.json`

**Setup:**

1. **Create OpenShift secrets:**
   ```bash
   oc create secret generic agentic-workspace-secrets \
     --from-literal=ANTHROPIC_API_KEY='sk-ant-xxxxxxxxxxxx' \
     --from-literal=GITHUB_TOKEN='ghp_xxxxxxxxxxxx' \
     -n your-namespace

   oc label secret agentic-workspace-secrets \
     controller.devfile.io/mount-as=env \
     -n your-namespace
   ```

2. **Use the devfile:**
   ```bash
   cp .devfile-ci-full.yaml .devfile.yaml
   # OR
   ./setup-ci.sh --tier full
   ```

---

## How to Deploy to OpenShift DevSpaces

### Method 1: Git Repository with Devfile

1. **Choose your tier** and copy the corresponding devfile:
   ```bash
   # For minimal tier
   cp .devfile-ci-minimal.yaml .devfile.yaml
   git add .devfile.yaml
   git commit -m "Add DevSpaces config (minimal tier)"
   git push
   ```

2. **Open in DevSpaces:**
   - Navigate to DevSpaces dashboard: `https://devspaces.apps.<cluster-domain>`
   - Click "Create Workspace"
   - Enter your Git repository URL
   - DevSpaces detects `.devfile.yaml` and provisions the workspace

### Method 2: Factory URL (Direct Link)

Create shareable URLs for each tier:

```bash
# Minimal tier (no tokens needed)
https://devspaces.apps.<cluster>/#{REPO_URL}?devfilePath=.devfile-ci-minimal.yaml

# Standard tier (GITHUB_TOKEN required)
https://devspaces.apps.<cluster>/#{REPO_URL}?devfilePath=.devfile-ci-standard.yaml

# Full tier (all tokens required)
https://devspaces.apps.<cluster>/#{REPO_URL}?devfilePath=.devfile-ci-full.yaml
```

### Method 3: Helper Script (Recommended)

```bash
# Clone the repo
git clone https://github.com/your-org/agentic-devspaces-demo.git
cd agentic-devspaces-demo

# Run setup script
./setup-ci.sh --tier minimal
# OR
./setup-ci.sh --tier standard
# OR
./setup-ci.sh --tier full

# The script will:
# - Copy the right devfile and MCP config
# - Validate your setup
# - Show next steps
```

---

## Token Management Best Practices

### For CI Pipelines (Tier 1-2)

**Option A: Org-wide shared tokens**
- Platform team creates secret once at cluster/namespace level
- All CI workspaces inherit automatically
- Use scoped, read-only tokens where possible

**Option B: Per-team tokens**
- Each team creates their own secret in their namespace
- More granular control and auditing

### For Developer Workspaces (Tier 3)

**Use Vault integration** (production):
```bash
# Enable Vault agent injection
oc patch checluster devspaces -n openshift-devspaces --type merge -p '
spec:
  components:
    cheServer:
      extraProperties:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "devspaces-agentic"
'
```

**Use OpenShift secrets** (quick start):
- Create secrets per-user or per-team
- Label with `controller.devfile.io/mount-as=env`
- Secrets auto-mount when workspace starts

---

## Verification & Testing

After workspace starts, validate the configuration:

```bash
# For any tier
./validate-agent-config.sh

# Start the app
uvicorn app:app --host 0.0.0.0 --port 8000

# Test from another terminal
curl http://localhost:8000/agent-status
```

**Expected output:**

**Minimal tier:**
```json
{
  "mcp_servers_available": ["filesystem", "git"],
  "agent_sdk_version": "1.0.0",
  "workspace_type": "ci-minimal"
}
```

**Standard tier:**
```json
{
  "mcp_servers_available": ["filesystem", "git", "github"],
  "agent_sdk_version": "1.0.0",
  "workspace_type": "ci-standard"
}
```

**Full tier:**
```json
{
  "mcp_servers_available": ["filesystem", "git", "github", "browser"],
  "agent_sdk_version": "1.0.0",
  "workspace_type": "governed-cloud"
}
```

---

## Integration Examples

### Tekton Pipeline (Tier 1 - Minimal)

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: agentic-ci-pipeline
spec:
  workspaces:
    - name: source
  tasks:
    - name: run-agentic-workspace
      taskRef:
        name: devspaces-task
      params:
        - name: devfile
          value: .devfile-ci-minimal.yaml
      workspaces:
        - name: source
          workspace: source
```

### GitHub Actions (Tier 2 - Standard)

```yaml
name: Agentic CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to DevSpaces
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          # Use standard tier with GitHub integration
          cp .devfile-ci-standard.yaml .devfile.yaml
```

### Jenkins (Tier 2 - Standard)

```groovy
pipeline {
    agent any
    environment {
        GITHUB_TOKEN = credentials('github-token-id')
    }
    stages {
        stage('DevSpaces Setup') {
            steps {
                sh 'cp .devfile-ci-standard.yaml .devfile.yaml'
                sh './setup-ci.sh --tier standard'
            }
        }
    }
}
```

---

## Troubleshooting

### "GITHUB_TOKEN not set" warning

**For Tier 2 (Standard):**
1. Verify secret exists:
   ```bash
   oc get secret ci-github-token -n your-namespace
   ```

2. Check if secret has correct label:
   ```bash
   oc get secret ci-github-token -n your-namespace -o yaml | grep controller.devfile.io/mount-as
   ```

3. Verify token is mounted in workspace:
   ```bash
   echo $GITHUB_TOKEN  # Should print token value
   ```

### MCP servers not starting

```bash
# Check if npx is available
npx --version

# Test MCP server manually
npx -y @modelcontextprotocol/server-filesystem /workspace
```

### Workspace fails to start

```bash
# Check DevSpaces operator logs
oc logs -n openshift-operators -l app=devspaces-operator

# Check workspace pod logs
oc logs -n <workspace-namespace> -l controller.devfile.io/devworkspace_name=<workspace-name>
```

---

## Cost Considerations

| Tier | Anthropic API Cost | GitHub API Cost | Infrastructure Cost |
|------|-------------------|-----------------|-------------------|
| Minimal | $0 | $0 | OpenShift compute only |
| Standard | $0 | $0 (within limits) | OpenShift compute only |
| Full | ~$50-500/dev/month | $0 (within limits) | OpenShift compute + storage |

**Recommendation for CI:** Use Tier 1 or 2 to avoid Anthropic API costs in automated pipelines.

---

## Migration Path

Start minimal, scale up as needed:

```
Tier 1 (Minimal)
  → Tier 2 (Standard) when you need GitHub PR automation
    → Tier 3 (Full) when transitioning to developer workspaces
```

Simply switch the devfile and MCP config - no code changes required.

---

## Support & Feedback

- **Issues**: https://github.com/your-org/agentic-devspaces-demo/issues
- **Documentation**: See README.md, QUICKSTART.md, DEPLOYMENT.md
- **Questions**: Contact the platform team

---

## Next Steps

1. Choose your tier based on requirements
2. Follow the setup instructions above
3. Test with `./validate-agent-config.sh`
4. Integrate into your CI/CD pipeline
5. Scale to additional teams using factory URLs or workspace templates
