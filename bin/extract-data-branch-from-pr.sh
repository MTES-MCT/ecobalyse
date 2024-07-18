#!/usr/bin/env bash
COMMIT=$1

# Be sure to exit as soon as something goes wrong
set -eo pipefail

if [ -z "$COMMIT" ]
then
  echo "Missing commit hash parameter. You should provide a commit belonging to the PR you want to check."
  echo ""
  echo "Usage : $0 <commit_hash>"
  exit
fi

SEARCH_RESULT=$(curl -sL "https://api.github.com/search/issues?q=$COMMIT&per_page=1&page=1&sort=updated&direction=desc")

echo $SEARCH_RESULT

# Extract the state of the PR "state": "open"
STATE=$(echo $SEARCH_RESULT | sed -E 's/.*"state": "([^"]*).*/\1/')
# Check if the response contains, on a single line, a pattern of type data: branch_name
# (it should be part of the body)
# Branch names format: https://docs.github.com/en/get-started/using-git/dealing-with-special-characters-in-branch-and-tag-names#naming-branches-and-tags
# The English alphabet (a to z and A to Z), Numbers (0 to 9), period (.), hyphen (-), underscore (_), forward slash (/)
DATA_BRANCH=$(echo $SEARCH_RESULT | sed -E 's/.*ecobalyse_data: ([[:alnum:]./_-]*).*/\1/g')

# If the PR is open and we've found a data: branch_name value, display it
if [[ "$STATE" == "open" && ! -z $DATA_BRANCH ]]; then
  echo $DATA_BRANCH
fi
