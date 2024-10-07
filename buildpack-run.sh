#!/usr/bin/env bash

git clone git@github.com:MTES-MCT/ecobalyse-private.git

# Scalingo should set the $SOURCE_VERSION variable
./bin/checkout-ecobalyse-private-branch.sh $SOURCE_VERSION

./bin/download_github_releases.py

# Remove big map files from old versions for a slimer scalingo image
find versions/ -type f -name "*.js.map" -delete
find versions/ -type f -name "*.css.map" -delete
