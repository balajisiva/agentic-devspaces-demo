# Optional: Custom container image with pre-installed tools
# Use this to avoid installing dependencies on every workspace start

FROM quay.io/devfile/universal-developer-image:ubi8-latest

USER root

# Install Node.js LTS for MCP servers
RUN curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash - \
    && dnf install -y nodejs \
    && dnf clean all

# Pre-install commonly used MCP servers
RUN npm install -g \
    @modelcontextprotocol/server-filesystem \
    @modelcontextprotocol/server-git \
    @modelcontextprotocol/server-github \
    @modelcontextprotocol/server-puppeteer

# Pre-install Python dependencies
COPY requirements.txt /tmp/
RUN pip3 install -r /tmp/requirements.txt && rm /tmp/requirements.txt

# Pre-install Claude Code CLI (optional)
RUN npm install -g @anthropic-ai/claude-code || echo "Claude Code install skipped"

# Create MCP and skills directories
RUN mkdir -p /workspace/.mcp /workspace/.claude/skills \
    && chown -R 1001:0 /workspace

USER 1001

# Metadata
LABEL name="agentic-devspace-image" \
      version="1.0.0" \
      description="Pre-configured image for agentic AI development in DevSpaces" \
      io.k8s.description="DevSpaces image with MCP servers and AI agent SDKs" \
      io.openshift.tags="devspaces,ai,mcp,claude"

# Default command
CMD ["/bin/bash"]
