#/bin/bash

bin/run &
pushd data/ecobalyse
gunicorn ecobalyse.wsgi &
sleep 0.5
trap "pkill SIGTERM -P $$" SIGTERM
popd

npm run server:start &
trap "pkill SIGTERM -P $$" SIGTERM

wait -n

pkill -P $$
