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

Si vous utilisez [gitpod.io](https://gitpod.io) cette étape est déjà gérée
automatiquement (très pratique !).

Pour le faire manuellement :

Suivre la [procédure d'installation](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html).

Créer un environnement virtuel avec toutes les dépendences requises :

    $ conda env create -f brightway/environment.yml

Activer l'environnement virtuel :

    $ conda activate env

## Importer la base agribalyse dans brightway

Tout d'abord se placer dans le bon répertoire :

    $ cd import_agb

Puis lancer le script d'import qui prend plusieurs minutes :

    $ python importing_databases.py

## Exporter la base agribalyse de brightway vers des fichiers json

Tout d'abord se placer dans le bon répertoire :

    $ cd food/export_agb

Consulter le [README](food/export_agb/README.md) dédié.

## Utiliser un notebook jupyter

Tout d'abord se placer dans le bon répertoire :

    $ cd sandbox

Lancer jupyter :

    $ jupyter-notebook

Puis ouvrir un des liens affichés, par exemple :

    http://localhost:8888/?token=........

(si c'est lancé sur gitpod, il suffit de CMD/CTRL click sur le lien
`http://localhost:8888/?token=...`, ou de cliquer sur "open in browser" dans la
fenêtre de notification).
