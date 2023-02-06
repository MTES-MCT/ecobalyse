Comment générer les données json utilisées par le frontal elm :

# Avec docker

* Installez `docker` et `make`
* Si vous êtes sur Mac avec architecture ARM, affectez 6Go de RAM à Docker dans Docker Desktop : Settings → Ressources → Advanced → Memory = 6G
* Lancez **`make`** ce qui va successivement :
    * construire l'image docker
    * importer agrobalyse
    * exporter les données json pour le builder

Le processus entier prend entre 1 et 2h.
En cas de problème vous pouvez redémarrer de zéro en faisant d'abord un `make clean_data`.

## Autres commandes :

* `make image` : pour construire l'image docker choisie
* `make import_agribalyse` : pour importer la base dans Brightway. Assurez-vous d'avoir le fichier `agribalyse3_no_param.CSV.zip` dans le dossier `food/import_agb/`
* `make export_builder` : pour exporter les json pour le builder
* `make json` : lance toutes les commandes précédentes dans l'ordre
* `make export_ciqual` : pour exporter les json des produits ciqual. Assurez-vous d'avoir le fichier `Agribalyse_Synthese.csv` dans le dossier `food/`
* `make bash` : lance un shell à l'intérieur conteneur
* `make server` : lancer le serveur Jupyter dans le conteneur (si image Jupyter)
* `make clean_data` : supprime toutes les données (celles de brightway et
  jupyter mais pas les json générés)
* `make clean_image` : supprime l'image docker

## Travailler dans le conteneur :

Vous pouvez entrer dans le conteneur avec `make bash`.

Toutes les données du conteneur, notamment celles de Brightway et de Jupyter,
sont dans `/home/jovyan` qui est situé dans un volume docker
(`/var/lib/docker/volume/jovyan` sur le *host*).  Le dépôt git ecobalyse se
retrouve à l'intérieur du conteneur dans `/home/jovyan/ecobalyse`.  Les
fichiers json générés arrivent directement sur place au bon endroit pour être
comparées puis commités.

## Lancer le serveur Jupyter

Vous pouvez démarrer le serveur Jupyter avec : `make server`. Ensuite
ctrl-cliquez sur le lien généré dans le terminal pour vous y connecter sans mot
de passe

## Remarques

Si l'`export_ciqual` prend des heures, c'est un problème d'installation de
`pypardiso` ou de la bibliothèque `mkl` (Math Kernel Library d'intel) ou une
incompatibilité avec l'architecture CPU utilisée. Dans ce cas c'est le solveur
de Scipy qui est utilisé. Il est possible que cela explique les très légères
différences d'arrondi rencontrées dans les résultats.

Les deux images docker utilisent les mêmes versions et le même solveur, elles fournissent exactement les mêmes fichiers en sortie.


# À la main

Certains scripts ont besoin d'importer d'autres modules. Pour cela il faut
installer le package `ecobalyse_data`, et pour cela il est recommandé de créer un
environnement virtuel au préalable :

Placez-vous en tout premier lieu dans le répertoire `data/`.

### Utilisation de anaconda

Suivez la [procédure d'installation de anaconda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html).

Ensuite créez un environnement virtuel avec toutes les dépendences requises :

    $ conda env create --name ecobalyse-env --file requirements.txt

Activez l'environnement virtuel :

    $ conda activate ecobalyse-env

Puis installez le package ecobalyse_data :

    $ conda develop .

# Utilisation de pip

Une fois que vous avez [installé
pip](https://pip.pypa.io/en/stable/installation/) et [créé et activé un
environnement
virtuel](https://packaging.python.org/en/latest/tutorials/installing-packages/#creating-and-using-virtual-environments),
installez le package ecobalyse_data de la sorte :

    $ pip install -r requirements.txt
    $ pip install -e .

# Import et export des données

Si vous êtes sur une architecture amd64, ajoutez pypardiso pour accélérer les calculs, grâce à la lib `mkl` :

    $ pip install pypardiso

Vous pouvez maintenant suivre la [procédure](food/README.md) pour lancer les scripts d'import et d'export.

