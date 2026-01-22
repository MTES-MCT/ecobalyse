#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$( dirname $SCRIPT_DIR )

cd $ROOT_DIR

mkdir -p versions
rm -rf ./versions/v7.0.0

export BUILD_CURRENT_VERSION=1
./bin/build-specific-app-version.sh v7.0.0

cd versions
tar -xzf ../v7.0.0-dist.tar.gz --strip-components=1 -C v7.0.0 dist/
rm ../v7.0.0-dist.tar.gz
