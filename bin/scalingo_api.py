#!/usr/bin/env python
import fileinput
import glob
import logging
import multiprocessing
import os
import re
from collections import Counter
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
        statuses = {}
        max_lines = 20
        error_lines = []
        versions = Counter()

        versions_pattern = r"/versions/(v\d+\.\d+\.\d+)"

        for line in f:
            if "[router]" in line:
                parsed_line = parse_log_line(line)
                status = parsed_line["status"]
                duration = parsed_line["duration"]
                path = parsed_line["path"].strip()

                if status in statuses:
                    statuses[status] += 1
                else:
                    statuses[status] = 1

                if path.startswith("/versions/v") and "version.json" not in path:
                    match = re.search(versions_pattern, path)
                    if match:
                        version = match.group(1)
                        if "/api/" in path:
                            version += "-api"
                        versions[version] += 1
                    else:
                        print(f"# -> Print no version match for {path}")

                if len(slowest_lines) < max_lines and duration < 55.0 and duration > 3:
                    slowest_lines.append(parsed_line)
                    slowest_lines = sorted(
                        slowest_lines, key=lambda value: value["duration"], reverse=True
                    )
                    continue

                if (
                    len(slowest_lines) > 0
                    and duration > slowest_lines[-1]["duration"]
                    and duration < 55.0
                    and duration > 3
                ):
                    slowest_lines.append(parsed_line)
                    slowest_lines = sorted(
                        slowest_lines, key=lambda value: value["duration"], reverse=True
                    )[:max_lines]

                if status >= 400:
                    error_lines.append(parsed_line)

        return (slowest_lines, statuses, error_lines, versions)


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
    download: Annotated[
        bool, typer.Option(help="Download the archives from scalingo")
    ] = True,
    days: Annotated[int, typer.Option(help="Number of days to download")] = 14,
):
    """
    Get the list of archived logs
    """

    # Create dir if it doesn’t exist
    os.makedirs(download_dir, exist_ok=True)

    now = datetime.now(UTC)
    api_token = os.getenv("SCALINGO_API_TOKEN")

    if download:
        bearer_token = scalingo.get_bearer_token(api_token=api_token)

        (archives, downloaded_files) = scalingo.list_logs_archives_for_range(
            start_date=now,
            end_date=now - timedelta(days=days),
            bearer_token=bearer_token,
            download_dir=download_dir,
        )

    cpu_count = multiprocessing.cpu_count() - 1 or 1

    slowest_lines = []
    versions = Counter()
    with Pool(cpu_count) as pool:
        results = pool.starmap(
            get_log_stats,
            [(filename,) for filename in glob.glob(f"{download_dir}/*.log-*.gz")],
        )

        slowest_lines = sorted(
            # Flatmap starmap results
            [y for ys in results for y in ys[0]],
            key=lambda value: value["duration"],
        )[-40:]

        statuses = {y: True for ys in results for y in ys[1]}

        error_lines = sorted(
            # Flatmap starmap results
            [y for ys in results for y in ys[2]],
            key=lambda value: value["status"],
        )

        for result in results:
            versions.update(result[3])

    print(statuses)
    print(len(error_lines))
    print(slowest_lines)
    print(dict(sorted(versions.items())))


if __name__ == "__main__":
    app()
