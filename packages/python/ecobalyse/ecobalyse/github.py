import os
import re
import sys

import github
from github import Auth, Github


def extract_branch_name(content: str) -> str | None:
    if not content:
        return

    # Check if the response contains, on a single line, a pattern of type data: branch_name
    # (it should be part of the body)
    # Branch names format: https://docs.github.com/en/get-started/using-git/dealing-with-special-characters-in-branch-and-tag-names#naming-branches-and-tags
    # The English alphabet (a to z and A to Z), Numbers (0 to 9), period (.), hyphen (-), underscore (_), forward slash (/)
    result = re.search(r"ecobalyse-private: ([0-9a-zA-Z./_-]+)", content, re.M | re.I)
    if result:
        return result.group(1)


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
    except github.RateLimitExceededException as e:
        print(
            "-> ⚠️ Github rate limit exceeded, can't get the tag for the current commit. You should setup GITHUB_ACCESS_TOKEN env variable to a valid Github access token.",
            file=sys.stderr,
        )
        raise e
