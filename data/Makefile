SHELL := /bin/bash
NAME := $(shell echo $$PWD|sed 's/\/data//'|sed 's/.*\///')
DOCKERRUN := docker run --rm -it -v $$PWD/../:/home/jovyan/ecobalyse -v $(NAME):/home/jovyan
DOCKEREXEC := docker exec -u jovyan -it

json: image import_agribalyse import_method import_ecoinvent export_builder

image:
	docker build -t $(NAME) docker

import_ecoinvent:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_ecoinvent.py;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_ecoinvent.py; fi

import_agribalyse:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_agribalyse.py;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_agribalyse.py; fi

import_method:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_method.py;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_method.py; fi


export_ciqual:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data/food/export_agb $(NAME) python3 export_ciqual.py;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/export_agb $(NAME) python3 export_ciqual.py; fi

export_builder:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data/food/export_agb $(NAME) python3 export_builder.py;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/export_agb $(NAME) python3 export_builder.py; fi

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

start_notebook:
	$(DOCKERRUN) -d --name $(NAME) -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes $(NAME) start-notebook.sh
	$(DOCKERRUN) $(NAME) bash -c "test -e ~/.jupyter/jupyter_notebook_config.json" || echo '### Run: `make shell` then `jupyter notebook password` to change the jupyter password, then restart with `make stop_notebook` and `make start_notebook`.'

stop_notebook:
	docker exec $(NAME) pkill jupyter

clean_data:
	docker volume rm $(NAME)

clean_image:
	docker image rm $(NAME)

clean: clean_data clean_image
