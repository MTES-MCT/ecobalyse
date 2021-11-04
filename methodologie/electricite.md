---
description: Choix du mix électrique à appliquer en fonction du pays
---

# Electricité

## Procédés

Le mix électrique appliqué dépend du pays dans lequel l'étape correspondante est réalisée.

| Pays       | Procédé électricité       | UUID                                 |
| ---------- | ------------------------- | ------------------------------------ |
| Bangladesh | Mix électrique réseau, BD | 1ee6061e-8e15-4558-9338-94ad87abf932 |
| Chine      | Mix électrique réseau, CN | 8f923f3d-0bd2-4326-99e2-f984b4454226 |
| Espagne    | Mix électrique réseau, ES | 37301c44-c4cf-4214-a4ac-eee5785ccdc5 |
| France     | Mix électrique réseau, FR | 05585055-9742-4fff-81ff-ad2e30e1b791 |
| Inde       | Mix électrique réseau, IN | 1b470f5c-6ae6-404d-bd71-8546d33dbc17 |
| Portugal   | Mix électrique réseau, PT | a1d83202-0052-4d10-b9d2-938564be6a0b |
| Tunisie    | Mix électrique réseau, TN | f0eb64cd-468d-4f3c-a9a3-3b3661625955 |
| Turquie    | Mix électrique réseau, TR | 6fad8643-de3e-49dd-a48b-8e17b4175c23 |

## Limites

Il peut être proposé :&#x20;

* d'ajouter de nouveaux pays, et donc de nouveaux mix énergétiques ;
* de proposer un mix énergétique sur mesure, permettant par exemple de modéliser un site industriel qui assurerait directement sa production énergétique pour l'électricité (panneaux photovoltaïques par exemple).

## \[Projet] Paramétrage manuel

A chaque étape de la production qui mobilise de l'électricité, il est proposé de paramétrer manuellement l'intensité carbone du mix énergétique.

Par défaut, l'intensité carbone du mix énergétique est la valeur spécifiée dans la base Impacts, pour l'impact "changement climatique" (UUID : `b2ad6d9a-c78d-11e6-9d9d-cec0c932ce01)`, pour chacun des mix électriques nationaux mentionnés (ci-dessus).

{% hint style="warning" %}
Le paramétrage manuel ne concerne que le changement climatique et pas les autres impacts qui pourraient être prochainement intégrés dans l'outil Wikicarbone
{% endhint %}

{% hint style="warning" %}
La modification manuelle de l'intensité carbone&#x20;
{% endhint %}
