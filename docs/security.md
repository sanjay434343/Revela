# Security

- **No raw source code** is transmitted in local fallback mode.
- API keys stored in `~/.mycli-config.json` with `0o600` permissions.
- Sensitive files (`.env`, private keys, credentials) are excluded from AI payloads.
- GitHub tokens are redacted before any network call.
- Review and rotate credentials regularly.
