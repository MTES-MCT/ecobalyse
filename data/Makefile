SHELL := /bin/bash
NAME := $(shell echo $$PWD|sed 's/\/data//'|sed 's/.*\///')
DOCKERRUN := docker run --rm --name $(NAME) -it -v $$PWD/../:/home/jovyan/ecobalyse -v $(NAME):/home/jovyan
DOCKEREXEC := docker exec -u jovyan -it

json: image import_agribalyse export_builder

image:
	docker build -t $(NAME) docker

import_ei391_agb311:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/ $(NAME) python3 imports.py

import_agribalyse:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/import_agb $(NAME) python3 importing_databases.py

import_agribalyse:
	curl -o food/import_agb/agribalyse3_no_param.CSV.zip https://nextcloud.prelab.fr/index.php/s/kmYtfqHa42EZA9R/download/agribalyse3_no_param.CSV.zip
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/import_agb $(NAME) python3 importing_databases.py

export_ciqual:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/export_agb $(NAME) python3 export_ciqual.py

export_builder:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/export_agb $(NAME) python3 export_builder.py

corrected_impacts:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/manual_update_agb3.1.1 $(NAME) python3 update_impacts_311.py
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/manual_update_agb3.1.1 $(NAME) python3 compute_corrected_impacts.py

python:
	echo Running Python inside the container...
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) $(NAME) python;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) python; fi

shell:
	echo starting a user shell inside the container...
	@if [ "$(shell docker container inspect -f '{{.State.Running}}' $(NAME) )" = "true" ]; then \
		$(DOCKEREXEC) $(NAME) bash;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) bash; fi

start_notebook:
	$(DOCKERRUN) -d -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes $(NAME) start-notebook.sh
	echo ### Run: `make shell` then `jupyter notebook password` to change the jupyter password

make notebook_link:
	docker logs $(NAME) | grep 8888 | grep 127.0.0.1 | sort | uniq

stop_notebook:
	docker exec $(NAME) jupyter-lab stop


clean_data:
	docker volume rm $(NAME)

clean_image:
	docker image rm $(NAME)

clean: clean_data clean_image
