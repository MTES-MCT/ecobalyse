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

  # Use already available key or use the one declared in the repository .env
  TRANSCRYPT_KEY="${TRANSCRYPT_KEY:-$(grep '^TRANSCRYPT_KEY=' "$(dirname "$0")/../.env" 2>/dev/null | cut -d= -f2-)}"

  if [ -z "$TRANSCRYPT_KEY" ]
  then
    echo "ℹ️ TRANSCRYPT_KEY is not set. Detailed impacts stay encrypted; the app will use aggregated impacts."
  else
    if ! transcrypt -d &> /dev/null; then
      transcrypt -y -F -c aes-256-cbc -p "$TRANSCRYPT_KEY"
    else
      echo 'ℹ️ `transcrypt` was already configured for this repo, skipping.'
    fi
  fi

fi
