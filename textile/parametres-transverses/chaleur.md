---
description: Choix du procédé de chaleur en fonction du pays
---

# 🔥 Chaleur

## Modélisation Ecobalyse

### Généralités

La consommation de chaleur s'exprime en mégajoules (MJ).

Deux scénarios existent pour modéliser la consommation de chaleur des procédés mobilisés :&#x20;

**Scénario 1** :  la chaleur est déjà intégrée dans le procédé mobilisé en tant que Flux Interne&#x20;

**Scénario 2** : la chaleur n'est pas intégrée dans le procédé mobilisé et doit être intégrée en tant que Flux Externe

Dans ce cas précis, la quantité de chaleur nécessaire pour actionner le procédé mobilisé correspond au produit de la masse "sortante" du procédé mobilisé (ex : masse d'étoffe en sortie du tissage) avec les coefficients du flux intermédiaire de chaleur mobilisé.&#x20;

### Scénarios

#### Mix chaleur < = >  région

Troix régions sont proposées dans Ecobalyse pour préciser le mix chaleur utilisé par les entreprises  : France, Europe, Monde.

En l'absence de procédés Ecoinvent modélisant les mix chaleurs de ces 3 régions, Ecobalyse a reconstitué de tels procédés en repartant de deux procédés source Ecoinvent :&#x20;

* Consommation de chaleur produite à partir de gaz naturel \
  procédé = _Market group for heat, district or industrial, natural gas; RER_
* Consommation de chaleur produite à partir de sources autres que gaz naturel\
  procédé = _Market group for heat, district or industrial, other than natural gas_ ; RER

<table><thead><tr><th width="122">Zone</th><th width="277">Procédé chaleur</th><th>Sources de chaleur</th></tr></thead><tbody><tr><td>France</td><td>Heat mix (FR) </td><td><a data-footnote-ref href="#user-content-fn-1">40% gaz naturel / 60% autres</a></td></tr><tr><td>Europe</td><td>Heat mix (Europe) </td><td><a data-footnote-ref href="#user-content-fn-2">44% gaz naturel / 56% autres</a></td></tr><tr><td>Rest of the world</td><td>Heat mix (World) </td><td><a data-footnote-ref href="#user-content-fn-3">23% gaz naturel / 77% autres</a></td></tr></tbody></table>

#### Illustration de l'impact de ces 3 scénarios :&#x20;

<div>

<figure><img src="../../.gitbook/assets/Impact de 1MJ de chaleur par région (unité = uPts).png" alt=""><figcaption></figcaption></figure>

 

<figure><img src="../../.gitbook/assets/Impact de 1MJ de chaleur par région (unité = kg CO2 eq.).png" alt=""><figcaption></figcaption></figure>

</div>

{% hint style="info" %}
Ces scénarios par défaut permettent de couvrir le Niveau 1 du dispositif d'affichage environnemental.&#x20;

Les entreprises qui souhaitent préciser le mix chaleur de tout ou partie des étapes de production peut le faire dans le cadre des Niveaux 2 et 3.&#x20;
{% endhint %}

### Limites

* Les deux procédés Ecoinvent utilisés (chaleur à partir de gaz naturel vs chaleur à partir d'autres sources) pour reconstituer les mix chaleur régionaux (France, Europe, Monde) sont basés sur des mix de consommation européens ("Market group for heat" / "RER"),
* Le mix chaleur World (Rest Of the World) est basé sur des données 2010.

[^1]: Source : Etude Carbone 4 :  [https://www.carbone4.com/publication-chaleur-renouvelable](https://www.carbone4.com/publication-chaleur-renouvelable)

[^2]: Source : Etude Reuters : [https://www.reuters.com/markets/commodities/industrial-heat-set-major-energy-source-overhaul-by-2050-2023-04-11/](https://www.reuters.com/markets/commodities/industrial-heat-set-major-energy-source-overhaul-by-2050-2023-04-11/)

[^3]: Article CarbonTrust (UK) : [https://www.carbontrust.com/news-and-insights/insights/industrial-renewable-heat](https://www.carbontrust.com/news-and-insights/insights/industrial-renewable-heat)
