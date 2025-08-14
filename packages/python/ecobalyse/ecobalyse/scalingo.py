import logging
import os
from datetime import datetime
from pathlib import Path

import requests
from dateutil import parser
from requests.auth import HTTPBasicAuth

# Tell ruff to not delete the unused import by rexporting it using as
# See https://docs.astral.sh/ruff/rules/unused-import/
from ecobalyse import logging_config as logging_config

logger = logging.getLogger(__name__)


def get_bearer_token(api_token: str) -> str:
    logging.info("-> Getting Bearer token")
    basic = HTTPBasicAuth("", api_token)
    endpoint = "https://auth.scalingo.com/v1/tokens/exchange"
    headers = {"Content-Type": "application/json", "Accept": "application/json"}
    response = requests.post(endpoint, auth=basic, headers=headers)

    return response.json()["token"]


def parse_archive_datetime(date_string: str) -> datetime:
    date_string_clean: str = date_string.replace(" UTC", "")
    return parser.parse(date_string_clean)


def list_logs_archives(
    bearer_token: str, cursor: str = "1", application: str = "ecobalyse"
) -> dict:
    logging.info(f"-> Listing log archives for cursor {cursor}")

    endpoint = f"https://api.osc-fr1.scalingo.com/v1/apps/{application}/logs_archives?cursor={cursor}"
    headers = {
        "Accept": "application/json",
        "Authorization": f"Bearer {bearer_token}",
        "Content-Type": "application/json",
    }
    response = requests.get(endpoint, headers=headers)
    return response.json()


def download_archive(archive: dict, download_dir: Path) -> str | None:
    url = archive["url"]

    filename = url.rsplit("/", 1)[1].rsplit("?", 1)[0]
    dest_file_path = os.path.join(download_dir, filename)

    # Download only if file is not present on disk
    if not Path(dest_file_path).is_file():
        logger.info(f"Downloading `{url}`…")
        response = requests.get(url, allow_redirects=True)
        if response.status_code == 200:
            open(dest_file_path, "wb").write(response.content)
        else:
            logger.error(f"Download failed: {response.status_code}, {response.content}")
    else:
        logger.info(
            f"File `{filename}` already present in `{download_dir}`, skipping download"
        )
    return dest_file_path if Path(dest_file_path).is_file else None


def list_logs_archives_for_range(
    start_date: datetime,
    end_date: datetime,
    bearer_token: str,
    application: str = "ecobalyse",
    download_dir: Path | None = None,
) -> tuple[list[dict], list[dict]]:
    logging.info(f"-> Listing log archives from {start_date} to {end_date}")

    cursor = 1
    archives_logs = list_logs_archives(bearer_token=bearer_token, cursor=cursor)
    archives = archives_logs["archives"]

    if len(archives) == 0:
        logger.info("-> No more archives, returning")
        return

    first_archive = archives[0]
    first_archive_from_date = parse_archive_datetime(first_archive["from"])

    last_archive = archives[-1]
    last_archive_to_date = parse_archive_datetime(last_archive["to"])
    downloaded_files = []

    while first_archive_from_date > start_date and archives_logs["has_more"]:
        cursor = archives_logs["next_cursor"]
        archives_logs = list_logs_archives(bearer_token=bearer_token, cursor=cursor)
        archives = archives_logs["archives"]

        if len(archives) == 0:
            logger.info("-> No more archives, returning")
            return

        first_archive = archives[0]
        first_archive_from_date = parse_archive_datetime(first_archive["from"])

    if download_dir:
        downloaded_file: str | None = download_archive(first_archive, download_dir)
        if downloaded_file:
            downloaded_files.append(downloaded_file)

    while last_archive_to_date > end_date and archives_logs["has_more"]:
        cursor = archives_logs["next_cursor"]
        archives_logs = list_logs_archives(bearer_token=bearer_token, cursor=cursor)
        archives += archives_logs["archives"]

        if download_dir:
            for archive in archives_logs["archives"]:
                downloaded_file: str | None = download_archive(archive, download_dir)
                if downloaded_file:
                    downloaded_files.append(downloaded_file)

        if len(archives) == 0:
            logger.info("-> No more archives, returning")
            return

        last_archive = archives[-1]
        last_archive_to_date = parse_archive_datetime(last_archive["to"])

    return (archives, downloaded_files)
