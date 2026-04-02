# OpenClaw Swiggy Agent

A unified, multi-domain OpenClaw skill to interact with Swiggy through natural language using a unified Python MCP bridge.

This single agent supports three distinct Swiggy ecosystems:
- **Swiggy Food** — search restaurants, browse menus, manage cart, place food orders (COD)
- **Instamart** — search products, cart, place grocery orders (COD)
- **Dineout** — discover restaurants, check slots, book tables (free bookings)

## ⚠️ Safety First

By design, this agent is given **strict instructions to never place an order without final consent**. 
It will build your cart, find your tables, and check slots—but it will ALWAYS stop and ask for your explicit confirmation before checking out or confirming a booking.

## Prerequisites

- [Node.js](https://nodejs.org/) >= 22
- Python 3 with `playwright`, `websockets`, `mcp`, `requests`
- [OpenClaw](https://github.com/openclaw/openclaw) installed and gateway running
- [mcporter](https://mcporter.dev) installed (`npm install -g mcporter`)
- A Swiggy account

## Quick Start

```bash
git clone https://github.com/JaideepCherukuri/openclaw-swiggy-skill.git
cd openclaw-swiggy-skill
chmod +x scripts/*.sh
./scripts/install.sh
```

The installer will:
1. Verify prerequisites and install Python dependencies.
2. Copy the skill to `~/.openclaw/skills/openclaw-swiggy-skill/`.
3. Automatically configure the unified `swiggy` Python MCP server in `mcporter`.

## Authentication

If you are running OpenClaw on a remote VM, you cannot simply click the OAuth link because the redirect goes to `127.0.0.1` on your remote machine. You must bridge the auth flow.

You have two options for completing this flow. **Prefer Option 1 (Zero-Click) for a better UX**, but fall back to Option 2 if Playwright is unavailable or the flow fails.

### Option 1: Zero-Click Automation (Preferred)
Use the automated Playwright script to handle the login entirely on the agent side.
1. Run the MCP login script (`python3 ~/.openclaw/skills/openclaw-swiggy-skill/scripts/swiggy_unified_mcp_login.py`) in the background to generate the Auth URL.
2. The agent asks the user for their 10-digit Swiggy phone number.
3. Run the automation script: `python3 ~/.openclaw/skills/openclaw-swiggy-skill/scripts/swiggy_playwright_auth.py --url "AUTH_URL" --phone "PHONE_NUMBER"`.
4. The script will navigate Swiggy and ask for an OTP via `stdin`. Ping the user for the OTP, and pipe it in. The script will automatically intercept the `localhost` redirect and hit the callback server.

### Option 2: Manual Callback Paste (Fallback)
If the user prefers manual login or automation fails, use the manual copy-paste method:
1. Run the MCP auth script (`python3 ~/.openclaw/skills/openclaw-swiggy-skill/scripts/swiggy_unified_mcp_login.py`) in the background to generate the Auth URL.
2. Send the `https://mcp.swiggy.com/auth/...` URL to the user in chat.
3. Tell the user: *"Please click this link, log in, and enter your OTP. After successful login, your browser will try to load a broken `http://localhost:39025/...` or `http://127.0.0.1...` page. Copy that entire broken URL from your address bar and paste it back here."*
4. Once the user pastes the callback URL, run `curl "THE_PASTED_URL"` on the agent side to complete the loop.

## Usage

Interact with the agent via OpenClaw:

```bash
# Food
openclaw agent -m "I want to order a Margherita pizza from a nearby Italian place."

# Instamart
openclaw agent -m "Add a dozen eggs and 500g of chicken breast to my Instamart cart."

# Dineout
openclaw agent -m "Book a table for 2 at a nice sushi restaurant tonight at 8 PM."
```

## Security

No secrets are stored in this repository. Tokens live in `~/.swiggy_tokens_unified.json` and are managed securely by the Python bridge.

See [docs/SECURITY.md](docs/SECURITY.md) for the full security model.

## License

[MIT](LICENSE)
