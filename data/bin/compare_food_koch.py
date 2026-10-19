"""Compare our food decomposition (`ours`, Agribalyse 3.2 through Brightway) with the
ecolysis workbook of Peter Koch (`koch`, Agribalyse 4.0 through volca).

    uv run python data/bin/decompose_food.py decompose --all-food
    uv run python data/bin/compare_food_koch.py [--koch-workbook <path>]

Products are joined on their exact activity name. The workbook's `optionA` sheet gives
the totals per kg of product (raw kg, electricity kWh, heat MJ, tap water kg), its
`detailedResults` sheet the raw inputs, used for Koch's main raw material. The result is
one Excel sheet, one row per product, with a status: match (every total within the
tolerance), delta, ours only or koch only.

The workbook received from Koch is versioned in `data/food/koch/`. Run from the repo
root. Reads and writes in the gitignored `output/decompose_food/`.
"""

import json
import math
from pathlib import Path

import openpyxl
import typer

from config import DATA_ROOT_DIR

OUTPUT_DIR = DATA_ROOT_DIR.parent / "output" / "decompose_food"
KOCH_WORKBOOK = DATA_ROOT_DIR / "food/koch/194-p09-ResultatsAnalyse10092026.xlsx"

QUANTITIES = ("raw_kg", "elec_kwh", "heat_mj", "water_kg")
SIGNIFICANT_DIGITS = 4

# optionA: B product, D raw kg, E electricity kWh, F heat MJ, G tap water kg
TOTALS_SHEET, TOTALS_FIRST_ROW, TOTALS_NAME_COLUMN = "optionA", 4, 1
TOTALS_COLUMNS = {"raw_kg": 3, "elec_kwh": 4, "heat_mj": 5, "water_kg": 6}
# detailedResults: B product, D input type, E input activity, F amount
DETAIL_SHEET, DETAIL_FIRST_ROW = "detailedResults", 2
DETAIL_PRODUCT_COLUMN, DETAIL_TYPE_COLUMN, DETAIL_INPUT_COLUMN = 1, 3, 4
DETAIL_AMOUNT_COLUMN = 5
KOCH_RAW_TYPE = "AgricFoodRaw"

STATUSES = ("match", "delta", "ours only", "koch only")
COLUMNS = [
    "status",
    "ours_name",
    "koch_name",
    *(
        f"{side}_{quantity}"
        for quantity in QUANTITIES
        for side in ("ours", "koch", "delta_pct")
    ),
    "ours_main_raw",
    "ours_main_raw_kg",
    "koch_main_raw",
    "koch_main_raw_kg",
]


def read_koch(total_rows, detail_rows) -> dict[str, dict]:
    """Koch's products by activity name, from the rows (tuples) of `optionA` and
    `detailedResults`. Each has its totals and its raw inputs in kg."""
    koch_products: dict[str, dict] = {}
    for row in total_rows:
        name = row[TOTALS_NAME_COLUMN]
        if name:
            totals = {
                quantity: float(row[column] or 0)
                for quantity, column in TOTALS_COLUMNS.items()
            }
            koch_products[name] = {**totals, "raw": {}}
    for row in detail_rows:
        product = koch_products.get(row[DETAIL_PRODUCT_COLUMN])
        if product is None or row[DETAIL_TYPE_COLUMN] != KOCH_RAW_TYPE:
            continue
        raw_name = row[DETAIL_INPUT_COLUMN]
        amount = float(row[DETAIL_AMOUNT_COLUMN] or 0)
        product["raw"][raw_name] = product["raw"].get(raw_name, 0.0) + amount
    return koch_products


def significant(value: float | None) -> float | None:
    """Round to 4 significant figures, to keep float noise out of the sheet."""
    if not value or not math.isfinite(value):
        return value
    return round(value, SIGNIFICANT_DIGITS - 1 - math.floor(math.log10(abs(value))))


def delta_pct(ours: float, koch: float) -> float | None:
    """Delta of ours against koch in percent, None when koch is 0 and ours is not."""
    if koch == 0:
        return 0.0 if ours == 0 else None
    return round((ours - koch) / koch * 100, 1)


def main_raw(raw: dict[str, float]) -> tuple[str | None, float | None]:
    if not raw:
        return None, None
    name = max(raw, key=raw.__getitem__)
    return name, significant(raw[name])


def comparison_row(
    ours: dict | None, koch_name: str | None, koch: dict | None, tolerance: float
) -> dict:
    """One row of the sheet. `ours` is a product of decomposition.json, `koch` one of
    `read_koch`, either may be missing."""
    row = {"ours_name": ours and ours["product"], "koch_name": koch_name}
    within_tolerance = True
    for quantity in QUANTITIES:
        ours_value = ours[quantity] if ours else None
        koch_value = koch[quantity] if koch else None
        row[f"ours_{quantity}"] = significant(ours_value)
        row[f"koch_{quantity}"] = significant(koch_value)
        if ours_value is not None and koch_value is not None:
            delta = delta_pct(ours_value, koch_value)
            row[f"delta_pct_{quantity}"] = delta
            within_tolerance &= delta is not None and abs(delta) <= tolerance * 100
    row["ours_main_raw"], row["ours_main_raw_kg"] = main_raw(
        ours["raw"] if ours else {}
    )
    row["koch_main_raw"], row["koch_main_raw_kg"] = main_raw(
        koch["raw"] if koch else {}
    )
    if ours and koch:
        row["status"] = "match" if within_tolerance else "delta"
    else:
        row["status"] = "ours only" if ours else "koch only"
    return row


def compare(
    ours_products: dict[str, dict], koch_products: dict[str, dict], tolerance: float
) -> list[dict]:
    """One row per product of either side, joined on the activity name, sorted by
    status then name."""
    ours_by_name = {product["product"]: product for product in ours_products.values()}
    rows = [
        comparison_row(
            ours,
            name if name in koch_products else None,
            koch_products.get(name),
            tolerance,
        )
        for name, ours in ours_by_name.items()
    ] + [
        comparison_row(None, name, koch, tolerance)
        for name, koch in koch_products.items()
        if name not in ours_by_name
    ]
    return sorted(
        rows,
        key=lambda row: (
            STATUSES.index(row["status"]),
            row["ours_name"] or row["koch_name"],
        ),
    )


def main(
    koch_workbook: Path = KOCH_WORKBOOK,
    ours_json: Path = OUTPUT_DIR / "decomposition.json",
    out: Path = OUTPUT_DIR / "ours_vs_koch.xlsx",
    tolerance: float = 0.01,
):
    """Compare decomposition.json (ours) with the ecolysis workbook (koch)."""
    workbook = openpyxl.load_workbook(koch_workbook, read_only=True, data_only=True)
    koch_products = read_koch(
        workbook[TOTALS_SHEET].iter_rows(min_row=TOTALS_FIRST_ROW, values_only=True),
        workbook[DETAIL_SHEET].iter_rows(min_row=DETAIL_FIRST_ROW, values_only=True),
    )
    rows = compare(json.loads(ours_json.read_text()), koch_products, tolerance)

    report = openpyxl.Workbook()
    sheet = report.active
    sheet.title = "ours_vs_koch"
    sheet.append(COLUMNS)
    for row in rows:
        sheet.append([row.get(column) for column in COLUMNS])
    sheet.freeze_panes = "D2"
    sheet.auto_filter.ref = sheet.dimensions
    report.save(out)
    counts = ", ".join(
        f"{status} {sum(row['status'] == status for row in rows)}"
        for status in STATUSES
    )
    print(f"{out}: {counts}")


if __name__ == "__main__":
    typer.run(main)
