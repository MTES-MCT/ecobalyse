#/bin/bash

bin/run &
pushd data/ecobalyse
gunicorn -b 127.0.0.1:8002 ecobalyse.wsgi &
popd
npm run server:start &

trap "pkill SIGTERM -P $$" SIGTERM
wait -n
pkill -P $$
