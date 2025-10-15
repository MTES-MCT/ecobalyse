#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$( dirname $SCRIPT_DIR )

cd $ROOT_DIR

mkdir -p versions
rm -rf ./versions/v0.0.1

export BUILD_CURRENT_VERSION=1
./bin/build-specific-app-version.sh v0.0.1

cd versions
tar -xzf ../v0.0.1-dist.tar.gz --strip-components=1 -C v0.0.1 dist/
rm ../v0.0.1-dist.tar.gz
