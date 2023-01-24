# Exporter la base agribalyse de brightway vers des fichiers json

Au préalable, vérifiez que vous avez bien suivi les instructions du
[README](../README.md) général, et que vous avez installé le projet comme
indiqué dans le [README](../../../../README.md) du repository.

## Exporter les données pour l'explorateur de produits CIQUAL

Lancer le script d'export qui peut prendre plusieurs heures (!) :

    $ python export_ciqual.py

Il est possible d'utiliser l'option `--max` pour limiter le nombre de produits
ciquals à exporter, et l'option `--no-impacts` pour ne pas calculer les impacts
des procédés (ce qui exportera un fichier `processes-no-impacts.json` au lieu de
`processes.json`) :

    $ python export_ciqual.py --max 1 --no-impacts
    # Beaucoup plus rapide, mais incomplet ;)

Les fichiers résultants sont `/public/data/food/processes/explorer.json` et
`/public/data/food/products.json`.

Optionnellement, lancer le script de vérification des différences d'impacts :

    $ python checks_ciqual.py

## Exporter les données pour le constructeur de recettes

Lancer le script d'export :

    $ python export_builder.py

Exemple :

    $ python export_builder.py

Les fichiers résultants sont `/public/data/food/processes/builder.json` et `/public/data/food/ingredients.json`.

## Ajouter un nouvel ingrédient (complexe)

Les nouveaux ingrédients se rajoutent dans le fichier
[ingredients_base.json](./ingredients_base.json). La structure se compose, selon
si c'est un ingrédient simple ou complexe, de la sorte :

### Ingrédient simple

    {
        "id": "carrot",
        "name": "carotte",
        "default": "61ca6413bd2be0106255b003424d00ba",
        "variants": {
            "organic": "9f147496e4f222def9af93b7b18ad49b"
        }
    },

    - `id`: un identifiant (nom de l'ingrédient en anglais)
    - `name`: nom de l'ingrédient en français
    - `default`: le `simapro_id` qu'on retrouve dans un export agribalyse par le biais de brightway
    - `variants`: optionnellement un objet `variants` avec des modes de production alternatif

Attention, il faut que les différents `simapro_id` correspondent à des procédés
exportés dans `builder_processes.json`, et pour cela, il faut donc rajouter les
noms de ces ingrédients (noms agribalyse) dans le fichier `builder_processes_to_export.txt`.

Pour trouver le `simapro_id` correspondant à un nom d'ingrédient (nom
agribalyse), il est possible d'utiliser le petit script python
`code_for_process_name.py`:

    python code_for_process_name.py "Sunflower, at farm (WFLDB 3.1)/FR U"

Voici un exemple d'ajout d'un ingrédient simple : [le
tournesol](https://github.com/MTES-MCT/ecobalyse-data/pull/14/commits/0dc2091095002c4f13b5147fe819ef6afa49e22f).

Dans le cas où l'indicateur "bvi" (biodiversité de Lindner) est connu, il faut aussi rajouter une entrée dans le fichier `bvi.csv`

### Ingrédient complexe

    {
        "id": "flour",
        "name": "farine",
        "default": "a343353e431d7dddc7bb25cbc41e179a",
        "variants": {
            "organic": {
                "ratio": 1.16,
                "simple_ingredient_default": "Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate",
                "simple_ingredient_variant": "Soft wheat grain, organic, 15% moisture, Central Region, at farm gate"
            }
        }
    }

    - `id`: un identifiant (nom de l'ingrédient en anglais)
    - `name`: nom de l'ingrédient en français
    - `default`: le `simapro_id` qu'on retrouve dans un export agribalyse par le biais de brightway
    - `variants`: pour chaque variant qui est un object et non un simple `simapro_id`, il faut
      - le ratio (par exemple il faut 1.16kg de blé pour faire 1kg de farine)
      - le nom agribalyse de l'ingrédient "par défaut" (conventionnel)
      - le nom agribalyse de l'ingrédient du variant spécifié (du blé bio dans notre example)

Là aussi il faut que les différents `simapro_id` correspondent à des procédés
exportés dans `builder_processes.json`.

Voici un exemple d'ajout d'un ingrédient complexe : [la farine de
blé](https://github.com/MTES-MCT/ecobalyse-data/pull/11/commits/2c7817d310fbc65bb954e339fcaf45369f0b5abe).
