#!/usr/bin/env python
import logging
import os
from enum import Enum

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


app = typer.Typer(help="Interact with the scalingo HTTP API")

logger = logging.getLogger(__name__)


@app.callback()
def main(
    loglevel: Annotated[
        LoggingLevels, typer.Option("--loglevel", "-l")
    ] = LoggingLevels.INFO,
):
    logger.setLevel(loglevel.value)


@app.command()
def log_archives():
    """
    Get the list of archived logs
    """

    api_token = os.getenv("SCALINGO_API_TOKEN")
    bearer_token = scalingo.get_bearer_token(api_token=api_token)
    logs = scalingo.list_logs_archives(bearer_token=bearer_token)
    print(logs)


if __name__ == "__main__":
    app()
