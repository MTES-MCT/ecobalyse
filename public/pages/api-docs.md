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

Pour poster une requête JSON de modélisation, on utilise le paramètre `-d`:

```
$ curl -sS -X POST "$API/food2/simulator" \
  -H "accept: application/json" \
  -H "content-type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{}'
```

Ici, `{}` est la requête JSON en question; elle est vide! Elle doit donc renvoyer un score nul:

```json
{
  "webUrl": "https://ecobalyse.beta.gouv.fr/#/food2/simulator/ecs/eyJjb21wb25lbnR…",
  "impacts": {
    "acd": 0,
    …
```

La réponse contient notamment `impacts`, qui liste les différentes valeurs d'impact, ainsi qu'un champ `webUrl` qui permet de charger la simulation dans l'interface Web.

## Anatomie d'un corps de requête JSON

Pour obtenir le coût environnemental de notre pizza, il faut renseigner les étapes de son cycle de vie ; pour chacune, une clé JSON correspond.

Les identifiants (ingrédients, procédés, pays, catégories) sont exposés par des points d'entrée `GET`. Le champ `amount` s'exprime toujours dans l'unité `unit` renvoyée par la liste correspondante (par exemple, `kg` ou `m2`).

Voici les différents champs de la requête, dans l'ordre du cycle de vie. Tous les champs sont optionnels.

### Composition (`components`)

- Type: tableau d'objets. Chaque objet a un `quantity` obligatoire (entier ≥ 1) et, selon le cas, un `id`, un `custom`, ou les deux.
- Source: `GET /{scope}/catalog` pour les `id`; `GET /{scope}/processes/material` et `GET /{scope}/processes/transform` pour un `custom`.
- Utilisation: décrit la production, c'est-à-dire de quoi le produit est fait. Un `id` reprend un composant du catalogue; un `custom` le décrit (ou le surcharge) via `elements` (matière, quantité, transformations éventuelles).
- Défaut: tableau vide. Le champ est obligatoire dès que le corps n'est pas `{}`; on peut envoyer `"components": []`.

### Catégorie de produit (`product`)

- Type: UUID.
- Source: `GET /{scope}/categories`.
- Utilisation: La catégorie de produit peut fournir des valeurs par défaut pour les étapes d'asseblmage, d'utilisation, de distribution et de transport/  `assembly.operations`, `consumptions`.
- Défaut: aucune catégorie de produit n'est appliquée par défaut.

### Assemblage (`assembly`)

- Type: objet `{ "country", "operations" }`. `country` est un code pays; `operations` est un tableau d'UUID de procédés.
- Source: `GET /{scope}/countries` et `GET /{scope}/processes/assembly`.
- Utilisation: localise l'assemblage (et le transport amont vers ce pays) et, le cas échéant, applique des procédés d'assemblage.
- Défaut: champ omis = pas de pays, et les opérations de la catégorie `product` s'il y en a (sinon aucune). `"operations": []` désactive explicitement ces défauts. Omettre seulement `country` ou seulement `operations` est possible.

### Distribution (`distribution`)

- Type: UUID (une seule valeur, ce n'est pas un tableau).
- Source: `GET /{scope}/processes/distribution`.
- Utilisation: procédé de l'étape de distribution (vente au détail, etc.).
- Défaut: si le champ est omis, celui de la catégorie `product`, sinon celui de la configuration du périmètre

### Transport (`transportOptions`)

- Type: objet `{ "cooling", "byAir" }`. `cooling` est un booléen; `byAir` un nombre entre `0` et `100` (pourcentage de transport aérien vers la distribution).
- Utilisation: options du transport *vers la distribution* uniquement, pas des transports entre pays de matière déjà portés par `country`.
- Défaut: `byAir` vaut `0`. `cooling` omis prend la valeur de la catégorie `product`, ou `false` s'il n'y en a pas. On peut n'envoyer qu'une des deux clés.

### Emballage (`packagings`)

- Type: tableau d'objets `{ "amount", "processId" }` (`amount` et `processId` obligatoires). `amount` est dans l'unité `unit` du procédé (`item`, `kg`, etc.).
- Source: `GET /{scope}/processes/packaging`.
- Utilisation: emballages du produit. Ces procédés ne figurent pas dans `processes/material`.
- Défaut: tableau vide, que le champ soit omis ou envoyé comme `[]`. Il n'y a pas de défaut de catégorie.

### Consommations en phase d'utilisation (`consumptions`)

- Type: tableau d'objets `{ "amount", "processId" }`, même forme que `packagings`.
- Source: `GET /{scope}/processes/consumption`.
- Utilisation: procédés de l'étape d'utilisation (cuisson, réfrigération, etc.). Beaucoup de procédés alimentaires sont proportionnels à la masse du produit (`unit` souvent `kg`).
- Défaut: champ omis = consommations de la catégorie `product` (ou aucune s'il n'y a pas de catégorie). `"consumptions": []` = aucune consommation, même si la catégorie en prévoit.

### Recyclabilité à l'étape Fin de vie (`recyclable`)

- Type: booléen.
- Utilisation: indique si le produit est recyclable. N'a d'effet que si la fin de vie est active (`object`, `veli`; pas `food2`).
- Défaut: `true`.

### Durabilité (`durability`)

- Type: nombre (coefficient). Les impacts totaux sont divisés par cette valeur.
- Utilisation: durabilité du produit. Activé pour `object` et `veli`; *rejeté* pour `food2` (ne pas l'envoyer dans une requête alimentaire).
- Défaut: champ omis = pas de coefficient appliqué.

> **💡 Notes :**
> - Deux notions de quantité cohabitent, et il est facile de les confondre. `quantity` est un entier (au moins 1) qui compte les exemplaires du composant: quatre olives sur notre pizza, c'est `"quantity": 4`, si l'on dispose d'un ingrédient olive unitaire. `amount` est la quantité de matière, d'emballage ou de consommation: 150 g de farine s'écrivent `"amount": 0.15` si l'unité est le kilogramme.
> - Omettre un champ n'équivaut pas toujours à envoyer `[]`: c'est vrai pour `packagings`, mais pas pour `consumptions` ni `assembly.operations`, où `[]` désactive les défauts de la catégorie.


## L'étape de production

C'est l'étape où l'on décrit avec quoi notre pizza est fabriquée. Le tableau `components` se construit de deux façons, que l'on peut d'ailleurs mélanger dans une même requête.

### Le catalogue d'ingrédients/matériaux

Le *catalogue* (`GET /{scope}/catalog`) recense des ingrédients ou matériaux complets déjà modélisés: matières premières et éventuelles transformations de ces dernières comprises. On les mobilie simplement par leur identifiant :

```json
{"id": "<uuid catalogue>", "quantity": 1}
```

### Les procédés matières

Les *procédés matières* (`GET /{scope}/processes/material`) recensent eux les ingrédients ou matériaux *bruts* (par exemple, non transformés On construit alors un composant `custom`: une liste d'éléments (`elements`), chacun muni d'une matière (`id`), d'une quantité de cette dernière (`amount`) et, éventuellement, d'étapes séquentielles de transformation (`transforms`, dont la liste des valeurs possibles est fournie par `GET /{scope}/processes/transform`). Une transformation ne s'applique qu'à l'élément qui la porte, dans l'ordre du tableau, et non au produit entier. Omettre `transforms` équivaut à envoyer une liste vide (`[]`).

Une entrée di tableau `components` peut donc prendre trois formes :

1. `id` seul : on reprend un composant du catalogue tel quel
2. `custom` seul : on décrit un composant entièrement nouveau
3. `id` et `custom` ensemble: on part d'un composant du catalogue et on le surcharge (éléments, nom, etc.)

> ⚠️ Actuellement, le catalogue de composants est vide pour le périmètre Alimentaire Bêta (`foo2`) : `GET /food2/catalog` renvoie `[]`. Une recette se décrit donc pour l'heure uniquement en mobilisant des champs de type `custom`.
