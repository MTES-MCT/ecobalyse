import os
import sys

import github
from github import Auth, Github


def get_github(github_access_token=None):
    # We may want to use our personal ACCESS_TOKEN for testing purpose as the GITHUB public
    # API is rate limited to 60 calls per hour by default
    if github_access_token is None:
        github_access_token = os.getenv("GITHUB_ACCESS_TOKEN")

    if github_access_token:
        g = Github(auth=Auth.Token(github_access_token))
    else:
        g = Github(retry=None)

    try:
        return (g.get_repo("MTES-MCT/ecobalyse"), g)
    except github.RateLimitExceededException:
        print(
            "-> ⚠️ Github rate limit exceeded, can't get the tag for the current commit. You should setup GITHUB_ACCESS_TOKEN env variable to a valid Github access token.",
            file=sys.stderr,
        )
