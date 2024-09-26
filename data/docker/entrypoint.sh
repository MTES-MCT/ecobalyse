#!/bin/bash

ECOBALYSE_ID=$(ls -lnd /home/jovyan/ecobalyse|awk '{print $3}')
JOVYAN_ID=$(id -u jovyan)
export PYTHONPATH=/home/jovyan/ecobalyse/data

if [ $ECOBALYSE_ID -ne $JOVYAN_ID ]; then
    usermod -u $ECOBALYSE_ID jovyan
fi

# Ensure .npm directory is owned by jovyan
mkdir -p /home/jovyan/.npm
chown -R jovyan:100 "/home/jovyan/.npm"

# Clear npm cache
su jovyan -c "npm cache clean --force"

exec gosu jovyan "$@"
