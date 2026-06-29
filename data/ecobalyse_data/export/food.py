import csv
import json
from enum import StrEnum
from typing import List, Optional

from common.export import (
    export_json,
)
from common.infer_metadata import infer_base_ingredient
from ecobalyse_data.bw.search import cached_search_one
from ecobalyse_data.export import complements
from ecobalyse_data.export.land_occupation import compute_land_occupation_batch
from ecobalyse_data.export.utils import get_metadata_for_scope
from ecobalyse_data.logging import logger
from models.process import EcosystemicServices, Ingredient


class Scenario(StrEnum):
    ORGANIC = "organic"
    REFERENCE = "reference"
    IMPORT = "import"


class DefaultOrigin(StrEnum):
    FRANCE = "France"
    EUROPE_AND_MAGHREB = "EuropeAndMaghreb"
    OUT_OF_EUROPE_AND_MAGHREB = "OutOfEuropeAndMaghreb"
    OUT_OF_EUROPE_AND_MAGHREB_BY_PLANE = "OutOfEuropeAndMaghrebByPlane"


def float_or_none(value) -> Optional[float]:
    try:
        return float(value)
    except ValueError:
        return None


def gen_factors(row):
    es = {}
    for kind in ["hedges", "plotSize", "cropDiversity"]:
        es[kind] = {}
        for key in ["reference", "organic", "import"]:
            es[kind][key] = float_or_none(row[f"{kind}_{key}"])
    return es


def load_ecosystemic_dic(PATH):
    """Load ecosystemic csv as dictionary"""

    ecosystemic_factors = {}

    with open(PATH, "r", encoding="utf-8-sig") as csvfile:
        reader = csv.DictReader(csvfile, delimiter=";")
        for row in reader:
            cropGroup = row.get("group")
            ecosystemic_factors[cropGroup] = gen_factors(row)
    return ecosystemic_factors


def resolve_feed(alias, feed_file_content, transformed_to_raw):
    """Resolve feed quantities for an animal ingredient.

    For direct products (milk, eggs, live animals): return feed from feed.json directly.
    For meat products: look up live animal feed and multiply by ratio.
    """
    if alias in feed_file_content:
        return feed_file_content[alias]
    if alias in transformed_to_raw:
        raw_alias, ratio = transformed_to_raw[alias]
        if raw_alias not in feed_file_content:
            raise ValueError(
                f"Raw alias ‘{raw_alias}’ for transformed product ‘{alias}’ not found in feed.json"
            )
        base_feed = feed_file_content[raw_alias]
        return {k: v * ratio for k, v in base_feed.items()}
    return None


def build_transformed_to_raw(raw_to_transformed):
    """Build reverse lookup: transformed_alias -> (raw_alias, ratio)."""
    transformed_to_raw = {}
    for raw_alias, products in raw_to_transformed.items():
        for transformed_alias, entry in products.items():
            transformed_to_raw[transformed_alias] = (raw_alias, entry["ratio"])
    return transformed_to_raw


def compute_es_for_ingredients(
    activities: List[dict],
    ecosystemic_factors,
    feed_file_content,
    raw_to_transformed,
) -> dict[str, dict]:
    es_for_ingredients = {}
    transformed_to_raw = build_transformed_to_raw(raw_to_transformed)

    metadata_by_alias = {}
    for activity in activities:
        for food_metadata in get_metadata_for_scope(activity, "food"):
            metadata_by_alias[food_metadata["alias"]] = food_metadata

    for activity in activities:
        for food_metadata in get_metadata_for_scope(activity, "food"):
            alias = food_metadata["alias"]
            if alias in es_for_ingredients:
                # The ES for this ingredient was already computed (a dependency of an animal activity)
                # skip it
                continue
            # If it’s a vegetal ingredient
            if all(
                food_metadata.get(key)
                for key in ["landOccupation", "cropGroup", "scenario"]
            ):
                services = complements.compute_vegetal_ecosystemic_services(
                    food_metadata, ecosystemic_factors
                )
                es_for_ingredients[alias] = services

            # If it’s an animal ingredient
            else:
                feed_quantities = resolve_feed(
                    alias, feed_file_content, transformed_to_raw
                )
                if feed_quantities is None:
                    displayName = activity["displayName"]
                    logger.warning(
                        f"{alias} - {displayName} doesn’t have any food complements associated"
                    )
                    continue

                # First, compute any missing feed activities
                for feed_activity_alias in feed_quantities.keys():
                    if feed_activity_alias not in es_for_ingredients:
                        if feed_activity_alias not in metadata_by_alias:
                            raise ValueError(
                                f"-> animal feed: {feed_activity_alias} not in activities list, can’t compute ES"
                            )
                        feed_services = (
                            complements.compute_vegetal_ecosystemic_services(
                                metadata_by_alias[feed_activity_alias],
                                ecosystemic_factors,
                            )
                        )
                        es_for_ingredients[feed_activity_alias] = feed_services

                # Now compute animal services with all dependencies available
                services = complements.compute_animal_ecosystemic_services(
                    es_for_ingredients,
                    feed_quantities,
                )
                es_for_ingredients[alias] = services

    return es_for_ingredients


def activities_to_ingredients_json(
    activities: List[dict],
    ingredients_paths: List[str],
    ecosystemic_factors_path: str,
    feed_file_path: str,
    raw_to_transformed_file_path: str,
    cpu_count: int,
) -> List[dict]:
    ecosystemic_factors = load_ecosystemic_dic(ecosystemic_factors_path)

    with open(feed_file_path, "r") as file:
        feed_file_content = json.load(file)

    with open(raw_to_transformed_file_path, "r") as file:
        raw_to_transformed = json.load(file)

    activities_with_land_occupation = add_land_occupations(activities)

    ingredients = activities_to_ingredients(
        activities_with_land_occupation,
        ecosystemic_factors,
        feed_file_content,
        raw_to_transformed,
    )

    ingredients_dicts = [
        ingredient.model_dump(by_alias=True) for ingredient in ingredients
    ]

    ingredients_dicts.sort(key=lambda x: x["id"])

    exported_files = []
    for ingredients_path in ingredients_paths:
        export_json(ingredients_dicts, ingredients_path)

        exported_files.append(ingredients_path)

    for ingredients_path in exported_files:
        logger.debug(
            f"-> Exported {len(ingredients_dicts)} 'ingredients' to {ingredients_path}"
        )

    return ingredients_dicts


def add_land_occupations(activities: List[dict]) -> List[dict]:
    """Populate `landOccupation` on every food metadata block via MultiLCA.

    Hardcoded values (e.g. `walnut-inshell-fr`) are preserved. One score per
    (source, activityName) is shared across all metadata entries of an activity.
    """
    needs_compute = []
    for activity in activities:
        for food_metadata in get_metadata_for_scope(activity, "food"):
            if food_metadata.get("landOccupation"):
                logger.debug(
                    f"-> Not computing land occupation for {food_metadata['alias']}, value is already hardcoded"
                )
                continue
            needs_compute.append((activity, food_metadata))

    bw_by_eco_id = {}
    for activity, _ in needs_compute:
        eco_id = activity["id"]
        if eco_id not in bw_by_eco_id:
            bw_by_eco_id[eco_id] = cached_search_one(
                activity.get("source"),
                activity.get("activityName"),
                location=activity.get("location"),
            )

    scores = compute_land_occupation_batch(list(bw_by_eco_id.values()))
    for activity, food_metadata in needs_compute:
        food_metadata["landOccupation"] = scores[bw_by_eco_id[activity["id"]].id]
    return activities


def activities_to_ingredients(
    activities: List[dict],
    ecosystemic_factors,
    feed_file_content,
    raw_to_transformed,
) -> List[Ingredient]:
    es_by_alias = compute_es_for_ingredients(
        activities,
        ecosystemic_factors,
        feed_file_content,
        raw_to_transformed,
    )

    ingredients = []
    for activity in activities:
        ingredients.extend(activity_to_ingredients(activity, es_by_alias))

    return ingredients


def activity_to_ingredients(eco_activity: dict, es_by_alias: dict) -> List[Ingredient]:
    ingredients = []

    bw_activity = cached_search_one(
        eco_activity.get("source"),
        eco_activity.get("activityName"),
        location=eco_activity.get("location"),
    )

    for food_metadata in get_metadata_for_scope(eco_activity, "food"):
        land_occupation = food_metadata.get("landOccupation")

        ecosystemic_services = None

        es = es_by_alias.get(food_metadata["alias"])

        if es:

            def _neg(key):
                value = es.get(key)
                return -value if value is not None else None

            ecosystemic_services = EcosystemicServices(
                crop_diversity=_neg("cropDiversity"),
                hedges=_neg("hedges"),
                permanent_pasture=_neg("permanentPasture"),
                plot_size=_neg("plotSize"),
            )

        ingredients.append(
            Ingredient(
                alias=food_metadata["alias"],
                base_ingredient=infer_base_ingredient(food_metadata["alias"]),
                categories=food_metadata.get("ingredientCategories", []),
                crop_group=food_metadata.get("cropGroup"),
                default_origin=food_metadata["defaultOrigin"],
                density=food_metadata["ingredientDensity"],
                ecosystemic_services=ecosystemic_services,
                id=food_metadata["id"],
                inedible_part=food_metadata["inediblePart"],
                land_occupation=land_occupation,
                location=bw_activity.get("location"),
                name=food_metadata["displayName"],
                raw_to_cooked_ratio=food_metadata["rawToCookedRatio"],
                scenario=food_metadata.get("scenario"),
                activity_name=eco_activity["activityName"],
                transport_cooling=food_metadata["transportCooling"],
                visible=food_metadata["visible"],
                process_id=eco_activity["id"],
            )
        )
    return ingredients


def scenario(activity):
    """compute scenario from activity data
    (if missing)"""
    if "ingredient" not in activity["categories"]:
        return None
    if "scenario" in activity:
        return activity["scenario"]
    if (
        "organic" in activity["ingredientCategories"]
        or "organic" in activity.get("activityName", "").lower()
    ):
        return "organic"
    match activity["defaultOrigin"]:
        case DefaultOrigin.FRANCE:
            return Scenario.REFERENCE
        case DefaultOrigin.EUROPE_AND_MAGHREB:
            return Scenario.IMPORT
        case (
            DefaultOrigin.OUT_OF_EUROPE_AND_MAGHREB
            | DefaultOrigin.OUT_OF_EUROPE_AND_MAGHREB_BY_PLANE
        ):
            return Scenario.IMPORT
