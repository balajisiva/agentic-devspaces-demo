from fastapi import FastAPI
import os

app = FastAPI(title="Agentic Hello World")

@app.get("/")
async def root():
    return {
        "message": "Hello from Agentic DevSpaces!",
        "environment": "OpenShift DevSpaces",
        "agentic_features": [
            "Pre-configured MCP servers",
            "Claude Code integration",
            "Governed cloud environment"
        ]
    }

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/agent-status")
async def agent_status():
    return {
        "mcp_servers_available": os.getenv("MCP_SERVERS", "filesystem,git").split(","),
        "agent_sdk_version": "1.0.0",
        "workspace_type": "governed-cloud"
    }
