#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
TIER=""
DRY_RUN=false

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to show usage
usage() {
    cat << EOF
Usage: $0 --tier <minimal|standard|full> [options]

Setup script for Agentic DevSpaces CI configurations.

Options:
  --tier <tier>       Required. Choose: minimal, standard, or full
  --dry-run          Show what would be done without making changes
  --help             Show this help message

Tiers:
  minimal            Zero tokens required (filesystem + local git)
  standard           Requires GITHUB_TOKEN (+ GitHub MCP)
  full               Requires ANTHROPIC_API_KEY + GITHUB_TOKEN (all features)

Examples:
  $0 --tier minimal
  $0 --tier standard --dry-run
  $0 --tier full

For more information, see DEPLOYMENT-CI.md
EOF
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --tier)
            TIER="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            usage
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate tier argument
if [ -z "$TIER" ]; then
    print_error "Missing required argument: --tier"
    usage
fi

if [[ ! "$TIER" =~ ^(minimal|standard|full)$ ]]; then
    print_error "Invalid tier: $TIER (must be minimal, standard, or full)"
    usage
fi

# Print banner
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Agentic DevSpaces - CI Setup                             ║"
echo "║  Tier: ${TIER^^}                                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if required files exist
print_info "Checking for required files..."

DEVFILE_SOURCE=".devfile-ci-${TIER}.yaml"
MCP_CONFIG_SOURCE="mcp-config-ci-${TIER}.json"

if [ ! -f "$DEVFILE_SOURCE" ]; then
    print_error "Devfile not found: $DEVFILE_SOURCE"
    exit 1
fi
print_success "Found devfile: $DEVFILE_SOURCE"

if [ ! -f "$MCP_CONFIG_SOURCE" ]; then
    print_error "MCP config not found: $MCP_CONFIG_SOURCE"
    exit 1
fi
print_success "Found MCP config: $MCP_CONFIG_SOURCE"

# Show what will be done
echo ""
print_info "Configuration summary:"
echo "  Source devfile: $DEVFILE_SOURCE"
echo "  Source MCP config: $MCP_CONFIG_SOURCE"
echo "  Target devfile: .devfile.yaml"
echo "  Target MCP config: .mcp/config.json"
echo ""

# Tier-specific information
case $TIER in
    minimal)
        print_info "Tier: Minimal (Zero tokens required)"
        echo "  ✓ Filesystem MCP"
        echo "  ✓ Git MCP (local operations)"
        echo "  ✗ GitHub integration"
        echo "  ✗ Anthropic API"
        echo "  ✗ Governance/audit logging"
        echo ""
        print_success "This tier works out of the box - no secrets needed!"
        ;;
    standard)
        print_info "Tier: Standard (GitHub integration)"
        echo "  ✓ Filesystem MCP"
        echo "  ✓ Git MCP (local operations)"
        echo "  ✓ GitHub MCP (requires GITHUB_TOKEN)"
        echo "  ✗ Anthropic API"
        echo "  ✗ Governance/audit logging"
        echo ""
        print_warning "This tier requires GITHUB_TOKEN to be set!"
        echo ""
        echo "Create OpenShift secret:"
        echo "  oc create secret generic ci-github-token \\"
        echo "    --from-literal=GITHUB_TOKEN='ghp_xxxxxxxxxxxx' \\"
        echo "    -n your-namespace"
        echo ""
        echo "  oc label secret ci-github-token \\"
        echo "    controller.devfile.io/mount-as=env \\"
        echo "    -n your-namespace"
        ;;
    full)
        print_info "Tier: Full (Complete governance)"
        echo "  ✓ Filesystem MCP"
        echo "  ✓ Git MCP (with approval gates)"
        echo "  ✓ GitHub MCP (with approval gates)"
        echo "  ✓ Anthropic API"
        echo "  ✓ Browser MCP"
        echo "  ✓ Full governance & audit logging"
        echo ""
        print_warning "This tier requires ANTHROPIC_API_KEY and GITHUB_TOKEN!"
        echo ""
        echo "Create OpenShift secret:"
        echo "  oc create secret generic agentic-workspace-secrets \\"
        echo "    --from-literal=ANTHROPIC_API_KEY='sk-ant-xxxxxxxxxxxx' \\"
        echo "    --from-literal=GITHUB_TOKEN='ghp_xxxxxxxxxxxx' \\"
        echo "    -n your-namespace"
        echo ""
        echo "  oc label secret agentic-workspace-secrets \\"
        echo "    controller.devfile.io/mount-as=env \\"
        echo "    -n your-namespace"
        ;;
esac

echo ""

# Dry run check
if [ "$DRY_RUN" = true ]; then
    print_warning "DRY RUN MODE - No changes will be made"
    echo ""
    exit 0
fi

# Prompt for confirmation
read -p "Proceed with setup? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Setup cancelled"
    exit 0
fi

# Backup existing files if they exist
echo ""
print_info "Backing up existing files (if any)..."
if [ -f ".devfile.yaml" ]; then
    BACKUP_FILE=".devfile.yaml.backup.$(date +%Y%m%d-%H%M%S)"
    cp .devfile.yaml "$BACKUP_FILE"
    print_success "Backed up .devfile.yaml to $BACKUP_FILE"
fi

if [ -f ".mcp/config.json" ]; then
    mkdir -p .mcp
    BACKUP_FILE=".mcp/config.json.backup.$(date +%Y%m%d-%H%M%S)"
    cp .mcp/config.json "$BACKUP_FILE"
    print_success "Backed up .mcp/config.json to $BACKUP_FILE"
fi

# Copy files
echo ""
print_info "Copying configuration files..."

cp "$DEVFILE_SOURCE" .devfile.yaml
print_success "Copied $DEVFILE_SOURCE → .devfile.yaml"

mkdir -p .mcp
cp "$MCP_CONFIG_SOURCE" .mcp/config.json
print_success "Copied $MCP_CONFIG_SOURCE → .mcp/config.json"

# Validation
echo ""
print_info "Validating configuration..."

# Check if devfile is valid YAML
if command -v python3 &> /dev/null; then
    python3 -c "import yaml; yaml.safe_load(open('.devfile.yaml'))" 2>/dev/null
    if [ $? -eq 0 ]; then
        print_success "Devfile YAML syntax is valid"
    else
        print_warning "Devfile YAML syntax check failed (install PyYAML for validation)"
    fi
fi

# Check if MCP config is valid JSON
if command -v jq &> /dev/null; then
    jq empty .mcp/config.json 2>/dev/null
    if [ $? -eq 0 ]; then
        print_success "MCP config JSON syntax is valid"
    else
        print_error "MCP config JSON syntax is invalid!"
        exit 1
    fi
fi

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Setup Complete!                                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

print_success "Configuration tier: ${TIER}"
print_success "Devfile ready: .devfile.yaml"
print_success "MCP config ready: .mcp/config.json"

echo ""
print_info "Next steps:"

case $TIER in
    minimal)
        echo "  1. Commit the changes:"
        echo "     git add .devfile.yaml .mcp/config.json"
        echo "     git commit -m 'Configure DevSpaces (minimal tier)'"
        echo "     git push"
        echo ""
        echo "  2. Open workspace in DevSpaces:"
        echo "     Navigate to: https://devspaces.apps.<cluster-domain>"
        echo "     Create workspace from your repo URL"
        echo ""
        echo "  3. No secrets needed - workspace will start immediately!"
        ;;
    standard|full)
        echo "  1. Create the required OpenShift secrets (see above)"
        echo ""
        echo "  2. Commit the changes:"
        echo "     git add .devfile.yaml .mcp/config.json"
        echo "     git commit -m 'Configure DevSpaces (${TIER} tier)'"
        echo "     git push"
        echo ""
        echo "  3. Open workspace in DevSpaces:"
        echo "     Navigate to: https://devspaces.apps.<cluster-domain>"
        echo "     Create workspace from your repo URL"
        ;;
esac

echo ""
print_info "For more information, see DEPLOYMENT-CI.md"
echo ""
