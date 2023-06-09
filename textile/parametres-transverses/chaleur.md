---
description: Choix du procédé de chaleur en fonction du pays
---

# 🔥 Chaleur

## Fonctionnement

### Généralités

La consommation de chaleur s'exprime en mégajoules (MJ).

Deux scénarios existent pour modéliser la consommation de chaleur des procédés mobilisés :&#x20;

**Scénario 1** :  la chaleur est déjà intégrée dans le procédé mobilisé en tant que Flux Interne&#x20;

**Scénario 2** : la chaleur n'est pas intégrée dans le procédé mobilisé et doit être intégrée en tant que Flux Externe\
Dans ce cas précis, la quantité de chaleur nécessaire pour actionner le procédé mobilisé correspond au produit de la masse "sortante" du procédé mobilisé (ex : masse d'étoffe en sortie du tissage) avec le coefficient du flux intermédiaire correspondant à la chaleur (`32045a18-e8a3-4068-9078-d17c72cea73d`).

### Spécificités

#### Source de chaleur < = >  pays&#x20;

L'impact environnemental de la production de chaleur varie significativement selon la source/technologie utilisée.

Ecobalyse applique par défaut un procédé de chaleur qui dépend  du pays dans lequel est réalisée le procédé mobilisé.

Trois procédés de chaleur sont disponibles dans la Base Impacts; ils correspondent à des mix moyens :&#x20;

<table><thead><tr><th width="122">Zone</th><th width="277">Procédé chaleur</th><th>UUID</th></tr></thead><tbody><tr><td>France</td><td>Mix Vapeur (mix technologique | mix de production, en sortie de chaudière), FR</td><td>12fc43f2-a007-423b-a619-619d725793ea</td></tr><tr><td>Europe</td><td>Mix Vapeur (mix technologique | mix de production, en sortie de chaudière), RER</td><td>63b1b03f-1f73-4791-829d-d49c06ddc8ee</td></tr><tr><td>Asie-Pacifique</td><td>Mix Vapeur (mix technologique | mix de production, en sortie de chaudière), RSA</td><td>2e8de6f6-0ea1-455b-adce-ea74d307d222</td></tr></tbody></table>

En première approche, trois scénarios par défaut sont appliqués : &#x20;

<table><thead><tr><th width="261">Pays</th><th width="251">Procédé chaleur</th></tr></thead><tbody><tr><td>France</td><td>France (FR)</td></tr><tr><td>Autres pays européens</td><td>Europe (RER)</td></tr><tr><td>Autres pays, hors Europe</td><td>Asie-Pacifique (RSA)</td></tr></tbody></table>

{% hint style="warning" %}
Ces choix de procédés doivent être discutés. Ils sont sélectionnés parmi les procédés proposés dans la base Impacts. Plusieurs points discutables apparaissent :

* Des pays hors Asie (par exemple Afrique du Nord) se voient appliqué un mix vapeur RSA (Asie Pacifique).
* Cette approche ne permet pas de distinguer des mix vapeur nationaux qui seraient spécifiques (exemple : transition du fuel lourd vers le gaz en Tunisie).
* Dans le cas de la France, un procédé de mix vapeur spécifique à ce pays est proposé. La France est le seul pays pour lequel un tel procédé est proposé dans la base Impacts.
{% endhint %}

## Limites

Il peut être proposé de permettre de sélectionner une source de chaleur spécifique (fuel, gaz naturel, bois, etc.) selon le site industriel et/ou le pays.
