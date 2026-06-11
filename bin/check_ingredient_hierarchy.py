#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "matplotlib",
#     "pandas",
# ]
# ///
"""Check ingredient impact hierarchy and generate comparison graphs + bookmarks for the method and product team to investigate the violations.

For each base food product, verifies that a hierarchy of impacts is respected
among its ingredients (organic < fr < eu < non-ue < default), and produces:
- bar charts per base product (output/ingredient_plots/)
- Importable bookmark files for the Ecobalyse comparator (output/bookmarks/)
- A CSV report of hierarchy violations (output/ingredient_hierarchy_report.csv) and a french format version (; and ,) (output/ingredient_hierarchy_report_fr.csv)
"""

import json
import logging
import pathlib
import time
from collections import defaultdict
from itertools import combinations
from typing import Any, TypedDict

import matplotlib.pyplot as plt
import pandas as pd

# Constants

PROJECT_ROOT = pathlib.Path(__file__).parent.parent.resolve()
PROCESSES_PATH = PROJECT_ROOT / "public" / "data" / "processes_impacts.json"
IMPACTS_PATH = PROJECT_ROOT / "public" / "data" / "impacts.json"
OUTPUT_DIR = PROJECT_ROOT / "output"
PLOTS_DIR = OUTPUT_DIR / "ingredient_plots"
BOOKMARKS_DIR = OUTPUT_DIR / "bookmarks"

# --- Sanity checks ---
#
# All expected impact-ordering sanity checks live here.
# each sanity check should have a comment to explain the reasons behind the check

# Variant hierarchy within a single baseIngredient (lower index = lower expected ecs).
INGREDIENT_HIERARCHY = {"organic": 0, "fr": 1, "eu": 2, "non-ue": 3, "default": 4}

# Sanity checks between different base_ingredient : (lower_alias, higher_alias)
EXPLICIT_PAIR_SANITY_CHECKS = [
    # The most impactful chicken should have lower impact than conventional beef
    ("chicken-breast-br-max", "beef-without-bone"),
    # Organic beef should have an impact lower than the most impactful chicken
    ("beef-without-bone-organic", "chicken-breast-br-max"),
]


# These impacts are = 0 or irrelevant (ie we ignore etf because we use etf-c) so we exclude them to remove noise from the graph
EXCLUDED_IMPACTS = {
    "etf",
    "htn",
    "htc",
    "htn-c",
    "htc-c",
    "pef",
    "ecs",
    "microfibers",
    "outOfEuropeEOL",
}

# --- Types ---


class Metadata(TypedDict):
    complements: dict[str, float]
    ingredient: dict[str, Any]


class Ingredient(TypedDict, total=False):
    """subset of a process entry in processes_impacts.json
    `variant_type` is added by `group_ingredients`.
    """

    id: str
    alias: str
    metadata: Metadata
    impacts: dict[str, float]
    variant_type: str


class Violation(TypedDict):
    base_ingredient: str
    reason: str
    lower_variant: str
    lower_type: str
    lower_ecs: float
    higher_variant: str
    higher_type: str
    higher_ecs: float
    delta: float


logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger(__name__)


# --- Step 1: Parse ingredients and group by base product ---


def load_json(path):
    with open(path) as f:
        return json.load(f)


def parse_variant_type(alias: str, base_ingredient: str) -> str:
    """Extract variant type from an alias given its base product."""
    suffix = alias[len(base_ingredient) :]  # e.g. "-fr-2025", "-organic", "-default"
    # Strip -2025 suffix if present
    if suffix.endswith("-2025"):
        suffix = suffix[: -len("-2025")]
    # Remove leading dash
    variant_type = suffix.lstrip("-") if suffix.startswith("-") else suffix
    if not variant_type:
        variant_type = "unknown"
    return variant_type


def group_ingredients(ingredients: list[Ingredient]) -> dict[str, list[Ingredient]]:
    """Group visible ingredients by base_ingredient"""
    ingredients_by_base = defaultdict(list)

    for ingredient in ingredients:
        ingredient_metadata = ingredient["metadata"]["ingredient"]
        base = ingredient_metadata["baseIngredient"]
        alias = ingredient["alias"]
        variant_type = parse_variant_type(alias, base)
        enriched = {
            **ingredient,
            "variant_type": variant_type,
        }
        ingredients_by_base[base].append(enriched)

    return ingredients_by_base


def compute_normalization_factors(impacts_data: dict[str, Any]) -> dict[str, float]:
    factors: dict[str, float] = {}
    for key, val in impacts_data.items():
        if val.get("ecoscore"):
            factors[key] = (
                val["ecoscore"]["weighting"] / val["ecoscore"]["normalization"]
            )
    return factors


def compute_impacts_norm(
    impacts_raw: dict[str, float], norm_factors: dict[str, float]
) -> dict[str, float]:

    impacts_norm: dict[str, float] = {}
    for key, value in impacts_raw.items():
        factor = norm_factors.get(key, 0)
        # we need to multiply by 1 000 000 to get UI points https://github.com/MTES-MCT/ecobalyse/issues/2262
        impacts_norm[key] = 1e6 * value * factor
    return impacts_norm


def compute_ecs_with_complements(ingredient: Ingredient) -> float:
    ecs_with_complements = 0
    for key, value in ingredient["impacts_norm"].items():
        ecs_with_complements += value
    if "complements" in ingredient["metadata"]:
        for key, value in ingredient["metadata"]["complements"].items():
            if value:
                ecs_with_complements += value

    return ecs_with_complements


# --- Step 2: Check hierarchy ---


def check_explicit_pair_sanity_checks(
    ingredients_by_alias: dict[str, Ingredient],
) -> list[Violation]:
    """Run EXPLICIT_PAIR_SANITY_CHECKS. Returns list of violation dicts."""
    violations = []
    for lower_alias, higher_alias in EXPLICIT_PAIR_SANITY_CHECKS:
        lower_ingr = ingredients_by_alias[lower_alias]
        higher_ingr = ingredients_by_alias[higher_alias]
        ecs_lower, ecs_higher = (
            compute_ecs_with_complements(lower_ingr),
            compute_ecs_with_complements(higher_ingr),
        )
        if ecs_lower > ecs_higher:
            base_lower = lower_ingr["metadata"]["ingredient"]["baseIngredient"]
            violations.append(
                {
                    "base_ingredient": base_lower,
                    "reason": f"{lower_alias} > {higher_alias}",
                    "lower_variant": lower_alias,
                    "lower_type": "explicit_sanity_check",
                    "lower_ecs": round(ecs_lower, 2),
                    "higher_variant": higher_alias,
                    "higher_type": "explicit_sanity_check",
                    "higher_ecs": round(ecs_higher, 2),
                    "delta": round(ecs_lower - ecs_higher, 2),
                }
            )
    return violations


def check_hierarchy(ingredient_by_base: dict[str, list[Ingredient]]) -> list[Violation]:
    """Check that the expected variant hierarchy is respected.

    Returns list of violation dicts.
    """
    violations = []
    for base, variants in ingredient_by_base.items():
        # Only check groups with 2+ known-order variants
        known = [v for v in variants if v["variant_type"] in INGREDIENT_HIERARCHY]
        if len(known) < 2:
            continue

        for v1, v2 in combinations(known, 2):
            t1, t2 = v1["variant_type"], v2["variant_type"]
            order1, order2 = INGREDIENT_HIERARCHY[t1], INGREDIENT_HIERARCHY[t2]
            if order1 == order2:
                continue
            # Ensure v1 is the one expected to have lower impact
            if order1 > order2:
                v1, v2 = v2, v1
                t1, t2 = t2, t1

            a1, a2 = (
                v1["alias"],
                v2["alias"],
            )

            ecs1, ecs2 = (
                compute_ecs_with_complements(v1),
                compute_ecs_with_complements(v2),
            )
            if ecs1 > ecs2:
                violations.append(
                    {
                        "base_ingredient": base,
                        "reason": f"{a1} > {a2}",
                        "lower_variant": a1,
                        "lower_type": t1,
                        "lower_ecs": round(ecs1, 2),
                        "higher_variant": a2,
                        "higher_type": t2,
                        "higher_ecs": round(ecs2, 2),
                        "delta": round(ecs1 - ecs2, 2),
                    }
                )

    return violations


# --- Step 3: Generate graphs ---


def build_df(aliases, ingredients: list[Ingredient]):
    """Build a plotting DataFrame: one row per (alias, impact) for the given aliases."""
    rows = []
    for alias in aliases:
        ingr = [
            ingredient for ingredient in ingredients if ingredient["alias"] == alias
        ][0]
        for impact_key, val in ingr["impacts_norm"].items():
            if impact_key in EXCLUDED_IMPACTS:
                continue
            rows.append({"product_name": alias, "impact": impact_key, "ecs": val})
        # Complements (ecosystemic services): leading `* ` sorts them first in the legend.
        if ingr["metadata"].get("complements"):
            for comp_key, val in ingr["metadata"]["complements"].items():
                rows.append(
                    {
                        "product_name": alias,
                        "impact": f"* {comp_key}",
                        "ecs": val,
                    }
                )
    return pd.DataFrame(rows)


def _render_stacked_bar(df, ax, title):
    """Render a stacked bar chart with totals + numeric labels onto `ax`."""
    pivot = df.pivot(index="product_name", columns="impact", values="ecs")
    totals = pivot.sum(axis=1).sort_values()
    pivot = pivot.loc[totals.index]

    colors = plt.get_cmap("tab20").colors
    pivot.plot(kind="bar", stacked=True, ax=ax, color=colors)
    ax.set_xlabel("")
    ax.axhline(0, color="black", linewidth=0.8)

    # Dashed total line + numeric label per bar.
    # patches are laid out: all bars for impact0, then all bars for impact1, etc.
    # So the i-th product's first bar is patches[i].
    ymin, ymax = ax.get_ylim()
    offset = (ymax - ymin) * 0.01
    for i, (_idx, total) in enumerate(totals.items()):
        bar = ax.patches[i]
        ax.hlines(
            total,
            bar.get_x(),
            bar.get_x() + bar.get_width(),
            color="black",
            linestyle="--",
            linewidth=2,
            label="Total Impact" if i == 0 else "",
        )
        positive = total >= 0
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            total + (offset if positive else -offset),
            f"{total:.0f}",
            ha="center",
            va="bottom" if positive else "top",
            fontsize=9,
            fontweight="bold",
        )

    ax.set_ylabel("Cout Environnemental")
    ax.set_title(title)

    max_label_len = max(len(str(x)) for x in pivot.index)
    if len(pivot) > 3 or max_label_len > 12:
        plt.xticks(rotation=45, ha="right")
    else:
        plt.xticks(rotation=0, ha="center")

    handles, labels = ax.get_legend_handles_labels()
    sorted_pairs = sorted(zip(labels, handles), key=lambda x: x[0], reverse=True)
    if sorted_pairs:
        sorted_labels, sorted_handles = zip(*sorted_pairs)
        ax.legend(
            sorted_handles,
            sorted_labels,
            title="Impact",
            bbox_to_anchor=(1.05, 1),
            loc="upper left",
        )


def save_stacked_bar_plot(df, title, output_path, figsize=(10, 7)):
    """Render a stacked-bar chart from `df` and save to disk. Returns True if saved."""
    if df.empty or df["product_name"].nunique() < 2:
        return False
    output_path.parent.mkdir(parents=True, exist_ok=True)
    fig, ax = plt.subplots(figsize=figsize)
    _render_stacked_bar(df, ax, title)
    plt.tight_layout()
    plt.savefig(output_path)
    plt.close()
    return True


def generate_all_plots(ingredients_by_base, bases_with_violations):
    """Generate stacked bar charts for all base products with 2+ variants."""
    count = 0
    for base, variants in sorted(ingredients_by_base.items()):
        df = build_df([v["alias"] for v in variants], ingredients_by_base[base])
        suffix = "_violation" if base in bases_with_violations else ""
        path = PLOTS_DIR / f"{base}_barchart{suffix}.png"
        if save_stacked_bar_plot(df, f"{base}, comparaison des variantes", path):
            count += 1
    logger.info(f"Generated {count} plots in {PLOTS_DIR}")


MEAT_CATEGORIES = {"material_type:red_meats", "material_type:poultry"}


def plot_all_meats(ingredients):
    """Generate a single stacked bar chart with all meat variants."""
    aliases = [
        ingr["alias"]
        for ingr in ingredients
        if MEAT_CATEGORIES & set(ingr.get("categories", []))
    ]
    df = build_df(aliases, ingredients)
    n = df["product_name"].nunique() if not df.empty else 0
    path = PLOTS_DIR / "_all_meats_barchart.png"
    save_stacked_bar_plot(
        df, "Viandes, comparaison des variantes", path, figsize=(max(12, n * 0.4), 8)
    )
    logger.info(f"Generated all-meats plot ({n} variants) at {path}")


def plot_explicit_pair_sanity_checks(ingredients_by_alias, violation_pairs):
    """Generate one chart per EXPLICIT_PAIR_SANITY_CHECKS entry."""
    count = 0
    for lower, higher in EXPLICIT_PAIR_SANITY_CHECKS:
        pair_ingredients = [ingredients_by_alias[lower], ingredients_by_alias[higher]]
        df = build_df([lower, higher], pair_ingredients)
        suffix = "_violation" if (lower, higher) in violation_pairs else ""
        path = PLOTS_DIR / f"_pair_{lower}_vs_{higher}{suffix}.png"
        if save_stacked_bar_plot(
            df, f"Sanity check: {lower} ≤ {higher}", path, figsize=(8, 7)
        ):
            count += 1
    if count:
        logger.info(
            f"Generated {count} explicit-pair sanity-check plots in {PLOTS_DIR}"
        )


# --- Step 4: Generate bookmarks ---


def make_bookmark(alias, ingredient_id, timestamp_ms):
    """Create a food2 bookmark for a single ingredient at 1kg."""
    return {
        "created": timestamp_ms,
        "name": f"{alias} (1kg)",
        "query": {
            "components": [
                {
                    "quantity": 1,
                    "custom": {
                        "name": "Nouveau composant",
                        "elements": [
                            {
                                "amount": 1,
                                "material": {"id": ingredient_id},
                                "transforms": [],
                            }
                        ],
                    },
                }
            ],
            "recyclable": True,
            "transportCooling": False,
        },
        "subScope": "food2",
    }


def generate_bookmarks(ingredients_by_base):
    """Generate 1 bookmark per base_product"""
    BOOKMARKS_DIR.mkdir(parents=True, exist_ok=True)
    base_ts = int(time.time() * 1000)
    count = 0

    for base, variants in sorted(ingredients_by_base.items()):
        if len(variants) < 2:
            continue

        # Sort by ECS for consistent ordering
        variants = sorted(variants, key=compute_ecs_with_complements)

        bookmarks = []
        for i, ingr in enumerate(variants):
            # add increasing timestamp to keep the order
            bm = make_bookmark(ingr["alias"], ingr["id"], base_ts + count * 100 + i)
            bookmarks.append(json.dumps(bm))

        # Write per-base-product file
        export = {"ecobalyse": bookmarks}
        path = BOOKMARKS_DIR / f"{base}.json"
        with open(path, "w") as f:
            json.dump(export, f, indent=2)
        count += 1


# --- Step 5: Report ---


def write_violation_report(violations):
    """Write violations to CSV."""
    if not violations:
        logger.info("No hierarchy violations found.")
        return

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    report_path = OUTPUT_DIR / "ingredient_hierarchy_report.csv"
    report_path_fr = OUTPUT_DIR / "ingredient_hierarchy_report_fr.csv"
    df = pd.DataFrame(violations)
    df.to_csv(report_path, index=False)
    df.to_csv(report_path_fr, index=False, sep=";", decimal=",", encoding="utf-8-sig")
    logger.info(f"Wrote {len(violations)} violations to {report_path}")
    logger.info(f"Wrote FR-format CSV to {report_path_fr}")


def print_summary(ingredients_by_base, violations):
    total_bases = len(ingredients_by_base)
    bases_with_variants = sum(
        1 for variants in ingredients_by_base.values() if len(variants) >= 2
    )
    total_ingredients = sum(len(v) for v in ingredients_by_base.values())

    print("\n" + "=" * 60)
    print("INGREDIENT HIERARCHY CHECK — SUMMARY")
    print("=" * 60)
    print(f"Total base products:              {total_bases}")
    print(f"Base products with 2+ variants:   {bases_with_variants}")
    print(f"Total ingredients:                {total_ingredients}")
    print(f"Hierarchy violations:             {len(violations)}")

    if violations:
        print("\nVIOLATIONS:")
        print("-" * 60)
        for v in violations:
            print(
                f"  {v['base_ingredient']}: "
                f"{v['lower_variant']} ({v['lower_ecs']}) > "
                f"{v['higher_variant']} ({v['higher_ecs']}) "
                f"[delta: {v['delta']}]"
            )

    print("\nOutputs:")
    print(f"  Plots:     {PLOTS_DIR}/")
    print(f"  Bookmarks: {BOOKMARKS_DIR}/")
    print(f"  Report:    {OUTPUT_DIR / 'ingredient_hierarchy_report.csv'}")
    print(f"  Report FR: {OUTPUT_DIR / 'ingredient_hierarchy_report_fr.csv'}")
    print("=" * 60)


# --- Main ---


def main():
    logger.info("Loading ingredients from processes_impacts.json...")
    processes = load_json(PROCESSES_PATH)
    ingredients = [
        proc
        for proc in processes
        if (proc.get("metadata") and proc["metadata"].get("ingredient"))
    ]

    impacts_data = load_json(IMPACTS_PATH)
    norm_factors = compute_normalization_factors(impacts_data)
    for ingredient in ingredients:
        ingredient["impacts_norm"] = compute_impacts_norm(
            ingredient["impacts"], norm_factors
        )

    logger.info("Grouping ingredients by base product...")
    ingredients_by_base = group_ingredients(ingredients)
    logger.info(
        f"Found {len(ingredients_by_base)} base products, "
        f"{sum(len(v) for v in ingredients_by_base.values())} visible variant ingredients"
    )

    logger.info("Checking hierarchy...")
    violations = check_hierarchy(ingredients_by_base)
    ingredients_by_alias = {ingr["alias"]: ingr for ingr in ingredients}
    explicit_violations = check_explicit_pair_sanity_checks(ingredients_by_alias)
    violations.extend(explicit_violations)
    bases_with_violations = {v["base_ingredient"] for v in violations}
    explicit_violation_pairs = {
        (v["lower_variant"], v["higher_variant"]) for v in explicit_violations
    }

    logger.info("Generating plots...")
    generate_all_plots(ingredients_by_base, bases_with_violations)
    plot_all_meats(ingredients)
    plot_explicit_pair_sanity_checks(ingredients_by_alias, explicit_violation_pairs)

    logger.info("Generating bookmarks...")
    generate_bookmarks(ingredients_by_base)

    write_violation_report(violations)
    print_summary(ingredients_by_base, violations)


if __name__ == "__main__":
    main()
