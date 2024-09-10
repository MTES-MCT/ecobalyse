#!/bin/bash

ECOBALYSE_ID=$(ls -lnd /home/jovyan/ecobalyse|awk '{print $3}')
JOVYAN_ID=$(id -u jovyan)
export PYTHONPATH=/home/jovyan/ecobalyse/data

if [ $ECOBALYSE_ID -ne $JOVYAN_ID ]; then
    usermod -u $ECOBALYSE_ID jovyan
fi

chown -R 1000:100 "/home/jovyan/.npm"

gosu jovyan "$@"
