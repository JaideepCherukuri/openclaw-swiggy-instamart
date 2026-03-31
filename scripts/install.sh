#!/usr/bin/env bash
# Interactive setup script for order-eggs-chicken
set -euo pipefail

SKILL_DIR="$HOME/.openclaw/skills/order-eggs-chicken"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Order Eggs & Chicken Installer ==="
echo ""

# 1. Check prerequisites
echo "[1/6] Checking prerequisites..."

if ! command -v openclaw &>/dev/null; then
  echo "ERROR: OpenClaw is not installed."
  echo "Install it: npm install -g openclaw@latest"
  exit 1
fi
echo "  OpenClaw: $(openclaw --version)"

if ! command -v node &>/dev/null; then
  echo "ERROR: Node.js is not installed."
  exit 1
fi
NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 22 ]; then
  echo "ERROR: Node.js >= 22 required. Found: $(node -v)"
  exit 1
fi
echo "  Node.js: $(node -v)"

# 2. Check gateway (use openclaw status instead of hardcoded port)
echo ""
echo "[2/6] Checking OpenClaw gateway..."
if openclaw gateway status 2>/dev/null | grep -q "Runtime: running"; then
  echo "  Gateway is running."
else
  echo "  WARNING: Gateway is not running."
  echo "  Start it with: openclaw gateway start"
  echo "  Or run: openclaw onboard --install-daemon"
  read -p "  Continue anyway? (y/N) " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

# 3. Copy skill files
echo ""
echo "[3/6] Installing skill to $SKILL_DIR..."
mkdir -p "$SKILL_DIR"
cp "$SCRIPT_DIR/skill/SKILL.md" "$SKILL_DIR/SKILL.md"
cp "$SCRIPT_DIR/skill/config.json" "$SKILL_DIR/config.json"
echo "  Skill files copied."

# 4. MCP server config (via mcporter)
echo ""
echo "[4/6] Swiggy MCP server configuration"

if ! command -v mcporter &>/dev/null; then
  echo "  mcporter not found. Installing..."
  npm install -g mcporter
fi

if mcporter list 2>/dev/null | grep -q "swiggy-instamart"; then
  echo "  Swiggy Instamart MCP server already configured. Skipping."
else
  echo "  Adding Swiggy MCP server via mcporter..."
  mcporter config add swiggy-instamart --url https://mcp.swiggy.com/im --scope home
  echo "  Done."
fi

# 5. Authenticate with Swiggy
echo ""
echo "[5/6] Swiggy authentication"
echo ""
echo "  Authenticating with Swiggy MCP server..."
echo "  A browser window will open for Swiggy OAuth login."
echo ""
mcporter auth swiggy-instamart --oauth-timeout 120000
echo ""
echo "  Verifying..."
if mcporter list 2>/dev/null | grep -q "tools"; then
  echo "  Authentication successful."
else
  echo "  WARNING: Authentication may have failed. Run: mcporter auth swiggy-instamart"
fi

# 6. Register cron job
echo ""
echo "[6/6] Setting up cron job..."
read -p "  Register daily 3 AM cron job? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  bash "$SCRIPT_DIR/config/cron-setup.sh"
else
  echo "  Skipped. Run config/cron-setup.sh later to set it up."
fi

echo ""
echo "=== Setup complete! ==="
echo ""
echo "Test it: openclaw agent --agent main -m 'Run the order-eggs-chicken skill. Report what happened.'"
echo "Or run:  ./scripts/test.sh"
