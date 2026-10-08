#!/usr/bin/env bash

# If $SOURCE_VERSION is set, we are building on Scalingo with npm
# so we should not decrypt the file.
# On scalingo, we don't have a git repo, so decrypting is handled
# differently in `buildpack-run.sh`
#
# If we set the first parameter to "force", don't take into account the
# $SOURCE_VERSION variable
if [ -z "$SOURCE_VERSION" ] || [ "$1" == "force" ]
then

  if [ -z "$TRANSCRYPT_KEY" ]
  then
    # attempt reading from .env file at the root of the repo
    TRANSCRYPT_KEY="$(grep '^TRANSCRYPT_KEY=' "$(dirname "$0")/../.env" | cut -d= -f2-)"
  fi

  if [ -z "$TRANSCRYPT_KEY" ]
  then
    echo "🚨 Error: TRANSCRYPT_KEY must be set in the environment or in the .env file to decode encrypted files."
    echo "-> Exiting"
    exit 1
  fi

  if ! transcrypt -d &> /dev/null; then
    transcrypt -y -F -c aes-256-cbc -p "$TRANSCRYPT_KEY"
  else
    echo 'ℹ️ `transcrypt` was already configured for this repo, skipping.'
  fi

fi
