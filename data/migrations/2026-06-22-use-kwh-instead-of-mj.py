#!/usr/bin/env -S uv run --script
"""
Converts electrical energy values from MJ to kWh
"""

import json

from config import PROJECT_ROOT_DIR, settings
from ecobalyse_data.logging import logger

MJ_TO_KWH = 3.6


def main():
    lci_catalog = PROJECT_ROOT_DIR / "lci_catalog"
    logger.debug(f"-> Loading lci_catalog {lci_catalog}")

    for lci_path in lci_catalog.glob("*/*.json"):
        if lci_path.is_file():
            activity = None
            with open(lci_path, "r", encoding="utf-8") as fd:
                activity = json.load(fd)
                if activity.get("elecMJ") is not None:
                    activity["elecKwh"] = round(
                        activity["elecMJ"] / MJ_TO_KWH, settings.NUMBER_PRECISION
                    )
                    del activity["elecMJ"]
            if activity:
                with open(lci_path, "w", encoding="utf-8") as fd:
                    json.dump(
                        activity, fd, ensure_ascii=False, sort_keys=True, indent=2
                    )
                    fd.write("\n")


if __name__ == "__main__":
    main()
