#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$( dirname $SCRIPT_DIR )

cd $ROOT_DIR

mkdir -p versions
rm -rf ./versions/test_build

export BUILD_CURRENT_VERSION=1
./bin/build-specific-app-version.sh test_build

cd versions
tar -xzf ../test_build-dist.tar.gz --strip-components=1 -C test_build dist/
rm ../test_build-dist.tar.gz

