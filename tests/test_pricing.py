import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from pricing import total_cents  # noqa: E402


def test_total_cents():
    items = [
        {"sku": "tee", "quantity": 2, "unit_cents": 2500},
        {"sku": "cap", "quantity": 1, "unit_cents": 1500},
    ]
    assert total_cents(items) == 6500
