SHELL := /bin/bash
NAME := $(shell echo $$PWD|sed 's/\/data//'|sed 's/.*\///')
ECOBALYSE_DATA_DIR := ${ECOBALYSE_DATA_DIR}
DOCKERRUN := echo "(Creating a new container)" && docker run --rm -it -v $$PWD/../:/home/jovyan/ecobalyse -v $(ECOBALYSE_DATA_DIR):/home/jovyan/ecobalyse-private -v $(NAME):/home/jovyan -e ECOBALYSE_DATA_DIR=/home/jovyan/ecobalyse-private/
DOCKEREXEC := echo "(Using the existing container)" && docker exec -u jovyan -it -e ECOBALYSE_DATA_DIR=/home/jovyan/ecobalyse-private/
JUPYTER_PORT ?= 8888

all: import export
import : image import_agribalyse import_ecoinvent import_method sync_datapackages
export: export_food format

image:
	docker build -t $(NAME) docker

import_agribalyse:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_agribalyse.py --recreate-activities;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_agribalyse.py; fi

import_method:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_method.py;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_method.py; fi

import_ecoinvent:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_ecoinvent.py;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_ecoinvent.py; fi

sync_datapackages:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data $(NAME) python3 common/sync_datapackages.py;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python3 common/sync_datapackages.py; fi

delete_database:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data $(NAME) python3 common/delete_database.py $(DB);\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python3 common/delete_database.py $(DB); fi

delete_method:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data $(NAME) python3 common/delete_methods.py;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python3 common/delete_method.py; fi

export_food:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
                $(DOCKEREXEC) -w /home/jovyan/ecobalyse/data/food $(NAME) python3 export.py && \
                $(DOCKEREXEC) -w /home/jovyan/ecobalyse/data/food $(NAME) npm run processes:build; \
        else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food $(NAME) python3 export.py && \
                $(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food $(NAME) npm run processes:build; fi

compare_food:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
                $(DOCKEREXEC) -w /home/jovyan/ecobalyse/data/food $(NAME) python3 export.py compare; \
        else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food $(NAME) python3 export.py compare; fi

format:
	npm run format:json

#export_textile:
#	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
#		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data/textile $(NAME) python3 export.py;\
#	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data/textile $(NAME) python3 export.py; fi

python:
	echo Running Python inside the container...
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) $(NAME) python;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python; fi

root_shell:
	echo starting a root shell inside the container...
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -u root $(NAME) bash;\
	else $(DOCKERRUN) -u root -w /home/jovyan/ecobalyse/data $(NAME) bash; fi

shell:
	echo starting a user shell inside the container...
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) $(NAME) bash;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) bash; fi

jupyter_password:
	echo starting a user shell inside the container...
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) $(NAME) jupyter notebook password;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) jupyter notebook password; fi

start_notebook:
	$(DOCKERRUN) -d --name $(NAME) -p $(JUPYTER_PORT):$(JUPYTER_PORT) -e JUPYTER_PORT=$(JUPYTER_PORT) -e JUPYTER_ENABLE_LAB=yes $(NAME) start-notebook.sh --collaborative
	docker cp ~/.gitconfig $(NAME):/home/jovyan/
	$(DOCKERRUN) $(NAME) bash -c "test -e ~/.jupyter/jupyter_notebook_config.json" || echo '### Run: `make jupyter_password` before starting to change the jupyter password.'

stop_notebook:
	@echo "Stopping Jupyter notebook and container..."
	@# Kill the Jupyter process inside the container (if specifically needed)
	-@$(DOCKEREXEC) $(NAME) bash -c "pkill jupyter" || true
	@# Stop the container explicitly
	-docker stop $(NAME) || echo "Container $(NAME) not running or already stopped."
	@echo "Container $(NAME) has been stopped."

start_bwapi:
	echo starting the Brightway API on port 8000...
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) $(NAME) bash -c "cd ../ecobalyse/data/bwapi; uvicorn --host 0.0.0.0 server:api";\
	else $(DOCKERRUN) $(NAME) bash -c "cd ../ecobalyse/data/bwapi; uvicorn --host 0.0.0.0 server:api"; fi

clean_data:
	docker volume rm $(NAME)

clean_image:
	docker image rm $(NAME)

clean: clean_data clean_image
