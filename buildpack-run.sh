#!/usr/bin/env bash


echo "-> Install 'transcrypt' to /usr/local/bin"

mkdir -p "$PWD/.local/bin"
export PATH="$PWD/.local/bin":$PATH
wget https://raw.githubusercontent.com/elasticdog/transcrypt/016b2e4b31951be5ea96233d8d2badef9c9836b6/transcrypt -O "$PWD/.local/bin/transcrypt"
chmod +x "$PWD/.local/bin/transcrypt"
echo "PATH: $PATH"

echo "-> Cloning 'ecobalyse' public repo at $SOURCE_VERSION"
mkdir ecobalyse
cd ecobalyse
# Trick to avoid cloning the whole repo
# Instead, only fetch the current commit
git init
git remote add origin https://github.com/MTES-MCT/ecobalyse.git
# depth=1 as we don't need the history
git fetch --depth 1 origin $SOURCE_VERSION
git checkout FETCH_HEAD

echo "-> Decrypt detailed impacts"

# Here we force the decrypt of the files. $SOURCE_VERSION is set
# but as we are into the clone repository by hand, we have a .git repo
# and can safely use transcrypt inside
./bin/run-transcrypt.sh force

cp -f public/data/processes_impacts.json ../public/data/
cd ..

echo "-> Removing 'ecobalyse' directory"
rm -rf ecobalyse


echo "-> Install 'uv' and create 'requirements.txt'"
curl -LsSf https://astral.sh/uv/install.sh | sh

uv run ./bin/download_github_releases.py

# Remove big map files from old versions for a slimer scalingo image
find versions/ -type f -name "*.js.map" -delete
find versions/ -type f -name "*.css.map" -delete
