set -euo pipefail

ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )
cd $ROOT_DIR

export ENABLE_FOOD_SECTION=False
export ENABLE_OBJECTS_SECTION=False
./bin/build-specific-app-version.sh v1.1.0
./bin/build-specific-app-version.sh v1.1.1
./bin/build-specific-app-version.sh v1.2.0
./bin/build-specific-app-version.sh v1.3.0 3531c73f23a1eb6f1fc6b9c256a5344742230fcf
./bin/build-specific-app-version.sh v1.3.1 3531c73f23a1eb6f1fc6b9c256a5344742230fcf
./bin/build-specific-app-version.sh v1.3.2 3531c73f23a1eb6f1fc6b9c256a5344742230fcf
./bin/build-specific-app-version.sh v2.0.0 e9f43a8bf4a10b6aab3916d2b86aac05056f7029
./bin/build-specific-app-version.sh v2.1.0 e9f43a8bf4a10b6aab3916d2b86aac05056f7029
./bin/build-specific-app-version.sh v2.2.0 4f9d293c79c839e87da01798f7e7b668aed5cb36
./bin/build-specific-app-version.sh v2.3.0 466221b4290fa52812614723302580329b6ca370
./bin/build-specific-app-version.sh v2.4.0 19d7941b2a8c536296b79f22d3058354efea23ee
./bin/build-specific-app-version.sh v2.5.0 703ef7e558df46e210bcba1caf4ac860a5b8c129
./bin/build-specific-app-version.sh v2.6.0 69dc4a693a7e2e76d3d3506dbef5eaf4c5771f81
./bin/build-specific-app-version.sh v2.7.0 83aa9c8f682e1c9bb874bb13d8b6440f568d7922
./bin/build-specific-app-version.sh v2.7.1 83aa9c8f682e1c9bb874bb13d8b6440f568d7922
./bin/build-specific-app-version.sh v3.0.0
./bin/build-specific-app-version.sh v3.1.0
./bin/build-specific-app-version.sh v4.0.1
export ENABLE_FOOD_SECTION=True
./bin/build-specific-app-version.sh v5.0.1
./bin/build-specific-app-version.sh v6.1.1
./bin/build-specific-app-version.sh v7.0.0
