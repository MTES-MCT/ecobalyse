# Configure logger
import sys

import bw2data
from loguru import logger

logger.remove()  # Remove default handler
logger.add(sys.stderr, format="{time} {level} {message}", level="INFO")

PROJECT = "default"
print("Syncing datapackages...")
bw2data.projects.set_current(PROJECT)
for method in bw2data.methods:
    logger.info(f"Syncing method {method}...")
    bw2data.Method(method).process()

for database in bw2data.databases:
    logger.info(f"Syncing database {database}...")
    bw2data.Database(database).process()
print("done")
