#!/usr/bin/env bash

COMMIT=$1

# Be sure to exit as soon as something goes wrong
set -eo pipefail

if [ -z "$COMMIT" ]
then
  echo "Missing commit hash parameter. You should provide a commit belonging to the PR you want to check."
  echo ""
  echo "Usage : $0 <commit_hash>"
  exit
fi


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$( dirname $SCRIPT_DIR )

export PYTHONPATH="$ROOT_DIR:$PYTHONPATH"

cd $ROOT_DIR

DATA_BRANCH_NAME=$(./bin/extract_data_branch_from_pr.py $COMMIT)

if [ ! -d ecobalyse-private ]; then
  echo "No ecobalyse-private directory found. You need to clone the private repository first."
  exit 1;
fi

if [ ! -z $DATA_BRANCH_NAME ]; then
  cd ecobalyse-private
  echo "-> Checkout branch $DATA_BRANCH_NAME of ecobalyse-private"
  git checkout $DATA_BRANCH_NAME
  cd ..
else
  echo "-> No specific ecobalyse-data branch found for $COMMIT. Using main."
fi
