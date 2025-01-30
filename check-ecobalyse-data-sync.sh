#!/bin/bash
set -euo pipefail

# Directory where ecobalyse-data will be cloned
TEMP_DIR=$(mktemp -d)
ECOBALYSE_DATA_REPO="https://github.com/MTES-MCT/ecobalyse-data.git"
ECOBALYSE_DATA_BRANCH="${ECOBALYSE_DATA_BRANCH:-main}"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Clone ecobalyse-data repository
echo "Cloning ecobalyse-data repository (branch: ${ECOBALYSE_DATA_BRANCH})..."
git clone -q -b "${ECOBALYSE_DATA_BRANCH}" "$ECOBALYSE_DATA_REPO" "$TEMP_DIR"

# Files to check
FILES=(
    "public/data/food/ingredients.json"
    "public/data/food/processes.json"
    "public/data/textile/materials.json"
    "public/data/textile/processes.json"
    "public/data/object/processes.json"
)

# Compare specified JSON files
echo "Comparing JSON files between ecobalyse-data and ecobalyse repositories..."
DIFFERENCES_FOUND=0

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
