SHELL := /bin/bash
NAME := $(shell echo $$PWD|sed 's/\/data//'|sed 's/.*\///')
DOCKERRUN := docker run --rm --name $(NAME) -it -v $$PWD/../:/home/jovyan/ecobalyse -v $(NAME):/home/jovyan

json: image import_agribalyse export_builder

plop:
	echo $(NAME)
image:
	docker build -t $(NAME) -f Dockerfile .

import_agribalyse:
	curl -o food/import_agb/agribalyse3_no_param.CSV.zip https://nextcloud.prelab.fr/index.php/s/kmYtfqHa42EZA9R/download/agribalyse3_no_param.CSV.zip
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data/food/import_agb $(NAME) python3 importing_databases.py

export_ciqual:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) bash -c "pip install -e . && cd food/export_agb && python3 export_ciqual.py"

export_builder:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) bash -c "pip install -e . && cd food/export_agb && python3 export_builder.py"

bash:
	$(DOCKERRUN) -w /home/jovyan/ecobalyse/data $(NAME) bash -c "pip install -e . && bash"

server:
	$(DOCKERRUN) -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes $(NAME)

clean_data:
	docker volume rm $(NAME)

clean_image:
	docker image rm $(NAME)
