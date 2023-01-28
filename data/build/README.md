# Build json data for ecobalyse

## prerequisite

* Install: Docker, make

## Fastpath

Just: `make json`
In case of trouble, first run `make clean`

## More choice

### Choose one of the two docker images

* `make choice` then press `m` or `j` (or wait 10s and it will select `m` for you)

* If you just want to generate the json data: choose `m`. This is a minimal Debian image with just Brightway installed with pip.
* If you also want to play with Brightway in Jupyter notebooks, choose `j`. This is a more complete image, with Jupyter server and Brightway installed with conda.

### Build the selected docker image

`make`

### Import Agribalyse in Brightway

`make import_agribalyse`

### Export ciqual

`make export_ciqual`

### Export builder

`make export_builder`

### Run Jupyter

If you chose the Jupyter image with `make choice` you can then start the Jupyter server with: `./run.sh`

Then you can connect to it by Ctrl-clicking on the generated passwordless link in the terminal.

### Work in the container

Your ecobalyse checkout on the host is accessible in the container (it's a bind-mount) from : `/home/jovyan/ecobalyse`

All other data generated in `/home/jovyan`, such as Brightway data or Jupyter notebooks are stored in a Docker volume (`/var/lib/docker/volume/jovyan`).

### Clean up

`make clean`

It deletes the docker volume: that is all Brightway data (and Jupyter data if you selected this image)

### Delete the docker image

`make clean_image`

### Notes

If the `export_ciqual` takes many hours, it means that pypardiso and the intel
math kernel (mkl) were not installed correctly or that they don't work on your
architecture. In that case, the default Scipy solver is used and it might
explain the slight difference in the result roundings between the two solvers.

Both docker images use the same versions, use the same solver and provide you with the same output json files.
