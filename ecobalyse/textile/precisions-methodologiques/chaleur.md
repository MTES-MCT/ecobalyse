---
description: Choix du procédé de chaleur en fonction du pays
hidden: true
---

# 🔥 Chaleur

### Généralités

La consommation de chaleur s'exprime en mégajoules (MJ).

Deux scénarios existent pour modéliser la consommation de chaleur des procédés mobilisés :&#x20;

**Scénario 1** :  la chaleur est déjà intégrée dans le procédé mobilisé en tant que Flux Interne,&#x20;

**Scénario 2** : la chaleur n'est pas intégrée dans le procédé mobilisé et doit être intégrée en tant que Flux Externe (c'est par exemple le cas pour de nombreux procédés de l'étape Ennoblissement).&#x20;

Dans ce cas précis, la quantité de chaleur nécessaire pour actionner le procédé mobilisé correspond au produit de la masse "sortante" du procédé mobilisé (ex : 0,5kg d'étoffe en sortie de l'étape Ennoblissement) avec le coefficient du flux externe de chaleur mobilisé (ex : 3,2 MJ / kg de chaleur pour le procédé de pré-traitement _Désencollage)_.&#x20;

### Procédés mobilisés

La base de données Ecoinvent ne propose pas de mix chaleur industrielle par zone géographique (ex : France, Europe, Asie, etc.). En l'absence de tels mix régionaux, Ecobalyse reconstitue de tels mix régionaux sur la base de quatre procédés source :&#x20;

* Consommation de chaleur produite à partir de gaz naturel (x2 régions : RER -Europe- et Global -Monde-)\
  procédé = _Market group for heat, district or industrial, natural gas_
* Consommation de chaleur produite à partir d'autres sources  (x2 régions : RER -Europe- et Global -Monde-)\
  procédé = _Market group for heat, district or industrial, other than natural gas_&#x20;

### Mix chaleurs (Europe x Monde)

Deux régions sont proposées dans Ecobalyse :&#x20;

<table><thead><tr><th width="122">Zone</th><th width="355">Procédé chaleur</th><th>Sources de chaleur</th></tr></thead><tbody><tr><td>Europe</td><td>Heat mix (Europe) </td><td><a data-footnote-ref href="#user-content-fn-1">44% gaz naturel / 56% autres</a></td></tr><tr><td>Rest of the world</td><td>Heat mix (World) </td><td><a data-footnote-ref href="#user-content-fn-2">23% gaz naturel / 77% autres</a></td></tr></tbody></table>

En compilant pour chaque zone (Europe et Monde) les sources de chaleur (gaz naturel vs autres sources) et leurs contributions au mix régional (ex : 44% gaz naturel vs 56% autres sources pour l'Europe), nous pouvons reconstituer l'impact de la consommation de chaleur industrielle au sein de chacune de ces zones.&#x20;

La consommation de chaleur industrielle à l'échelle mondiale est significativement plus impactante que celle européenne (+73% en score d'impacts -uPts-).



### Coût environnemental

<figure><img src="../../.gitbook/assets/Coût environnemental des mix chaleur disponibles dans Ecobalyse (uPts _ MJ)  (1).png" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
Ces scénarios par défaut permettent de couvrir le Niveau 1 du dispositif d'affichage environnemental.&#x20;

Les entreprises qui souhaitent préciser le mix chaleur de tout ou partie des étapes de production peut le faire dans le cadre des Niveaux 2 et 3.&#x20;
{% endhint %}

[^1]: Source : Etude Reuters : [https://www.reuters.com/markets/commodities/industrial-heat-set-major-energy-source-overhaul-by-2050-2023-04-11/](https://www.reuters.com/markets/commodities/industrial-heat-set-major-energy-source-overhaul-by-2050-2023-04-11/)

[^2]: Article CarbonTrust (UK) : [https://www.carbontrust.com/news-and-insights/insights/industrial-renewable-heat](https://www.carbontrust.com/news-and-insights/insights/industrial-renewable-heat)
