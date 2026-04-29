#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "matplotlib",
#     "pandas",
#     "requests",
# ]
# ///
"""Check ingredient impact hierarchy and generate comparison graphs + bookmarks.

For each base food product, verifies that a hierarchy of impacts is respected
among its ingredients (organic < fr < eu < non-ue < default), and produces:
- Stacked bar charts per base product (output/ingredient_plots/)
- Importable bookmark files for the Ecobalyse comparator (output/bookmarks/)
- A CSV report of hierarchy violations (output/ingredient_hierarchy_report.csv)

Usage:
    python bin/check_ingredient_hierarchy.py <API_URL>

Example:
    python bin/check_ingredient_hierarchy.py http://localhost:8001
"""

import json
import logging
import pathlib
import sys
import time
from collections import defaultdict
from itertools import combinations

import matplotlib.pyplot as plt
import pandas as pd
import requests

# Constants

PROJECT_ROOT = pathlib.Path(__file__).parent.parent.resolve()
INGREDIENTS_PATH = PROJECT_ROOT / "public" / "data" / "food" / "ingredients.json"
IMPACTS_PATH = PROJECT_ROOT / "public" / "data" / "impacts.json"
OUTPUT_DIR = PROJECT_ROOT / "output"
PLOTS_DIR = OUTPUT_DIR / "ingredient_plots"
BOOKMARKS_DIR = OUTPUT_DIR / "bookmarks"

# --- Sanity checks ---
#
# All expected impact-ordering sanity checks live here.
# For each sanity check, add a comment to explain the reasons behind the check

# Variant order within a single baseProduct (lower index = lower expected ecs).
INGREDIENT_ORDER = {"organic": 0, "fr": 1, "eu": 2, "non-ue": 3, "default": 4}

# Explicit cross-baseProduct sanity checks: (lower_alias, higher_alias)
EXPLICIT_PAIR_SANITY_CHECKS = [
    # The most impactful chicken should have lower impact than conventional beef
    ("chicken-breast-br-max", "beef-without-bone"),
    # Organic beef should have an impact lower than the most impactful chicken
    ("beef-without-bone-organic", "chicken-breast-br-max"),
]


# These impacts are = 0 so we exclude them to remove noise from the graph
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

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger(__name__)


# --- Step 1: Parse ingredients and group by base product ---


def load_json(path):
    with open(path) as f:
        return json.load(f)


def parse_variant_type(alias, base_product):
    """Extract variant type from an alias given its base product."""
    suffix = alias[len(base_product) :]  # e.g. "-fr-2025", "-organic", "-default"
    # Strip -2025 suffix if present
    if suffix.endswith("-2025"):
        suffix = suffix[: -len("-2025")]
    # Remove leading dash
    variant_type = suffix.lstrip("-") if suffix.startswith("-") else suffix
    if not variant_type:
        variant_type = "unknown"
    return variant_type


def group_ingredients(ingredients):
    """Group visible ingredients by base_product.

    Returns:
        by_base: dict mapping base_product -> list of ingredient dicts (with added fields)
    """
    by_base = defaultdict(list)

    for ingr in ingredients:
        if not ingr.get("visible", False):
            continue
        base = ingr.get("baseProduct")
        if not base:
            continue
        alias = ingr["alias"]
        variant_type = parse_variant_type(alias, base)
        enriched = {
            **ingr,
            "variant_type": variant_type,
        }
        by_base[base].append(enriched)

    return by_base


# --- Step 2 & 3: Fetch impacts from API and compute ECS ---


def compute_normalization_factors(impacts_data):
    factors = {}
    for key, val in impacts_data.items():
        if val.get("ecoscore"):
            factors[key] = (
                val["ecoscore"]["weighting"] / val["ecoscore"]["normalization"]
            )
        else:
            factors[key] = 0
    return factors


def fetch_ingredient_impacts(ingredient_id, api_url):
    """Call the food API for a single ingredient at 1kg."""
    url = f"{api_url}/api/food/"
    payload = {"ingredients": [{"id": ingredient_id, "mass": 1000}]}
    headers = {"Authorization": "Bearer dummy"}
    resp = requests.post(url, json=payload, headers=headers, timeout=30)
    resp.raise_for_status()
    return resp.json()


def extract_impacts(api_response, norm_factors):
    """Extract per-impact normalized values and total ECS from an API response.

    Returns:
        impacts_norm: dict of impact_key -> normalized value (µPt)
        complements_norm: dict of complement_key -> normalized value (µPt)
        ecs_total: total ECS score (µPt)
    """
    results = api_response["results"]
    ingredients_total = results["recipe"]["ingredientsTotal"]
    bonus_impacts = results["recipe"]["totalBonusImpact"]

    impacts_norm = {}
    for key, value in ingredients_total.items():
        factor = norm_factors.get(key, 0)
        impacts_norm[key] = 1e6 * value * factor

    complements_norm = {}
    for key, value in bonus_impacts.items():
        complements_norm[key] = value  # already in µPt

    ecs_total = sum(impacts_norm.values()) + sum(complements_norm.values())
    return impacts_norm, complements_norm, ecs_total


def fetch_all_impacts(by_base, api_url, norm_factors):
    """Fetch impacts for all ingredients. Returns a dict: alias -> result dict."""
    all_ingredients = []
    for variants in by_base.values():
        all_ingredients.extend(variants)

    total = len(all_ingredients)
    logger.info(f"Fetching impacts for {total} ingredients from {api_url}...")

    results = {}
    errors = []
    for i, ingr in enumerate(all_ingredients):
        alias = ingr["alias"]
        if (i + 1) % 50 == 0 or i == 0:
            logger.info(f"  [{i + 1}/{total}] {alias}")
        try:
            response = fetch_ingredient_impacts(ingr["id"], api_url)
            impacts_norm, complements_norm, ecs_total = extract_impacts(
                response, norm_factors
            )
            results[alias] = {
                "impacts_norm": impacts_norm,
                "complements_norm": complements_norm,
                "ecs_total": ecs_total,
                "ingredient": ingr,
            }
        except Exception as e:
            errors.append((alias, str(e)))
            logger.warning(f"  Failed to fetch {alias}: {e}")

    if errors:
        logger.warning(f"{len(errors)} ingredients failed to fetch.")
    return results


# --- Step 4: Check hierarchy ---


def check_explicit_pair_sanity_checks(impact_results, ingredients_by_alias):
    """Run EXPLICIT_PAIR_SANITY_CHECKS. Returns list of violation dicts."""
    violations = []
    for lower_alias, higher_alias in EXPLICIT_PAIR_SANITY_CHECKS:
        r_lower = impact_results.get(lower_alias)
        r_higher = impact_results.get(higher_alias)
        if not r_lower or not r_higher:
            logger.warning(
                f"Explicit sanity check skipped — missing impact data for "
                f"{lower_alias if not r_lower else higher_alias}"
            )
            continue
        ecs_lower, ecs_higher = r_lower["ecs_total"], r_higher["ecs_total"]
        if ecs_lower > ecs_higher:
            base_lower = ingredients_by_alias.get(lower_alias, {}).get(
                "baseProduct", "explicit"
            )
            violations.append(
                {
                    "base_product": base_lower,
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


def check_hierarchy(by_base, impact_results):
    """Check that the expected variant ordering is respected.

    Returns list of violation dicts.
    """
    violations = []
    for base, variants in by_base.items():
        # Only check groups with 2+ known-order variants
        known = [v for v in variants if v["variant_type"] in INGREDIENT_ORDER]
        if len(known) < 2:
            continue

        for v1, v2 in combinations(known, 2):
            t1, t2 = v1["variant_type"], v2["variant_type"]
            order1, order2 = INGREDIENT_ORDER[t1], INGREDIENT_ORDER[t2]
            if order1 == order2:
                continue
            # Ensure v1 is the one expected to have lower impact
            if order1 > order2:
                v1, v2 = v2, v1
                t1, t2 = t2, t1

            a1, a2 = v1["alias"], v2["alias"]
            r1 = impact_results.get(a1)
            r2 = impact_results.get(a2)
            if not r1 or not r2:
                continue

            ecs1, ecs2 = r1["ecs_total"], r2["ecs_total"]
            if ecs1 > ecs2:
                violations.append(
                    {
                        "base_product": base,
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


# --- Step 5: Generate graphs ---


def build_df(aliases, impact_results):
    """Build a plotting DataFrame: one row per (alias, impact) for the given aliases."""
    rows = []
    for alias in aliases:
        result = impact_results.get(alias)
        if not result:
            continue
        for impact_key, val in result["impacts_norm"].items():
            if impact_key in EXCLUDED_IMPACTS:
                continue
            rows.append(
                {"product_name": alias, "impact": impact_key, "cout_enviro": val}
            )
        # Complements (ecosystemic services): leading space sorts them first in the legend.
        for comp_key, val in result["complements_norm"].items():
            rows.append(
                {"product_name": alias, "impact": f" {comp_key}", "cout_enviro": val}
            )
    return pd.DataFrame(rows)


def _render_stacked_bar(df, ax, title):
    """Render a stacked bar chart with totals + numeric labels onto `ax`."""
    pivot = df.pivot(index="product_name", columns="impact", values="cout_enviro")
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

    ax.set_ylabel("Cout Environnemental (uPt)")
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


def generate_all_plots(by_base, impact_results, bases_with_violations):
    """Generate stacked bar charts for all base products with 2+ variants."""
    count = 0
    for base, variants in sorted(by_base.items()):
        df = build_df([v["alias"] for v in variants], impact_results)
        suffix = "_violation" if base in bases_with_violations else ""
        path = PLOTS_DIR / f"{base}_barchart{suffix}.png"
        if save_stacked_bar_plot(df, f"{base}, comparaison des variantes", path):
            count += 1
    logger.info(f"Generated {count} plots in {PLOTS_DIR}")


def plot_all_meats(by_base, impact_results):
    """Generate a single stacked bar chart with all animal_product variants."""
    aliases = [
        ingr["alias"]
        for variants in by_base.values()
        for ingr in variants
        if "animal_product" in ingr.get("categories", [])
    ]
    df = build_df(aliases, impact_results)
    n = df["product_name"].nunique() if not df.empty else 0
    path = PLOTS_DIR / "_all_meats_barchart.png"
    if save_stacked_bar_plot(
        df, "Viandes, comparaison des variantes", path, figsize=(max(12, n * 0.4), 8)
    ):
        logger.info(f"Generated all-meats plot ({n} variants) at {path}")
    else:
        logger.info("No animal_product variants to plot.")


def plot_explicit_pair_sanity_checks(impact_results, violation_pairs):
    """Generate one stacked bar chart per EXPLICIT_PAIR_SANITY_CHECKS entry."""
    count = 0
    for lower, higher in EXPLICIT_PAIR_SANITY_CHECKS:
        df = build_df([lower, higher], impact_results)
        suffix = "_violation" if (lower, higher) in violation_pairs else ""
        path = PLOTS_DIR / f"_pair_{lower}_vs_{higher}{suffix}.png"
        if save_stacked_bar_plot(
            df, f"Sanity check: {lower} ≤ {higher}", path, figsize=(8, 7)
        ):
            count += 1
        else:
            logger.warning(f"Skipping pair plot {lower} vs {higher} — missing data.")
    if count:
        logger.info(
            f"Generated {count} explicit-pair sanity-check plots in {PLOTS_DIR}"
        )


# --- Step 6: Generate bookmarks ---


def make_bookmark(alias, ingredient_id, timestamp_ms):
    """Create a single bookmark dict matching the Elm Bookmark format."""
    return {
        "created": timestamp_ms,
        "name": f"{alias} (1kg)",
        "query": {"ingredients": [{"id": ingredient_id, "mass": 1000}]},
    }


def generate_bookmarks(by_base, impact_results):
    """Generate per-base-product and combined bookmark files."""
    BOOKMARKS_DIR.mkdir(parents=True, exist_ok=True)
    base_ts = int(time.time() * 1000)
    all_bookmarks = []
    count = 0

    for base, variants in sorted(by_base.items()):
        # Only generate for groups with 2+ successful results
        valid = [v for v in variants if v["alias"] in impact_results]
        if len(valid) < 2:
            continue

        # Sort by ECS for consistent ordering
        valid.sort(key=lambda v: impact_results[v["alias"]]["ecs_total"])

        bookmarks = []
        for i, ingr in enumerate(valid):
            bm = make_bookmark(ingr["alias"], ingr["id"], base_ts + count * 100 + i)
            bookmarks.append(json.dumps(bm))

        # Write per-base-product file
        export = {"ecobalyse": bookmarks}
        path = BOOKMARKS_DIR / f"{base}.json"
        with open(path, "w") as f:
            json.dump(export, f, indent=2)

        all_bookmarks.extend(bookmarks)
        count += 1

    # Write combined file
    if all_bookmarks:
        all_path = BOOKMARKS_DIR / "_all.json"
        with open(all_path, "w") as f:
            json.dump({"ecobalyse": all_bookmarks}, f)
        logger.info(
            f"Generated {count} bookmark files ({len(all_bookmarks)} total bookmarks) in {BOOKMARKS_DIR}"
        )


# --- Step 7: Report ---


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


def print_summary(by_base, violations, impact_results):
    total_bases = len(by_base)
    bases_with_variants = sum(1 for variants in by_base.values() if len(variants) >= 2)
    total_fetched = len(impact_results)

    print("\n" + "=" * 60)
    print("INGREDIENT HIERARCHY CHECK — SUMMARY")
    print("=" * 60)
    print(f"Total base products:              {total_bases}")
    print(f"Base products with 2+ variants:   {bases_with_variants}")
    print(f"Ingredients fetched successfully:  {total_fetched}")
    print(f"Hierarchy violations:             {len(violations)}")

    if violations:
        print("\nVIOLATIONS:")
        print("-" * 60)
        for v in violations:
            print(
                f"  {v['base_product']}: "
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
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    api_url = sys.argv[1].rstrip("/")

    logger.info("Loading ingredients and impacts data...")
    ingredients = load_json(INGREDIENTS_PATH)
    impacts_data = load_json(IMPACTS_PATH)
    norm_factors = compute_normalization_factors(impacts_data)

    logger.info("Grouping ingredients by base product...")
    by_base = group_ingredients(ingredients)
    logger.info(
        f"Found {len(by_base)} base products, "
        f"{sum(len(v) for v in by_base.values())} visible variant ingredients"
    )

    impact_results = fetch_all_impacts(by_base, api_url, norm_factors)

    logger.info("Checking hierarchy...")
    violations = check_hierarchy(by_base, impact_results)
    ingredients_by_alias = {ingr["alias"]: ingr for ingr in ingredients}
    explicit_violations = check_explicit_pair_sanity_checks(
        impact_results, ingredients_by_alias
    )
    violations.extend(explicit_violations)
    bases_with_violations = {v["base_product"] for v in violations}
    explicit_violation_pairs = {
        (v["lower_variant"], v["higher_variant"]) for v in explicit_violations
    }

    logger.info("Generating plots...")
    generate_all_plots(by_base, impact_results, bases_with_violations)
    plot_all_meats(by_base, impact_results)
    plot_explicit_pair_sanity_checks(impact_results, explicit_violation_pairs)

    logger.info("Generating bookmarks...")
    generate_bookmarks(by_base, impact_results)

    write_violation_report(violations)
    print_summary(by_base, violations, impact_results)


if __name__ == "__main__":
    main()
