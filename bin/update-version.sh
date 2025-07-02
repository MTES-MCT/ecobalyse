#!/usr/bin/env bash



SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$( dirname $SCRIPT_DIR )

# If the SOURCE_VERSION is provided (usually by scalingo), search for a corresponding TAG
# Using the github API or use the provided one in the tag ENV variable
if [[ ! -z "${SOURCE_VERSION}" ]]; then
  # Add uv to the path on scalingo
  export PATH=~/.local/bin:$PATH

  HASH=$SOURCE_VERSION


  if [[ ! -z "${TAG}" ]]; then
    TAG_NAME=$TAG
  else
    TAG_NAME=$(uv run python $SCRIPT_DIR/get_tag_for_commit.py $HASH)
  fi
else
  # If it's not provided we are certainly in the dev env, so get the current hash from
  # the git repo
  HASH=$(git rev-parse HEAD)

  if [[ ! -z "${TAG}" ]]; then
    TAG_NAME=$TAG
  else
    # And get the possible tag from it too
    TAG_NAME=$(git describe --tags --exact-match $HASH 2> /dev/null)
  fi
fi

# If we found a tag, set the json object value to it
if [[ ! -z $TAG_NAME ]]; then
  TAG=\"$TAG_NAME\"
else
  TAG=null
fi


echo "{\"hash\": \"$HASH\", \"tag\": $TAG }" > public/version.json
