#!/usr/bin/env bash

git clone git@github.com:MTES-MCT/ecobalyse-private.git

# Hack to deploy the hotfix here https://github.com/MTES-MCT/ecobalyse/pull/851
# As he current `ecobalyse-private` repo is not compatible anymore with the code
# of the 2.7.0
cd ecobalyse-private
git checkout 83aa9c8f682e1c9bb874bb13d8b6440f568d7922
cd ..
# Scalingo should set the $SOURCE_VERSION variable
# ./bin/checkout-ecobalyse-private-branch.sh $SOURCE_VERSION

./bin/download_github_releases.py

# Remove big map files from old versions for a slimer scalingo image
find versions/ -type f -name "*.js.map" -delete
find versions/ -type f -name "*.css.map" -delete
