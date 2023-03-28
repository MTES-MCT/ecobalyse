SHELL := /bin/bash
NAME := $(shell echo $$PWD|sed 's/\/data//'|sed 's/.*\///')
RUNNING := $(shell docker container inspect -f '{{.State.Running}}' $(NAME) )
DOCKERRUN := docker run --rm --name $(NAME) -it -v $$PWD/../:/home/jovyan/ecobalyse -v $(NAME):/home/jovyan
DOCKEREXEC := docker exec -it

json: image import_agribalyse export_builder

image:
	docker build -t $(NAME) docker

import_agribalyse:
	curl -o food/import_agb/AGB3.1.1.20230306.CSV.zip https://nextcloud.prelab.fr/index.php/s/nDT3DSkgxYJLgJ3/download/AGB3.1.1.20230306.CSV.zip
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/import_agb $(NAME) python3 import_agribalyse.py

export_ciqual:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/export_agb $(NAME) python3 export_ciqual.py

export_builder:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/export_agb $(NAME) python3 export_builder.py

corrected_impacts:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/manual_update_agb3.1.1 $(NAME) python3 update_impacts_311.py
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/manual_update_agb3.1.1 $(NAME) python3 compute_corrected_impacts.py

bash:
	@if [ "$(RUNNING)" = "true" ]; then \
		$(DOCKEREXEC) $(NAME) bash;\
	else $(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) bash; fi

notebook:
	$(DOCKERRUN) -d -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes $(NAME) start-notebook.sh;\
	docker logs -f $(NAME)

kill_notebook:
	docker kill $(NAME)


clean_data:
	docker volume rm $(NAME)

clean_image:
	docker image rm $(NAME)

clean: clean_data clean_image
