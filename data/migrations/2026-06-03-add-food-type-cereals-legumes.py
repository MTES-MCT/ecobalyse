#!/usr/bin/env -S uv run --script
"""
Transform activities.json from flat structure to nested structure with metadata.
"""

import json

from config import PROJECT_ROOT_DIR
from ecobalyse_data.logging import logger

# Extracted from https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/impacts-consideres/rapport-cru-cuit
RATIO_TO_CAT = {
    0.856: "material_type:fruits_and_vegetables",
    0.819: "material_type:fish_and_shellfish",
    2.259: "material_type:cereals",
    2.330: "material_type:legumes",
    0.974: "material_type:eggs",
    0.792: "material_type:red_meats",
    0.755: "material_type:poultry",
    0.730: "material_type:offal",
}

OTHER_ITEMS_TAG = "material_type:other_food_items"

INGREDIENT_CATEGORIES = set(RATIO_TO_CAT.values()) | set([OTHER_ITEMS_TAG])


def main():
    lci_catalog = PROJECT_ROOT_DIR / "lci_catalog"
    logger.debug(f"-> Loading lci_catalog {lci_catalog}")

    for lci_path in lci_catalog.glob("*/*.json"):
        if lci_path.is_file():
            activity = None
            with open(lci_path, "r", encoding="utf-8") as fd:
                activity = json.load(fd)
                categories = set(activity["categories"])
                metadata = activity.get("metadata")

                if metadata and "ingredient" in categories:
                    # The `material` tag is added if needed. All ingredients have
                    # to have it.
                    categories |= set(["material"])

                    # Any `material_type:*` tag is removed, so that we can just
                    # add the proper one afterwards, without having to worry about
                    # duplicates
                    categories -= INGREDIENT_CATEGORIES

                    # Arbitrarly take the first rawToCookedRatio, and emit a warning
                    # in case they are not all identical
                    rawToCookedRatio = metadata[0]["rawToCookedRatio"]
                    if any(
                        [m["rawToCookedRatio"] != rawToCookedRatio for m in metadata]
                    ):
                        categories.add(OTHER_ITEMS_TAG)
                        logger.warning(
                            f"{activity['displayName']}: several rawToCookedRatio found, using the first one ",
                        )
                    else:
                        # Add the tag corresponding to the rawToCookedRatio
                        if RATIO_TO_CAT.get(rawToCookedRatio):
                            categories.add(RATIO_TO_CAT[rawToCookedRatio])
                        else:
                            # Emit a warning for unknown rawToCookedRatio
                            if rawToCookedRatio != 1:
                                logger.warning(
                                    f"{activity['displayName']}: no category found for ratio {rawToCookedRatio}"
                                )
                            categories.add(OTHER_ITEMS_TAG)

                    activity["categories"] = sorted(categories)

            with open(lci_path, "w", encoding="utf-8") as fd:
                json.dump(activity, fd, ensure_ascii=False, sort_keys=True, indent=2)
                fd.write("\n")


if __name__ == "__main__":
    main()
