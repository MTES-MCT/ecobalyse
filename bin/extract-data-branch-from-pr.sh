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

# Extract the state of the PR "state": "open"
STATE=$(echo $SEARCH_RESULT | sed -E 's/.*"state": "([^"]*).*/\1/')
# Check if the response contains, on a single line, a pattern of type data: branch_name
# (it should be part of the body)
DATA_BRANCH=$(echo $SEARCH_RESULT | sed -E 's/.*ecobalyse_data: ([^\R]*).*/\1/g')

# If the PR is open and we've found a data: branch_name value, display it
if [[ "$STATE" == "open" && ! -z $DATA_BRANCH ]]; then
  echo $DATA_BRANCH
fi
