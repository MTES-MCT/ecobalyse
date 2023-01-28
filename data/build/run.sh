#!/bin/bash

docker run --name brightway2 --rm -it -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v $PWD/../../:/home/jovyan/ecobalyse -v jovyan:/home/jovyan brightway2-jupyter
