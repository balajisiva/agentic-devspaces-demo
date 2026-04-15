# Contributing to Agentic DevSpaces Demo

Thank you for your interest in contributing to this project! This is a proof-of-concept demonstrating governed agentic AI development in OpenShift DevSpaces.

## How to Contribute

### Reporting Issues

If you find bugs or have suggestions:
1. Check if the issue already exists in [GitHub Issues](https://github.com/balajisiva/agentic-devspaces-demo/issues)
2. If not, create a new issue with:
   - Clear description of the problem or suggestion
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment (OpenShift version, DevSpaces version, etc.)

### Submitting Changes

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
   - Follow existing code style
   - Update documentation if needed
   - Test your changes locally
4. **Commit your changes**
   ```bash
   git commit -m "Add feature: description of your change"
   ```
5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
6. **Create a Pull Request**
   - Describe what your PR does
   - Reference any related issues
   - Explain testing you've done

## Types of Contributions Welcome

### MCP Server Configurations
- New MCP server examples (Slack, Jira, etc.)
- Improved governance policies
- Industry-specific configurations (healthcare, finance)

### Documentation Improvements
- Clearer explanations
- Additional examples
- Troubleshooting guides
- Translations

### DevSpaces Enhancements
- Custom container images with pre-installed tools
- Performance optimizations
- Additional postStart automation

### Skills and Agent Examples
- Reusable Claude skills
- Example agent workflows
- Integration patterns

### Governance and Security
- Enhanced audit logging
- RBAC examples
- Compliance templates (PCI, HIPAA, SOC2)

## Code Style Guidelines

### Devfile (.devfile.yaml)
- Use 2-space indentation
- Add comments for non-obvious configurations
- Follow [Devfile 2.2.0 schema](https://devfile.io/docs/2.2.0/)

### MCP Configuration (mcp-config.json)
- Use 2-space indentation for JSON
- Always include governance settings
- Document why approval gates exist

### Python Code
- Follow PEP 8
- Add docstrings for functions
- Keep it simple (this is a demo/example)

### Documentation
- Use clear, concise language
- Include code examples
- Provide context for "why" not just "what"

## Testing Your Changes

### Local Testing
```bash
# Test Python app
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app:app --reload

# Test validation script
./validate-agent-config.sh
```

### DevSpaces Testing
1. Push your branch to your fork
2. Create DevSpaces workspace from your branch
3. Verify postStart events complete successfully
4. Test that MCP servers are configured correctly
5. Verify governance policies work as expected

## Questions?

- Open a [GitHub Discussion](https://github.com/balajisiva/agentic-devspaces-demo/discussions)
- File an [Issue](https://github.com/balajisiva/agentic-devspaces-demo/issues)
- Comment on existing PRs or issues

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn
- Assume good intentions

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping make governed agentic AI development accessible to everyone! 🚀
