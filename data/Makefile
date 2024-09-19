SHELL := /bin/bash
NAME := $(shell echo $$PWD|sed 's/\/data//'|sed 's/.*\///')
ECOBALYSE_DATA_DIR := ${ECOBALYSE_DATA_DIR}
JUPYTER_PORT ?= 8888

# Define a DOCKER function
define DOCKER
env | grep ECOBALYSE_DATA_DIR || echo "No ECOBALYSE_DATA_DIR in environment. Consider adding it in .env and run: pipenv shell"
env | grep ECOBALYSE_DATA_DIR || exit
@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
  echo "(Using the existing container)" &&\
	docker exec -u jovyan -it -e ECOBALYSE_DATA_DIR=/home/jovyan/ecobalyse-private/ -w /home/jovyan/ecobalyse/data $(NAME) $(1);\
else \
	echo "(Creating a new container)" &&\
	docker run --rm -it -v $(NAME):/home/jovyan -v $$PWD/../:/home/jovyan/ecobalyse -v $(ECOBALYSE_DATA_DIR):/home/jovyan/ecobalyse-private -e ECOBALYSE_DATA_DIR=/home/jovyan/ecobalyse-private/ -w /home/jovyan/ecobalyse/data $(NAME) $(1); fi
endef

all: import export
import : image import_food import_ecoinvent import_method sync_datapackages
export: export_food format

image:
	docker build -t $(NAME) docker

import_food:
	@$(call DOCKER,python3 import_food.py --recreate-activities)

import_method:
	@$(call DOCKER,python3 import_method.py)

import_ecoinvent:
	@$(call DOCKER,python3 import_ecoinvent.py)

sync_datapackages:
	@$(call DOCKER,python3 common/sync_datapackages.py)

delete_database:
	@$(call DOCKER,python3 common/delete_database.py $(DB))

delete_method:
	@$(call DOCKER,python3 common/delete_methods.py)

export_food:
	@$(call DOCKER,bash -c "python3 food/export.py && npm run processes:build")

compare_food:
	@$(call DOCKER,python3 export.py compare)

format:
	npm run fix:all

python:
	echo Running Python inside the container...
	@$(call DOCKER,python)

shell:
	echo starting a user shell inside the container...
	@$(call DOCKER,bash)

jupyter_password:
	echo starting a user shell inside the container...
	@$(call DOCKER,jupyter notebook password)

start_notebook:
	@docker run --rm -it -d \
    -v $(NAME):/home/jovyan \
    -v $$PWD/../:/home/jovyan/ecobalyse \
    -v $(ECOBALYSE_DATA_DIR):/home/jovyan/ecobalyse-private \
    -e ECOBALYSE_DATA_DIR=/home/jovyan/ecobalyse-private/ \
    -e JUPYTER_PORT=$(JUPYTER_PORT) \
    -e JUPYTER_ENABLE_LAB=yes \
    -w /home/jovyan/ecobalyse/data \
    -p $(JUPYTER_PORT):$(JUPYTER_PORT) \
    --name $(NAME) \
    $(NAME) start-notebook.sh --collaborative
	@docker cp ~/.gitconfig $(NAME):/home/jovyan/
	@docker exec -it -u jovyan $(NAME) \
    bash -c "if [ ! -e ~/.jupyter/jupyter_server_config.json ]; then echo '### Run: you have no Jupyter password. Run: make jupyter_password and restart it.'; fi"

stop_notebook:
	@echo "Stopping Jupyter notebook and container..."
	-@$(call DOCKER,bash -c "pkill jupyter") || true
	-docker stop $(NAME) || echo "Container $(NAME) not running or already stopped."
	@echo "Container $(NAME) has been stopped."

start_bwapi:
	echo starting the Brightway API on port 8000...
	@$(call DOCKER,bash -c "cd /home/jovyan/ecobalyse/data/bwapi; uvicorn --host 0.0.0.0 server:api")

clean_data:
	docker volume rm $(NAME)

clean_image:
	docker image rm $(NAME)

clean: clean_data clean_image
