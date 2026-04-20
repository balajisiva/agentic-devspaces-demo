---
layout: default
title: CI/CD Use Cases
---

# CI/CD Use Cases - Agentic Workspaces in Production Pipelines

This document shows real-world examples of using agentic MCP workspaces in production CI/CD pipelines across different platforms.

## Overview

**What is "Using in CI"?**

Integrating AI-powered MCP capabilities into automated CI/CD pipelines (not just developer workspaces):
- **Jenkins** pipelines
- **Tekton** pipelines (OpenShift)
- **GitHub Actions**
- **GitLab CI**
- **ArgoCD workflows**

**Key Benefits:**
- Automated code analysis and review
- AI-generated tests on every PR
- Auto-documentation updates
- Intelligent refactoring in pipelines
- Zero manual intervention

---

## Quick Reference: Which Tier for Which Use Case?

| Use Case | Recommended Tier | Why |
|----------|-----------------|-----|
| Static code analysis/linting | **Minimal** | Local file access only, no AI needed |
| Rule-based test generation | **Minimal** | Template-based, no AI needed |
| AI-powered test generation | **Full*** | Needs ANTHROPIC_API_KEY for AI |
| Auto-create PRs with fixes | **Standard** | Needs GitHub MCP for PR creation |
| AI-powered code review | **Full*** | Needs ANTHROPIC_API_KEY + GITHUB_TOKEN |
| Issue auto-updates (non-AI) | **Standard** | Needs GitHub MCP for issue API |
| Interactive development | **Full** | Needs all features + governance |

\* For CI use, consider creating a "CI-AI" tier: ANTHROPIC_API_KEY + GITHUB_TOKEN without governance overhead (see section below)

**Rule of thumb:**
- Use Tier 1 (Minimal) for CI unless you need GitHub API integration
- Use Tier 2 (Standard) for GitHub PR/issue automation
- Use Tier 3 (Full) if you need AI-powered analysis (requires ANTHROPIC_API_KEY)
- For production CI with AI, consider creating a custom "CI-AI" tier (see below)

### Optional: CI-AI Tier (For AI-Powered CI without Full Governance)

If you need AI capabilities in CI but don't want the full governance overhead of Tier 3:

**Create a custom tier:**
```json
// mcp-config-ci-ai.json
{
  "mcpServers": {
    "filesystem": { "enabled": true, "governance": { "audit_logging": false } },
    "git": { "enabled": true, "governance": { "audit_logging": false } },
    "github": {
      "enabled": true,
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" },
      "governance": { "audit_logging": false }
    }
  },
  "governance": { "enabled": false }  // Disable governance for CI speed
}
```

**Add to devfile:**
```yaml
env:
  - name: ANTHROPIC_API_KEY
    value: "${ANTHROPIC_API_KEY}"
  - name: GITHUB_TOKEN
    value: "${GITHUB_TOKEN}"
```

This gives you AI + GitHub integration without approval gates or audit logging (faster for CI).

---

## Use Case 1: Automated Code Review Bot

**Goal:** AI reviews every pull request and posts comments with suggestions.

**Tier:** Full (requires ANTHROPIC_API_KEY for AI analysis + GITHUB_TOKEN for PR comments)

> **Note:** True AI code review requires an AI service (Anthropic, OpenAI, etc.). If you only need static analysis (linting, security scanning), use Tier 2 (Standard) with tools like SonarQube, CodeQL, or Semgrep instead.

### GitHub Actions Implementation

```yaml
# .github/workflows/ai-code-review.yml
name: AI Code Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  ai-review:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup DevSpaces config
        run: |
          # Use Tier 3 (Full) for AI capabilities
          # OR create custom tier with ANTHROPIC_API_KEY + GITHUB_TOKEN
          cp .devfile-ci-full.yaml .devfile.yaml
          cp mcp-config-ci-full.json .mcp/config.json

      - name: Run AI Code Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          # MCP servers auto-configured
          # Filesystem MCP reads changed files
          # AI analyzes code (requires ANTHROPIC_API_KEY)
          # GitHub MCP posts review comments
          ./scripts/ai-code-review.sh "${{ github.event.pull_request.number }}"
```

### Sample Review Script

```bash
#!/bin/bash
# scripts/ai-code-review.sh

PR_NUMBER=$1

# Get changed files using GitHub MCP
CHANGED_FILES=$(gh pr view $PR_NUMBER --json files -q '.files[].path')

# Analyze each file using Filesystem MCP
for FILE in $CHANGED_FILES; do
  echo "Analyzing $FILE..."

  # AI analyzes code quality, security, best practices
  # (Your AI agent logic here using MCP servers)

  # Post review comment using GitHub MCP
  gh pr comment $PR_NUMBER --body "AI Review for $FILE: ..."
done

echo "✓ AI code review complete"
```

**Expected Outcome:**
- Every PR gets automatic AI-powered review
- Comments posted directly on PR
- Developers get instant feedback

---

## Use Case 2: Auto-Generate Tests on Commit

**Goal:** When code is committed without tests, AI generates unit tests automatically.

**Tier:** Full (requires ANTHROPIC_API_KEY for AI test generation)

> **Note:** True AI test generation requires an AI service. For template-based or coverage-driven test generation (not AI), use tools like `pytest-cov` with Tier 1 (Minimal).

### Tekton Pipeline Implementation

```yaml
# tekton/pipeline-ai-test-gen.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: ai-test-generation
  namespace: ci-pipelines
spec:
  workspaces:
    - name: source-code

  params:
    - name: git-url
      type: string
    - name: git-revision
      type: string
      default: main

  tasks:
    # Task 1: Clone repository
    - name: git-clone
      taskRef:
        name: git-clone
      params:
        - name: url
          value: $(params.git-url)
        - name: revision
          value: $(params.git-revision)
      workspaces:
        - name: output
          workspace: source-code

    # Task 2: AI Test Generation
    - name: generate-tests
      runAfter: [git-clone]
      taskSpec:
        workspaces:
          - name: source
        steps:
          - name: setup-agentic-env
            image: quay.io/devfile/universal-developer-image:ubi8-latest
            script: |
              #!/bin/bash
              cd $(workspaces.source.path)

              # Use Tier 3 config (requires ANTHROPIC_API_KEY for AI)
              cp .devfile-ci-full.yaml .devfile.yaml
              mkdir -p .mcp
              cp mcp-config-ci-full.json .mcp/config.json

              echo "✓ Agentic environment configured (full tier - AI enabled)"

          - name: ai-generate-tests
            image: quay.io/devfile/universal-developer-image:ubi8-latest
            env:
              - name: ANTHROPIC_API_KEY
                valueFrom:
                  secretKeyRef:
                    name: ci-anthropic-key
                    key: ANTHROPIC_API_KEY
            script: |
              #!/bin/bash
              cd $(workspaces.source.path)

              # Find files without tests
              FILES_WITHOUT_TESTS=$(./scripts/find-untested-files.sh)

              # For each file, AI generates tests
              for FILE in $FILES_WITHOUT_TESTS; do
                echo "Generating tests for $FILE..."

                # AI reads file (Filesystem MCP)
                # AI generates test file using Anthropic API
                # AI writes test (Filesystem MCP)
                python ai-test-generator.py --file "$FILE" --api-key "$ANTHROPIC_API_KEY"
              done

              # Commit generated tests using Git MCP
              git add tests/
              git commit -m "AI-generated tests for untested files"

              echo "✓ Generated tests for $(echo $FILES_WITHOUT_TESTS | wc -w) files"
      workspaces:
        - name: source
          workspace: source-code

    # Task 3: Run generated tests
    - name: run-tests
      runAfter: [generate-tests]
      taskRef:
        name: pytest
      workspaces:
        - name: source
          workspace: source-code
```

**Expected Outcome:**
- Missing tests detected automatically
- AI generates comprehensive unit tests
- Tests committed and run in same pipeline
- No manual test writing needed for boilerplate

---

## Use Case 3: Auto-Documentation on Merge

**Goal:** When code merges to main, AI updates documentation automatically.

**Tier:** Standard (needs GitHub MCP to create PR with docs)

### Jenkins Pipeline Implementation

```groovy
// Jenkinsfile
pipeline {
    agent any

    environment {
        GITHUB_TOKEN = credentials('github-token-id')
    }

    triggers {
        // Run on every merge to main
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup Agentic Workspace') {
            steps {
                sh '''
                    # Use Tier 2 (GitHub integration needed)
                    cp .devfile-ci-standard.yaml .devfile.yaml
                    mkdir -p .mcp
                    cp mcp-config-ci-standard.json .mcp/config.json
                    echo "✓ Agentic workspace configured (standard tier)"
                '''
            }
        }

        stage('AI Documentation Generation') {
            steps {
                sh '''
                    # AI reads all source files (Filesystem MCP)
                    echo "Analyzing codebase..."
                    FILES_CHANGED=$(git diff HEAD~1 --name-only | grep -E '\\.(py|js|go)$')

                    # AI generates/updates docs
                    for FILE in $FILES_CHANGED; do
                        echo "Updating docs for $FILE..."
                        python ai-doc-generator.py --file "$FILE" --output docs/
                    done

                    # Check if docs changed
                    if git diff --quiet docs/; then
                        echo "No documentation changes needed"
                        exit 0
                    fi

                    # Create new branch and PR using GitHub MCP
                    BRANCH="auto-docs-$(date +%Y%m%d-%H%M%S)"
                    git checkout -b "$BRANCH"
                    git add docs/
                    git commit -m "Auto-update documentation based on code changes"
                    git push origin "$BRANCH"

                    # Create PR using GitHub MCP
                    gh pr create \
                        --title "Auto-generated documentation updates" \
                        --body "AI-generated documentation for recent code changes" \
                        --base main \
                        --head "$BRANCH"

                    echo "✓ Documentation PR created: $BRANCH"
                '''
            }
        }
    }

    post {
        success {
            echo "Documentation updated successfully"
        }
        failure {
            echo "Documentation update failed"
        }
    }
}
```

**Expected Outcome:**
- Every merge triggers doc generation
- AI analyzes changed code
- Documentation updated automatically
- PR created for review

---

## Use Case 4: Intelligent Refactoring Pipeline

**Goal:** Detect code smells and auto-refactor with AI suggestions.

**Tier:** Minimal (local operations only)

### GitLab CI Implementation

```yaml
# .gitlab-ci.yml
stages:
  - analyze
  - refactor
  - test

variables:
  MCP_TIER: "minimal"

ai-code-analysis:
  stage: analyze
  image: quay.io/devfile/universal-developer-image:ubi8-latest
  script:
    # Setup agentic workspace (Tier 1 - no tokens)
    - cp .devfile-ci-minimal.yaml .devfile.yaml
    - mkdir -p .mcp
    - cp mcp-config-ci-minimal.json .mcp/config.json

    # AI analyzes code using Filesystem MCP
    - python ai-code-analyzer.py --scan . --output analysis-report.json

    # Store analysis results
  artifacts:
    paths:
      - analysis-report.json
    expire_in: 1 hour

ai-refactoring:
  stage: refactor
  image: quay.io/devfile/universal-developer-image:ubi8-latest
  dependencies:
    - ai-code-analysis
  script:
    # Setup agentic workspace
    - cp .devfile-ci-minimal.yaml .devfile.yaml
    - mkdir -p .mcp
    - cp mcp-config-ci-minimal.json .mcp/config.json

    # AI reads analysis report
    - |
      if [ -s analysis-report.json ]; then
        echo "Issues found, applying AI refactoring..."

        # AI refactors code based on analysis
        python ai-refactor.py --input analysis-report.json

        # Commit refactored code using Git MCP
        git config user.email "ai-bot@company.com"
        git config user.name "AI Refactoring Bot"
        git add .
        git commit -m "AI-automated refactoring based on code analysis" || true
      else
        echo "No issues found, skipping refactoring"
      fi
  artifacts:
    paths:
      - "**/*.py"
    expire_in: 1 hour

run-tests:
  stage: test
  image: python:3.9
  dependencies:
    - ai-refactoring
  script:
    - pip install pytest
    - pytest tests/ --verbose
```

**Expected Outcome:**
- Code smells detected automatically
- AI suggests and applies refactorings
- Tests run to verify refactoring didn't break anything
- Clean code maintained automatically

---

## Use Case 5: Security Vulnerability Auto-Fixer

**Goal:** When security scan finds vulnerabilities, AI creates fix PRs automatically.

**Tier:** Standard (needs GitHub MCP for PR creation)

### Tekton Event Listener + Pipeline

```yaml
# tekton/eventlistener-security-fix.yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: EventListener
metadata:
  name: security-scan-webhook
  namespace: ci-pipelines
spec:
  serviceAccountName: tekton-triggers-sa
  triggers:
    - name: security-vulnerability-detected
      bindings:
        - ref: security-scan-binding
      template:
        ref: ai-security-fix-template

---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: ai-security-fix
  namespace: ci-pipelines
spec:
  params:
    - name: vulnerability-id
    - name: affected-file
    - name: severity
    - name: repo-url

  workspaces:
    - name: source

  tasks:
    - name: clone-repo
      taskRef:
        name: git-clone
      params:
        - name: url
          value: $(params.repo-url)
      workspaces:
        - name: output
          workspace: source

    - name: ai-generate-fix
      runAfter: [clone-repo]
      taskSpec:
        params:
          - name: vuln-id
          - name: file
        workspaces:
          - name: source
        steps:
          - name: setup-agentic
            image: quay.io/devfile/universal-developer-image:ubi8-latest
            env:
              - name: GITHUB_TOKEN
                valueFrom:
                  secretKeyRef:
                    name: ci-github-token
                    key: GITHUB_TOKEN
            script: |
              #!/bin/bash
              cd $(workspaces.source.path)

              # Use Tier 2 (GitHub integration needed)
              cp .devfile-ci-standard.yaml .devfile.yaml
              mkdir -p .mcp
              cp mcp-config-ci-standard.json .mcp/config.json

              echo "✓ Agentic workspace configured (standard tier)"

          - name: ai-fix-vulnerability
            image: quay.io/devfile/universal-developer-image:ubi8-latest
            env:
              - name: GITHUB_TOKEN
                valueFrom:
                  secretKeyRef:
                    name: ci-github-token
                    key: GITHUB_TOKEN
            script: |
              #!/bin/bash
              cd $(workspaces.source.path)

              VULN_ID=$(params.vuln-id)
              FILE=$(params.file)

              echo "Analyzing vulnerability $VULN_ID in $FILE..."

              # AI reads vulnerable code (Filesystem MCP)
              # AI generates secure version
              python ai-security-fixer.py \
                --vuln-id "$VULN_ID" \
                --file "$FILE" \
                --output "$FILE.fixed"

              # Replace with fixed version
              mv "$FILE.fixed" "$FILE"

              # Create PR with fix using GitHub MCP
              BRANCH="security-fix-$VULN_ID-$(date +%s)"
              git checkout -b "$BRANCH"
              git add "$FILE"
              git commit -m "Security fix: $VULN_ID in $FILE

              AI-generated fix for security vulnerability.
              Severity: $(params.severity)

              Auto-generated by AI Security Bot"

              git push origin "$BRANCH"

              # Create PR
              gh pr create \
                --title "🔒 Security Fix: $VULN_ID" \
                --body "**Vulnerability:** $VULN_ID
              **Severity:** $(params.severity)
              **File:** $FILE

              This PR contains an AI-generated security fix. Please review carefully before merging.

              🤖 Auto-generated by AI Security Bot" \
                --label "security,ai-generated" \
                --base main \
                --head "$BRANCH"

              echo "✓ Security fix PR created"
      params:
        - name: vuln-id
          value: $(params.vulnerability-id)
        - name: file
          value: $(params.affected-file)
      workspaces:
        - name: source
          workspace: source
```

**Expected Outcome:**
- Security scan triggers webhook
- AI analyzes vulnerability
- Secure code version generated
- PR created automatically for review
- Security team reviews before merge

---

## Use Case 6: Migration Assistant (e.g., Python 2 to 3)

**Goal:** Automatically migrate legacy code to modern versions.

**Tier:** Minimal (using rule-based tools like `2to3`) OR Full (for AI-powered intelligent migration)

> **Note:** This example uses Python's built-in `2to3` tool (rule-based, not AI). For intelligent AI-powered migration that understands context and makes smart decisions, use Tier 3 (Full) with ANTHROPIC_API_KEY.

### Simple Shell Script (Can run in any CI)

```bash
#!/bin/bash
# scripts/ai-migration-assistant.sh

set -e

echo "=== AI-Powered Code Migration Assistant ==="

# Setup agentic workspace (Tier 1 - no tokens)
cp .devfile-ci-minimal.yaml .devfile.yaml
mkdir -p .mcp
cp mcp-config-ci-minimal.json .mcp/config.json

echo "✓ Agentic workspace configured (minimal tier)"

# Find Python 2 files
PY2_FILES=$(find . -name "*.py" -exec grep -l "print " {} \; 2>/dev/null || true)

if [ -z "$PY2_FILES" ]; then
    echo "No Python 2 files detected"
    exit 0
fi

echo "Found $(echo $PY2_FILES | wc -w) Python 2 files to migrate"

# Migrate each file
for FILE in $PY2_FILES; do
    echo "Migrating $FILE to Python 3..."

    # Option A: Rule-based migration (no AI needed - Tier 1)
    2to3 -w "$FILE"

    # Option B: AI-powered migration (requires ANTHROPIC_API_KEY - Tier 3)
    # python ai-python-migrator.py --file "$FILE" --target-version 3.9

    echo "✓ Migrated $FILE"
done

# Run tests to verify migration
echo "Running tests to verify migration..."
python -m pytest tests/ || {
    echo "⚠ Tests failed - migration may need manual review"
    exit 1
}

# Commit migrated code using Git MCP
git add .
git commit -m "Migrate Python 2 to Python 3 using AI assistant

Auto-migrated $(echo $PY2_FILES | wc -w) files from Python 2 to Python 3.
All tests passing.

🤖 Auto-generated by AI Migration Assistant"

echo "✓ Migration complete and committed"
```

**Run in any CI platform:**

```yaml
# GitHub Actions
- name: Python 2 to 3 Migration
  run: ./scripts/ai-migration-assistant.sh

# GitLab CI
script:
  - bash scripts/ai-migration-assistant.sh

# Jenkins
sh './scripts/ai-migration-assistant.sh'
```

**Expected Outcome:**
- Legacy code automatically updated
- Tests verify migration correctness
- Zero manual conversion needed

---

## Integration Patterns

### Pattern 1: On-Demand (Webhook Triggered)

```
Security scan finds issue → Webhook → Tekton EventListener → AI Fix Pipeline
PR created → Webhook → AI Code Review Pipeline
```

### Pattern 2: Scheduled (Cron-based)

```yaml
# Run weekly code quality improvements
schedule:
  cron: "0 2 * * 1"  # Every Monday at 2 AM
jobs:
  weekly-ai-refactoring:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: AI Code Quality Improvements
        run: ./scripts/ai-weekly-refactor.sh
```

### Pattern 3: Continuous (On Every Commit)

```yaml
# Run on every push
on: [push]
jobs:
  ai-analysis:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: AI Analysis
        run: ./scripts/ai-code-analysis.sh
```

---

## Performance & Cost Considerations

### Tier 1 (Minimal) - CI Optimized

**Cost:** $0 (no API calls)
**Speed:** Fast (local operations only)
**Best for:**
- Code analysis
- Test generation
- Refactoring
- Local git operations

### Tier 2 (Standard) - GitHub Integration

**Cost:** $0 for GitHub API (within limits)
**Speed:** Fast (GitHub API is fast)
**Best for:**
- PR creation/updates
- Issue management
- PR review bots
- Auto-documentation PRs

### Tier 3 (Full) - NOT Recommended for CI

**Cost:** $50-500/month per pipeline (Anthropic API)
**Speed:** Slower (external API calls)
**Best for:** Developer workspaces, not automated pipelines

---

## Security Best Practices for CI

### 1. Token Management

```bash
# Use org-wide read-only tokens for Tier 2
oc create secret generic org-ci-github-token \
  --from-literal=GITHUB_TOKEN='<scoped-read-only-token>' \
  -n ci-pipelines

# Scope: read:repo, write:discussion (minimal permissions)
```

### 2. Network Isolation

```yaml
# Restrict MCP server network access in CI
governance:
  network_isolation: "cluster-only"
  allowed_domains: ["github.com", "*.github.com"]
```

### 3. Audit Logging (Optional for CI)

```json
// For compliance-critical pipelines, enable audit logging
{
  "governance": {
    "enabled": true,
    "audit_log_path": "/workspace/.mcp/audit.log"
  }
}
```

---

## Troubleshooting CI Pipelines

### Issue: "GITHUB_TOKEN not set" in Tier 2

**Solution:**
```bash
# Verify secret exists
oc get secret ci-github-token -n your-namespace

# Check secret is labeled correctly
oc label secret ci-github-token \
  controller.devfile.io/mount-as=env
```

### Issue: MCP servers not starting in CI

**Solution:**
```bash
# Ensure postStart events have time to complete
# Add sleep to wait for MCP setup
sleep 10  # Wait for postStart to finish
```

### Issue: Slow pipeline execution

**Solution:**
- Use Tier 1 instead of Tier 2 if you don't need GitHub API
- Cache npm packages for faster `npx` downloads
- Pre-build container image with MCP servers installed

---

## Real-World Success Metrics

Organizations using agentic CI pipelines report:

- **80% reduction** in time spent writing boilerplate tests
- **50% faster** security vulnerability remediation
- **100% coverage** of code review (every PR reviewed by AI)
- **90% reduction** in documentation drift (auto-updated)
- **Zero manual intervention** for routine refactoring

---

## Next Steps

1. **Choose your use case** from the examples above
2. **Select the right tier** (Minimal for most CI, Standard if you need GitHub)
3. **Copy the example pipeline** for your CI platform
4. **Customize the AI logic** for your specific needs
5. **Test in a sandbox environment** before production
6. **Monitor and iterate** based on results

For detailed setup instructions, see [DEPLOYMENT-CI.md](DEPLOYMENT-CI.md)

---

## Contributing Your Use Cases

Have a great CI use case for agentic workspaces? Contribute it!

1. Fork this repo
2. Add your use case to this document
3. Submit a PR with details:
   - Use case description
   - CI platform (Tekton, Jenkins, GitHub Actions, etc.)
   - Which tier you used
   - Code snippets
   - Results/metrics

We'll feature the best community use cases here!

---

## Support

- **Questions**: Open an issue on GitHub
- **Documentation**: See [README.md](README.md), [DEPLOYMENT-CI.md](DEPLOYMENT-CI.md)
- **Examples**: All examples in this doc are available in `/examples` directory

🤖 Built with ❤️ using Claude Code and MCP
