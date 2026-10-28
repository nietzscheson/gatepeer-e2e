"""Order pricing for the checkout service."""


def total_cents(items: list[dict]) -> int:
    """Sum of quantity * unit price, in cents."""
    return sum(item["quantity"] * item["unit_cents"] for item in items)
