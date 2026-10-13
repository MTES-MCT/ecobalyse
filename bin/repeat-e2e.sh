#!/usr/bin/env bash

# Run the e2e tests suite n times and stop at the first failure; useful to test
# for intermittent failures. Eg. to run 80 times the whole e2e test suite:
#
#     ./bin/repeat-e2e.sh 80

set -uo pipefail

if [ "${1:-}" = "" ] || ! [[ "$1" =~ ^[1-9][0-9]*$ ]]; then
  echo "Usage: $0 <times>" >&2
  echo "Example: $0 80" >&2
  exit 1
fi

times="$1"
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

for ((run = 1; run <= times; run++)); do
  echo "🏁 e2e suite run ${run}/${times}"
  if ! npm run test:e2e; then
    echo "🚨 e2e failed on run ${run}/${times}" >&2
    exit 1
  fi
done

echo "✅ e2e passed ${times} time(s)"
