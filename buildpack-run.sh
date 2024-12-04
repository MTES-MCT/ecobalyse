#!/usr/bin/env bash

echo "-> Install 'transcrypt' to /usr/local/bin"

mkdir -p "$PWD/.local/bin"
export PATH="$PWD/.local/bin":$PATH
wget https://raw.githubusercontent.com/elasticdog/transcrypt/refs/heads/main/transcrypt -O "$PWD/.local/bin/transcrypt"
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
transcrypt -y -c aes-256-cbc -p $TRANSCRYPT_KEY
cp -f public/data/food/processes_impacts.json ../public/data/food/
cp -f public/data/object/processes_impacts.json ../public/data/object/
cp -f public/data/textile/processes_impacts.json ../public/data/textile/
cd ..

echo "-> Removing 'ecobalyse' directory"
rm -rf ecobalyse

./bin/download_github_releases.py

# Remove big map files from old versions for a slimer scalingo image
find versions/ -type f -name "*.js.map" -delete
find versions/ -type f -name "*.css.map" -delete
