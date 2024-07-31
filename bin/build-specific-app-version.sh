#!/usr/bin/env bash
COMMIT_OR_TAG=$1
ECOBALYSE_DATA_DIR_COMMIT=$2

# Be sure to exit as soon as something goes wrong
set -eo pipefail

if [ -z "$COMMIT_OR_TAG" ]
then
  echo "Missing commit hash or tag name parameter."
  echo ""
  echo "Usage : $0 <commit_hash_or_tag>"
  exit
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$( dirname $SCRIPT_DIR )
ECOBALYSE_GIT_REPO="git@github.com:MTES-MCT/ecobalyse.git"
ECOBALYSE_DATA_DIR_GIT_REPO="git@github.com:MTES-MCT/ecobalyse-private.git"
VERSION_DIR=$ROOT_DIR/versions/$COMMIT_OR_TAG
GIT_CLONE_DIR=$ROOT_DIR/git_build
PUBLIC_GIT_CLONE_DIR=$ROOT_DIR/git_build/public
DATA_DIR_GIT_CLONE_DIR=$ROOT_DIR/git_build/private

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

if git rev-parse "$COMMIT_OR_TAG" >/dev/null 2>&1; then
  # Tag exists
  # Use custom error handler to avoid set -eo to be triggred before displaying the error message
  git checkout tags/$COMMIT_OR_TAG || error_handler $ERR_INVALID_COMMIT
else
  # Tag doesn't exist
  git checkout $COMMIT_OR_TAG || error_handler $ERR_INVALID_COMMIT
fi


# Check if detailed impacts are present in the directory, if not an ECOBALYSE_DATA_DIR env variable need to be set
# and a commit hash for the private repo specified

TEXTILE_DETAILED_IMPACTS_FILE="$PUBLIC_GIT_CLONE_DIR/public/data/textile/processes_impacts.json"
FOOD_DETAILED_IMPACTS_FILE="$PUBLIC_GIT_CLONE_DIR/public/data/textile/processes_impacts.json"


if [[ ! -f "$TEXTILE_DETAILED_IMPACTS_FILE" ]]; then

  if [ -z "$ECOBALYSE_DATA_DIR_COMMIT" ]; then
    echo ""
    echo "🚨 This version of the application requires data files from the Ecobalyse data dir. You need to specify the ECOBALYSE_DATA_DIR_COMMIT as a second parameter."
    echo "   The corresponding data dir version will be cloned locally."
    echo ""
    echo "Usage : $0 <public_commit_hash> <data_dir_commit_hash>"
    echo ""
    exit
  fi

  TEXTILE_DETAILED_IMPACTS_FILE="$DATA_DIR_GIT_CLONE_DIR/data/textile/processes_impacts.json"
  FOOD_DETAILED_IMPACTS_FILE="$DATA_DIR_GIT_CLONE_DIR/data/textile/processes_impacts.json"


  if [ -d $DATA_DIR_GIT_CLONE_DIR ]; then
    echo "⚠️ Data dir Git destination directory exists, deleting."
    echo "-> Deleting '$DATA_DIR_GIT_CLONE_DIR'."
    rm -rf $DATA_DIR_GIT_CLONE_DIR
  fi

  mkdir -p $DATA_DIR_GIT_CLONE_DIR

  echo "-> Cloning $ECOBALYSE_DATA_DIR_GIT_REPO to $DATA_DIR_GIT_CLONE_DIR"
  echo ""

  git clone $ECOBALYSE_DATA_DIR_GIT_REPO $DATA_DIR_GIT_CLONE_DIR

  cd $DATA_DIR_GIT_CLONE_DIR

  # Use custom error handler to avoid set -eo to be triggred before displaying the error message
  git checkout $ECOBALYSE_DATA_DIR_COMMIT || error_handler $ERR_INVALID_COMMIT

  cp $DATA_DIR_GIT_CLONE_DIR/data/textile/processes_impacts.json $PUBLIC_GIT_CLONE_DIR/public/data/textile/processes_impacts.json
  cp $DATA_DIR_GIT_CLONE_DIR/data/food/processes_impacts.json $PUBLIC_GIT_CLONE_DIR/public/data/food/processes_impacts.json

  export ECOBALYSE_DATA_DIR=$DATA_DIR_GIT_CLONE_DIR
fi

cd $PUBLIC_GIT_CLONE_DIR

# Installing node stuff
# We need to specify dev as the env to avoid errors with needed dev packages at build time like
# old husky prerequesite
NODE_ENV=dev npm ci

# We want a production build
export NODE_ENV=production

ELM_VERSION_FILE="src/Request/Version.elm"

# Patch old versions of the app so that it gets the version file using relative path
# Otherwise serving the app from /versions will not display the good version number
if [[ -f "$ELM_VERSION_FILE" ]]; then
  sed -i 's/"\/version\.json"/"version\.json"/g' $ELM_VERSION_FILE
fi

# Rely on the build command of the version we are on. We should be careful when changing this build command
# It should always generate a dist/ directory because that's what we are assuming here
npm run build
npm run server:build

# If a data dir commit was specified, put it in the version file if needed
# it will to keep track of the commit used to build the version
if [[ ! -z "$ECOBALYSE_DATA_DIR_COMMIT" ]]; then
  if grep dataDirHash dist/version.json >/dev/null 2>&1; then
    # version file is up to date, don't do anything
    echo "-> dataDirHash already in version.json, skipping."
  else
    # version file is missing the dataDirHash parameter (old version of the app, before 2.0.0)
    # patch the file to add it
    sed -i "s/}/, \"dataDirHash\": \"$ECOBALYSE_DATA_DIR_COMMIT\"}/" dist/version.json
  fi
fi

cd $ROOT_DIR

# Clean dir for specific commit if it already exists
if [ -d $VERSION_DIR ]; then
  rm -rf $VERSION_DIR
fi

mkdir -p $VERSION_DIR

npm run encrypt $PUBLIC_GIT_CLONE_DIR/public/data/textile/processes_impacts.json $PUBLIC_GIT_CLONE_DIR/dist/processes_impacts_textile.json.enc
npm run encrypt $PUBLIC_GIT_CLONE_DIR/public/data/food/processes_impacts.json $PUBLIC_GIT_CLONE_DIR/dist/processes_impacts_food.json.enc


mv $PUBLIC_GIT_CLONE_DIR/dist/* $VERSION_DIR
mv $PUBLIC_GIT_CLONE_DIR/server-app.js $VERSION_DIR
cp $PUBLIC_GIT_CLONE_DIR/openapi.yaml $VERSION_DIR
# Never ship detailed impacts
rm -f -- $VERSION_DIR/data/textile/processes_impacts.json
rm -f -- $VERSION_DIR/data/food/processes_impacts.json
