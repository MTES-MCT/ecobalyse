#!/usr/bin/env python

import argparse
import os

from ecobalyse_lib.github import get_github

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Get tag for a specific commit")

    parser.add_argument(
        "commit_sha",
        type=str,
        help="The sha of the commit you want to search the tag for",
    )
    args = parser.parse_args()

    (repo, _) = get_github(os.getenv("GITHUB_ACCESS_TOKEN"))

    # It's not possible to query the API to get a tag for a specific commit, we need to
    # query all tags and the parse the response
    tags = repo.get_tags()

    version = None

    for tag in tags:
        if tag.commit.sha == args.commit_sha:
            version = tag.name
            break

    if version is not None:
        print(version)
