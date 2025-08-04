#!/usr/bin/env python
import logging
import os
from datetime import UTC, datetime, timedelta
from enum import Enum
from pathlib import Path
from typing import Optional

import requests
import typer
from ecobalyse import logging_config as logging_config
from ecobalyse import scalingo
from typing_extensions import Annotated


class LoggingLevels(str, Enum):
    CRITICAL = "CRITICAL"
    DEBUG = "DEBUG"
    ERROR = "ERROR"
    INFO = "INFO"
    NOTSET = "NOTSET"
    WARNING = "WARNING"


app = typer.Typer(help="Interact with the scalingo HTTP API")

logger = logging.getLogger(__name__)


@app.callback()
def main(
    loglevel: Annotated[
        LoggingLevels, typer.Option("--loglevel", "-l")
    ] = LoggingLevels.INFO,
):
    logger.setLevel(loglevel.value)


@app.command()
def log_archives(
    download_dir: Annotated[
        Optional[Path],
        typer.Argument(help="The output CSV file."),
    ] = Path("./archives_logs"),
):
    """
    Get the list of archived logs
    """

    # Create dir if it doesn’t exist
    os.makedirs(download_dir, exist_ok=True)

    now = datetime.now(UTC)
    api_token = os.getenv("SCALINGO_API_TOKEN")
    bearer_token = scalingo.get_bearer_token(api_token=api_token)

    archives = scalingo.list_logs_archives_for_range(
        start_date=now, end_date=now - timedelta(days=14), bearer_token=bearer_token
    )

    logger.info(f"-> Got {len(archives)} archives")

    for archive in archives:
        url = archive["url"]

        filename = url.rsplit("/", 1)[1].rsplit("?", 1)[0]
        dest_file_path = os.path.join(download_dir, filename)

        # Download only if file is not present on disk
        if not Path(dest_file_path).is_file():
            response = requests.get(url, allow_redirects=True)
            open(dest_file_path, "wb").write(response.content)
        else:
            logger.info(
                f"File `{filename}` already present in `{download_dir}`, skipping download"
            )


if __name__ == "__main__":
    app()
