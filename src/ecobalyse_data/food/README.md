# Utiliser la librairie python "Brightway2"

La librairie python [brightway2](https://brightway.dev/) est un framework
d'analyse du cycle de vie. Elle est très pratique pour pouvoir importer des
données dans une base locale, faire des requêtes et calculs, et pour ensuite
pouvoir exporter des données.

Dans le répertoire [brightway/import_agb/](import_agb/) vous trouverez
un script permettant d'importer la base de données
[agribalyse](https://agribalyse.ademe.fr/), et dans le répertoire
[brightway/export_agb/](export_agb/) le script utilisé pour exporter
des données sous format json.

Pour utiliser ces scripts, il vous faudra installer le gestionnaire de paquets
[anaconda](https://docs.conda.io/projects/conda/en/latest/) et créer un
environnement virtuel.

Dans le répertoire
[brightway/brightway_tutorial_notebooks/](brightway_tutorial_notebooks/)
vous trouverez plusieurs exemples d'utilisation de la librairie brightway2 sous
forme de [notebooks jupyter](https://jupyter.org/) pour explorer et expérimenter
par vous-même.

## Installer anaconda et créer son environnement virtuel

Suivre la [procédure d'installation](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html).

Créer un environnement virtuel avec toutes les dépendences requises :

    $ conda env create -f food/environment.yml

Activer l'environnement virtuel :

    $ conda activate ecobalyse-env

## Importer la base agribalyse v3.0 dans brightway

Tout d'abord se placer dans le bon répertoire :

    $ cd import_agb

Attention : il est nécessaire d'avoir le fichier `agribalyse3_no_param.CSV` dans
le répertoire. Ce fichier est un export de la base Agribalyse par le biais du
logiciel (payant) SimaPro. Veuillez nous contacter si vous en avez besoin.

Puis lancer le script d'import qui prend plusieurs minutes :

    $ python importing_databases.py

Si vous souhaitez relancer un import en repartant de zéro, vous pouvez utiliser
le script de nettoyage :

    $ python clean_agb.py

## Exporter la base agribalyse de brightway vers des fichiers json

Tout d'abord se placer dans le bon répertoire :

    $ cd export_agb

Consulter le [README](export_agb/README.md) dédié.

## Utiliser un notebook jupyter

Tout d'abord se placer dans le bon répertoire :

    $ cd sandbox

Lancer jupyter :

    $ jupyter-notebook

Puis ouvrir un des liens affichés, par exemple :

    http://localhost:8888/?token=........
