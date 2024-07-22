#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Default JSON value for the TAG
TAG=null

# If the SOURCE_VERSION is provided (usually by scalingo), search for a corresponding TAG
# Using the github API
if [[ ! -z "${SOURCE_VERSION}" ]]; then
  HASH=$SOURCE_VERSION
  TAG_FOUND=$(python $SCRIPT_DIR/get-tag-for-commit.py $HASH)
else
  # If it's not provided we are certainly in the dev env, so get the current hash from
  # the git repo
  HASH=$(git rev-parse HEAD)
  # And get the possible tag from it too
  TAG_FOUND=$(git describe --tags --exact-match $HASH 2> /dev/null)
fi

# If we found a tag, set the json object value to it
if [[ ! -z $TAG_FOUND ]]; then
  TAG=\"$TAG_FOUND\"
fi

echo "{\"hash\": \"$HASH\", \"tag\": $TAG}" > public/version.json
