#!/bin/bash

ECOBALYSE_ID=$(ls -lnd /home/jovyan/ecobalyse|awk '{print $3}')
JOVYAN_ID=$(id -u jovyan)

if [ $ECOBALYSE_ID -ne $JOVYAN_ID ]; then 
    usermod -u $ECOBALYSE_ID jovyan
fi

pushd /home/jovyan/ecobalyse/data
pip install -e .
popd

ldconfig

gosu jovyan "$@"
