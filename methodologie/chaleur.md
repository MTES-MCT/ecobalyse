---
description: Choix du procédé de chaleur en fonction du pays
---

# 🔥 Chaleur

## Procédés

Le procédé de chaleur appliqué dépend du pays dans lequel l'étape correspondante est réalisée.

En première approche, seulement trois procédés sont mobilisés. Le détail pays par pays est présenté dans l'explorateur.

| Pays                     | Procédé chaleur                                                                | UUID                                 |
| ------------------------ | ------------------------------------------------------------------------------ | ------------------------------------ |
| France                   | Mix Vapeur (mix technologique\|mix de production, en sortie de chaudière), FR  | 12fc43f2-a007-423b-a619-619d725793ea |
| Autres pays européens    | Mix Vapeur (mix technologique\|mix de production, en sortie de chaudière), RER | 63b1b03f-1f73-4791-829d-d49c06ddc8ee |
| Autres pays, hors Europe | Mix Vapeur (mix technologique\|mix de production, en sortie de chaudière), RSA | 2e8de6f6-0ea1-455b-adce-ea74d307d222 |

{% hint style="warning" %}
Ces choix de procédés doivent être discutés. Ils sont sélectionnés parmi les procédés proposés dans la base Impacts. Plusieurs points discutables apparaissent :&#x20;

* Des pays hors Asie (par exemple Afrique du Nord) se voient appliqué un mix vapeur RSA (Asie Pacifique).
* Cette approche ne permet pas de distinguer des mix vapeur nationaux qui seraient spécifiques (exemple : transition du fuel lourd vers le gaz en Tunisie).
* Dans le cas de la France, un procédé de mix vapeur spécifique à ce pays est proposé. La France est le seul pays pour lequel un tel procédé est proposé dans la base Impacts.
{% endhint %}

## Limites

Il peut être proposé :&#x20;

* d'ajouter de nouveaux pays ;
* de proposer une source de chaleur paramétrable, en tirant profit des procédés disponibles dans la base Impacts (Gaz naturel, Fuel lourd, Fuel léger, Charbon, Bois) ;
* une analyse de sensibilité serait utile pour apprécier l'impact de ces paramétrages sur la simulation et, le cas échéant, les faire mieux ressortir dans l'outil.
