#!/usr/bin/env bash

git clone git@github.com:MTES-MCT/ecobalyse-private.git

# Scalingo should set the $SOURCE_VERSION variable
DATA_BRANCH_NAME=$(./bin/extract-data-branch-from-pr.sh $SOURCE_VERSION)

if [ ! -z $DATA_BRANCH_NAME ]; then
  cd ecobalyse-private
  echo "-> Checkout branch $DATA_BRANCH_NAME of ecobalyse-private"
  git checkout $DATA_BRANCH_NAME && git pull
  cd ..
else
  echo "-> No specific ecobalyse-data branch found for $SOURCE_VERSION. Using master."
fi
