# OpenClaw Swiggy Instamart

Automatically add eggs and chicken to your Swiggy Instamart cart every day at 3 AM — using an AI agent that is **explicitly forbidden** from checking out.

## How It Works

An [OpenClaw](https://github.com/openclaw/openclaw) skill uses Swiggy's official [MCP server](https://github.com/Swiggy/swiggy-mcp-server-manifest) to add "Eggs and Chicken" to your Instamart cart via a scheduled cron job.

**Why MCP instead of browser automation?**

| | Browser Agent | MCP Agent (this project) |
|-|--------------|--------------------------|
| Can accidentally checkout | Yes | **Low** (skill forbidden from calling checkout) |
| Prompt injection risk | High (reads page HTML) | **Low** (structured API, no HTML) |
| Clicks wrong button | Possible | **N/A** (no buttons) |
| Cost per run | $0.10–0.50 | **< $0.01** |
| Breaks when UI changes | Yes | **No** (API is stable) |

Swiggy's Instamart MCP endpoint does expose checkout (capped at ₹1000 during beta), but the skill is explicitly forbidden from calling it. See [docs/SECURITY.md](docs/SECURITY.md) for the full threat model.

## Prerequisites

- [Node.js](https://nodejs.org/) >= 22
- [OpenClaw](https://github.com/openclaw/openclaw) installed and gateway running
- [mcporter](https://mcporter.dev) installed (`npm install -g mcporter`)
- A Swiggy account
- A Groq API key (free tier available at [console.groq.com](https://console.groq.com))

## Quick Start

```bash
git clone https://github.com/JaideepCherukuri/openclaw-swiggy-instamart.git
cd openclaw-swiggy-instamart
chmod +x scripts/*.sh config/*.sh
./scripts/install.sh
```

The installer will:
1. Verify prerequisites
2. Copy the skill to `~/.openclaw/skills/openclaw-swiggy-instamart/`
3. Guide you through Swiggy MCP server config
4. Help you authenticate with Swiggy (OTP-based)
5. Optionally register the 3 AM daily cron job

## Manual Setup

### 1. Install the skill

```bash
mkdir -p ~/.openclaw/skills/openclaw-swiggy-instamart
cp skill/SKILL.md ~/.openclaw/skills/openclaw-swiggy-instamart/
cp skill/config.json ~/.openclaw/skills/openclaw-swiggy-instamart/
```

### 2. Add Swiggy MCP server

```bash
mcporter config add swiggy-instamart --url https://mcp.swiggy.com/im --scope home
```

### 3. Authenticate with Swiggy

```bash
mcporter auth swiggy-instamart
```

This opens a browser window for Swiggy OAuth login. Complete the login flow.

Verify it worked:
```bash
mcporter list  # Should show "swiggy-instamart (13 tools)"
```

### 4. Test

```bash
openclaw agent --agent main -m "Run the openclaw-swiggy-instamart skill. Report what happened."
```

Then check your Swiggy Instamart cart.

### 5. Schedule (optional)

```bash
bash config/cron-setup.sh
```

This registers a daily 3 AM cron job in OpenClaw.

## Customization

### Change the product

Edit `skill/SKILL.md` — replace "Eggs and Chicken" with your desired product. Re-copy to `~/.openclaw/skills/openclaw-swiggy-instamart/`.

### Change the schedule

Edit the cron expression in `config/cron-setup.sh`. Examples:
- `0 3 * * *` — daily at 3 AM (default)
- `0 3 * * 1-5` — weekdays only
- `0 8,20 * * *` — twice daily at 8 AM and 8 PM

### Change the LLM

Update the model in your `~/.openclaw/openclaw.json`:
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "groq/openai/gpt-oss-120b"
      }
    }
  }
}
```

Any model supported by OpenClaw works. We use Groq for speed and low cost.

## Session Expiry

Swiggy MCP sessions expire periodically. When this happens:
1. The skill reports "Swiggy session expired"
2. The `session-notify.sh` script sends a macOS notification (if configured)
3. Re-authenticate: `mcporter auth swiggy-instamart`

To set up notifications (macOS and Linux):
```bash
# Add to your crontab (crontab -e)
5 3 * * * /path/to/openclaw-swiggy-instamart/scripts/session-notify.sh
```
Uses `osascript` on macOS, `notify-send` on Linux, or falls back to stderr.

## Security

No secrets are stored in this repository. All API keys and tokens live in `~/.openclaw/.env` (chmod 600) and are referenced via `${VAR_NAME}` in config files. See [config/.env.example](config/.env.example) for the expected format.

See [docs/SECURITY.md](docs/SECURITY.md) for the full security model, threat analysis, and defense layers.

## Known Limitations

- **Session expiry** — Swiggy sessions expire; manual re-authentication needed
- **MCP server stability** — Swiggy's MCP is relatively new and may have occasional issues
- **Product availability** — If the item is out of stock, the agent can't add it
- **Machine must be awake** — The cron job runs via OpenClaw's gateway, which requires the machine to be on
- **Limited observability** — The session-notify script only detects auth failures. Other failure modes (MCP down, product not found, Groq rate limit) are logged by OpenClaw but don't trigger notifications. Check `~/.openclaw/logs/` periodically.
- **Swiggy ToS** — Automated interaction with Swiggy may violate their Terms of Service. Use at your own risk.

## Docs

- [Security Model](docs/SECURITY.md) — Threat analysis and defense layers
- [Architecture](docs/ARCHITECTURE.md) — Why MCP, design decisions, LLM choice
- [Troubleshooting](docs/TROUBLESHOOTING.md) — Common issues and fixes

## License

[MIT](LICENSE)
