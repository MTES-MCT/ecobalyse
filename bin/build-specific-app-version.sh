#!/usr/bin/env bash
COMMIT_OR_TAG=$1
ECOBALYSE_DATA_DIR_COMMIT=$2

# Be sure to exit as soon as something goes wrong
set -eo pipefail

if [ -z "$COMMIT_OR_TAG" ]
then
  echo "Missing commit hash or tag name parameter."
  echo ""
  echo "Usage: $0 <public_commit_hash> [<data_dir_commit_hash>]"
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
  TAG=$COMMIT_OR_TAG
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
    echo "Usage: $0 <public_commit_hash> <data_dir_commit_hash>"
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

ELM_VERSION_FILE=$PUBLIC_GIT_CLONE_DIR"/src/Request/Version.elm"
INDEX_JS_FILE=$PUBLIC_GIT_CLONE_DIR"/index.js"

# Patch old versions of the app so that it gets the version file using relative path in Elm
# Otherwise serving the app from /versions will not display the good version number
# Also patch the local storage key to avoid messing things up between versions
$ROOT_DIR/bin/patch_files_for_versions_compat.py elm-version $ELM_VERSION_FILE
$ROOT_DIR/bin/patch_files_for_versions_compat.py local-storage-key $INDEX_JS_FILE $COMMIT_OR_TAG
$ROOT_DIR/bin/patch_files_for_versions_compat.py version-selector $ROOT_DIR/packages/python/ecobalyse/ecobalyse/0001-feat-patch-homepage-link-and-inject-and-inject-versi.patch $PUBLIC_GIT_CLONE_DIR

cd $PUBLIC_GIT_CLONE_DIR

# Installing node stuff
# We need to specify dev as the env to avoid errors with needed dev packages at build time like
# old husky prerequesite
NODE_ENV=development npm ci

# We want a production build
export NODE_ENV=production

# Rely on the build command of the version we are on. We should be careful when changing this build command
# It should always generate a dist/ directory because that's what we are assuming here
npm run build
npm run server:build

# Always put the tag name in the version.json file to help debugging if needed later on
# If TAG is defined
if [[ ! -z "$TAG" ]]; then
  $ROOT_DIR/bin/patch_files_for_versions_compat.py add-entry-to-version dist/version.json tag $TAG
fi


# If a data dir commit was specified, put it in the version file if needed
# it will to keep track of the commit used to build the version
if [[ ! -z "$ECOBALYSE_DATA_DIR_COMMIT" ]]; then
  $ROOT_DIR/bin/patch_files_for_versions_compat.py add-entry-to-version dist/version.json dataDirHash $ECOBALYSE_DATA_DIR_COMMIT

fi

# We need to send the referer to python in order to properly redirect after login
# so we need to patch the html files that don't have it
$ROOT_DIR/bin/patch_files_for_versions_compat.py patch-cross-origin dist/index.html

cd $ROOT_DIR

# Clean dir for specific commit if it already exists
if [ -d $VERSION_DIR ]; then
  rm -rf $VERSION_DIR
fi

mkdir -p $VERSION_DIR

npm run encrypt $PUBLIC_GIT_CLONE_DIR/public/data/textile/processes_impacts.json $PUBLIC_GIT_CLONE_DIR/dist/processes_impacts_textile.json.enc
npm run encrypt $PUBLIC_GIT_CLONE_DIR/public/data/food/processes_impacts.json $PUBLIC_GIT_CLONE_DIR/dist/processes_impacts_food.json.enc

# Never ship detailed impacts
rm -f -- $PUBLIC_GIT_CLONE_DIR/data/textile/processes_impacts.json
rm -f -- $PUBLIC_GIT_CLONE_DIR/data/food/processes_impacts.json

mv $PUBLIC_GIT_CLONE_DIR/server-app.js $PUBLIC_GIT_CLONE_DIR/dist
mv $PUBLIC_GIT_CLONE_DIR/openapi.yaml $PUBLIC_GIT_CLONE_DIR/dist

# Create the dist archive and put it in the ROOT_DIR
cd $PUBLIC_GIT_CLONE_DIR
tar czvf $VERSION_DIR-dist.tar.gz dist
mv $VERSION_DIR-dist.tar.gz $ROOT_DIR/

# Move the standalone app into the version directory
mv $PUBLIC_GIT_CLONE_DIR/dist/* $VERSION_DIR
