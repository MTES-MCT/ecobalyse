"""Decompose the transformed food ingredients of the LCI catalog with Brightway and
create the food2 components.

    uv run python data/bin/decompose_food.py decompose [--only comte-aop-2025,apple-juice-2025]
    uv run python data/bin/decompose_food.py decompose --activity "Lemon juice, pure juice, at plant {IT} U"
    uv run python data/bin/decompose_food.py decompose --all-food
    uv run python data/bin/decompose_food.py components [--only ...] [--dry-run]
    uv run python data/bin/decompose_food.py components --activity "<activity name>" --name "Abondance FR"

`decompose` writes `output/decompose_food/decomposition.json` at the repo root
(gitignored): per product, the raw materials, electricity, heat, water, waste and other
inputs per kg, and the transformation steps walked. It takes the catalog ingredients by
default, `--activity` adds Agribalyse activities that are not in the catalog and
`--all-food` takes every `Agricultural / Food` activity of the database. Products outside
the catalog are keyed on their activity name. `components` ignores them, unless one is
named with `--activity` and `--name`.

`components` writes its JSON files in the repo format (bin/json_formatter.py), so a rerun on
unchanged data leaves them unchanged.

`components` writes one transformation process in `lci_catalog/ecobalyse_manual_lcia/`
and one component in `public/data/food2/components.json` per product whose main raw
material is a catalog ingredient, and marks the aggregated ingredient's display name with
" agrégé". Ids are uuid5 of the product alias, so a rerun rewrites the same entries and an
Agribalyse rename does not change them.

`components --activity "<name>" --name "<French name>"` does the same for one product
outside the catalog, decomposed beforehand with `decompose --activity`. Its main raw
material must still be a catalog ingredient. Ids and the file name derive from the French
name, and there is no aggregated ingredient to mark. Prefer the "at plant" activity over
the consumption mix when both exist, as the app handles transport separately.

Run from the repo root, with `BRIGHTWAY2_DIR` (in `.env`) pointing at the Brightway env
holding the project.
"""

import json
import re
import unicodedata
import uuid
from pathlib import Path
from typing import Annotated

import bw2data
import typer
from ecobalyse.json import CompactJSONEncoder

from common.infer_metadata import infer_material_type_for_alias
from config import DATA_ROOT_DIR, settings
from ecobalyse_data.food_decomposition import (
    BrightwayGraph,
    CatalogIngredient,
    Decomposer,
    is_farm_gate,
    load_catalog_ingredients,
    preferred_ingredient,
)
from ecobalyse_data.logging import logger

app = typer.Typer(pretty_exceptions_show_locals=False)

LCI_CATALOG_DIR = DATA_ROOT_DIR / "lci_catalog"
MANUAL_LCIA_DIR = LCI_CATALOG_DIR / "ecobalyse_manual_lcia"
FOOD2_COMPONENTS_PATH = DATA_ROOT_DIR.parent / "public/data/food2/components.json"
OUTPUT_DIR = DATA_ROOT_DIR.parent / "output" / "decompose_food"
DEFAULT_JSON = OUTPUT_DIR / "decomposition.json"

ECOBALYSE_NAMESPACE = uuid.UUID("a4e1d123-5c67-4b89-9def-1234567890ab")
IMPACT_KEYS = [
    "acd", "cch", "etf", "etf-c", "fru", "fwe", "htc", "htc-c", "htn", "htn-c",
    "ior", "ldu", "mru", "ozd", "pco", "pma", "swe", "tre", "wtu",
]  # fmt: skip
AGGREGATED_MARKER = " agrégé"
OLD_SUFFIX = " (2025)"
OLD_ALIAS_SUFFIX = "-2025"
TRIVIAL_RATIO_TOLERANCE = 0.01


def catalog_products(
    catalog: dict[str, list[CatalogIngredient]], only: str | None, source: str
) -> list[tuple[str, CatalogIngredient]]:
    """One (activity name, preferred variant) per catalog activity of `source`, filtered
    by alias."""
    wanted = {alias.strip() for alias in only.split(",")} if only else None
    products = []
    for activity_name, variants in catalog.items():
        if wanted and not wanted & {variant.alias for variant in variants}:
            continue
        if variants[0].source != source:
            continue
        products.append((activity_name, preferred_ingredient(variants)))
    return sorted(products, key=lambda item: item[1].alias)


def open_graph() -> BrightwayGraph:
    bw2data.projects.set_current(settings.bw.project)
    return BrightwayGraph(bw2data.Database(settings.bw.agribalyse))


@app.command()
def decompose(
    only: Annotated[
        str | None,
        typer.Option(help="Comma separated catalog aliases to restrict the run"),
    ] = None,
    json_out: Path = DEFAULT_JSON,
    activity: Annotated[
        list[str] | None,
        typer.Option(
            help="Agribalyse activity name to decompose in addition to the catalog, "
            "repeatable. The row is keyed on the activity name."
        ),
    ] = None,
    all_food: Annotated[
        bool,
        typer.Option(
            help="Decompose every `Agricultural / Food` activity of the database "
            "instead of the catalog ingredients. Not combinable with --only or "
            "--activity."
        ),
    ] = False,
    stop_at_catalog: Annotated[
        bool,
        typer.Option(
            help="Stop on every catalog ingredient, even a transformed one (bread stops "
            "at flour). By default only raw catalog ingredients stop the walk."
        ),
    ] = False,
):
    """Decompose the Agribalyse food ingredients of the catalog (or the aliases of --only),
    the activities of --activity, or every food activity with --all-food."""
    if all_food and (only or activity):
        raise typer.BadParameter(
            "--all-food cannot be combined with --only or --activity"
        )
    catalog = load_catalog_ingredients(LCI_CATALOG_DIR)
    catalog_names = set(catalog)
    graph = open_graph()
    decomposer = Decomposer(graph, catalog_names, stop_at_catalog=stop_at_catalog)
    # (activity name, catalog ingredient), the ingredient is None outside the catalog
    products: list[tuple[str, CatalogIngredient | None]]
    if all_food:
        products = [(name, None) for name in graph.food_activity_names()]
    else:
        products = [
            *catalog_products(catalog, only, settings.bw.agribalyse),
            *((name, None) for name in activity or []),
        ]
    results = {}
    raw_products = 0
    for activity_name, ingredient in products:
        key = ingredient.alias if ingredient else activity_name
        node = graph.node(activity_name)
        if node is None:
            logger.warning(f"{key}: activity not in Brightway, skipped")
            continue
        if is_farm_gate(node):
            logger.debug(f"{key}: raw agricultural product, nothing to decompose")
            raw_products += 1
            continue
        decomposition = decomposer.decompose(activity_name)
        results[key] = decomposition.to_dict()
        totals = decomposition.totals
        logger.info(
            f"{key}: raw {totals.raw_kg:.3f} kg, elec {totals.elec_kwh:.4f} kWh, "
            f"heat {totals.heat_mj:.4f} MJ, {len(totals.raw)} raw material(s)"
        )
    json_out.parent.mkdir(parents=True, exist_ok=True)
    json_out.write_text(json.dumps(results, ensure_ascii=False, indent=2) + "\n")
    with_raw = sum(1 for result in results.values() if result["raw"])
    print(
        f"{len(results)} products written to {json_out}, {with_raw} with a raw "
        f"material, {raw_products} raw agricultural products skipped"
    )


def slugify(value: str) -> str:
    ascii_value = (
        unicodedata.normalize("NFKD", value).encode("ascii", "ignore").decode()
    )
    return re.sub(r"[^a-z0-9]+", "-", ascii_value.lower()).strip("-")


def deterministic_id(*parts: str) -> str:
    return str(uuid.uuid5(ECOBALYSE_NAMESPACE, ":".join(parts)))


def round_param(value: float) -> float:
    return float(f"{value:.4g}")


def base_alias(alias: str) -> str:
    return alias.removesuffix(OLD_ALIAS_SUFFIX)


def clean_display_name(display_name: str) -> str:
    return (
        display_name.replace(OLD_SUFFIX, "")
        .replace(AGGREGATED_MARKER + "e", "")
        .replace(AGGREGATED_MARKER, "")
        .strip()
    )


def write_json(path: Path, content) -> None:
    """Write in the format of bin/json_formatter.py, the repo's JSON formatter."""
    formatted = json.dumps(
        content, ensure_ascii=False, sort_keys=True, indent=2, cls=CompactJSONEncoder
    )
    path.write_text(formatted + "\n")


def skip_reason(result: dict, catalog_names: set[str], min_share: float) -> str | None:
    if result["unit"] != "kilogram":
        return f"unit is {result['unit']}, not kg"
    if not result["raw"]:
        return "no raw material found"
    if result["main_raw"] not in catalog_names:
        return f"main raw material not in catalog: {result['main_raw']}"
    if result["main_raw_share"] < min_share:
        return f"main raw material is {result['main_raw_share']:.0%} of the raw inputs"
    trivial_ratio = abs(result["main_raw_kg"] - 1) <= TRIVIAL_RATIO_TOLERANCE
    if trivial_ratio and result["elec_kwh"] == 0 and result["heat_mj"] == 0:
        return "no transformation (ratio 1, no energy)"
    return None


def build_entries(
    key: str, product_name: str, raw: CatalogIngredient, result: dict
) -> dict:
    """`key` names the transformation file and seeds the ids, `product_name` is the French
    name of the transformed product."""
    slug = f"{key}-transformation"
    raw_kg = result["main_raw_kg"]
    material_type = infer_material_type_for_alias(raw.alias)
    transform_metadata_id = deterministic_id(
        "food-decomposition-transform-metadata", slug
    )
    transform = {
        "categories": ["transformation", f"material_type:{material_type}"],
        "comment": (
            f"Elec et chaleur de '{result['product']}' ({settings.bw.agribalyse}), ramenées "
            f"au kg de '{raw.activity_name}'. {raw_kg:.2f} kg par kg de produit. "
            "Généré par data/bin/decompose_food.py."
        ),
        "displayName": f"Transformation : {product_name}",
        "elecKwh": round_param(result["elec_kwh"] / raw_kg),
        "heatMJ": round_param(result["heat_mj"] / raw_kg),
        "id": deterministic_id("food-decomposition-transform", slug),
        "impacts": {key: 0 for key in IMPACT_KEYS},
        "metadata": [{"id": transform_metadata_id, "scopes": ["food2"]}],
        "qtyVariationRatio": round_param(1 / raw_kg),
        "scopes": ["food2"],
        "source": "Ecobalyse_manual_lcia",
        "unit": "kg",
    }
    component = {
        "comment": (
            f"1 kg = {raw_kg:.2f} kg de {raw.alias} + transformation. "
            f"À comparer au procédé Agribalyse agrégé '{result['product']}'."
        ),
        "elements": [
            {
                "amount": 1,
                "material": {"id": raw.metadata_id},
                "transforms": [{"country": "FR", "id": transform_metadata_id}],
            }
        ],
        "id": deterministic_id("food-decomposition-component", slug),
        "name": f"{product_name} (1 kg)",
        "scopes": ["food2"],
    }
    return {"slug": slug, "transform": transform, "component": component}


def upsert_component(components: list[dict], component: dict) -> None:
    for position, existing in enumerate(components):
        if existing["id"] == component["id"]:
            components[position] = component
            return
    components.append(component)


def mark_aggregated(metadata_id: str) -> str | None:
    """Add the aggregated marker to the product's display name, return the file changed."""
    for path in LCI_CATALOG_DIR.glob("*/*.json"):
        activity = json.loads(path.read_text())
        for metadata in activity.get("metadata", []):
            if metadata.get("id") != metadata_id:
                continue
            display_name = metadata.get("displayName", "")
            if "agrég" in display_name:
                return None
            if display_name.endswith(OLD_SUFFIX):
                display_name = (
                    display_name[: -len(OLD_SUFFIX)] + AGGREGATED_MARKER + OLD_SUFFIX
                )
            else:
                display_name = display_name + AGGREGATED_MARKER
            metadata["displayName"] = display_name
            write_json(path, activity)
            return str(path.relative_to(DATA_ROOT_DIR))
    return None


@app.command()
def components(
    only: Annotated[
        str | None,
        typer.Option(help="Comma separated catalog aliases to restrict the run"),
    ] = None,
    activity: Annotated[
        str | None,
        typer.Option(
            help="Agribalyse activity outside the catalog, decomposed with "
            "`decompose --activity`. Needs --name."
        ),
    ] = None,
    name: Annotated[
        str | None,
        typer.Option(help="French name of the --activity product, e.g. 'Abondance FR'"),
    ] = None,
    json_in: Path = DEFAULT_JSON,
    min_share: float = 0.6,
    dry_run: bool = False,
    no_rename: bool = False,
):
    """Create the transformation processes and the food2 components from decomposition.json."""
    results = json.loads(json_in.read_text())
    catalog = load_catalog_ingredients(LCI_CATALOG_DIR)
    catalog_names = set(catalog)
    by_alias = {
        variant.alias: (activity_name, variants)
        for activity_name, variants in catalog.items()
        for variant in variants
    }
    # (label, result, key, product name, metadata id of the aggregated ingredient to mark)
    targets: list[tuple[str, dict, str, str, str | None]] = []
    if activity or name:
        if not (activity and name):
            raise typer.BadParameter("--activity and --name go together")
        if only:
            raise typer.BadParameter("--activity cannot be combined with --only")
        if activity in catalog_names:
            aliases = ", ".join(variant.alias for variant in catalog[activity])
            raise typer.BadParameter(
                f"{activity} is a catalog ingredient, use --only {aliases}"
            )
        key = slugify(name)
        if key in {slugify(base_alias(alias)) for alias in by_alias}:
            raise typer.BadParameter(
                f"--name {name!r} gives the key of a catalog product: {key}"
            )
        if activity not in results:
            raise typer.BadParameter(
                f"{activity} not in {json_in}, run decompose --activity first"
            )
        targets.append((activity, results[activity], key, name, None))
    else:
        wanted = (
            {alias.strip() for alias in only.split(",")}
            if only
            else set(results) & set(by_alias)
        )
        for alias in sorted(wanted):
            result = results.get(alias)
            if result is None:
                logger.warning(f"{alias}: not in {json_in}, run decompose first")
                continue
            if alias not in by_alias:
                print(f"{alias}: skipped, not a catalog alias")
                continue
            product = preferred_ingredient(by_alias[alias][1])
            product_name = (
                clean_display_name(product.display_name) or product.activity_name
            )
            key = slugify(base_alias(alias))
            targets.append((alias, result, key, product_name, product.metadata_id))

    components_list = json.loads(FOOD2_COMPONENTS_PATH.read_text())
    created = 0
    for label, result, key, product_name, aggregated_metadata_id in targets:
        reason = skip_reason(result, catalog_names, min_share)
        if reason:
            print(f"{label}: skipped, {reason}")
            continue
        raw = preferred_ingredient(catalog[result["main_raw"]])
        entries = build_entries(key, product_name, raw, result)
        if dry_run:
            print(f"--- {label}")
            print(json.dumps(entries["transform"], ensure_ascii=False, indent=2))
            print(json.dumps(entries["component"], ensure_ascii=False, indent=2))
            continue
        write_json(MANUAL_LCIA_DIR / f"{entries['slug']}.json", entries["transform"])
        upsert_component(components_list, entries["component"])
        if aggregated_metadata_id and not no_rename:
            renamed = mark_aggregated(aggregated_metadata_id)
            if renamed:
                logger.info(f"{label}: aggregated ingredient marked in {renamed}")
        created += 1
        print(
            f"{label}: {entries['component']['name']} = {result['main_raw_kg']:.2f} kg "
            f"{raw.alias} + {entries['slug']}"
        )
    if not dry_run:
        write_json(FOOD2_COMPONENTS_PATH, components_list)
        print(
            f"{created} component(s) written, run `just export-all` to publish the transformations"
        )


if __name__ == "__main__":
    app()
