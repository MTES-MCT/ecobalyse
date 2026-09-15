# Construire une requête pour l'API générique

---

Ce tutoriel présente pas à pas la modélisation d'une pizza en utilisant [l'API générique](/#/api) dans sa variante *Alimentaire bêta*, afin d'en obtenir le coût environnemental.

Nous utiliserons pour cela le point d'entrée `POST /food2/simulator` sur lequel nous posterons un objet JSON qui représente notre modélisation.

> ⚠️ attention, l'API générique est en cours de construction, son utilisation ainsi que la présente documentation peuvent être amenées à évoluer

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

Vous pouvez également assigner ces valeurs aux variables d'environnement, par commodité.

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
