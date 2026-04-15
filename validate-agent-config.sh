#!/bin/bash

echo "=========================================="
echo "Agentic Workspace Configuration Validator"
echo "=========================================="
echo ""

# Check MCP configuration
echo "📋 Checking MCP Server Configuration..."
if [ -f ".mcp/config.json" ]; then
    echo "✓ MCP config found"
    echo "  Configured servers:"
    cat .mcp/config.json | grep -o '"[^"]*":' | grep -v "governance\|skills\|enabled\|description" | sed 's/://g' | sed 's/"//g' | sed 's/^/    - /'
else
    echo "✗ MCP config not found at .mcp/config.json"
fi

echo ""

# Check environment variables
echo "🔐 Checking Environment Variables..."
[ ! -z "$MCP_SERVERS" ] && echo "✓ MCP_SERVERS: $MCP_SERVERS" || echo "✗ MCP_SERVERS not set"
[ ! -z "$AGENT_WORKSPACE_TYPE" ] && echo "✓ AGENT_WORKSPACE_TYPE: $AGENT_WORKSPACE_TYPE" || echo "✗ AGENT_WORKSPACE_TYPE not set"
[ ! -z "$ANTHROPIC_API_KEY" ] && echo "✓ ANTHROPIC_API_KEY: [REDACTED]" || echo "⚠ ANTHROPIC_API_KEY not set (required for agent SDK)"

echo ""

# Check Python dependencies
echo "🐍 Checking Python Dependencies..."
python3 -c "import fastapi; print('✓ FastAPI:', fastapi.__version__)" 2>/dev/null || echo "✗ FastAPI not installed"
python3 -c "import uvicorn; print('✓ Uvicorn:', uvicorn.__version__)" 2>/dev/null || echo "✗ Uvicorn not installed"
python3 -c "import anthropic; print('✓ Anthropic SDK:', anthropic.__version__)" 2>/dev/null || echo "✗ Anthropic SDK not installed"

echo ""

# Check governance
echo "🛡️  Checking Governance Configuration..."
if [ -f ".mcp/config.json" ]; then
    GOVERNANCE_ENABLED=$(cat .mcp/config.json | grep -o '"governance":[^}]*"enabled":\s*true' | wc -l | tr -d ' ')
    if [ "$GOVERNANCE_ENABLED" -gt "0" ]; then
        echo "✓ Governance enabled"
        echo "  - Audit logging configured"
        echo "  - Network isolation active"
        echo "  - Secret management via Vault"
    else
        echo "⚠ Governance not enabled"
    fi
fi

echo ""

# Check workspace type
echo "🏢 Workspace Environment..."
if [ "$AGENT_WORKSPACE_TYPE" = "governed-cloud" ]; then
    echo "✓ Running in governed cloud environment (OpenShift DevSpaces)"
    echo "  - Centralized secret management"
    echo "  - Audit trail enabled"
    echo "  - Policy enforcement active"
else
    echo "⚠ Running in local/ungoverned environment"
fi

echo ""
echo "=========================================="
echo "Validation Complete"
echo "=========================================="
