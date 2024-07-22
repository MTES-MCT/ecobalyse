#!/usr/bin/env python

import argparse
import os
import sys

import github
from github import Auth, Github

parser = argparse.ArgumentParser(description="Get tag for a specific commit")

parser.add_argument(
    "commit_sha",
    type=str,
    help="The sha of the commit you want to search the tag for",
)
args = parser.parse_args()

# We may want to use our personal ACCESS_TOKEN for testing purpose as the GITHUB public
# API is rate limited to 60 calls per hour by default
github_access_token = os.getenv("GITHUB_ACCESS_TOKEN")
if github_access_token:
    g = Github(auth=Auth.Token(github_access_token))
else:
    g = Github(retry=None)

try:
    repo = g.get_repo("MTES-MCT/ecobalyse")
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
except github.RateLimitExceededException:
    print(
        "-> ⚠️ Github rate limit exceeded, can't get the tag for the current commit. You should setup GITHUB_ACCESS_TOKEN env variable to a valid Github access token.",
        file=sys.stderr,
    )
