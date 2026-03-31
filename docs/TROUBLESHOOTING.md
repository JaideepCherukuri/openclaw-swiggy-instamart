# Troubleshooting

## Session Expired

**Symptom**: Agent reports "Swiggy session expired" or MCP returns authentication errors.

**Fix**: Re-authenticate with Swiggy MCP:
```bash
mcporter auth swiggy-instamart
```
This opens a browser window for Swiggy OAuth login. Sessions expire periodically — this is expected.

## Product Not Found

**Symptom**: Agent reports "Product not found."

**Possible causes**:
- Product name changed on Swiggy
- Product delisted from Instamart
- Product not available in your delivery area

**Fix**: Search manually on Swiggy Instamart. If the product name changed, update it in `skill/SKILL.md` and re-copy to `~/.openclaw/skills/sneak-treat/`.

## Product Out of Stock

**Symptom**: Agent reports "Product out of stock."

**Fix**: Wait. Stock changes daily. The next cron run will try again.

## MCP Server Down

**Symptom**: Agent reports connection errors to `mcp.swiggy.com`.

**Fix**: Swiggy's MCP server may be experiencing downtime. Check [Swiggy's status page](https://www.swiggy.com) or try again later.

## OpenClaw Gateway Not Running

**Symptom**: Scripts fail with connection errors to `127.0.0.1:18789`.

**Fix**:
```bash
openclaw gateway start
```

If it still fails, check logs:
```bash
tail -50 ~/.openclaw/logs/gateway.err.log
```

Common causes:
- Missing environment variables → check `~/.openclaw/.env`
- Port conflict → check if another process uses port 18789
- Config error → run `openclaw doctor --fix`

## Duplicate Items in Cart

**Symptom**: Multiple units of the treat appear in cart.

**Possible causes**:
- The idempotency check in SKILL.md failed (LLM skipped cart check)
- The `update_cart` call didn't properly preserve existing items (it replaces the entire cart)

**Fix**: Manually remove extra items from your Swiggy cart. If this keeps happening, check if Swiggy's MCP `get_cart` tool is returning correct data: `mcporter call swiggy-instamart.get_cart`

## Cron Job Not Running

**Symptom**: Item not added to cart at 3 AM.

**Check**:
```bash
openclaw cron list
```

If `sneak-treat-run` is not listed:
```bash
bash config/cron-setup.sh
```

If it is listed but not executing, check that the OpenClaw gateway is running at 3 AM (machine must be on and not sleeping).

## Groq API Errors

**Symptom**: Agent fails with model/API errors.

**Check**: Verify your Groq API key is set (without printing the full key):
```bash
echo "${GROQ_API_KEY:0:8}..."  # Should start with gsk_
```

Check Groq rate limits at [console.groq.com](https://console.groq.com).
