#!/usr/bin/env bash

# Be sure to exit as soon as something goes wrong
set -eo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$( dirname $SCRIPT_DIR )
ECOBALYSE_GIT_REPO="MTES-MCT/ecobalyse"
#ECOBALYSE_GIT_REPO="vjousse/pomodorolm"
BASE_VERSION_DIR=$ROOT_DIR/versions

mkdir -p $BASE_VERSION_DIR

ARCHIVE_FILE_NAME_TEMPLATE="TAG-dist.tar.gz"
DOWNLOAD_URL_TEMPLATE="https://github.com/$ECOBALYSE_GIT_REPO/releases/download/TAG/$ARCHIVE_FILE_NAME_TEMPLATE"


TAGS=$(curl -sSL \
  https://api.github.com/repos/MTES-MCT/ecobalyse/releases \
  | grep tag_name \
  | sed 's/ //g; s/"//g; s/,//' \
  | cut -d':' -f 2)


while IFS= read -r TAG; do

  DOWNLOAD_URL="${DOWNLOAD_URL_TEMPLATE//TAG/"$TAG"}"
  ARCHIVE_FILE_NAME="${ARCHIVE_FILE_NAME_TEMPLATE//TAG/"$TAG"}"
  VERSION_DIR=$BASE_VERSION_DIR/$TAG


  if [ -d $VERSION_DIR ]; then
    echo "⚠️ Version $TAG destination directory exists, deleting."
    echo "-> Deleting '$VERSION_DIR'."
    rm -rf $VERSION_DIR
  fi

  mkdir -p $VERSION_DIR

  cd $BASE_VERSION_DIR

  curl -sSLO $DOWNLOAD_URL

  echo "-> Extracting archive to '$VERSION_DIR'."
  tar xzf $ARCHIVE_FILE_NAME

  mv dist/* $VERSION_DIR
  rm -rf dist
  rm $ARCHIVE_FILE_NAME

done <<< "$TAGS"
