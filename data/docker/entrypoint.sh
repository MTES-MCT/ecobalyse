#!/bin/bash

ECOBALYSE_ID=$(ls -lnd /home/jovyan/ecobalyse|awk '{print $3}')
JOVYAN_ID=$(id -u jovyan)

chown -R 1000:100 "/home/jovyan/.cache"
if [ $ECOBALYSE_ID -ne $JOVYAN_ID ]; then
    usermod -u $ECOBALYSE_ID jovyan
fi

pushd /home/jovyan/${ECOBALYSE:=ecobalyse}/data
pip install -e .
popd

ldconfig
chown -R 1000:100 "/home/jovyan/.npm"

gosu jovyan "$@"
