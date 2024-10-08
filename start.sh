#/bin/bash

# run all three tasks in the background

# express
npm run server:start &

# django
pushd backend
./update.sh
python manage.py collectstatic --noinput
gunicorn -b 127.0.0.1:8002 backend.wsgi &
popd

# nginx
bin/run &

# if the current shell is killed, also terminate all its children
trap "pkill SIGTERM -P $$" SIGTERM

# wait for a single child to finish,
wait -n
# then kill all the other tasks
pkill -P $$
