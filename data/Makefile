SHELL := /bin/bash
NAME := $(shell echo $$PWD|sed 's/\/data//'|sed 's/.*\///')
DOCKERRUN := docker run --rm -it -v $$PWD/../:/home/jovyan/ecobalyse -v $(NAME):/home/jovyan
DOCKEREXEC := docker exec -u jovyan -it

json: image import_agribalyse import_food_method import_ecoinvent import_textile_method export_food

image:
	docker build -t $(NAME) docker

import_agribalyse:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_agribalyse.py;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_agribalyse.py; fi

import_food_method:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_method.py Food;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_method.py Food; fi

import_ecoinvent:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_ecoinvent.py;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_ecoinvent.py; fi

import_textile_method:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_method.py Textile;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python3 import_method.py Textile; fi

export_food:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data/food $(NAME) python3 export.py;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food $(NAME) python3 export.py; fi

export_textile:
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) -w /home/jovyan/ecobalyse/data/textile $(NAME) python3 export.py;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data/textile $(NAME) python3 export.py; fi

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
	$(DOCKERRUN) -d --name $(NAME) -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes $(NAME) start-notebook.sh
	docker cp ~/.gitconfig $(NAME):/home/jovyan/
	$(DOCKERRUN) $(NAME) bash -c "test -e ~/.jupyter/jupyter_notebook_config.json" || echo '### Run: `make shell` then `jupyter notebook password` to change the jupyter password, then restart with `make stop_notebook` and `make start_notebook`.'

stop_notebook:
	docker exec $(NAME) bash -c "pkill jupyter; while pgrep jupyter-lab > /dev/null; do echo waiting to stop jupyter; sleep 1;done"

clean_data:
	docker volume rm $(NAME)

clean_image:
	docker image rm $(NAME)

clean: clean_data clean_image
