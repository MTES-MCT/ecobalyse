#!/usr/bin/env python
import fileinput
import glob
import logging
import multiprocessing
import os
import re
from datetime import UTC, datetime, timedelta
from enum import Enum
from multiprocessing import Pool
from pathlib import Path
from typing import Optional

import typer
from dateutil import parser
from ecobalyse import logging_config as logging_config
from ecobalyse import scalingo
from rich import print
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


def parse_log_line(log_line):
    # Split the log line into parts
    parts = log_line.split(" ")

    # Extract timestamp and timezone
    timestamp = parser.parse(" ".join(parts[:3]))

    # Initialize the dictionary with the timestamp
    log_dict = {"timestamp": timestamp}

    # Use regex to find key-value pairs
    key_value_pairs = re.findall(r'(\w+)=("[^"]*"|\S+)', log_line)

    # Populate the dictionary with key-value pairs
    for key, value in key_value_pairs:
        value = value.strip('"')

        if key == "duration":
            value = float(value.strip("s"))
        elif key == "status" or key == "bytes":
            value = int(value)

        log_dict[key] = value

    return log_dict


def get_log_stats(filename):
    with fileinput.input(
        files=[filename],
        openhook=fileinput.hook_compressed,
        encoding="utf-8",
    ) as f:
        slowest_lines = []
        max_lines = 20
        for line in f:
            if "[router]" in line:
                parsed_line = parse_log_line(line)
                if len(slowest_lines) < max_lines:
                    slowest_lines.append(parsed_line)
                    slowest_lines = sorted(
                        slowest_lines, key=lambda value: value["duration"], reverse=True
                    )
                    continue

                if parsed_line["duration"] > slowest_lines[-1]["duration"]:
                    slowest_lines.append(parsed_line)
                    slowest_lines = sorted(
                        slowest_lines, key=lambda value: value["duration"], reverse=True
                    )[:10]

        return slowest_lines


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

    if False:
        (archives, downloaded_files) = scalingo.list_logs_archives_for_range(
            start_date=now,
            end_date=now - timedelta(days=14),
            bearer_token=bearer_token,
            download_dir=download_dir,
        )

    cpu_count = multiprocessing.cpu_count() - 1 or 1

    slowest_lines = []
    with Pool(cpu_count) as pool:
        logs_slowest_lines = pool.starmap(
            get_log_stats,
            [(filename,) for filename in glob.glob(f"{download_dir}/*.log-*.gz")],
        )
        slowest_lines = sorted(
            # Flatmap starmap results
            [y for ys in logs_slowest_lines for y in ys],
            key=lambda value: value["duration"],
            reverse=True,
        )[:20]

    print(slowest_lines)


if __name__ == "__main__":
    app()
