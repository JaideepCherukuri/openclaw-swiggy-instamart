# OpenClaw Swiggy Agent

A unified, multi-domain OpenClaw skill to interact with Swiggy through natural language using the [Swiggy MCP server](https://github.com/Swiggy/swiggy-mcp-server-manifest).

This single agent supports three distinct Swiggy ecosystems:
- **Swiggy Food** — search restaurants, browse menus, manage cart, place food orders (COD)
- **Instamart** — search products, cart, place grocery orders (COD)
- **Dineout** — discover restaurants, check slots, book tables (free bookings)

## ⚠️ Safety First

By design, this agent is given **strict instructions to never place an order without final consent**. 
It will build your cart, find your tables, and check slots—but it will ALWAYS stop and ask for your explicit confirmation before checking out or confirming a booking.

## Prerequisites

- [Node.js](https://nodejs.org/) >= 22
- [OpenClaw](https://github.com/openclaw/openclaw) installed and gateway running
- [mcporter](https://mcporter.dev) installed (`npm install -g mcporter`)
- A Swiggy account

## Quick Start

```bash
git clone https://github.com/JaideepCherukuri/openclaw-swiggy-instamart.git
cd openclaw-swiggy-instamart
chmod +x scripts/*.sh
./scripts/install.sh
```

The installer will:
1. Verify prerequisites
2. Copy the skill to `~/.openclaw/skills/swiggy-agent/`
3. Automatically configure `swiggy-food`, `swiggy-instamart`, and `swiggy-dineout` in `mcporter`.

## Authentication (Headless Playbook)

If you are running OpenClaw on a remote VM, you cannot simply click the OAuth link because the redirect goes to `127.0.0.1` on your remote machine. You must bridge the auth flow manually.

**Crucial Notes:**
- Authenticating `swiggy-instamart` automatically covers `swiggy-food` (they share the same token).
- `swiggy-dineout` requires its own separate authentication run.

### The Step-by-Step Auth Process:
1. **Start the auth flow in the background**
   ```bash
   mcporter auth swiggy-instamart
   ```
2. **Extract the Authorization URL**
   Look in the terminal output for the URL starting with `https://mcp.swiggy.com/auth/authorize?...`
3. **Open the URL on your local machine**
   Copy that link and open it in your local browser. Log in with your phone number and OTP.
4. **Copy the broken callback link**
   After successful login, your browser will try to redirect to `127.0.0.1:PORT` and fail. **This is expected.** Copy the full `http://127.0.0.1:PORT/callback?code=...` URL from your browser's address bar.
5. **Complete the loop on your remote VM**
   Go back to your remote VM terminal and run a `curl` command using that exact URL (wrapped in quotes) to complete the OAuth loop:
   ```bash
   curl "http://127.0.0.1:PORT/callback?code=..."
   ```
6. **Verify and repeat**
   Check that it says `Authorization successful`. Then, verify the tools are available using `mcporter list swiggy-instamart`.
   Repeat this exact same process for `mcporter auth swiggy-dineout`.

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

No secrets are stored in this repository. All API keys and tokens live in `~/.mcporter/credentials.json` and are managed securely by the OpenClaw environment. 

See [docs/SECURITY.md](docs/SECURITY.md) for the full security model.

## License

[MIT](LICENSE)
