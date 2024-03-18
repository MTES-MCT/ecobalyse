#/bin/bash

# run all three tasks in the background

# express
npm run server:start &

# django
pushd data/ecobalyse
./reinit.sh # warning: temporary reinit of the application with a local sqlite
python manage.py collectstatic --noinput
gunicorn -b 127.0.0.1:8002 ecobalyse.wsgi &
popd

# nginx
bin/run &

# if the current shell is killed, also terminate all its children
trap "pkill SIGTERM -P $$" SIGTERM

# wait for a single child to finish,
wait -n
# then kill all the other tasks
pkill -P $$
