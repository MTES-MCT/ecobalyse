#!/usr/bin/env bash

ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )
cd $ROOT_DIR

if [ "$IS_REVIEW_APP" == "true" ]; then
   echo "-> In review app, resetting DB";
   uv run backend database drop-all --no-prompt
   uv run backend database upgrade --no-prompt
fi

# Test if variable is set
if test -n "${BACKEND_ADMINS:+x}"; then
 IFS=',' read -ra ADDR <<< "$BACKEND_ADMINS"
 for entry in "${ADDR[@]}"; do
   IFS='/' read -r email first_name last_name <<< "$entry"
   uv run backend users create-user --email "$email" --first-name "$first_name" --last-name "$last_name" --organization "Ecobalyse" --superuser
 done
fi
