# Construire une requête pour l'API générique

## Introduction

**Ce tutoriel présente pas à pas la modélisation d'une pizza en utilisant [l'API générique](/#/api) dans sa variante *Alimentaire bêta*, afin d'en obtenir le coût environnemental.**

> ⚠️ Attention, l'API générique est en cours de construction, son utilisation ainsi que la présente documentation peuvent être amenées à évoluer

## Prérequis

Les exemples d'appels ci-après utilisent tous l'utiltitaire en ligne de commande `curl`, utilisable depuis un terminal.

Tous les appels s'authentifient de la même façon, en passant le jeton d'authentification via un entête dédié. Vous pouvez obtenir ce jeton d'accès à l'API depuis l'espace de gestion de [votre compte Ecobalyse](/#/auth), dans l'onglet *Jetons d'API*.

```
$ curl -sS "$API/food2/countries" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

Dans cet exemple d'appel et les suivants, il conviendra de remplacer les valeurs suivantes :

- `$API` par l'url courante de l'API, par exemple `https://ecobalyse.beta.gouv.fr/api`
- `$TOKEN` par votre jeton d'accès

Vous pouvez également assigner ces valeurs à des variables d'environnement, par commodité.

```
$ API=https://ecobalyse.beta.gouv.fr/api
$ TOKEN=<votre token ici>
```

## Requêter l'API

Pour poster une requête JSON de modélisation sur le point d'entrée dédié, on utilise le verbe `POST` et le paramètre `-d`:

```
$ curl -sS -X POST "$API/food2/simulator" \
  -H "accept: application/json" \
  -H "content-type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{}'
```

Ici, `{}` est la requête JSON en question ; elle est vide! Elle doit donc renvoyer un score nul dans la réponse HTTP :

```json
{
  "webUrl": "https://ecobalyse.beta.gouv.fr/#/food2/simulator/ecs/eyJjb21wb25lbnR…",
  "impacts": {
    "ecs": 0,
    …
```

La réponse contient notamment `impacts`, qui liste les différentes valeurs d'impact, ainsi qu'un champ `webUrl` qui permet de charger la simulation dans l'interface Web. Le coût environnemental s'obtient en interrogeant le chemin `impacts.ecs`.

> ⚠️ Si des valeurs d'impacts sont nulles, cela peut vouloir dire que vous n'avez pas accepté les conditions générales d'utilisation du service. Veuillez en ce cas vous reporter à votre espace de gestion de compte.

### Modéliser la composition à l'étape de production

L'étape de production décrit avec quoi notre pizza est fabriquée. Pour simplifier l'exercice, considérons notre pizza comme simplement constituée de 4 procédés matières en guise d'ingrédients :

- 250 g de farine
- 100 ml d'eau
- 200 g de tomate
- 70 g de mozzarella

Nous pouvons interroger le point d'entrée `GET /{scope}/processes/material` pour lister et repérer ceux qui pourront nous servir à fabriquer notre pizza :

```
$ curl -sS "$API/food2/processes/material" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

La réponse est un tableau d'objets `{ "id", "name", "unit", "categories" }` parmi lequels se trouve notre farine :

```json
[
  {
    "id": "a2e25aca-1f42-4bc8-bc0e-4d7c751775aa",
    "name": "Farine UE (2025)",
    "unit": "kg",
    "categories": ["ingredient", "material", "material_type:other_food_items"]
  },
  …
]
```

Dans la liste résultante, nous pouvons trouver nos trois autres ingrédients :

- *Eau de source UE*, identifiant `2c2bec89-b05e-5493-a58e-b504fb81c6ea`, unité `L`
- *Tomate FR*, identifiant `b94d40bd-3394-59d3-9397-fe097a5f7138`, unité `kg`
- *Mozzarella FR (2025)*, identifiant `faa513ae-9c32-4e6c-874e-58c13309339e`, unité `kg`

Les quantités s'expriment dans cette unité : 250 g de farine deviennent `"amount": 0.25`, 100 ml d'eau `"amount": 0.1`.

Nous pouvons également interroger le point d'entrée `GET /{scope}/processes/transform/{materialType}` pour voir quels sont les procédés de transformation disponibles pour un type de matière. Le paramètre `materialType` reprend le suffixe de la catégorie `material_type:` du procédé matière (par exemple `fruits_and_vegetables` pour une tomate) ; une valeur invalide ou inconnue sera rejetée avec une erreur HTTP 400.

```
$ curl -sS "$API/food2/processes/transform/fruits_and_vegetables" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

- Nous souhaitons cuire notre tomate, aussi le procédé *Cuisson des fruits et légumes frais*, identifiant `de307fb4-99d3-4a01-962b-242ace7b2739`, paraît adapté.
- Pour la mozzarella, le type de matière est `other_food_items` (`GET /food2/processes/transform/other_food_items`) ; nous retenons *Cuisson divers*, identifiant `6de57003-6767-49e2-a5a1-36ead9b78c42`.
- La farine et l'eau ne subissent pas de transformation, on omet donc le champ `transforms`.

La requête que nous envoyons est donc la suivante :

```json
{
  "components": [
    {
      "quantity": 1,
      "custom": {
        "name": "Farine UE (2025)",
        "elements": [
          {
            "amount": 0.25,
            "material": "a2e25aca-1f42-4bc8-bc0e-4d7c751775aa"
          }
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
          {
            "amount": 0.1,
            "material": "2c2bec89-b05e-5493-a58e-b504fb81c6ea"
          }
        ]
      }
    }
  ]
}
```

À noter, le champ `material` accepte un UUID seul, comme ici, ou un objet `{ "id", "country" }` pour localiser la matière. De même, `transforms` accepte une liste d'UUID ou une liste d'objets `{ "id", "country" }`. Localiser ces porocédés permet de mobiliser des micx énergétiques appropriés.

Nous réutiliserons ce tableau de `components` dans les étapes suivantes.

### Le catalogue d'ingrédients/matériaux

Le *catalogue* (`GET /{scope}/catalog`) recense des ingrédients ou matériaux complets déjà modélisés: matières premières et éventuelles transformations de ces dernières comprises. On les mobilise simplement par leur identifiant :

```
$ curl -sS "$API/food2/catalog" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

```json
{"id": "<uuid catalogue>", "quantity": 1}
```

> ⚠️ Pour l'heure, le domaine alimentaire bêta ne dispose pas encore de composants, ces derniers viendront par la suite.

### Les procédés matières

Les *procédés matières* (`GET /{scope}/processes/material`) recensent eux les ingrédients ou matériaux *bruts* (par exemple, non transformés). On construit alors un composant `custom`: une liste d'éléments (`elements`), chacun mobilisant :

- une matière (`id`)
- une quantité de cette dernière (`amount`)
- éventuellement, une ou plusieurs étapes successives de transformation (`transforms`, dont la liste des valeurs possibles est fournie par `GET /{scope}/processes/transform/{materialType}`)

> 💡 Les transformations ne s'appliquent qu'à l'élément qui les porte, dans l'ordre et avec application séquentielle du taux de perte résultant

Une entrée du tableau `components` peut donc prendre trois formes :

1. `id` seul : on reprend un composant existant du catalogue tel quel
2. `custom` seul : on décrit un composant entièrement nouveau
3. `id` et `custom` ensemble: on part d'un composant existant du catalogue, et on le surcharge (on, peut surcharger ou redéfinir ses éléments, son nom, etc.)

> ⚠️ Comme vu précédemment, faute de composants alimentaires, une recette se décrit pour l'heure uniquement en mobilisant des champs de type `custom`.

## Anatomie d'un corps de requête JSON

Pour obtenir le coût environnemental de notre pizza, il faut donc renseigner le paramétrage des étapes de son cycle de vie ; pour chacune, une clé JSON correspond.

Les identifiants (ingrédients, procédés, pays, catégories) sont exposés par des points d'entrée de type `GET`. Le champ `amount` s'exprime toujours dans l'unité `unit` renvoyée par la liste de procédés correspondants (par exemple, `kg` ou `m2`).

Voici les différents champs de la requête, par phase ou spécificité du cycle de vie. Hormis `quantity` sur chaque composant, tous les champs sont optionnels.

### Composition (`components`)

- Type: tableau d'objets. Chaque objet a un `quantity` obligatoire (entier ≥ 1) et, selon le cas, un `id`, un `custom`, ou les deux.
- Source: `GET /{scope}/catalog` pour les `id`; `GET /{scope}/processes/material` et `GET /{scope}/processes/transform/{materialType}` pour un composant `custom`.
- Utilisation: décrit la production, c'est à dire de quoi le produit est fait. Le champ `id` référence un composant existant du catalogue ; le champ `custom` le décrit (ou le surcharge) via `elements` (matière, quantité, transformations éventuelles).
- Par défaut: tableau vide. Le champ est obligatoire dès que le corps n'est pas `{}`; on peut envoyer `"components": []`.

### Catégorie de produit (`product`)

- Type: UUID.
- Source: `GET /{scope}/categories`.
- Utilisation: la catégorie de produit peut fournir des valeurs par défaut pour `assembly.operations`, `consumptions`, `distribution` et `transportOptions.cooling`. Un champ présent dans la requête l'emporte toujours sur ces défauts.
- Par défaut: aucune catégorie de produit n'est appliquée.

### Assemblage (`assembly`)

- Type: objet `{ "country", "operations" }`:
  * `country` est un code pays
  * `operations` est un tableau d'UUID de procédés
- Source: `GET /{scope}/countries` et `GET /{scope}/processes/assembly`.
- Utilisation: localise l'assemblage (et le transport amont vers ce pays) et, le cas échéant, applique des procédés d'assemblage.
- Par défaut: champ omis = pas de pays, et les opérations de la catégorie `product` s'il y en a (sinon aucune). `"operations": []` désactive explicitement ces défauts. Omettre seulement `country` ou seulement `operations` est possible.

### Distribution (`distribution`)

- Type: UUID (une seule valeur, ce n'est pas un tableau).
- Source: `GET /{scope}/processes/distribution`.
- Utilisation: procédé de l'étape de distribution (vente au détail, etc.).
- Par défaut: si le champ est omis, celui de la catégorie `product`, sinon celui de la configuration du périmètre.

### Transport (`transportOptions`)

- Type: objet `{ "cooling", "byAir" }`:
  * `cooling` est un booléen et précise si le transport est réfrigéré
  * `byAir` est un nombre entre `0` et `100` et précise le taux de transport aérien vers l'étape de distribution
- Utilisation: options du transport *vers la distribution* uniquement, pas des transports entre pays de matière déjà portés par `country`.
- Par défaut: `byAir` vaut `0`. `cooling` omis prend la valeur de la catégorie `product`, ou `false` s'il n'y en a pas. On peut n'envoyer qu'une des deux clés.

### Emballage (`packagings`)

- Type: tableau d'objets `{ "amount", "processId" }` (`amount` et `processId` obligatoires). `amount` est dans l'unité `unit` du procédé (`item`, `kg`, etc.).
- Source: `GET /{scope}/processes/packaging`.
- Utilisation: emballages du produit. Ces procédés ne figurent pas dans `processes/material`.
- Par défaut: tableau vide, que le champ soit omis ou envoyé comme `[]`. Il n'y a pas de défaut de catégorie.

### Consommations en phase d'utilisation (`consumptions`)

- Type: tableau d'objets `{ "amount", "processId" }`, même forme que `packagings`.
- Source: `GET /{scope}/processes/consumption`.
- Utilisation: procédés de l'étape d'utilisation (cuisson, réfrigération, etc.). Beaucoup de procédés alimentaires sont proportionnels à la masse du produit (`unit` souvent `kg`).
- Par défaut: champ omis = consommations de la catégorie `product` (ou aucune s'il n'y a pas de catégorie). `"consumptions": []` = aucune consommation, même si la catégorie en prévoit.

### Recyclabilité à l'étape Fin de vie (`recyclable`)

- Type: booléen.
- Utilisation: indique si le produit est recyclable. N'a d'effet que si la fin de vie est active (`object`, `veli`; pas `food2`).
- Par défaut: `true`.

### Durabilité (`durability`)

- Type: nombre (coefficient). Les impacts totaux sont divisés par cette valeur.
- Utilisation: durabilité du produit. Activé pour `object` et `veli`; *rejeté* pour `food2` (ne pas l'envoyer dans une requête alimentaire).
- Par défaut: champ omis = pas de coefficient appliqué.

> **💡 Notes :**
> - Deux notions de quantité cohabitent, et il est facile de les confondre. `quantity` est un entier (au moins 1) qui compte les exemplaires du composant: quatre olives sur notre pizza, c'est `"quantity": 4`, si l'on dispose d'un ingrédient olive unitaire. `amount` est la quantité de matière, d'emballage ou de consommation: 150 g de farine s'écrivent `"amount": 0.15` si l'unité est le kilogramme.
> - Omettre un champ n'équivaut pas toujours à envoyer `[]`: c'est vrai pour `packagings`, mais pas pour `consumptions` ni `assembly.operations`, où `[]` désactive les défauts de la catégorie.

## L'étape d'assemblage

La phase d'assemblage localise le lieu où le produit est monté, et peut appliquer des procédés d'assemblage. La liste des procédés d'assemblage disponibles s'obtient ainsi :

```
$ curl -sS "$API/food2/processes/assembly" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

Pas de procédé d'assemblage intéressants pour notre pizza, on se contente donc d'indiquer le pays (la liste des codes pays s'obtient via `GET /food2/countries`) :

```json
  "assembly": {"country": "FR"}
```

> 💡 Les `operations` d'assemblage se rencontrent davantage sur les périmètres `object` et `veli`. Exemple véhicules (`GET /veli/processes/assembly` nous renvoit notamment un procédé "Assemblage") :
>
>```json
>  "assembly": {"country": "FR", "operations": ["c51ab87d-f368-4704-a5ec-7ea17ba87d46"]}
>```

## La catégorie de produit

`GET /{scope}/categories` renvoie les catégories de produits, et pour chacune, les valeurs par défaut qui l'accompagnent.

```
$ curl -sS "$API/food2/categories" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

```json
  {
    "consumptions": ["b4642cec-b72e-4116-81c5-5dbfccb46055", "1040ee69-9dff-47f1-a989-c7cd04d2c419"],
    "cooling": true,
    "distribution": "be66b80b-1500-4e3b-bfd2-87a89ff54031",
    "id": "18fdea50-1a04-4948-bf13-7b54e169235b",
    "label": "Plats préparés",
    "scope": "food2"
  }
```

Si l'on choisit *Plats préparés* (`18fdea50-1a04-4948-bf13-7b54e169235b`) pour notre pizza, cette catégorie prévoit :

- Une distribution en produit frais ;
- Un transport réfrigéré ;
- Des consommations de réfrigération et de micro-ondes en phase d'utilisation.

On peut alors omettre de spécifier `distribution`, `consumptions` et `transportOptions.cooling`, puisque les valeurs par défaut de la catégorie de produit seront appliquées :

```json
  "product": "18fdea50-1a04-4948-bf13-7b54e169235b",
  "assembly": {"country": "FR"}
```

La catégorie *Produits congelés* (`1eacb555-5f0c-498e-8e97-f4c9104642e4`), en revanche, imposerait une distribution surgelée et des consommations de congélation et de four.

## L'étape de distribution

La liste des procédés mobilisables à l'étape de distribution s'obtient via un point d'entrée dédié :

```
$ curl -sS "$API/food2/processes/distribution" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

Le champ de requête `distribution` n'accepte qu'un seul procédé.

> Note: Sans préciser de catégorie de produit, une valeur par défaut peut s'appliquer si configurée comme telle pour le périmètre mobilisé. Ici, le périmètre `food2` applique *Vente au détail : produit sec* (`29118025-efa0-47bb-94e2-f5ccba31a903`) si rien n'est spécifié par l'utilisateur dans la requête.

Pour une pizza vendue au détail en produit frais, on peut choisir le procédé de distribution *Vente au détail : produit frais* :

```json
  "distribution": "be66b80b-1500-4e3b-bfd2-87a89ff54031"
```

## Le transport vers la distribution

Ce paramètre permet de préciser :

- si le transport est réfrigéré (`cooling` à `true`)
- la part de transport aérien dans son acheminement vers la distribution (on pense à la mangue brésilienne par exemple)

Pour notre pizza, le transport est réfrigéré et aucun transport en avion n'est opéré :

```json
  "transportOptions": {"cooling": true, "byAir": 0}
```

## L'emballage

La liste des procédés d'emballage se récupère en utilisant un point d'entrée dédié :

```
$ curl -sS "$API/food2/processes/packaging" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

Pour notre pizza réfrigérée, on peut retenir le *Sachet en plastique (PE) flow pack et étui carton pour pizza, réfrigérée - 380g* (`fa775270-4bc7-4f6d-a9d3-c80ed05ed90c`), unité `item` :

```json
  "packagings": [
    {"amount": 1, "processId": "fa775270-4bc7-4f6d-a9d3-c80ed05ed90c"}
  ]
```

## La phase d'utilisation

La liste des procédés de consommation en phase d'utilisation se récupère par le point d'entrée suivant :

```
$ curl -sS "$API/food2/processes/consumption" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $TOKEN"
```


Beaucoup de procédés alimentaires sont proportionnels à la masse du produit (ils sont alors étiquettés `productmassdependent`). Noitre pizza sera cuite au four, on utilise donc le procédé *Cuisson au four* :
```json
  "consumptions": [
    "a49670fc-0642-43f6-a673-fe15dc7d88da"
  ]
```

> 💡 Omettre de renseigner le champ `consumptions` alors qu'une catégorie de produit est stpiulée, c'est accepter les valeurs par défaut de cette dernière (pour les *Plats préparés*, réfrigération et cuisson au micro-ondes). On peut imposer la non-utilisation de procédés de consommation en explicitant une liste vide : `"consumptions": []`.

## Pour résumer

Envoyons notre requête finale modélisant notre pizza :

```
$ curl -sS -X POST "$API/food2/simulator" \
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
  "consumptions": [
    {"amount": 0.62, "processId": "a49670fc-0642-43f6-a673-fe15dc7d88da"}
  ]
}'
```

Son coût environnemental se trouve dans la clé `impacts.ecs` de la réponse JSON.
