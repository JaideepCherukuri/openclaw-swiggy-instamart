---
name: order-eggs-chicken
description: Add eggs and chicken to the Swiggy Instamart cart via MCP. Use when asked to order eggs and chicken from Swiggy Instamart.
---

# Order Eggs & Chicken

Add eggs (e.g., 6 pack or similar standard pack) and chicken (e.g., 500g breast or curry cut) to the Swiggy Instamart cart.

## Steps

1. Run `mcporter call swiggy-instamart.get_addresses` to get the user's delivery addresses
2. Use the first address (or the one tagged "Home") — note the `addressId`
3. Run `mcporter call swiggy-instamart.search_products addressId=<ID> query="eggs"` to find eggs. Select a standard option (e.g., 6 pack) and note its `spinId`.
4. Run `mcporter call swiggy-instamart.search_products addressId=<ID> query="chicken breast"` (or curry cut) to find chicken. Select a standard option (e.g., 500g) and note its `spinId`.
5. Check if the items are already in the cart: `mcporter call swiggy-instamart.get_cart`
   - If cart has other items, note their spinIds and quantities — you must preserve them
6. Add the products to the cart: `mcporter call swiggy-instamart.update_cart --args '{"selectedAddressId":"<ID>","items":[...existing items..., {"spinId":"<EGGS_SPIN_ID>","quantity":1}, {"spinId":"<CHICKEN_SPIN_ID>","quantity":1}]}'`
   - IMPORTANT: `update_cart` replaces the entire cart. Always include existing cart items in the items array.
7. Report success: "Added eggs and chicken to cart."

## Rules

- Only use `mcporter` to call Swiggy Instamart MCP tools — do NOT use browser, filesystem, or any other tools
- Add exactly 1 unit, never more
- Preserve all existing cart items when calling update_cart (it replaces the entire cart)
- Do not modify quantities of existing items
- If the product is not found, report "Product not found" and STOP
- If the product is out of stock, report "Product out of stock" and STOP
- If authentication has expired, report "Swiggy session expired" and STOP
- Do not call the `checkout` tool under any circumstances
- Do not call `clear_cart` under any circumstances
- Do not interact with any payment, address creation, or order functionality
