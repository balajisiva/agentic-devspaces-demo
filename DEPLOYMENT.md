# Deployment Guide: Agentic DevSpaces to OpenShift

## Prerequisites

- OpenShift cluster with DevSpaces operator installed
- Cluster admin access for initial setup
- Vault instance for secret management (optional but recommended)

## Step 1: Prepare OpenShift DevSpaces

### Install DevSpaces Operator

```bash
# Via OpenShift Console
Operators → OperatorHub → Search "Red Hat OpenShift DevSpaces" → Install

# Or via CLI
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: devspaces
  namespace: openshift-operators
spec:
  channel: stable
  name: devspaces
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

### Create DevSpaces Instance

```bash
oc apply -f - <<EOF
apiVersion: org.eclipse.che/v2
kind: CheCluster
metadata:
  name: devspaces
  namespace: openshift-devspaces
spec:
  components:
    cheServer:
      debug: false
      logLevel: INFO
    metrics:
      enable: true
  devEnvironments:
    startTimeoutSeconds: 300
    secondsOfRunBeforeIdling: -1
    maxNumberOfWorkspacesPerUser: 5
    containerBuildConfiguration:
      openShiftSecurityContextConstraint: container-build
  networking:
    auth:
      gateway:
        configLabels:
          app: che
          component: che-gateway-config
EOF
```

## Step 2: Create Secret for Agent SDK

```bash
# Create namespace for the workspace
oc new-project agentic-workspaces

# Create secret with API keys
oc create secret generic agentic-secrets \
  --from-literal=ANTHROPIC_API_KEY='your-anthropic-key' \
  --from-literal=GITHUB_TOKEN='your-github-token' \
  -n agentic-workspaces

# Label the secret so DevSpaces can mount it
oc label secret agentic-secrets \
  controller.devfile.io/mount-as=env \
  controller.devfile.io/watch-secret=true \
  -n agentic-workspaces
```

## Step 3: Configure DevSpaces to Use Secrets

Update the `.devfile.yaml` to reference OpenShift secrets:

```yaml
components:
  - name: python-agentic-runtime
    container:
      image: quay.io/devfile/universal-developer-image:ubi8-latest
      env:
        - name: ANTHROPIC_API_KEY
          valueFrom:
            secretKeyRef:
              name: agentic-secrets
              key: ANTHROPIC_API_KEY
        - name: GITHUB_TOKEN
          valueFrom:
            secretKeyRef:
              name: agentic-secrets
              key: GITHUB_TOKEN
```

## Step 4: Push Code to Git Repository

```bash
cd /Users/basivasu/Documents/agenticportal

# Initialize git if not already
git init
git add .
git commit -m "Add agentic DevSpaces PoC"

# Push to your Git server (GitHub, GitLab, Gitea, etc.)
git remote add origin https://github.com/your-org/agentic-devspaces-poc.git
git push -u origin main
```

## Step 5: Create DevSpaces Workspace

### Via DevSpaces Dashboard

1. Navigate to DevSpaces URL: `https://devspaces.apps.<cluster-domain>`
2. Click "Create Workspace"
3. Enter Git repository URL
4. DevSpaces will detect `.devfile.yaml` and provision the workspace

### Via Factory URL

Create a shareable factory URL:

```
https://devspaces.apps.<cluster-domain>#https://github.com/your-org/agentic-devspaces-poc
```

Share this URL with developers - one click to launch pre-configured agentic workspace.

## Step 6: Verify Deployment

Once workspace starts, open terminal and run:

```bash
# Validate configuration
./validate-agent-config.sh

# Start the application
uvicorn app:app --host 0.0.0.0 --port 8000

# Test from another terminal
curl http://localhost:8000/agent-status
```

Expected output:
```json
{
  "mcp_servers_available": ["filesystem", "git", "github"],
  "agent_sdk_version": "1.0.0",
  "workspace_type": "governed-cloud"
}
```

## Step 7: Configure Governance (Production)

### Integrate with HashiCorp Vault

```bash
# Enable Vault integration in DevSpaces
oc patch checluster devspaces -n openshift-devspaces --type merge -p '
spec:
  components:
    cheServer:
      extraProperties:
        CHE_INFRA_KUBERNETES_TRUSTED__CA__DEST__CONFIGMAP__LABELS: "app=che"
        CHE_INFRA_KUBERNETES_NAMESPACE_ANNOTATIONS: |
          vault.hashicorp.com/agent-inject: "true"
          vault.hashicorp.com/role: "devspaces-agentic"
          vault.hashicorp.com/agent-inject-secret-anthropic: "secret/agentic/anthropic"
'
```

### Setup Audit Logging

Create a persistent volume for audit logs:

```bash
oc apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mcp-audit-logs
  namespace: agentic-workspaces
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: ocs-storagecluster-cephfs
EOF
```

Update devfile to mount audit volume:

```yaml
components:
  - name: mcp-audit-logs
    volume:
      size: 10Gi
  - name: python-agentic-runtime
    container:
      volumeMounts:
        - name: mcp-audit-logs
          path: /workspace/.mcp
```

## Step 8: Create Workspace Template

For organization-wide deployment, create a DevWorkspaceTemplate:

```bash
oc apply -f - <<EOF
apiVersion: workspace.devfile.io/v1alpha2
kind: DevWorkspaceTemplate
metadata:
  name: agentic-workspace-template
  namespace: openshift-devspaces
spec:
  components:
    - name: agentic-runtime
      container:
        image: quay.io/devfile/universal-developer-image:ubi8-latest
        env:
          - name: MCP_SERVERS
            value: "filesystem,git,github"
          - name: AGENT_WORKSPACE_TYPE
            value: "governed-cloud"
          - name: ANTHROPIC_API_KEY
            valueFrom:
              secretKeyRef:
                name: agentic-secrets
                key: ANTHROPIC_API_KEY
  commands:
    - id: setup-agent-env
      exec:
        component: agentic-runtime
        commandLine: |
          pip install anthropic fastapi uvicorn
          mkdir -p .mcp
          echo "Agentic environment ready"
EOF
```

## Step 9: RBAC and Multi-Tenancy

```bash
# Create role for agentic workspace users
oc apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: agentic-workspace-user
  namespace: agentic-workspaces
rules:
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get"]
    resourceNames: ["agentic-secrets"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: agentic-workspace-users
  namespace: agentic-workspaces
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: agentic-workspace-user
subjects:
  - kind: Group
    name: agentic-developers
    apiGroup: rbac.authorization.k8s.io
EOF
```

## Step 10: Monitoring and Audit Dashboard

Deploy Prometheus monitoring:

```bash
# Create ServiceMonitor for workspace metrics
oc apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: agentic-workspace-metrics
  namespace: agentic-workspaces
spec:
  selector:
    matchLabels:
      app: agentic-workspace
  endpoints:
    - port: metrics
      interval: 30s
      path: /metrics
EOF
```

## Troubleshooting

### Workspace fails to start

```bash
# Check DevSpaces operator logs
oc logs -n openshift-operators -l app=devspaces-operator

# Check workspace pod logs
oc logs -n <workspace-namespace> -l controller.devfile.io/devworkspace_name=<workspace-name>
```

### Secrets not mounted

```bash
# Verify secret exists and has correct labels
oc get secret agentic-secrets -n agentic-workspaces -o yaml

# Check if secret is mounted in pod
oc exec -n <workspace-namespace> <pod-name> -- env | grep ANTHROPIC_API_KEY
```

### MCP servers not starting

```bash
# Check Node.js/npm available in container
oc exec -n <workspace-namespace> <pod-name> -- node --version
oc exec -n <workspace-namespace> <pod-name> -- npm --version

# Manually test MCP server
oc exec -n <workspace-namespace> <pod-name> -- npx -y @modelcontextprotocol/server-filesystem /workspace
```

## Production Checklist

- [ ] Vault integration configured for secret management
- [ ] Audit logging PVC created and mounted
- [ ] RBAC policies defined and applied
- [ ] Network policies restrict external access
- [ ] Resource quotas set per namespace
- [ ] Backup strategy for workspace configurations
- [ ] Monitoring and alerting configured
- [ ] Workspace idle timeout configured
- [ ] Custom container image with pre-installed tools
- [ ] Skills directory with approved agent capabilities

## Next Steps

1. **Build Custom Container Image**: Pre-install Claude Code, MCP servers, common tools
2. **Create Skills Catalog**: Internal marketplace of approved agent skills
3. **Setup Audit Dashboard**: Web UI to view all AI operations across team
4. **Policy Automation**: Auto-apply governance policies based on project type
5. **Integration Testing**: CI/CD pipeline to test workspace configurations
