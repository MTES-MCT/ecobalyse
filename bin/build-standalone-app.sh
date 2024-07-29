#!/usr/bin/env bash
TAG_NAME=$1

# Be sure to exit as soon as something goes wrong
set -eo pipefail

if [ -z "$TAG_NAME" ]
then
  echo "Missing tag name parameter."
  echo ""
  echo "Usage : $0 <tag_name>"
  exit
fi


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$( dirname $SCRIPT_DIR )

ELM_VERSION_FILE="src/Request/Version.elm"

# Patch old versions of the app so that it gets the version file using relative path
# Otherwise serving the app from /versions will not display the good version number
if [[ -f "$ELM_VERSION_FILE" ]]; then
  sed -i 's/"\/version\.json"/"version\.json"/g' $ELM_VERSION_FILE
fi

npm run build
npm run server:build
cp server-app.js dist/
cp openapi.yaml dist/
