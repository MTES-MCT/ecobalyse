#!/usr/bin/env bash

ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )
cd $ROOT_DIR

# run all three tasks in the background

# express
npm run server:start &

npm run start:backend &

# nginx
bin/run &

# if the current shell is killed, also terminate all its children
trap "pkill SIGTERM -P $$" SIGTERM

# wait for a single child to finish,
wait -n
# then kill all the other tasks
pkill -P $$
