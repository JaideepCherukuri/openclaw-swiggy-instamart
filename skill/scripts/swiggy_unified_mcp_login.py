import sys
import asyncio
from swiggy_unified_mcp import create_oauth_provider, TOKEN_FILE

async def _test_login():
    sys.stderr.write("Starting standalone login flow...\n")
    auth = create_oauth_provider()
    token = await auth.get_token()
    sys.stderr.write(f"Tokens successfully saved to {TOKEN_FILE}!\n")

if __name__ == "__main__":
    asyncio.run(_test_login())
