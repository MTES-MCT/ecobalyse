#!/usr/bin/env python3

import argparse
import json
import uuid
from pathlib import Path

from ecobalyse.json import export_json

from config import DATA_ROOT_DIR
from ecobalyse_data.logging import logger


def read_ids(path: Path) -> set[str]:
    ids = set()
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            ids.add(str(uuid.UUID(line)))
        except ValueError:
            logger.warning(f"'{line}' is not a valid UUID, ignored")
    return ids


def main():
    parser = argparse.ArgumentParser(
        description="Hide (default) or show food ingredients."
    )
    parser.add_argument(
        "ids_file", type=Path, help="Text file with one ingredient id per line"
    )
    parser.add_argument(
        "--visible", action="store_true", help="Show the ingredients instead"
    )
    args = parser.parse_args()

    ids = read_ids(args.ids_file)
    found = set()

    for lci_path in sorted((DATA_ROOT_DIR / "lci_catalog").glob("*/*.json")):
        with open(lci_path, encoding="utf-8") as fd:
            activity = json.load(fd)

        modified = False
        for metadata in activity.get("metadata") or []:
            if metadata.get("id") in ids:
                found.add(metadata["id"])
                metadata["visible"] = args.visible
                modified = True

        if modified:
            export_json(activity, lci_path)

    for missing_id in sorted(ids - found):
        logger.warning(f"{missing_id}: no ingredient with this id in the LCI catalog")

    logger.info(f"{len(found)} ingredients set to visible={args.visible}")


if __name__ == "__main__":
    main()
