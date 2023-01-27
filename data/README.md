Certains scripts ont besoin d'importer d'autres modules. Pour cela il faut
installer le package ecobalyse_data, et pour cela il est recommandé de créer un
environnement virtuel au préalable :

Placez-vous en tout premier lieu dans le répertoire `data/`.

# Utilisation de anaconda (recommandé)

Suivez la [procédure d'installation de anaconda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html).

Ensuite créez un environnement virtuel avec toutes les dépendences requises :

    $ conda env create -f food/environment.yml

Activez l'environnement virtuel :

    $ conda activate ecobalyse-env

Puis installez le package ecobalyse_data :

    $ conda develop .

# Utilisation de pip (non maintenu)

Une fois que vous avez [installé
pip](https://pip.pypa.io/en/stable/installation/) et [créé et activé un
environnement
virtuel](https://packaging.python.org/en/latest/tutorials/installing-packages/#creating-and-using-virtual-environments),
installez le package ecobalyse_data de la sorte :

    $ pip install -e .

# Import et export des données

Vous pouvez maintenant suivre la [procédure](food/README.md) pour lancer les scripts d'import et d'export.
