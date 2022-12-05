# Ecobalyse data

Ce repo contient les scripts utilisées (principalement python) pour préparer/explorer les données du projet [Ecobalyse](https://github.com/MTES-MCT/ecobalyse)
Certains scripts ont besoin d'importer d'autres modules. Pour cela il faut installer le package ecobalyse_data en se plaçant à la racine du repo et en lançant :

    $ pip install -e .

Si vous utilisez [anaconda](https://docs.conda.io/projects/conda/en/latest/)
comme recommandé dans le [README de l'alimentaire](src/ecobalyse_data/food),
utilisez plutôt la commande suivante :

    $ conda develop src/
