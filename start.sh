#/bin/bash

# run all three tasks in the background

# express
npm run server:start &


pushd backend
uv run backend database upgrade --no-prompt
uv run backend run &
popd

# nginx
bin/run &

# if the current shell is killed, also terminate all its children
trap "pkill SIGTERM -P $$" SIGTERM

# wait for a single child to finish,
wait -n
# then kill all the other tasks
pkill -P $$
