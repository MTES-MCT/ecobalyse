#!/bin/bash
set -euo pipefail

# Directory where files will be downloaded
TEMP_DIR=$(mktemp -d)
ECOBALYSE_DATA_BRANCH="${ECOBALYSE_DATA_BRANCH:-main}"
ECOBALYSE_DATA_REPO="${ECOBALYSE_DATA_REPO:-MTES-MCT/ecobalyse-data}"
RAW_GITHUB_URL="https://raw.githubusercontent.com/${ECOBALYSE_DATA_REPO}/${ECOBALYSE_DATA_BRANCH}"
DIFFERENCES_FOUND=0

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Files to check
FILES=(
    "public/data/food/ingredients.json"
    "public/data/textile/materials.json"
    "public/data/processes.json"
)

echo "Downloading files from ecobalyse-data repository (branch: ${ECOBALYSE_DATA_BRANCH})..."

# Create necessary directories in TEMP_DIR
for file in "${FILES[@]}"; do
    mkdir -p "$TEMP_DIR/$(dirname "$file")"
done

# Download each file
for file in "${FILES[@]}"; do
    curl -s "$RAW_GITHUB_URL/$file" -o "$TEMP_DIR/$file" || {
        echo "--⚠️  Failed to download $file from ecobalyse-data repository"
        continue
    }
done

echo "Comparing JSON files between ecobalyse-data and ecobalyse repositories..."

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        other_file="$TEMP_DIR/$file"

        if [ -f "$other_file" ]; then
            # Compare files and store the diff output
            diff_output=$(diff -u "$file" "$other_file" || true)
            if [ -n "$diff_output" ]; then
                echo "--❌ $file is different:"
                echo "$diff_output"
                DIFFERENCES_FOUND=1
            else
                echo "--✅ $file is synchronized"
            fi
        else
            echo "--⚠️  $file does not exist in ecobalyse-data repository"
            DIFFERENCES_FOUND=1
        fi
    else
        echo "--⚠️  $file does not exist in ecobalyse repository"
        DIFFERENCES_FOUND=1
    fi
done

if [ $DIFFERENCES_FOUND -eq 1 ]; then
    echo "❌ Differences found between repositories ecobalyse-data and ecobalyse"
    exit 1
else
    echo "✅ All JSON files are synchronized"
    exit 0
fi
