#!/usr/bin/env bash
COMMIT=$1

# Be sure to exit as soon as something goes wrong
set -eo pipefail

if [ -z "$COMMIT" ]
then
  echo "Missing commit hash parameter."
  echo ""
  echo "Usage : $0 <commit_hash>"
  exit
fi


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$( dirname $SCRIPT_DIR )
ECOBALYSE_GIT_REPO="https://github.com/MTES-MCT/ecobalyse.git"
VERSION_DIR=$ROOT_DIR/versions/$COMMIT
GIT_CLONE_DIR=$ROOT_DIR/git_build

# Custom error codes
ERR_INVALID_COMMIT=2
ERR_INVALID_COMMAND=3

cd $ROOT_DIR

# Exit everything when this shell exits
trap "exit" INT TERM
trap "cleanup" EXIT

function cleanup() {
  status=$?
  >&2 echo "Cleaning up... (status=$status)"
  children=$(jobs -p)
  if [[ -n "$children" ]]; then
    kill $children ||true
  fi

  exit $status
}

trap 'error_handler $?' ERR

# Function to handle errors
error_handler() {
  case $1 in
    $ERR_INVALID_COMMIT)
      echo ""
      echo "🚨 Unable to git checkout $COMMIT. Are you sure that it's a valid commit hash?"
      ;;
    $ERR_INVALID_COMMAND)
      echo ""
      echo "🚨 You need '$2' to be installed in order to use this script."
      ;;
    *)
      echo ""
      echo "🚨 An unknown error occurred (exit code: $1)."
      ;;
  esac

  echo "-> Exiting."
  exit $1
}


hash git &> /dev/null || error_handler $ERR_INVALID_COMMAND git
hash npm &> /dev/null || error_handler $ERR_INVALID_COMMAND npm

if [ -d $GIT_CLONE_DIR ]; then
  echo "⚠️ Git destination directory exists, deleting."
  echo "-> Deleting '$GIT_CLONE_DIR'."
  rm -rf $GIT_CLONE_DIR
fi

mkdir -p $GIT_CLONE_DIR

echo "-> Cloning $ECOBALYSE_GIT_REPO to $GIT_CLONE_DIR"
echo ""

git clone $ECOBALYSE_GIT_REPO $GIT_CLONE_DIR

cd $GIT_CLONE_DIR

# Use custom error handler to avoid set -eo to be triggred before displaying the error message
git checkout $COMMIT || error_handler $ERR_INVALID_COMMIT

# Installing node stuff
npm install

# Rely on the build command of the version we are on. We should be careful when changing thig build command
# It should always generate a dist/ directory because that's what we are assuming here
npm run build
npm run server:build

cd $ROOT_DIR

# Clean dir if it already exists
if [ -d $VERSION_DIR ]; then
  rm -rf $VERSION_DIR
fi


mkdir -p $VERSION_DIR

npm run encrypt $ECOBALYSE_DATA_DIR/data/textile/processes_impacts.json $GIT_CLONE_DIR/dist/processes_impacts_textile.json.enc
npm run encrypt $ECOBALYSE_DATA_DIR/data/food/processes_impacts.json $GIT_CLONE_DIR/dist/processes_impacts_food.json.enc

mv $GIT_CLONE_DIR/dist/* $VERSION_DIR
mv $GIT_CLONE_DIR/server-app.js $VERSION_DIR
cp $GIT_CLONE_DIR/openapi.yaml $VERSION_DIR
