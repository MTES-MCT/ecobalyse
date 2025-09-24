#!/usr/bin/env python

import argparse
import logging
import os
import pathlib
import shutil
from pathlib import Path

import requests

# Tell ruff to not delete the unused import by rexporting it using as
# See https://docs.astral.sh/ruff/rules/unused-import/
from ecobalyse import logging_config as logging_config
from ecobalyse.github import get_github

logger = logging.getLogger(__name__)


def download_file(url, destination_directory=None):
    local_filename = url.split("/")[-1]

    if destination_directory is not None:
        local_filename = os.path.join(destination_directory, local_filename)

    logger.debug(f"-> Downloading {url} to {local_filename}")

    with requests.get(url, stream=True) as r:
        if r.status_code == 200:
            with open(local_filename, "wb") as f:
                shutil.copyfileobj(r.raw, f)
        else:
            logger.error(f"Status: {r.status_code}, body: {r.text}")
            return None

    return local_filename


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Download Ecobalyse releases and unpack into the versions directory."
    )
    parser.add_argument(
        "destination_directory",
        type=pathlib.Path,
        nargs="?",
        help="The destination directory. Default to 'versions'.",
        default="./versions",
    )

    parser.add_argument(
        "--loglevel",
        type=str.upper,
        help="Override default logging level for current module.",
        choices=logging.getLevelNamesMapping().keys(),
    )

    args = parser.parse_args()

    logger.info(f"Downloading versions to '{args.destination_directory}' directory.")
    if args.loglevel is not None:
        logger.setLevel(args.loglevel)

    (repo, _) = get_github(os.getenv("GITHUB_ACCESS_TOKEN"))

    # Create destination directory if it doesn't exist
    os.makedirs(args.destination_directory, exist_ok=True)

    # Get releases from github
    releases = repo.get_releases()
    logger.info(f"Found {releases.totalCount} release(s).")
    nb_releases_extracted = 0
    for release in releases:
        if release.tag_name is None:
            logger.info("Skipping release without a tag.")
            continue

        if release.draft:
            logger.info(f"Skipping draft {release}.")
            continue

        if release.prerelease:
            logger.info(f"Skipping prerelease {release}.")
            continue

        for asset in release.assets:
            if "-dist.tar.gz" in asset.browser_download_url:
                logger.info(
                    f"Downloading {asset.browser_download_url} to {args.destination_directory}."
                )
                file_path = download_file(
                    asset.browser_download_url, args.destination_directory
                )
                if not file_path:
                    logger.error(
                        f"Error downloading {asset.browser_download_url}, skipping."
                    )
                    continue

                # 'dist' is the name of the directory contained in the archive
                unpacked_destination_directory = os.path.join(
                    args.destination_directory, "dist"
                )
                version_destination_directory = os.path.join(
                    args.destination_directory, release.tag_name
                )
                shutil.unpack_archive(file_path, args.destination_directory)

                if os.path.isdir(version_destination_directory):
                    logger.warning(
                        f"Destination directory for {release.tag_name} already exists, deleting it."
                    )
                    shutil.rmtree(version_destination_directory)

                os.rename(unpacked_destination_directory, version_destination_directory)

                # Delete dowloaded archives
                for p in Path(args.destination_directory).glob("*-dist.tar.gz"):
                    p.unlink()

                nb_releases_extracted += 1

    logger.info(
        f"{nb_releases_extracted} release(s) extracted to '{args.destination_directory}' directory."
    )
