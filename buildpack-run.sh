#!/usr/bin/env bash

git clone git@github.com:MTES-MCT/ecobalyse-private.git

# Scalingo should set the $SOURCE_VERSION variable
./bin/checkout-ecobalyse-private-branch.sh $SOURCE_VERSION

./bin/download-github-releases.sh
