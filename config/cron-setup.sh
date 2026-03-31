#!/usr/bin/env bash
# Register the order-eggs-chicken cron job in OpenClaw
# Runs daily at 3 AM in an isolated session

set -euo pipefail

echo "Registering order-eggs-chicken cron job..."

# Check if the cron job already exists
if openclaw cron list 2>/dev/null | grep -q "order-eggs-chicken-run"; then
  echo "Cron job 'order-eggs-chicken-run' already exists. Skipping."
  echo "To recreate, first delete it: openclaw cron delete order-eggs-chicken-run"
  exit 0
fi

CRON_PROMPT="Add eggs and chicken to my Swiggy Instamart cart. \
Search for 'eggs and chicken' groceries using mcporter to call swiggy-instamart MCP tools. \
Steps: 1) mcporter call swiggy-instamart.get_addresses to get my address ID. \
2) mcporter call swiggy-instamart.search_products with that addressId and query 'eggs and chicken'. \
3) Pick the first in-stock eggs and chicken product. \
4) mcporter call swiggy-instamart.get_cart to check existing items. \
5) If the product is already in cart, stop. \
6) mcporter call swiggy-instamart.update_cart with all existing items plus the new ones (quantity 1). \
Do NOT call checkout or clear_cart. Report what happened."

openclaw cron create \
  --name "order-eggs-chicken-run" \
  --schedule "0 3 * * *" \
  --prompt "$CRON_PROMPT" \
  --isolated true

echo "Done. Verify with: openclaw cron list"
