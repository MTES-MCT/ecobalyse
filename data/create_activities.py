#!/usr/bin/env python3
import os

import bw2data

from common.import_ import add_created_activities, setup_project
from config import DATA_ROOT_DIR
from ecobalyse_data.logging import logger


def create_activities(file):
    """Add additional processes"""

    if "Ecobalyse_custom_lci" in bw2data.databases:
        del bw2data.databases["Ecobalyse_custom_lci"]

    if (dbname := "Ecobalyse_custom_lci") not in bw2data.databases:
        if os.path.exists(file):
            logger.info(f"Adding activities from {file} to {dbname}")  # Add this line
            add_created_activities(dbname, file)
        else:
            logger.error(f"File {file} does not exist")
    else:
        logger.info(f"{dbname} already imported")


if __name__ == "__main__":
    setup_project()
    create_activities(DATA_ROOT_DIR / "custom_lci.json")
