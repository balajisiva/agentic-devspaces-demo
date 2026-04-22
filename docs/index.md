---
layout: default
title: Home
---

# Agentic Workspaces for OpenShift DevSpaces

> **Governed AI-powered development in the cloud** - Enable AI coding tools while maintaining security, compliance, and control.

---

## What Is This?

OpenShift DevSpaces environments **pre-configured** with AI agent capabilities:

- 🤖 **AI Agent SDKs** - Claude, Anthropic pre-installed
- 🔧 **MCP Servers** - Filesystem, Git, GitHub access for AI
- 🔒 **Enterprise Governance** - Audit logs, approval gates, policy enforcement
- ☁️ **Cloud-Based** - Zero secrets on developer laptops

**The key problem we solve:** Organizations want AI coding tools, but can't allow ungoverned AI agents on local machines (security/compliance risk).

**Our solution:** Pre-wired AI workspaces in OpenShift DevSpaces with built-in governance.

---

## Three Tiers - Pick What You Need

| Tier | What You Get | Tokens Required | Best For |
|------|--------------|-----------------|----------|
| **🟢 Minimal** | Filesystem + Local Git | None | Basic CI pipelines, file operations |
| **🟡 Standard** | + GitHub Integration | GITHUB_TOKEN | CI with PR creation, GitHub automation |
| **🔴 Full** | + AI Features + Governance | ANTHROPIC_API_KEY + GITHUB_TOKEN | Developer workspaces, AI-powered workflows |

[**Choose Your Tier →**](deployment-ci)

---

## Real-World CI/CD Examples

See **complete working code** for:

1. **AI Code Review Bot** - Claude reviews every PR automatically
2. **Auto-Generate Tests** - AI creates pytest tests for untested code
3. **Auto-Documentation** - AI generates markdown docs on merge
4. **Intelligent Refactoring** - Code quality improvements via AI
5. **Security Auto-Fixes** - AI creates PRs to fix vulnerabilities
6. **Migration Assistant** - Upgrade legacy code (Python 2→3)

**Platforms:** OpenShift Pipelines (Tekton), Jenkins, GitHub Actions

[**View All Use Cases →**](ci-use-cases)

---

## Quick Start (5 Minutes)

### For Developer Workspaces:

```bash
# 1. Create OpenShift secrets
oc create secret generic agentic-secrets \
  --from-literal=ANTHROPIC_API_KEY='sk-ant-xxx' \
  --from-literal=GITHUB_TOKEN='ghp_xxx'

oc label secret agentic-secrets controller.devfile.io/mount-as=env

# 2. Open in DevSpaces
https://devspaces.example.com/#https://github.com/balajisiva/agentic-devspaces-demo
```

### For CI Pipelines:

```bash
# Clone repo
git clone https://github.com/balajisiva/agentic-devspaces-demo.git
cd agentic-devspaces-demo

# Choose tier (minimal = no tokens needed)
./setup-ci.sh --tier minimal
```

[**Full Quick Start Guide →**](quickstart)

---

## Benefits vs Local Development

| Aspect | Local Machines | Agentic DevSpaces |
|--------|---------------|-------------------|
| **Secrets** | Scattered `.env` files | Vault-managed, centralized |
| **Audit Trail** | None | Every AI operation logged |
| **Consistency** | "Works on my machine" | Standardized across org |
| **Onboarding** | 2-3 days setup | 5 minutes |
| **Compliance** | Manual, error-prone | Automated, policy-driven |

---

## Business Value

- **267% ROI** in year one
- **$600K net benefit** (first year)
- **90% reduction** in onboarding time
- **Zero security incidents** related to AI tools
- **3.3 month** payback period

[**See Full ROI Analysis →**](business-value)

---

## Architecture

```
┌──────────────────────────────────────────────┐
│ OpenShift DevSpaces                          │
│                                              │
│  ┌────────────────────────────────────┐     │
│  │ Agentic Workspace Container        │     │
│  │                                     │     │
│  │  • FastAPI App                     │     │
│  │  • Claude SDK (pre-installed)      │     │
│  │  • MCP Servers (governed)          │     │
│  │    - Filesystem (workspace only)   │     │
│  │    - Git (audit logged)            │     │
│  │    - GitHub (approval gated)       │     │
│  │  • Secrets from Vault              │     │
│  │  • Full audit logging              │     │
│  └────────────────────────────────────┘     │
└──────────────────────────────────────────────┘
```

---

## Get Started Now

<div style="text-align: center; margin: 3rem 0;">
  <a href="quickstart" style="display: inline-block; padding: 1rem 2rem; background: #238636; color: white; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 1.1rem; margin: 0.5rem;">
    🚀 Quick Start Guide
  </a>
  <a href="ci-use-cases" style="display: inline-block; padding: 1rem 2rem; background: #1f6feb; color: white; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 1.1rem; margin: 0.5rem;">
    📘 View Use Cases
  </a>
</div>

---

## Resources

- 📦 [Deployment Guide](deployment-ci) - Complete setup instructions
- 💰 [Business Value](business-value) - ROI analysis for stakeholders
- 🏗️ [GitHub Repository](https://github.com/balajisiva/agentic-devspaces-demo) - Source code
- 🐛 [Report Issues](https://github.com/balajisiva/agentic-devspaces-demo/issues) - Bugs and feature requests

---

**Built with ❤️ for Red Hat OpenShift**
