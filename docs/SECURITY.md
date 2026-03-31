# Security Model

## Threat Model

This project uses an AI agent (via OpenClaw) to modify a Swiggy Instamart cart. Here's what could go wrong and how we mitigate it.

### Risk: Accidental Checkout

| Approach | Risk Level | Why |
|----------|-----------|-----|
| Browser automation (Playwright/Puppeteer) | High | Agent can click any button, including "Place Order" |
| Browser automation with LLM (OpenClaw + browser tool) | High | LLM could misinterpret page and click checkout |
| **MCP server (this project)** | **Low** | Checkout exists but capped at ₹1000; skill explicitly forbidden from calling it |

Swiggy's Instamart MCP endpoint (`https://mcp.swiggy.com/im`) exposes structured API tools including search, update-cart, view-cart, and checkout. **Checkout is available** but restricted to orders under ₹1000 (Swiggy's MCP beta limitation). Our defense: the skill instructions (`SKILL.md`) explicitly forbid calling `checkout`, `clear_cart`, or any payment/order tools.

### Risk: Prompt Injection

Browser-based agents read web page content (DOM, text, ads) and pass it to the LLM. Malicious content on the page could manipulate the agent.

**Our mitigation**: No browser — significantly reduced attack surface. However, MCP tool responses still contain text data (product names, descriptions) from Swiggy's catalog. A malicious or compromised product listing could theoretically include adversarial text that the LLM interprets as instructions (indirect prompt injection via tool responses). Risk is **low** (not zero) because:
- Product catalog data is managed by Swiggy, not arbitrary web content
- The attack surface is limited to structured JSON fields, not free-form HTML
- The skill's tool restriction (`mcp:swiggy-instamart` only) limits what the agent can do even if manipulated

### Risk: Unintended Cart Modifications

The agent could theoretically remove items or change quantities.

**Our mitigation**:
- The skill instructions (`SKILL.md`) explicitly forbid removing items or changing quantities
- The skill config (`config.json`) restricts tool access to `mcp:swiggy-instamart` only — no browser, filesystem, or exec tools
- The skill checks if the item is already in cart before adding (best-effort idempotent)
- **Note**: `update_cart` replaces the entire cart, so the skill must preserve existing items. A bug here could clear your cart — this is an LLM instruction risk, not a safety guarantee.

### Risk: Secret Leakage

| Secret | Where It Lives | NOT In |
|--------|---------------|--------|
| Groq API key | `~/.openclaw/.env` (chmod 600) | This repo |
| Telegram bot token | `~/.openclaw/.env` (chmod 600) | This repo |
| Gateway auth token | `~/.openclaw/.env` (chmod 600) | This repo |
| Swiggy session tokens | OpenClaw internal state | This repo |

All secrets are stored in environment variables or OpenClaw's `.env` file. The `openclaw.json` config file references them via `${VAR_NAME}` syntax. No secrets exist in this repository.

### Risk: Session Hijacking

Swiggy MCP authentication uses OAuth (browser-based login). Session tokens are stored by mcporter locally (`~/.mcporter/`). If the machine is compromised, the attacker could access:
- Your Swiggy cart (add/view items)
- Your Swiggy account info accessible through MCP

**Mitigation**: This is the same risk as being logged into Swiggy on your phone. Machine-level compromise is out of scope.

## Defense Layers

```
Layer 1: MCP-only (no browser)        → No page interaction, no accidental clicks
Layer 2: Tool restriction              → Skill only has access to mcp:swiggy-instamart
Layer 3: Checkout forbidden in skill   → SKILL.md explicitly bans checkout/clear_cart/payment tools
Layer 4: Idempotency (best-effort)     → LLM instructed to check cart before adding*
Layer 5: Isolated cron sessions        → No context leakage between runs
Layer 6: Session expiry notification   → Alerts when re-auth is needed
```

*Layer 4 is an LLM instruction, not a programmatic guarantee. The agent is told to check the cart before adding, but LLMs are non-deterministic — it may occasionally skip the check or misinterpret the cart contents. In practice this means a rare duplicate item, not a safety issue.

## Responsible Use

- **Terms of Service**: Automated interaction with Swiggy (even on your own account) may violate Swiggy's Terms of Service. Use at your own risk. This project is provided for educational purposes and as a reference for safe AI agent design.
- **Your own account only**: Using this to modify someone else's cart without their knowledge could have legal implications depending on your jurisdiction.
- **No warranty**: This project does not guarantee that Swiggy won't flag, rate-limit, or ban accounts that use automated tools.
