#!/usr/bin/env bash
ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)
cd "$ROOT_DIR"

# start jobs and remember their PIDs
npm run server:start & SERVER_PID=$!
bin/run             & NGINX_PID=$!

# on SIGTERM kill the children we started
trap 'kill -TERM "$SERVER_PID" "$NGINX_PID"' SIGTERM

# wait for the first job to finish
wait -n

# kill the remaining job(s)
kill -TERM "$SERVER_PID" "$NGINX_PID" 2>/dev/null
wait
