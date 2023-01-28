SHELL := /bin/bash
DOCKERRUN := docker run --rm --name brightway2 -it -v $$PWD/../:/home/jovyan/ecobalyse -v jovyan:/home/jovyan

default: choice image

json: choice image import_agribalyse export_builder export_ciqual

choice:
	@read -e -N 1 -t 10 -p "Press m or j to choose the Minimal or Jupyter image: " choice; \
	choice=$${choice:-m}; \
	if [ "$$choice" == "j" ]; then \
		ln -sf Dockerfile.jupyter Dockerfile; \
	elif [ "$$choice" == "m" ]; then \
		ln -sf Dockerfile.minimal Dockerfile; \
	else rm Dockerfile; \
	fi

image:
	docker build -t brightway2 -f Dockerfile .

import_agribalyse:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/import_agb brightway2 python3 importing_databases.py

export_ciqual:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data brightway2 bash -c "pip install -e . && cd food/export_agb && python3 export_ciqual.py"

export_builder:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data brightway2 bash -c "pip install -e . && cd food/export_agb && python3 export_builder.py"

clean_data:
	docker volume rm jovyan
	rm -f Dockerfile

clean_image:
	docker image rm brightway2
