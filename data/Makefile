SHELL := /bin/bash
NAME := $(shell echo $$PWD|sed 's/\/data//'|sed 's/.*\///')
ECOBALYSE_DATA_DIR := ${ECOBALYSE_DATA_DIR}
DOCKERRUN := echo "(Creating a new container)" && docker run --rm -it -v $$PWD/../:/home/jovyan/ecobalyse -v $(ECOBALYSE_DATA_DIR):/home/jovyan/ecobalyse-private -v $(NAME):/home/jovyan -e ECOBALYSE_DATA_DIR=/home/jovyan/ecobalyse-private/
DOCKEREXEC := echo "(Using the existing container)" && docker exec -u jovyan -it -e ECOBALYSE_DATA_DIR=/home/jovyan/ecobalyse-private/
JUPYTER_PORT ?= 8888

# Define a DOCKER function
define DOCKER
@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
	$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data $(NAME) $(1);\
else \
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) $(1); fi
endef

all: import export
import : image import_agribalyse import_ecoinvent import_method sync_datapackages
export: export_food format

image:
	docker build -t $(NAME) docker

import_agribalyse:
	$(call DOCKER,python3 import_agribalyse.py --recreate-activities)

import_method:
	$(call DOCKER,python3 import_method.py)

import_ecoinvent:
	$(call DOCKER,python3 import_ecoinvent.py)

sync_datapackages:
	$(call DOCKER,python3 common/sync_datapackages.py)

delete_database:
	$(call DOCKER,python3 common/delete_database.py $(DB))

delete_method:
	$(call DOCKER,python3 common/delete_methods.py)

export_food:
	$(call DOCKER,bash -c "python3 export.py && npm run processes:build")

compare_food:
	$(call DOCKER,python3 export.py compare)

format:
	npm run format:json

python:
	echo Running Python inside the container...
	$(call DOCKER,python)

root_shell:
	echo starting a root shell inside the container...
	$(call DOCKER,bash)

shell:
	echo starting a user shell inside the container...
	$(call DOCKER,bash)

jupyter_password:
	echo starting a user shell inside the container...
	$(call DOCKER,jupyter notebook password)

start_notebook:
	$(DOCKERRUN) -d --name $(NAME) -p $(JUPYTER_PORT):$(JUPYTER_PORT) -e JUPYTER_PORT=$(JUPYTER_PORT) -e JUPYTER_ENABLE_LAB=yes $(NAME) start-notebook.sh --collaborative
	docker cp ~/.gitconfig $(NAME):/home/jovyan/
	$(DOCKERRUN) $(NAME) bash -c "test -e ~/.jupyter/jupyter_notebook_config.json" || echo '### Run: `make jupyter_password` before starting to change the jupyter password.'

stop_notebook:
	@echo "Stopping Jupyter notebook and container..."
	-@$(call DOCKER,bash -c "pkill jupyter") || true
	-docker stop $(NAME) || echo "Container $(NAME) not running or already stopped."
	@echo "Container $(NAME) has been stopped."

start_bwapi:
	echo starting the Brightway API on port 8000...
	$(call DOCKER,bash -c "cd /home/jovyan/ecobalyse/data/bwapi; uvicorn --host 0.0.0.0 server:api")

clean_data:
	docker volume rm $(NAME)

clean_image:
	docker image rm $(NAME)

clean: clean_data clean_image

