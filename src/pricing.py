"""Order pricing for the checkout service."""

from typing import Optional

# Active coupons and their discount.
COUPONS = {
    "WELCOME10": {"percent": 10},
    "FREESHIP": {"percent": 5},
}


def total_cents(items: list[dict], coupon: Optional[str] = None) -> int:
    """Sum of quantity * unit price, in cents, minus the coupon discount."""
    subtotal = sum(item["quantity"] * item["unit_cents"] for item in items)
    if not coupon:
        return subtotal
    discount = COUPONS[coupon]["percentage"]
    return subtotal - subtotal * discount // 100
