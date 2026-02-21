# Uptime Monitor

Keep-alive pings for services that sleep on inactivity (Render free tier, Neon DB, etc.) using GitHub Actions.

## Setup

1. Copy the template to create your local config:

```bash
cp services.example.json services.json
```

2. Edit `services.json` with your services:

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

3. Add the config as a GitHub secret:
   - Go to **Settings → Secrets and variables → Actions → New repository secret**
   - Name: `SERVICES_CONFIG`
   - Value: paste the full content of your `services.json`

4. Push to GitHub. The workflow runs every 10 minutes automatically.

> `services.json` is gitignored — your service URLs and config stay private. Only `services.example.json` is tracked as a template.

## Authenticated services

For services that require tokens or API keys:

1. Add a new repository secret (e.g. `MY_API_TOKEN`)
2. Reference it in your `services.json` using `${MY_API_TOKEN}` syntax inside headers
3. Add the secret to `.github/workflows/ping.yml` in the "Ping all services" step:

```yaml
env:
  MY_API_TOKEN: ${{ secrets.MY_API_TOKEN }}
```

## Logs

Go to the **Actions** tab in your GitHub repo to see ping results.

## Manual trigger

Actions tab → **Ping Services** workflow → **Run workflow**.

## Important

The repo must be **public** for unlimited GitHub Actions minutes on the free plan.
