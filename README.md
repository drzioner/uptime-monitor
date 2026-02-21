# Uptime Monitor

Keep-alive pings for services that sleep on inactivity (Render free tier, Neon DB, etc.) using GitHub Actions.

## Setup

1. Copy the template and add your services:

```bash
cp services.example.json services.json
```

2. Edit `services.json`:

```json
[
  {
    "name": "My API",
    "url": "https://my-app.onrender.com/health"
  },
  {
    "name": "Protected API",
    "url": "https://my-private-api.com/health",
    "headers": {
      "Authorization": "Bearer ${MY_API_TOKEN}"
    }
  }
]
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Descriptive name |
| `url` | string | yes | URL to GET |
| `timeout` | number | no | Timeout in seconds (default: 10) |
| `headers` | object | no | HTTP headers as key-value pairs. Use `${ENV_VAR}` to reference secrets |

3. Push to GitHub.
4. The workflow runs every 10 minutes automatically.

> `services.example.json` is the template with examples. `services.json` is the real config that the workflow uses. Tokens are safe because they use `${ENV_VAR}` references resolved at runtime.

## Authenticated services

For services that require tokens or API keys:

1. Go to your repo **Settings → Secrets and variables → Actions → New repository secret**
2. Add your secret (e.g. `MY_API_TOKEN`)
3. Reference it in `services.json` using `${MY_API_TOKEN}` syntax inside headers
4. Add the secret to `.github/workflows/ping.yml`:

```yaml
- name: Ping all services
  run: bash ping.sh
  env:
    MY_API_TOKEN: ${{ secrets.MY_API_TOKEN }}
```

Secrets never appear in logs or in the repository — they are only available at runtime via GitHub Actions.

## Logs

Go to the **Actions** tab in your GitHub repo to see ping results.

## Manual trigger

Actions tab → **Ping Services** workflow → **Run workflow**.

## Important

The repo must be **public** for unlimited GitHub Actions minutes on the free plan.
