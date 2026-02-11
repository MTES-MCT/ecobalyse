#!/usr/bin/env bash
COMMIT_OR_TAG=$1
ECOBALYSE_DATA_DIR_COMMIT=$2

# Be sure to exit as soon as something goes wrong
set -eo pipefail

if [ -z "$COMMIT_OR_TAG" ] && [ -z "$BUILD_CURRENT_VERSION" ]
then
  echo "Missing commit hash or tag name parameter."
  echo ""
  echo "Usage: $0 <public_commit_hash> [<data_dir_commit_hash>]"
  exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$( dirname $SCRIPT_DIR )
ECOBALYSE_GIT_REPO="git@github.com:MTES-MCT/ecobalyse.git"
PUBLIC_GIT_CLONE_DIR=$ROOT_DIR/git_build/public

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
      echo "🚨 Unable to git checkout $COMMIT_OR_TAG. Are you sure that it's a valid commit hash or tag?"
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

if [ -z "$BUILD_CURRENT_VERSION" ]; then
  if [ -d $PUBLIC_GIT_CLONE_DIR ]; then
    echo "⚠️ Public Git destination directory exists, deleting."
    echo "-> Deleting '$PUBLIC_GIT_CLONE_DIR'."
    rm -rf $PUBLIC_GIT_CLONE_DIR
  fi

  mkdir -p $PUBLIC_GIT_CLONE_DIR

  echo "-> Cloning $ECOBALYSE_GIT_REPO to $PUBLIC_GIT_CLONE_DIR"
  echo ""

  git clone $ECOBALYSE_GIT_REPO $PUBLIC_GIT_CLONE_DIR

  cd $PUBLIC_GIT_CLONE_DIR

  git checkout $COMMIT_OR_TAG || error_handler $ERR_INVALID_COMMIT
else

  echo "⚠️ Building using the current version."
  PUBLIC_GIT_CLONE_DIR=.
fi

if [ -z "$TRANSCRYPT_KEY" ]; then

  echo ""
  echo "🚨 This version of the application requires a TRANSCRYPT_KEY environment var to be set to be able to decrypt the detailed impacts."
  echo ""
  exit

fi

$ROOT_DIR/bin/run-transcrypt.sh


cd $PUBLIC_GIT_CLONE_DIR

# Installing node stuff
# We need to specify dev as the env to avoid errors with needed dev packages at build time like
# old husky prerequesite
NODE_ENV=development npm ci --ignore-scripts

# We want a production build
export NODE_ENV=production

# Rely on the build command of the version we are on. We should be careful when changing this build command
# It should always generate a dist/ directory because that's what we are assuming here
npm run build
npm run server:build

cd $ROOT_DIR

if [[ -f "$PUBLIC_GIT_CLONE_DIR/public/data/processes_impacts.json" ]]; then
  # New version with all the impacts in the same file
  npm run encrypt $PUBLIC_GIT_CLONE_DIR/public/data/processes_impacts.json $PUBLIC_GIT_CLONE_DIR/dist/processes_impacts.json.enc

  # Never ship detailed impacts
  rm -f -- $PUBLIC_GIT_CLONE_DIR/dist/data/processes_impacts.json
fi

cp $PUBLIC_GIT_CLONE_DIR/server-app.js $PUBLIC_GIT_CLONE_DIR/dist
cp $PUBLIC_GIT_CLONE_DIR/openapi.yaml $PUBLIC_GIT_CLONE_DIR/dist

# Create the dist archive and put it in the ROOT_DIR
cd $PUBLIC_GIT_CLONE_DIR
tar czvf $COMMIT_OR_TAG-dist.tar.gz dist

mv $COMMIT_OR_TAG-dist.tar.gz $ROOT_DIR

echo "✅ $ROOT_DIR/$COMMIT_OR_TAG-dist.tar.gz successfully created"
