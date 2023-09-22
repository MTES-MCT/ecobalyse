Comment générer les données json utilisées par le frontal elm :

# Avec docker

* Installez `docker` et `make`
* Si vous êtes sur Mac avec architecture ARM, affectez 6Go de RAM à Docker dans Docker Desktop :
  Settings → Ressources → Advanced → Memory = 6G
* Préparez les bases de données à importer, elle ne font pas partie du dépôt :
    * Agribalyse : compressé dans un fichier `AGB3.1.1.20230306.CSV.zip` dans ce dossier data/
    * Ecoinvent : décompressé dans un dossier `ECOINVENT3.9.1` dans ce même dossier
* Lancez **`make`** ce qui va successivement :
    * construire l'image docker
    * importer agribalyse et EF 3.1 adapted dans un projet `food` de Brightway
    * importer ecoinvent et EF 3.1 adapted dans un projet `textile` de Brightway
    * exporter les données json utilisées côté front-end

Le processus entier prend environ 1h. En cas de problème vous pouvez redémarrer de zéro en faisant
d'abord un `make clean_data` (qui supprime le volume docker).

## Autres commandes :

* `make image` : pour construire l'image docker choisie
* `make import_agribalyse` : pour importer Agribalyse 3.1.1 dans Brightway (projet food).
  Assurez-vous d'avoir le fichier `AGB3.1.1.20230306.CSV.zip` dans le dossier `data/`
* `make import_food_method` : pour importer EF 3.1 adapted dans Brightway (projet food).
  Assurez-vous d'avoir le fichier `Environmental Footprint 3.1 (adapted).CSV` dans le dossier
  `data/`
* `make import_textile_method` : pour importer EF 3.1 adapted dans Brightway (projet textile).
  Assurez-vous d'avoir le fichier `Environmental Footprint 3.1 (adapted).CSV` dans le dossier
  `data/`
* `make import_ecoinvent` : pour importer Ecoinvent 3.9.1. Brightway (projet textile). Assurez-vous
  d'avoir le dossier `ECOINVENT3.9.1/` dans le dossier `data/`
* `make export_food` : pour exporter les json pour le builder alimentaire
* `make export_textile` : pour exporter les json pour le builder textile
* `make delete_textile_method` : pour supprimer la méthode utilisée dans le projet textile
* `make json` : lance toutes les commandes précédentes dans l'ordre
* `make shell` : lance un shell bash à l'intérieur du conteneur
* `make python` : lance un interpréteur Python à l'intérieur du conteneur
* `make jupyter_password` : définit le mot de passe jupyter. Doit être lancé avant son démarrage.
* `make root_shell` : lance un shell root à l'intérieur du conteneur
* `make jupyter_password` : pour définir le mot de passe de Jupyter avant de le lancer
* `make start_notebook` : lance le serveur Jupyter dans le conteneur
* `make stop_notebook` : arrête le serveur Jupyter donc aussi le conteneur
* `make clean_data` : supprime toutes les données (celles de brightway et jupyter mais pas les json
  générés)
* `make clean_image` : supprime l'image docker
* `make clean` : lance `clean_data` et `clean_image`


## Travailler dans le conteneur :

Vous pouvez entrer dans le conteneur avec `make shell`.

Toutes les données du conteneur, notamment celles de Brightway et de Jupyter, sont dans
`/home/jovyan` qui est situé dans un volume docker (`/var/lib/docker/volume/jovyan` sur le *host*).
Le dépôt git ecobalyse se retrouve (via un bind mount) aussi à l'intérieur du conteneur dans
`/home/jovyan/ecobalyse`.  Les fichiers json générés arrivent directement sur place au bon endroit
pour être comparées puis commités.

## Lancer le serveur Jupyter

Avant de lancer Jupyter vous pouvez définir son mot de passe avec `make jupyter_password`. Ensuite
vous le démarrez avec `make start_notebook`.

## Lancer l'explorateur Brightway

Créez un notebook dans Jupyter puis tapez `import notebooks.explore`, puis shift-Enter

## Lancer l'éditeur de procédés/ingrédients

Créez un notebook dans Jupyter puis tapez `import notebooks.ingredients`, puis shift-Enter

## Remarques

Si l'`export` prend plus de 2 secondes par procédé, c'est un problème d'installation de `pypardiso`
ou de la bibliothèque `mkl` (Math Kernel Library d'Intel) ou une incompatibilité avec l'architecture
CPU utilisée. Dans ce cas c'est le solveur de Scipy qui est utilisé. Il est possible que cela
explique les très légères différences d'arrondi rencontrées dans les résultats.

# À la main

Il faut d'abord installer le package `ecobalyse_data` qui est dans `data/` (voir le fichier `setup.py`),
et pour cela il est recommandé de créer un environnement virtuel au préalable :

Placez-vous en tout premier lieu dans le répertoire `data/`.

## Utilisation de anaconda

Suivez la [procédure d'installation de anaconda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html).

Ensuite créez un environnement virtuel avec toutes les dépendences requises :

    $ conda env create --name ecobalyse-env --file requirements.txt

Activez l'environnement virtuel :

    $ conda activate ecobalyse-env

Puis installez le package `ecobalyse_data` :

    $ conda develop .

## Utilisation de pip

Une fois que vous avez [installé
pip](https://pip.pypa.io/en/stable/installation/) et [créé et activé un
environnement
virtuel](https://packaging.python.org/en/latest/tutorials/installing-packages/#creating-and-using-virtual-environments),
installez le package `ecobalyse_data` de la sorte :

    $ pip install -r requirements.txt
    $ pip install -e .

## Import et export des données

Si vous êtes sur une architecture amd64, ajoutez `pypardiso` pour accélérer les calculs grâce à la lib `mkl` :

    $ pip install pypardiso

Vous pouvez ensuite lancer les commandes d'import `./import_agribalyse.py`, `import_method.py food`,
`import_ecoinvent.py`, `import_method.py textile`. Puis les commandes d'export : `cd food;
./export.py`, `cd textile; ./export.py`.
