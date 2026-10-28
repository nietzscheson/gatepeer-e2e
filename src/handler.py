"""Checkout Lambda: prices an order."""

import json
import logging

from pricing import total_cents

logger = logging.getLogger()
logger.setLevel(logging.INFO)

DEFAULT_ITEMS = [{"sku": "tee", "quantity": 1, "unit_cents": 2500}]


def handler(event, context):
    items = event.get("items") or DEFAULT_ITEMS
    coupon = event.get("coupon")
    total = total_cents(items, coupon=coupon)
    logger.info(
        "checkout priced total_cents=%s items=%s coupon=%s", total, len(items), coupon
    )
    return {"statusCode": 200, "body": json.dumps({"total_cents": total})}
