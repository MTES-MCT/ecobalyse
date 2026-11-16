# Ajouter un secteur générique

Ce guide technique décrit, dans l'ordre, les étapes pour ajouter une nouvelle verticale au moteur générique et ouvrir une PR prête à être mergée et déployable en production.

> 💡 Dans ce document et dans la documentation du projet Ecobalyse, les termes *secteur*, *sector*, *scope*, *périmètre*, *domaine métier* et *verticale* désignent tous le même concept : un domaine spécifique d'activités humaines pour lequel une calculette et le moteur de calcul générique sous-jacent sont spécifiquement configurés et des données mises à disposition en conséquence. **Dans ce guide, nous emploierons le terme *secteur*** qui est le terme à privilégier lors d'échanges techniques sur le sujet.
> ⚠️ Ce guide ne couvre ni la création de données métiers (ICV, procédés, composants, catégories, exemples, etc.) ni les subtilités de configuration spécifiques au secteur ; il se concentre sur le **minimum technique** à opérer pour qu'un nouveau secteur soit *techniquement déployable* en production.

Nous prendrons pour exemple l'ajout d'un nouveau secteur **Flowers**, qui sera matérialisé de la façon suivante :

- Libellé en français : `Fleurs`
- Identifiant technique : `flowers`
- Constructeur Elm : `Flowers`
- Variable d'environnement d'activation : `ENABLE_FLOWERS_SECTION`

> ℹ️ Les **identifiants techniques sont en anglais**, les libellés visibles dans l'interface (boutons, menus, messages, erreurs, etc.) sont en français.

## Architecture historique et généricité

`Textile` puis `Food` (ou *food1*), secteurs historiques, ont permis les premières implémentations de calculettes dont ont découlé les choix techniques socles du moteur générique. Ils disposent chacun d'un moteur de calcul, d'un module de page Elm et de points d'entrée d'API spécifiques ; `Textile` et `Food` ne sont donc pas *génériques*, tandis que `Food2`, `Object` et `Veli` le sont.

C'est sur le modèle de ces derniers que de nouveaux secteurs doivent être conçus et introduits dans la base de code, afin de s'appuyer sur le jeu de fonctionnalités transverses qu'offre désormais la plateforme. Pas de module `Page/Flowers.elm` ni de routes d'API spécifiques à un sector particulier, notamment.

## Séquence de mise à jour

Voici la séquence type qu'il convient de suivre pour ajouter un nouveau secteur Ecobalyse à la base de code ; chaque étape est détaillée dans la suite du guide.

1. Ajouter un nouveau constructeur `Flowers`
2. Suivre et corriger les erreurs de compilation Elm suite à son introduction
3. Câbler ce que le compilateur ne "voit" pas (routes, fichiers JSON, menus…)
4. Ajouter les fichiers de données minimaux requis
5. Mettre à jour le code js et définir les variables d'environnement
6. Déployer progressivement en production

## 1. Ajouter le nouveau constructeur de type Elm

Dans le module [`Data.Sector`](../src/Data/Sector.elm), on ajoute le constructeur `Flowers` correspondant à notre nouvelle verticale *Fleurs* au type `GenericSector` :

```elm
type GenericSector
    = Flowers -- <-- on ajoute le nouveau constructeur ici
    | Food2
    | Object
    | Veli
```

> 💡 L'avantage d'utiliser un langage strict fortement typé comme Elm et son compilateur sourcilleux, c'est que ce dernier nous guidera pour l'essentiel des modifications à opérer dans la base de code afin que les modifications restent cohérentes. Il suffit de suivre les messages qu'il nous fournit et corriger pas à pas.

> 💡 On note que les constructeurs doivent toujours être ordonnés alphabétiquement (une règle `elm-review` s'en assure dans la CI)

Le compilateur nous indique immédiatement de gérer les nouvelles branches introduites par l'ajout de cette nouvelle entrée, typiquement dans des fonctions Elm comme `toLabelGeneric` et `toStringGeneric` du même fichier. Il s'agit là de fournir la représentation textuelle du secteur dans certains contextes. Par exemple, le compilateur affiche ce message pour la fonction `toLabelGeneric` :

```
-- MISSING PATTERNS ---------------------------------------- src/Data/Sector.elm

198|#>#    case genericSector of
199|#>#        Food2 ->
200|#>#            "Alimentaire BÉTA"
201|#>#
202|#>#        Object ->
203|#>#            "Objets"
204|#>#
205|#>#        Veli ->
206|#>#            "Véhicules"

Missing possibilities include:

    #Flowers#

I would have to crash if I saw one of those. Add branches for them!
```

Il nous faut donc rajouter la branche manquante traitant `Flowers`. Pour rappel, si l'identifiant textuel de notre secteur `Flowers` est `flowers`, son libellé d'affichage dans l'interface en français est `Fleurs` :

```elm
toLabelGeneric : GenericSector -> String
toLabelGeneric genericSector =
    case genericSector of
        -- la nouvelle branche est ajoutée ici (notez l'ordre alphabétique)
        Flowers ->
            "Fleurs"

        Food2 ->
            "Alimentaire BÉTA"
        …
```

## 2. Cas exhaustifs

### Liste exhaustive des secteurs génériques

Toujours dans le module [`Data.Sector`](../src/Data/Sector.elm), compléter `allGeneric` avec `Flowers`, dans l'ordre alphabétique :

```elm
allGeneric : List GenericSector
allGeneric =
    [ Flowers
    , Food2
    , Object
    , Veli
    ]
```

### Session

Dans le module [`Data.Session`](../src/Data/Session.elm), ajouter le champ `flowers : Component.Query` au type `Queries` :

```elm
type alias Queries =
    { flowers : Component.Query
    , food : FoodQuery.Query
    …
```

Le compilateur signalera également tous les enregistrements `Queries` à compléter, notamment dans la fonction `setupSession` du module [`Main`](../src/Main.elm) :

```elm
    , queries =
        { flowers = Component.emptyQuery
        , food = FoodQuery.empty
        …
```

On continue de suivre pas à pas les messages du compilateur, en mettant à jour les branches des fonctions le nécessitant, comme la fonction `genericQuery` :

```elm
    case genericSector of
        Sector.Flowers ->
            session.queries.flowers
```

ou `updateGenericQuery` :

```elm
    case genericSector of
        Sector.Flowers ->
            { session | queries = { queries | flowers = query } }
```

### Dataset

Le type `Dataset` du module [`Data.Dataset`](../src/Data/Dataset.elm) décrit le type de données de l'[Explorateur](/#/explore/food2).

Ajouter les jeux de données de `datasetsGeneric` pour `Sector.Flowers`. Par exemple pour :

```elm
    Sector.Flowers ->
        [ GenericExamples sector Nothing
        , Components (Sector.Generic sector) Nothing
        , Countries Nothing
        , Processes (Sector.Generic sector) Nothing
        , Impacts Nothing
        , ProductCategory sector Nothing
        ]
```

Ajouter également les slugs attendus pour les URLs de l'explorateur du nouveau secteur `flowers` dans les fonctions suivantes :
- `componentGenericDatasetToString`
- `processesDatasetGenericToString`
- `examplesDatasetToString`
- `productCategoryDatasetToString`

### Éléments de vue génériques

Dans le module [`Views.Page`](../src/Views/Page.elm), la fonction `commonNoticesForGeneric` permet d'afficher un bandeau informatif dans l'entête de la page d'une calculette ; on peut décider d'en ajouter un spécifique à notre nouveau secteur :

```elm
    Sector.Flowers ->
        Notice.info
            [ Icon.info
            , Markdown.simple [] "**Cette verticale sent particulièrement bon.**"
            ]
```

#### Data.Db

Dans le module [`Data.Db`](../src/Data/Db.elm), ajouter les nouveaux champs de données au type `Properties`.

```elm
type alias Properties a =
    …
    , flowersComponents : a
    , flowersExamples : a
    , flowersProductCategories : a
    , food2Components : a
```

ce qui permet d'implémenter les fonctions `sectorToComponent`, `sectorToExamples`, et `sectorPropGetters` que le compilateur vous demandera de compléter.

> 🚨 Ordonner les noms des propriétés par ordre alphabétique, ça n'est pas que cosmétique : les constructeurs de type Elm sont des fonctions qui prennent leurs arguments dans un ordre déterministe !

#### Main

Compléter la fonction `loadDataForSector` du module [`Main`](../src/Main.elm) en ajoutant les trois URLs des fichiers JSON correspondant à charger :

```elm
    Sector.Generic Sector.Flowers ->
        [ ( "/data/flowers/components.json", \data raw -> { raw | flowersComponents = data } )
        , ( "/data/flowers/categories.json", \data raw -> { raw | flowersProductCategories = data } )
        , ( "/data/flowers/examples.json", \data raw -> { raw | flowersExamples = data } )
        ]
```

## 3. Mises à jour manuelles spécifiques

Le compilateur Elm est un outil précieux mais certains fichiers compilent encore si on oublie d'opérer certaines modifications manuellement, et ce à deux niveaux principalement :

- les sources de données à charger pour le nouveau secteur (composants, catégories de produits et exemples)
- les menus de navigation et certains affichages dans l'interface utilisateur

Les URL d'accès à la calculatrice seront donc préfixées par `flowers`, comme `#/flowers/simulator`.

### Chargement des données

Chaque secteur générique requiert trois fichiers de données JSON, qui seront mappés dans une structure de données dédiée en mémoire vive :

- Les composants disponibles pour ce secteur, qui seront lus depuis `public/data/flowers/components.json`
- Les catégories de produit disponibles pour ce secteur, qui seront lues depuis `public/data/flowers/categories.json`
- Les exemples de simulation préenregistrés pour ce secteur, qui seront lus depuis `public/data/flowers/examples.json`

On peut déjà créer les fichiers de composants et de catégories en les laissant intentionnellement vides dans un premier temps :

```bash
mkdir -p public/data/flowers
echo "[]" > public/data/flowers/components.json
echo "[]" > public/data/flowers/categories.json
```

Un exemple n'est pas obligatoire pour démarrer l'application, mais il est utile pour l'explorateur et les liens directs. Nous allons donc créer le fichier `public/data/flowers/examples.json` en y ajoutant un exemple minimal, par simplicité :

```json
[
  {
    "category": "",
    "id": "<uuid>",
    "name": "Produit vide",
    "query": { "components": [] },
    "scope": "flowers"
  }
]
```

> 💡 Pour générer un UUID, vous pouvez utiliser un [service en ligne](https://www.uuidgenerator.net)

Si vous décidez d'ajouter des catégories ou des composants à ce stade, vérifiez :

- pour `components.json`, que chaque composant ait une propriété `"scopes": ["flowers"]`
- pour `categories.json`, que chaque catégorie ait au minimum les propriétés requises `"cooling"`, `"id"`, `"label"` et `"scope": "flowers"`


#### Request.Db

Dans le module [`Request.Db`](../src/Request/Db.elm), initialiser l'état de chargement des trois fichiers et les enchaîner dans `resolve` **dans le même ordre** :

```elm
    , flowersComponents = RemoteData.NotAsked
    , flowersExamples = RemoteData.NotAsked
    , flowersProductCategories = RemoteData.NotAsked
    , food2Components = RemoteData.NotAsked
```

> ⚠️ Encore une fois, l'ordre doit scrupuleusement suivre celui du type `Properties`, comme évoqué plus haut.

#### Static.ProdDb et template JSON

Le module [`Static.ProdJson`](../src/Static/ProdJson.elm) est particulier, car il est généré. Il sert notamment au serveur d'API, puisque Elm ne dispose pas d'API système pour interroger le système de fichiers et récupérer directement le contenu de fichiers s'y trouvant ; c'est pour cela que ces contenus sont encapsulés dans ce fichier généré, qui est chargé d'un bloc en RAM par l'app serveur.

> ℹ️ Notes :
>
> - L'application Web Elm, elle, charge les données JSON à travers HTTP, réduisant ainsi le poids applicatif et les temps de chargement initiaux
> - Les tests unitaires et d'intégration utilisent un jeu de données restreint situé dans le répertoire [`tests/fixtures`](../tests/fixtures), compilé dans [`Static.TestJson`](../src/Static/TestJson.elm) et exposé par [`Static.TestDb`](../src/Static/TestDb.elm)

On modifie le template en question dans le fichier [`src/Static/Json.elm-template`](../src/Static/Json.elm-template), ainsi que le script de génération situé dans [`bin/build-db`](../bin/build-db). Exposer les trois chaînes en question :

```elm
flowersComponentsJson : String
flowersComponentsJson =
   """%flowersComponentsJson%"""
-- même chose pour flowersProductCategoriesJson et flowersExamplesJson
```

Ajouter une propriété `flowersComponents` au type `RawJsonComponents` :

```elm
type alias RawJsonComponents =
    { flowersComponents : String
    , food2Components : String
    , objectComponents : String
    , textileComponents : String
    , veliComponents : String
    }
```

Ensuite, ajouter la propriété `flowersComponents` à la fonction `rawJsonComponents` :

```elm
rawJsonComponents : RawJsonComponents
rawJsonComponents =
    { flowersComponents = flowersComponentsJson
    , food2Components = food2ComponentsJson
    , objectComponents = objectComponentsJson
    , textileComponents = textileComponentsJson
    , veliComponents = veliComponentsJson
    }
```

> 💡 Seules les données JSON des composants transitent par `RawJsonComponents` ; les exemples et catégories de produit conservent leurs propres constantes `*Json` (comme `flowersExamplesJson`).

Mobiliser ces nouveaux contenus JSON dans `dbFromJsonStrings`, dans [`Static.ProdDb`](../src/Static/ProdDb.elm) et [`Static.TestDb`](../src/Static/TestDb.elm). Ces fonctions passent des chaînes JSON brutes à `Db.buildFromStrings` :

```elm
    , flowersComponents = ProdJson.rawJsonComponents.flowersComponents
    , flowersExamples = ProdJson.flowersExamplesJson
    , flowersProductCategories = ProdJson.flowersProductCategoriesJson
    , food2Components = ProdJson.food2ComponentsJson
```

> ⚠️ Attention
>
> - Dans le module [`Static.TestDb`](../src/Static/TestDb.elm), les mêmes champs sont lus mais ils utilisent l'alias `TestJson` au lieu de `ProdJson`
> - Les fichiers JSON du dossier `public/data` doivent également exister dans `tests/fixtures`
> - Quand aucun test unitaire ou d'API n'utilise ces données, le fichier de fixtures peut être une simple liste vide (`[]`)

Dans le script [`bin/build-db`](../bin/build-db), il faut maintenant ajouter les substitutions de chaînes requises pour générer les modules de données statiques JSON Elm à partir du template :

```js
  .replace(
    "%flowersComponentsJson%",
    parseAndValidate(dataDir, "flowers/components.json", "id"),
  )
  .replace(
    "%flowersProductCategoriesJson%",
    parseAndValidate(dataDir, "flowers/categories.json", "id"),
  )
  .replace(
    "%flowersExamplesJson%",
    parseAndValidate(dataDir, "flowers/examples.json", "id"),
  )
```

Pour construire les bases statiques à partir de ce script et générer `Static/ProdJson.elm` et `Static/TestJson.elm`, on lance :

```bash
npm run db:build
```

Cette commande (re)génère les fichiers et effectue les vérifications de cohérence et d'intégrité des données. Si vous vous êtes trompé dans les manipulations décrites précédemment, c'est à ce stade que vous ne pourrez plus l'ignorer !

### Menus et accueil

Dans le module [`Data.Session`](../src/Data/Session.elm), ajouter le flag `flowers : Bool` à `EnabledSections`. Ces valeurs sont fournies par les *flags* JavaScript passés à l'initialisation de l'app Elm dans [`index.js`](../index.js) : **⚠️ si ce champ est erroné côté JavaScript, l'application plante au démarrage.**

```elm
type alias EnabledSections =
    { flowers : Bool
    , food : Bool
    , food2 : Bool
    , objects : Bool
    , textile : Bool
    , veli : Bool
    }
```

Dans [`index.js`](../index.js), on ajoute donc le flag `flowers` à `enabledSections`.

> 💡 Parcel fige cette valeur dans le bundle au moment du build. Le menu ne change plus tant qu'on ne rebuild pas !

```js
    enabledSections: {
      flowers: process.env.ENABLE_FLOWERS_SECTION === "True",
      food: process.env.ENABLE_FOOD_SECTION === "True",
      food2: process.env.ENABLE_FOOD2_SECTION === "True",
```

Dans la fonction `mainMenuLinks` du module [`Views.Page`](../src/Views/Page.elm), conditionner l'affichage de la nouvelle entrée de menu sectorielle en vérifiant le flag `enabledSections.flowers` :

```elm
    , addRouteIf enabledSections.flowers
        (\() -> Internal [ text "Fleurs" ] (Route.GenericSimulatorHome Sector.Flowers) (Generic Sector.Flowers))
```

> 💡 Un bouton d'appel sur la page d'accueil est totalement optionnel. S'il est ajouté, le filtrer dans [`Page.Home`](../src/Page/Home.elm) avec le même flag.

Les libellés et terminologies spécifiques à un secteur pour affichage dans l'UI (*"ingrédient"*, *"matériau"*, etc.) se modifient dans la fonction `sectorLabels` du module [`Views.Component`](../src/Views/Component.elm).

### Explorateur

La fonction `sectorMenuView` du module [`Page.Explore`](../src/Page/Explore.elm) doit également être mise à jour pour activer la nouvelle entrée `Fleurs` dans le sélecteur de verticale :

```elm
        , [ ( Sector.Food, enabledSections.food )
          , ( Sector.Generic Sector.Flowers, enabledSections.flowers )
          , ( Sector.Generic Sector.Food2, enabledSections.food2 )
          , ( Sector.Generic Sector.Object, enabledSections.objects )
```

## 4. Configuration, attribution des pays

### Configuration transverse

Dans [`public/data/components/config.json`](../public/data/components/config.json), ajouter la clé `flowers` nécessaire aux sections du type [`Data.Component.Config`](../src/Data/Component/Config.elm) :

- `defaultExamples` : UUID d'un exemple du secteur
- `durability.enabled` : activation du module durabilité
- `endOfLife.enabled` : activation de l'étape de fin de vie
- `endOfLife.scopeCollectionRates` : définition des taux de collecte pour recyclage (si la fin de vie est activée)
- `distribution.defaultProcess` : procédé de distribution par défaut, seulement si le nouveau secteur en dispose
- `docLinks.scoped` : surcharges éventuelles des liens par défaut vers la [documentation GitBook](https://fabrique-numerique.gitbook.io/ecobalyse)

> 💡 Les stratégies de fin de vie (`endOfLife.strategies`) sont partagées ; on ne les duplique pas par secteur.

### Pays accessibles au nouveau secteur

Pour rendre des pays accessibles au nouveau secteur, il convient de les étiqueter dans le fichier [`public/data/countries.json`](../public/data/countries.json) :

```json
  {
    …
    "code": "PT",
    "name": "Portugal",
    "scopes": ["flowers", "object", "veli"],
    …
  },
```

> 💡 Si des procédés doivent être scopés `"flowers"`, il sera nécessaire au préalable d'autoriser l'identifiant dans l'enum `Sector` et l'ensemble `GENERIC_SCOPES` du module Python [`data/models/process.py`](../data/models/process.py), ainsi que dans l'enum `scopes` de [`schemas/lci-schema.json`](../schemas/lci-schema.json).

> 💡 Pour le tri des exemples génériques, on peut également ajouter `"flowers"` au tuple `SCOPES` dans le module Python [`bin/sort_generic_examples.py`](../bin/sort_generic_examples.py).

## 5. JavaScript et variables d'environnement

Le même flag `ENABLE_FLOWERS_SECTION` pilote le menu et la visibilité du secteur au niveau de l'API. Seule la chaîne exacte `"True"` l'active. `False`, `true`, `1` ou une variable absente sont inopérants.

### Registre API

Dans [`lib/sectors.js`](../lib/sectors.js), `GENERIC_SECTOR_CONFIG` expose le registre de l'API générique :

```js
const GENERIC_SECTOR_CONFIG = {
  flowers: { env: "ENABLE_FLOWERS_SECTION", label: "Fleurs" },
  food2: { env: "ENABLE_FOOD2_SECTION", label: "Alimentaire BÉTA" },
  object: { env: "ENABLE_OBJECTS_SECTION", label: "Objets" },
  veli: { env: "ENABLE_VELI_SECTION", label: "Véhicules" },
};
```

Le point d'entrée `GET /api/generic/scopes` ainsi que le contrôle d'accès des URL `/{sector}/*` s'en servent. Un secteur absent de ce registre répond comme s'il n'existait pas.

> ℹ️ À terme, un fichier JSON centralisé de configuration prendra certainement le relais pour définir les propriétés d'un secteur

### Documentation des variables

Ajouter `ENABLE_FLOWERS_SECTION` à [`.env.sample`](../.env.sample) et à la liste des variables frontend du [`README.md`](../README.md).

### Review apps et CI

Activer le flag également là où les autres secteurs génériques le sont déjà :

- [`scalingo.json`](../scalingo.json)
- [`.github/workflows/node.js.yml`](../.github/workflows/node.js.yml)
- [`.github/workflows/e2e.yml`](../.github/workflows/e2e.yml)

> ⚠️ On laissera volontairement de côté le fichier historique [`docker/server-simple.js`](../docker/server-simple.js), actuellement déprécié et non synchronisé avec les en cours de développement autour des fonctionnalités génériques : il n'impacte pas la production et ne subsiste aujourd'hui qu'à des fins d'archivage.

## 6. Déploiement progressif

1. Ouvrir la pull request sans positionner `ENABLE_FLOWERS_SECTION` sur la production. L'absence de variable est traitée comme désactivé. De son côté, le fichier [`scalingo.json`](../scalingo.json) activera le flag sur la review app Scalingo.
2. Une fois la PR recettée et validée, on peut la merger. À ce stade, la production n'affiche pas le menu et répond HTTP 403 sur `/api/flowers/*`
3. Quand le secteur doit devenir public : positionner `ENABLE_FLOWERS_SECTION=True` sur l'application Scalingo de production, puis redéployer pour que Parcel recompile le frontend en conséquence.

> 💡 Si le secteur doit être visible dès le premier déploiement en production, positionner `ENABLE_FLOWERS_SECTION=True` sur l'app Scalingo `ecobalyse` de production au préalable.
