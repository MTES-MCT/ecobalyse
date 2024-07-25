#!/usr/bin/env python

import argparse
import os

from lib.ecobalyse_github import extract_branch_name, get_github

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Extract ecobalyse-data branch name from PR description"
    )

    parser.add_argument(
        "commit_sha",
        type=str,
        help="A commit sha belonging to the PR you want to check",
    )
    args = parser.parse_args()

    (_, g) = get_github(os.getenv("GITHUB_ACCESS_TOKEN"))

    issues = g.search_issues(
        query=f"is:pull-request state:open {args.commit_sha}",
        sort="updated",
        order="desc",
    )

    if issues.totalCount > 0:
        branch_name = extract_branch_name(issues[0].body)
        if branch_name:
            print(branch_name)
