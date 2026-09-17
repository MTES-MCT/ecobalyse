# Construire une requête pour l'API générique

## Introduction

**Ce tutoriel présente pas à pas la modélisation d'une pizza en utilisant [l'API générique](/#/api) dans sa variante *Alimentaire bêta*, afin d'en obtenir le coût environnemental.**

L'API générique existe pour trois périmètres : `food2` (alimentaire bêta), `object` (objets) et `veli` (véhicules). Ici, tous les appels utilisent `food2`.

> ⚠️ Attention, l'API générique est en cours de construction, son utilisation ainsi que la présente documentation peuvent être amenées à évoluer

## Prérequis

Les exemples d'appels ci-après utilisent tous l'utilitaire en ligne de commande `curl`, utilisable depuis un terminal.

Tous les appels s'authentifient de la même façon, en passant le jeton d'authentification via un entête dédié. Vous pouvez obtenir ce jeton d'accès à l'API depuis l'espace de gestion de [votre compte Ecobalyse](/#/auth), dans l'onglet *Jetons d'API*. Un appel sans jeton, ou avec un jeton invalide, est rejeté avec une erreur HTTP 401.

> 💡 Pour permettre de jouer les exemples d'appels `curl` par simple copier-coller, assignez au préalable l'URL de l'API et votre jeton à des variables d'environnement dans votre terminal :
>
>```
>API=https://ecobalyse.beta.gouv.fr/api
>TOKEN=<votre token ici>
>```

## Premier appel : une requête vide

Pour poster une requête JSON de modélisation, on utilise le verbe `POST` et le paramètre `-d` :

```bash
curl -sS -X POST "$API/food2/simulator" \
  -H "accept: application/json" \
  -H "content-type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{}'
```

Ici, `{}` est la requête JSON en question ; elle est vide. Elle doit donc renvoyer un score nul :

```json
{
  "webUrl": "https://ecobalyse.beta.gouv.fr/#/food2/simulator/ecs/eyJjb21wb25lbnR…",
  "impacts": {
    "ecs": 0,
    …
```

La réponse contient `impacts` (le coût environnemental est `impacts.ecs`) et `webUrl`, qui charge la simulation dans l'interface Web.

> ⚠️ Si des valeurs d'impacts sont nulles alors que la requête n'est pas vide, cela peut vouloir dire que vous n'avez pas accepté les conditions générales d'utilisation du service. Veuillez en ce cas vous reporter à votre espace de gestion de compte.

## La composition

L'étape de production décrit avec quoi notre pizza est fabriquée. Pour simplifier, elle est constituée de quatre procédés matières :

- 250 g de farine
- 100 ml d'eau
- 200 g de tomate
- 70 g de mozzarella

Listons les procédés matières :

```bash
curl -sS "$API/food2/processes/material" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

La réponse est un tableau d'objets `{ "id", "name", "unit", "categories" }`. On y trouve par exemple la farine :

```json
{
  "id": "a2e25aca-1f42-4bc8-bc0e-4d7c751775aa",
  "name": "Farine UE (2025)",
  "unit": "kg",
  "categories": ["ingredient", "material", "material_type:other_food_items"]
}
```

Pour retrouver un ingrédient dans la liste, cherchez son nom dans la réponse JSON, par exemple avec [jq](https://jqlang.org/) :

```bash
curl -sS "$API/food2/processes/material" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.[] | select(.name | test("Tomate"; "i"))'
```

On trouvera de la même manière nos trois autres ingrédients :

- *Eau de source UE*, identifiant `2c2bec89-b05e-5493-a58e-b504fb81c6ea`, unité `L`, `material_type:other_food_items`
- *Tomate FR*, identifiant `b94d40bd-3394-59d3-9397-fe097a5f7138`, unité `kg`, `material_type:fruits_and_vegetables`
- *Mozzarella FR (2025)*, identifiant `faa513ae-9c32-4e6c-874e-58c13309339e`, unité `kg`, `material_type:other_food_items`

## Les transformations

Certains ingrédients sont cuits. Les procédés de transformation se listent par type de matière : le paramètre `materialType` reprend le suffixe de la catégorie `material_type:` du procédé matière (`fruits_and_vegetables` pour la tomate).

```bash
curl -sS "$API/food2/processes/transform/fruits_and_vegetables" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

```bash
curl -sS "$API/food2/processes/transform/other_food_items" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

- Pour la tomate, *Cuisson des fruits et légumes frais*, identifiant `de307fb4-99d3-4a01-962b-242ace7b2739`.
- Pour la mozzarella, *Cuisson divers*, identifiant `6de57003-6767-49e2-a5a1-36ead9b78c42`.
- Farine et eau ne sont pas transformés, donc le champ `transforms` est omis complètement

## Première simulation

Postons notre simulation :

```bash
curl -sS -X POST "$API/food2/simulator" \
  -H "accept: application/json" \
  -H "content-type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
  "components": [
    {
      "quantity": 1,
      "custom": {
        "name": "Farine UE (2025)",
        "elements": [
          {"amount": 0.25, "material": "a2e25aca-1f42-4bc8-bc0e-4d7c751775aa"}
        ]
      }
    },
    {
      "quantity": 1,
      "custom": {
        "name": "Tomate FR",
        "elements": [
          {
            "amount": 0.2,
            "material": "b94d40bd-3394-59d3-9397-fe097a5f7138",
            "transforms": ["de307fb4-99d3-4a01-962b-242ace7b2739"]
          }
        ]
      }
    },
    {
      "quantity": 1,
      "custom": {
        "name": "Mozzarella FR (2025)",
        "elements": [
          {
            "amount": 0.07,
            "material": "faa513ae-9c32-4e6c-874e-58c13309339e",
            "transforms": ["6de57003-6767-49e2-a5a1-36ead9b78c42"]
          }
        ]
      }
    },
    {
      "quantity": 1,
      "custom": {
        "name": "Eau de source UE",
        "elements": [
          {"amount": 0.1, "material": "2c2bec89-b05e-5493-a58e-b504fb81c6ea"}
        ]
      }
    }
  ]
}'
```

Notez que `impacts.ecs` n'est déjà plus nul !

Notes:
- Le champ `amount` s'exprime dans l'`unit` du procédé : 250 g de farine deviennent `"amount": 0.25`, 100 ml d'eau `"amount": 0.1`. À ne pas confondre avec `quantity`, qui compte le *nombre d'exemplaires* du composant par un entier supérieur ou égal à 1.
- Le champ `webUrl` de la réponse permet de charger la simulation dans un navigateur Web.


## L'assemblage

Localisons maintenant le lieu où notre pizza sera assemblée. La liste des codes pays s'obtient ainsi :

```bash
curl -sS "$API/food2/countries" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

Indiquons que notre pizza est assemblée en France :

```json
  "assembly": {"country": "FR"}
```

> 💡 Les `operations` d'assemblage se rencontrent surtout sur les périmètres `object` et `veli`.

## L'emballage

```bash
curl -sS "$API/food2/processes/packaging" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

Pour notre pizza réfrigérée, on retient le *Sachet en plastique (PE) flow pack et étui carton pour pizza, réfrigérée - 380g* (`fa775270-4bc7-4f6d-a9d3-c80ed05ed90c`), que l'on mobilise ainsi dans la requête :

```json
  "packagings": [
    {"amount": 1, "processId": "fa775270-4bc7-4f6d-a9d3-c80ed05ed90c"}
  ]
```

> 💡 il est possible de préciser plusieurs emballages pour un même produit (par exemple, pour un lot)


## La distribution et le transport

Les procédés de distribution sont récupérables par le point d'entrée dédié :

```bash
curl -sS "$API/food2/processes/distribution" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

Le champ `distribution` n'accepte qu'un seul procédé. Pour une pizza vendue au détail en produit frais :

```json
  "distribution": "be66b80b-1500-4e3b-bfd2-87a89ff54031"
```

> 💡 En l'absence d'une valeur spécifié pour ce champ, le périmètre `food2` est configuré pour appliquer le procédé *Vente au détail : produit sec* par défaut.

Le transport *entre assemblage et distribution* se paramètre via l'objet `transportOptions` :

```json
  "transportOptions": {"cooling": true, "byAir": 0}
```

Le champ `cooling` indique un transport réfrigéré, `byAir` la part de transport aérien (de `0` à `100`).

## La phase d'utilisation

Les procédés de consommation en phase d'utilisation du produit sont récupérés via un point d'entrée dédié :

```bash
curl -sS "$API/food2/processes/consumption" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

Notre pizza étant vouée à être cuite au four, on mobilisera *Cuisson au four* (`a49670fc-0642-43f6-a673-fe15dc7d88da`). Ce procédé est étiqueté `productmassdependent` : le moteur de calcul utilisera la masse du produit, donc nul besoin de préciser `amount` :

```json
  "consumptions": [
    {"processId": "a49670fc-0642-43f6-a673-fe15dc7d88da"}
  ]
```



## Pour résumer

La requête finale assemble les différents champs que nous avons parcourus :

- `components`
- `assembly`
- `packagings`
- `distribution`
- `transportOptions`
- `consumptions`

```bash
curl -sS -X POST "$API/food2/simulator" \
  -H "accept: application/json" \
  -H "content-type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
  "assembly": {"country": "FR"},
  "components": [
    {
      "quantity": 1,
      "custom": {
        "name": "Farine UE (2025)",
        "elements": [
          {"amount": 0.25, "material": "a2e25aca-1f42-4bc8-bc0e-4d7c751775aa"}
        ]
      }
    },
    {
      "quantity": 1,
      "custom": {
        "name": "Tomate FR",
        "elements": [
          {
            "amount": 0.2,
            "material": "b94d40bd-3394-59d3-9397-fe097a5f7138",
            "transforms": ["de307fb4-99d3-4a01-962b-242ace7b2739"]
          }
        ]
      }
    },
    {
      "quantity": 1,
      "custom": {
        "name": "Mozzarella FR (2025)",
        "elements": [
          {
            "amount": 0.07,
            "material": "faa513ae-9c32-4e6c-874e-58c13309339e",
            "transforms": ["6de57003-6767-49e2-a5a1-36ead9b78c42"]
          }
        ]
      }
    },
    {
      "quantity": 1,
      "custom": {
        "name": "Eau de source UE",
        "elements": [
          {"amount": 0.1, "material": "2c2bec89-b05e-5493-a58e-b504fb81c6ea"}
        ]
      }
    }
  ],
  "packagings": [
    {"amount": 1, "processId": "fa775270-4bc7-4f6d-a9d3-c80ed05ed90c"}
  ],
  "distribution": "be66b80b-1500-4e3b-bfd2-87a89ff54031",
  "transportOptions": {"cooling": true, "byAir": 0},
  "consumptions": ["a49670fc-0642-43f6-a673-fe15dc7d88da"]
}'
```

Le coût environnemental final du produit correspondant se trouve dans la clé `impacts.ecs`.

## Pour aller plus loin

### Catégorie de produit

Le point d'entrée `GET /food2/categories` liste des catégories de produit qui fournissent des valeurs par défaut.

Par exemple, la catégorie *Plats préparés* (`18fdea50-1a04-4948-bf13-7b54e169235b`) impose une distribution en produit frais, un transport réfrigéré, et des consommations de réfrigération et de micro-ondes. On peut alors omettre `distribution`, `consumptions` et `transportOptions.cooling` dans notre requête en précisant que la catégorie de produit est celle des *Plats préparés* :

```json
  "product": "18fdea50-1a04-4948-bf13-7b54e169235b",
  "assembly": {"country": "FR"}
```

Chaque champ manuellement spécifié aura toujours précédence sur les valeurs par défaut fournies par la catégorie de produit. Pour surcharger ou supprimer ces valeurs catégorielles par défaut, il convient alors de forcer leur valeurs ; par exemple, en stipulant `"consumptions": []` qui désactivera explicitement les consommations, y compris celles découlant de la catégorie.

### Origine d'un procédé

Les champs `material` et `transforms` acceptent un UUID seul, comme dans ce tutoriel, ou un objet `{ "id", "country" }` pour localiser les procédés (ce qui permet de mobiliser le mix énergétique du pays en question).

### Catalogue

Sur la verticale `object`, `GET /{scope}/catalog` recense des composants déjà modélisés, que l'on ajoute avec `{"id": "<uuid>", "quantity": 1}`.

### Référence

La [documentation interactive de l'API](/#/api) décrit l'ensemble des paramètres et des points d'entrée de façon plus exhaustive et détaillée.
