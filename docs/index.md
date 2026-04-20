---
layout: default
title: Home
---

# Agentic Workspaces - OpenShift DevSpaces

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenShift DevSpaces](https://img.shields.io/badge/OpenShift-DevSpaces-EE0000?logo=redhat)](https://developers.redhat.com/products/openshift-dev-spaces/overview)
[![Model Context Protocol](https://img.shields.io/badge/MCP-Enabled-blue)](https://modelcontextprotocol.io)

> **Governed AI-powered development in the cloud** - Enable AI coding tools while maintaining security, compliance, and control.

---

## What Are Agentic Workspaces?

OpenShift DevSpaces environments that come **pre-wired** with:

- 🤖 **Agent SDKs** - Claude API, Anthropic SDK pre-installed
- 🔧 **MCP Tool Connections** - Filesystem, Git, GitHub, Browser
- 🔒 **Governance Layer** - Audit logging, policy enforcement, secret management
- ✨ **Pre-configured Skills** - Code review, testing, documentation

**The key insight:** Developers build AI agents in a **governed cloud environment**, not on ungoverned local machines.

---

## The Problem We Solve

Traditional AI agent development happens on ungoverned local machines where:
- ❌ Secrets and API keys scattered across local filesystems
- ❌ No audit trail of AI agent actions
- ❌ Inconsistent tooling and configurations across teams
- ❌ No policy enforcement on AI operations
- ❌ Security vulnerabilities in local MCP server setups

**Result:** Organizations either block AI tools (productivity loss) or allow them (security/compliance risk).

---

## The Solution

**Agentic workspaces** provide:

- ✅ **5-minute workspace startup** (vs hours for local setup)
- ✅ **Zero secrets on local machines** (100% Vault-managed)
- ✅ **100% audit coverage** of AI operations
- ✅ **Consistent environment** across all developers
- ✅ **Policy enforcement** without developer intervention

---

## Three Consumption Tiers

We provide **three tiers** for different use cases:

### 🟢 Tier 1: CI-Minimal (Zero Tokens)

**What you get:**
- Filesystem MCP (file operations)
- Git MCP (local operations: commit, diff, branch)
- Works out of the box, no configuration needed

**Best for:**
- Basic CI pipelines
- File operations and local git commits
- Development environments without GitHub integration

**Setup:** Zero config - works immediately!

[View Minimal Config →](.devfile-ci-minimal.yaml)

---

### 🟡 Tier 2: CI-Standard (GitHub Integration)

**What you get:**
- Everything from Tier 1
- GitHub MCP (create PRs, manage issues, GitHub API)
- Automated PR workflows

**Requires:**
- `GITHUB_TOKEN`

**Best for:**
- CI pipelines that create PRs automatically
- Automated code review bots (non-AI)
- GitHub issue/label automation

**Setup:** One secret required (GITHUB_TOKEN)

[View Standard Config →](.devfile-ci-standard.yaml)

---

### 🔴 Tier 3: Full Governance (AI + All Features)

**What you get:**
- Everything from Tier 2
- Anthropic API integration (Claude SDK, AI capabilities)
- Full governance: audit logging, approval gates, policy enforcement
- Browser MCP, Claude Code skills

**Requires:**
- `ANTHROPIC_API_KEY`
- `GITHUB_TOKEN`

**Best for:**
- Developer workspaces
- AI-powered code review/generation
- Governed cloud development

**Setup:** Complete setup with all tokens

[View Full Config →](.devfile-ci-full.yaml)

---

## Quick Start

### Option 1: DevSpaces (Developer Workspaces)

```bash
# 1. Create OpenShift secrets
oc create secret generic agentic-workspace-secrets \
  --from-literal=ANTHROPIC_API_KEY='sk-ant-xxx' \
  --from-literal=GITHUB_TOKEN='ghp_xxx' \
  -n your-namespace

oc label secret agentic-workspace-secrets \
  controller.devfile.io/mount-as=env

# 2. Open in DevSpaces
https://devspaces.apps.<cluster>/#https://github.com/balajisiva/agentic-devspaces-demo
```

### Option 2: CI/CD Pipelines

```bash
# Clone the repo
git clone https://github.com/balajisiva/agentic-devspaces-demo.git
cd agentic-devspaces-demo

# Choose your tier
./setup-ci.sh --tier minimal   # No tokens needed
./setup-ci.sh --tier standard  # GITHUB_TOKEN required
./setup-ci.sh --tier full      # All tokens required
```

---

## Popular Use Cases

### 🤖 For CI/CD Pipelines

See our **[CI/CD Use Cases Guide](ci-use-cases)** for complete examples:

- **Automated Code Review Bot** - AI reviews every PR (Tier 3)
- **Auto-Generate Tests** - Missing tests? AI creates them (Tier 3)
- **Auto-Documentation** - Docs update automatically (Tier 2)
- **Security Auto-Fixes** - Vulnerabilities get fix PRs (Tier 2)
- **Intelligent Refactoring** - Code quality improvements (Tier 1)
- **Migration Assistant** - Legacy code upgraded (Tier 1)

**Platforms covered:** Tekton, Jenkins, GitHub Actions, GitLab CI

---

### 💼 For Enterprises

See our **[Business Value Guide](business-value)** for ROI analysis:

- **267% ROI in year one**
- **$600K net benefit** (first year)
- **3.3 month payback period**
- **90% reduction in onboarding time**
- **Zero security incidents** related to AI tools

---

## Documentation

**📘 [Quick Start (5 min)](quickstart)**
Get up and running fast

**🚀 [CI/CD Use Cases](ci-use-cases)**
6 real-world examples with code

**📦 [Deployment Guide](deployment-ci)**
Complete setup instructions

**💰 [Business Value](business-value)**
ROI analysis & stakeholder talking points

**🏗️ [Architecture](https://github.com/balajisiva/agentic-devspaces-demo/blob/main/PROJECT_STRUCTURE.md)**
Technical deep dive

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│ OpenShift DevSpaces (Governed Cloud Environment)           │
│                                                             │
│  ┌───────────────────────────────────────────────────┐    │
│  │ Agentic Workspace Container                       │    │
│  │                                                    │    │
│  │  ├─ Application Code (FastAPI)                   │    │
│  │  ├─ Agent SDK (Anthropic/Claude)                 │    │
│  │  ├─ MCP Servers (Pre-configured)                 │    │
│  │  │   ├─ Filesystem (workspace-scoped)            │    │
│  │  │   ├─ Git (audit-logged)                       │    │
│  │  │   ├─ GitHub (approval-gated)                  │    │
│  │  │   └─ Browser (domain-restricted)              │    │
│  │  └─ Governance Layer                              │    │
│  │      ├─ Audit logging                             │    │
│  │      ├─ Secret management (Vault)                 │    │
│  │      ├─ Network isolation                         │    │
│  │      └─ Policy enforcement                        │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## Benefits Over Local Development

| Aspect | Local Machine | Agentic DevSpaces |
|--------|--------------|-------------------|
| **Secret Management** | `.env` files, scattered | Vault-integrated, centralized |
| **MCP Server Security** | Unaudited, full access | Governed, restricted, logged |
| **Consistency** | "Works on my machine" | Standardized across org |
| **Audit Trail** | None | Complete AI operation logs |
| **Policy Enforcement** | Manual/none | Automatic (PRs require approval) |
| **Onboarding** | Hours/days to setup | Minutes (pre-configured) |

---

## Enterprise Governance Features

### 1. Audit Logging
All MCP server operations are logged:
```
2026-04-14 10:23:45 [filesystem] READ /workspace/app.py - user:dev@company.com
2026-04-14 10:24:12 [git] COMMIT "Add feature" - user:dev@company.com
2026-04-14 10:25:03 [github] CREATE_PR #123 - user:dev@company.com
```

### 2. Approval Gates
Sensitive operations require approval:
- Git force-push → Requires team lead approval
- GitHub PR merge → Requires code review
- Production deployments → Requires security scan

### 3. Network Isolation
MCP servers can only access:
- Cluster-internal services
- Explicitly allowed external domains
- No unrestricted internet access

### 4. Secret Rotation
API keys rotate automatically via Vault integration, no code changes needed.

---

## Get Started

1. **[Quick Start Guide](quickstart)** - 5 minutes to first workspace
2. **[Choose Your Tier](deployment-ci)** - Which config for your use case
3. **[Browse Use Cases](ci-use-cases)** - See what's possible
4. **[Deploy to Production](deployment-ci)** - Complete deployment guide

---

## Community & Support

- 📂 **[GitHub Repository](https://github.com/balajisiva/agentic-devspaces-demo)**
- 🐛 **[Report Issues](https://github.com/balajisiva/agentic-devspaces-demo/issues)**
- 💬 **[Discussions](https://github.com/balajisiva/agentic-devspaces-demo/discussions)**
- 📖 **[Contributing](https://github.com/balajisiva/agentic-devspaces-demo/blob/main/CONTRIBUTING.md)**

---

## References

- [Model Context Protocol (MCP) Specification](https://modelcontextprotocol.io)
- [OpenShift DevSpaces Documentation](https://docs.openshift.com/container-platform/latest/devspaces/)
- [Devfile Schema 2.2.0](https://devfile.io/docs/2.2.0/)
- [Claude API & Agent SDK](https://docs.anthropic.com)

---

<div style="text-align: center; margin-top: 3rem; padding: 2rem; background: #f6f8fa; border-radius: 6px;">
  <h3>Ready to enable governed AI development?</h3>
  <p style="margin: 1rem 0;">
    <a href="quickstart" style="display: inline-block; padding: 12px 24px; background: #EE0000; color: white; text-decoration: none; border-radius: 6px; font-weight: bold;">Get Started in 5 Minutes →</a>
  </p>
</div>
