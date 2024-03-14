#/bin/bash

bin/run &
python data/ecobalyse/manage.py runserver &
trap "pkill SIGTERM -P $$" SIGTERM

npm run server:start &
trap "pkill SIGTERM -P $$" SIGTERM

wait -n

pkill -P $$
