#!/bin/sh

# On scalingo we don't have a git repository, but we have a SOURCE_VERSION env var
HASH=${SOURCE_VERSION:-`git rev-parse HEAD`}

echo "{\"hash\": \"$HASH\"}" > public/version.json
