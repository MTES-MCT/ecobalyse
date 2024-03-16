#/bin/bash

# run all three tasks in the background
bin/run &
pushd data/ecobalyse

# warning: temporary reinit of the application with a local sqlite
data/ecobalyse/reinit.sh
#

gunicorn -b 127.0.0.1:8002 ecobalyse.wsgi &
popd
npm run server:start &

# if the current shell is killed, also terminate all its children
trap "echo pkill SIGTERM -P $$" SIGTERM

# wait for a single child to finish,
wait -n
# then kill all the other tasks
pkill -P $$
