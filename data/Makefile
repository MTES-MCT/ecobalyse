SHELL := /bin/bash
NAME := $(shell echo $$PWD|sed 's/\/data//'|sed 's/.*\///')
DOCKERRUN := docker run --rm --name $(NAME) -it -v $$PWD/../:/home/jovyan/ecobalyse -v $(NAME):/home/jovyan

json: image import_agribalyse export_builder

image:
	docker build -t $(NAME) -f Dockerfile .

import_agribalyse:
	curl -o food/import_agb/AGB3.1.1.20230306.CSV.zip https://nextcloud.prelab.fr/index.php/s/nDT3DSkgxYJLgJ3/download/AGB3.1.1.20230306.CSV.zip
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/import_agb $(NAME) python3 import_agribalyse.py

export_ciqual:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/export_agb $(NAME) python3 export_ciqual.py

export_builder:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/export_agb $(NAME) python3 export_builder.py

bash:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) bash

notebook:
	$(DOCKERRUN) -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes $(NAME) start-notebook.sh

clean_data:
	docker volume rm $(NAME)

clean_image:
	docker image rm $(NAME)
