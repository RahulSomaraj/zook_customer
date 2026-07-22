# Zook Customer App — API Specification

Derived from the app's current data models, repositories, cubits and screens. Endpoints already scaffolded in code are marked **Defined**; the rest are **Proposed** (currently backed by mock/local data).

- **Base URL:** `https://api.zook.ae/v1`
- **Auth:** Bearer token (returned by OTP verify) in `Authorization: Bearer <token>`
- **Content-Type:** `application/json`
- **Currency:** all prices are integer AED (no decimals), field suffix `_aed`

---

## 1. Auth

### POST `/auth/otp/send` — **Defined**
Send a one-time passcode to a phone number.
```json
// request
{ "phone_number": "+971501234567" }
// 200
{ "success": true, "expires_in": 300 }
```

### POST `/auth/otp/verify` — **Defined**
Verify the OTP and return the authenticated user + token.
```json
// request
{ "phone_number": "+971501234567", "otp": "1234" }
// 200
{
  "id": "usr_123",
  "phone_number": "+971501234567",
  "name": "Zook User",
  "email": null,
  "token": "jwt-token"
}
```

### POST `/auth/logout` — *Proposed*
Invalidate the current token. `204 No Content`.

---

## 2. Products

A product (full shape used by detail screen):
```json
{
  "id": "p7",
  "brand": "Apple",
  "name": "iPhone 14 Pro 256GB — Deep Purple",
  "price_aed": 2100,
  "grade": "B",                  // A | B | C
  "emoji": "📱",
  "image_gradient": ["#FFF0EB", "#FFD4C2"],
  "is_verified": true,
  "is_new": false,
  "is_wishlisted": false,
  "store": "Al Turath Electronics",
  "category_id": "electronics",
  "year": 2022,
  "condition_note": "Minor scratches on the frame",
  "seller_initials": "AH",
  "seller_meta": "Verified seller · 4.8★",
  "battery_health_pct": 89
}
```
List responses may omit the detail-only fields (`year`, `condition_note`, `seller_initials`, `seller_meta`, `battery_health_pct`).

### GET `/products/recently-listed` — *Proposed*
Backs `getRecentlyListed()`. Returns `{ "items": [Product] }`.

### GET `/products/top-picks` — *Proposed*
Backs `getTopPicks()`. Returns `{ "items": [Product] }`.

### GET `/products?category_id={id}` — *Proposed*
Backs `getByCategory(categoryId)`. Supports filtering and paging:
`category_id`, `grade` (A/B/C), `min_price_aed`, `max_price_aed`, `sort`, `page`, `page_size`. Returns `{ "items": [Product], "page": 1, "total": 120 }`.

### GET `/products/search?q={query}` — *Proposed*
Backs `search(query)`. Same filters/paging as above plus `q`.

### GET `/products/{id}` — *Proposed*
Full product detail (all fields above).

---

## 3. Categories

```json
{ "id": "electronics", "label": "Electronics", "icon": "📱" }
```

### GET `/categories` — *Proposed*
Top-level browse pills. Currently static (`kCategories`): electronics, gaming, laptops, furniture, clothing.

### GET `/categories/{id}/subcategories` — *Proposed*
Subcategory grid (`kSubCategories`): smartphones, laptops, gaming, cameras, audio, wearables.

---

## 4. Wishlist

Backs the `isWishlisted` flag / wishlist toggle.

### GET `/wishlist` — *Proposed* → `{ "items": [Product] }`
### POST `/wishlist/{productId}` — *Proposed* → adds, `204`
### DELETE `/wishlist/{productId}` — *Proposed* → removes, `204`

---

## 5. Cart

Cart line item:
```json
{ "product_id": "p7", "quantity": 1, "line_total_aed": 2100 }
```
Cart totals (computed in `CartState`): `subtotal_aed`, `delivery_fee_aed` (0 = free), `total_aed`, `item_count`, `tabby_instalment_aed` (= total / 4).

> The cart is currently local-only (singleton `CartCubit`). These endpoints are for a server-synced cart.

### GET `/cart` — *Proposed*
```json
{
  "items": [{ "product": { /* Product */ }, "quantity": 1 }],
  "subtotal_aed": 3900,
  "delivery_fee_aed": 0,
  "total_aed": 3900,
  "item_count": 2,
  "tabby_instalment_aed": 975
}
```
### POST `/cart/items` — *Proposed* → `{ "product_id": "p7", "quantity": 1 }` (add / increment)
### PATCH `/cart/items/{productId}` — *Proposed* → `{ "quantity": 3 }`
### DELETE `/cart/items/{productId}` — *Proposed* → remove line
### DELETE `/cart` — *Proposed* → clear cart

---

## 6. Addresses

From the checkout delivery-address section.
```json
{
  "id": "addr_1",
  "name": "Ahmed Hassan",
  "phone_number": "+971501234567",
  "line1": "Apt 1203, Marina Heights",
  "area": "Dubai Marina",
  "city": "Dubai",
  "is_default": true
}
```
### GET `/addresses` — *Proposed* → `{ "items": [Address] }`
### POST `/addresses` — *Proposed*
### PATCH `/addresses/{id}` — *Proposed*
### DELETE `/addresses/{id}` — *Proposed*

---

## 7. Payment methods

Checkout offers three options: `apple_pay`, `card`, `tabby` (pay in 4, 0% interest).

### GET `/payment-methods` — *Proposed* → saved cards + available wallets
### POST `/payment-methods` — *Proposed* → add a card (Add card action)

---

## 8. Checkout & Orders

### POST `/orders` — *Proposed*
Place an order from the current cart (powers the "Order confirmed" screen).
```json
// request
{
  "address_id": "addr_1",
  "payment_method": "tabby",     // apple_pay | card | tabby
  "items": [{ "product_id": "p7", "quantity": 1 }]
}
// 201
{
  "id": "ord_456",
  "status": "confirmed",
  "total_aed": 3900,
  "payment_status": "paid",
  "created_at": "2026-06-24T10:30:00Z"
}
```

### GET `/orders` — *Proposed*
Order history (Orders tab). `{ "items": [Order] }`.

### GET `/orders/{id}` — *Proposed*
Single order with line items, address, payment and status timeline.

---

## 9. User profile

### GET `/me` — *Proposed* → current `AuthUser`
### PATCH `/me` — *Proposed* → update `name`, `email`

---

## Summary

| Area | Endpoints | Status |
|------|-----------|--------|
| Auth | otp/send, otp/verify | **Defined** (stubbed) |
| Auth | logout | Proposed |
| Products | recently-listed, top-picks, list, search, detail | Proposed |
| Categories | list, subcategories | Proposed (static today) |
| Wishlist | get, add, remove | Proposed |
| Cart | get, add, update, remove, clear | Proposed (local today) |
| Addresses | CRUD | Proposed |
| Payment methods | list, add | Proposed |
| Orders | create, list, detail | Proposed |
| Profile | get, update | Proposed |

**Conventions to lock in:** integer AED prices, `grade` enum `A|B|C`, snake_case JSON, Bearer auth, cursor/page paging on all list endpoints.
