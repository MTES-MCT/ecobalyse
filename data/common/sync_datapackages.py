# Configure logger

import bw2data

from common import brightway_patch as brightway_patch
from config import settings
from ecobalyse_data.logging import logger

logger.info("Syncing datapackages")

bw2data.projects.set_current(settings.bw.project)
for method in bw2data.methods:
    logger.debug(f"Syncing method {method}")
    bw2data.Method(method).process()

for database in bw2data.databases:
    logger.info(f"Syncing database {database}")
    bw2data.Database(database).process()
