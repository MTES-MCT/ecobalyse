---
description: >-
  Introduction d'un complément à l'analyse de cycle de vie traduisant l'impact
  des microfibres
---

# 🐠 Microfibres

## De quoi parle-t-on ?&#x20;

Les microfibres sont des particules d'une taille variant entre 1 µm (micromètre) et 5 mm (millimètres).

Les enjeux autour des microfibres d'origine Textile sont progressivement mis en lumière suite aux préoccupations croissantes liées aux microplastiques (relarguées par les fibres synthétiques).&#x20;

<details>

<summary>En savoir plus sur les microplastiques</summary>

On distingue deux sources de microplastiques :&#x20;

* les microplastiques primaires (c. 1/3 des volumes) => particules se retrouvant directement dans l’environnement sous forme de microplastiques. \
  Deux scénarios existent : ceux ajoutés volontairement dans des produits (ex : microbilles utilisées dans la cosmétiques) ou ceux résultant de l’abrasion d’objets plus grands lors de leur fabrication ou utilisation(ex : abrasion des pneus, relargage de fibres lors du lavage des vêtements).
* les microplastiques secondaires (2/3 des volumes) => sont issus de la dégradation d’objets plus grands (ex : décomposition de sacs/bouteilles, etc.).

Entre 16% et 35% des microplastiques émis dans les océans à l'échelle mondiale proviennent du secteur Textile (source : [European Environment Agency](https://www.eea.europa.eu/publications/microplastics-from-textiles-towards-a))

</details>

## Pourquoi introduire ce complément ?

En l'état, les référentiels d'ACV existants tels que le projet de PEFCR Apparel & Footwear (v1.3) n'intègrent pas les impacts environnementaux liés au relargage de microfibres dans l'environnement.

Les vêtements relarguent des microfibres dans différents compartiments (eau, air et sol) tout au long du cycle de vie du vêtement (cf. cartographie ci-dessous).&#x20;

Les microfibres relarguées dans l'environnement sont problématiques car elles peuvent être plus ou moins persistantes (non biodégradables) et toxiques pour les organismes vivants. Différents paramètres (ex : nature de la fibre, apprêts chimiques utilisés, conditions de lavage, etc.) impactent la quantité et la toxicité des microfibres relarguées par un vêtement.&#x20;

{% hint style="info" %}
La recherche scientifique liée aux microfibres d'origine Textile n'est qu'à ses débuts. Cela s'explique notamment par l'apparition récente de préoccupations sanitaires et environnementales liées à notre consommation de plastiques (dont les microplastiques sont une conséquence). Les chiffres avancés sont donc à interpréter avec précaution. Cela explique l'approche semi-quantitative retenue par Ecobalyse pour modéliser l'impact des microfibres.
{% endhint %}

<figure><img src="../../../.gitbook/assets/Cartographie hotspots microfibres.png" alt=""><figcaption><p>Cartographie des émissions de microfibres sur le cycle de vie d'un vêtement (source : <a href="https://www.eea.europa.eu/publications/microplastics-from-textiles-towards-a">EEA</a>)</p></figcaption></figure>

Le complément proposé couvre l'ensemble des émissions de microfibres intervenant sur le cycle de vie d'un vêtement. &#x20;

## Matérialité du complément

Un coefficient (`Coef`), exprimé en micropoints d'impacts par kg de vêtement (`microPts/kg`), est défini et reflète l'impact d'un vêtement proposant les pires caractéristiques d'un point de vue microfibres : \
1\) vêtement composé de fibres persistantes dans l'environnement,\
2\) vêtement relarguant une quantité élevée de microfibres sur l'ensemble de son cycle de vie.

La valeur de ce coefficient est fixée à :&#x20;

$$
Coef = 1000microPts / kg = 0,001 Pts/kg de vêtement
$$

<details>

<summary>En savoir plus</summary>

Il n'existe pas encore suffisament de littérature scientifique permettant d'estimer, de manière quantitative, l'impact des microfibres dans l'environnement.&#x20;

Cependant, de premiers éléments font consensus :&#x20;

1\) les produits chimiques qui sont appliqués sur les fibres textile lors des différentes étapes d'ennoblissement (ex : blanchiment, teinture, etc.) peuvent altérer la biodégradabilité de certaines fibres intrinsèquement biodégradables.

2\) les microplastiques constituent un enjeu majeur \
En effet, les microplastiques sont persistants (non biodégradables) dans l'environnement et proviennent de fibres synthétiques qui constituent la majorité du marché textile (62%[^1] des volumes en 2020). De plus, l'essort des pratiques liées à la Fast-fashion depuis les années 2000 intensifie l'utilisation des matières synthétiques.

3\) les microfibres sont relarguées dans l'environnement lors de différentes étapes (fabrication de la fibre et du vêtement, confection, utilisation, fin de vie) et au sein de différents compartiments (air, eau, sol).&#x20;

Dès lors, Ecobalyse adopte une approche semi-quantitative basée sur des critères simples afin de définir les scénarios de référence permettant d'estimer l'impact microfibres des vêtements distribués sur le marché français.&#x20;

</details>

Grâce à l'utilisation de scénarios de référence spécifiques à chaque vêtement (cf. ci-dessous), ce coefficient permet de calcul le complément microfibres (`Comp`).

## Paramètres considérés&#x20;

Deux dimensions sont considérées pour calibrer l'impact des microfibres du vêtement modélisé :&#x20;

{% tabs %}
{% tab title="Persistance" %}
La persistance définit le caractère biodégradable d'une fibre. Plus une substance est biodégradable, plus faible est sa persistance.&#x20;

Les fibres utilisées dans l'industrie textile proposent des propriétés intrinsèques différentes selon leur nature (ex : le polyester est persistant tandis que le lyocell est biodégradable).&#x20;

Cependant, du fait de traitements appliqués sur les fibres lors des étapes de fabrication du vêtement, les propriétés intrinsèques des fibres peuvent évoluer (ex : l'application d'apprêts chimiques sur des fibres intrinsèquement biodégradables peut rendre ces dernières plus ou moins persistantes). &#x20;

**Illustration de résultats de tests ci-dessous**\
(Source = tests listés dans le rapport "Biodegradability within the context of Fibre Fragmentation" de _TheMicrofibreConsortium_)&#x20;

* Cotton (avec teinture) : 74% après 112 jours à 10°C (compartiment = eau)
* Chanvre (sans teinture) : 79% après 112 jours à 10°C (compartiment = eau)
* Cotton (avec blanchiment + adoucissant ) : 29% après 90 jours (compartiment = sol)
* Lyocell (sans teinture) : 81% après 112 jours à 10°C (compartiment = eau)
* Laine Merino : 23% après 90 jours à 30°C (compartiment = eau)
* Laine (avec teinture) : 9% après 161 jours à 30°C (compartiment = eau)
* Polyester : 1% après 90 jours à 30°C (compartiment = eau)
* Polyester (avec teinture) : 0% après 161 jours à 30°C (compartiment = eau)
* Polyester : 13% après 90 jours (compartiment = sol)
* Nylon : 1% après 90 jours à 30°C (compartiment = eau)

Ecobalyse propose des scénarios par défaut selon la nature des fibres (ex : fibres naturelles d'origine végétale) afin de préciser le calcul du complément microfibres.
{% endtab %}

{% tab title="Relargage" %}
Le relargage correspond à la capacité d'une fibre/vêtement à relarguer des microfibres dans l'environnement. Cet enjeu est présent sur l'ensemble des étapes du cycle de vie d'un vêtement et compartiments (eau, air, sol).&#x20;

Extrait d'une [publication ](https://www.eea.europa.eu/publications/microplastics-from-textiles-towards-a)sur les microplastiques d'origine Textile : \
_"Most research has focused on microfibre release through the washing of synthetic textiles, considering waste water to be the predominant pathway for leakage into the aquatic environment (Boucher and Friot, 2017). However, microfibres are also emitted during textile manufacturing, garment wearing and end-of-life disposal, and are dispersed in water, air and soil."_

Ecobalyse propose des scénarios par défaut selon la nature des fibres (ex : fibres naturelles d'origine végétale) afin de préciser le calcul du complément microfibres.
{% endtab %}
{% endtabs %}

<details>

<summary>Quid de la dimension Toxicité ?</summary>

La toxicité des microfibres n'est pas prise en compte dans ce complément car cette dimension est déjà couverte par trois catégories d'impacts (Ecotoxicité aquatique, Toxicité Humaine Cancérigène, Toxicité Humaine Non Cancérigène).&#x20;

</details>

## Scénarios de référence&#x20;

Selon sa composition, chaque vêtement se voit attribuer un complément microfibres.&#x20;

**Etape 1 = Définition des scénarios**

Ce complément est basé sur des scénarios qui sont spécifique à la nature des fibres (f) entrant dans la composition d'un vêtement.&#x20;

Cinq scénarios de fibre sont proposés : synthétique, naturelle origine végétale, naturelle origine animale, artificielle origine organique, artificielle origine inorganique.&#x20;

Pour chacun de ces scénarios, un niveau de Persistance (P) et de Relargage (R) est défini sur une échelle de 0 (très faible) à 10 (très élevé).    &#x20;

<table><thead><tr><th width="314.3333333333333">Nature des fibres (f)</th><th width="202">Persistance (P)</th><th width="160">Relargage (R)</th></tr></thead><tbody><tr><td>Synthétique</td><td>10</td><td>3</td></tr><tr><td>Naturelle (origine végétale)</td><td>3</td><td>7</td></tr><tr><td>Naturelle (origine animale)</td><td>6</td><td>5</td></tr><tr><td>Artificielle (origine organique)</td><td>3</td><td>5</td></tr><tr><td>Artificielle (origine inorganique)</td><td>10</td><td>5</td></tr></tbody></table>

**Etape 2 = Pondération des paramètres**

La capacité d'une fibre à se dégrader dans l'environnement (persistance) est considérée comme plus importante que sa capacité à relarguer un nombre important de microfibres (relargage). En effet, des microfibres biodégradables (donc non persistantes) relarguées en grande quantité dans l'environnement n'affectent que peu les écosystèmes car ces dernières disparaissent au bout de quelques jours.&#x20;

Dès lors, la pondération suivante est proposée :&#x20;

| Persistance (P) | Relargage (R) |
| --------------- | ------------- |
| 70%             | 30%           |

**Etape 3 = Calcul des valeurs de référence (%)**

Dès lors, chaque scénario (f) se voit attribuer une valeur de référence (Ref) selon la formule suivante :&#x20;

$$
Ref (f) = (0,7*P + 0,3*R) * 10
$$

Cette valeur de référence (`Ref(f)`) est exprimée en pourcentage (%) et reflète la part du coefficient microfibres (`CoefMicroF.`) correspondant à chaque scénario.&#x20;

<table><thead><tr><th width="314.3333333333333">Type de fibre (f)</th><th width="202">0,7 * P</th><th width="160">0,3 * R</th><th>Ref (f)</th></tr></thead><tbody><tr><td>Synthétique</td><td> 7</td><td>0,9</td><td>79%</td></tr><tr><td>Naturelle (origine végétale)</td><td>2,1</td><td>2,1</td><td>42%</td></tr><tr><td>Naturelle (origine animale)</td><td>4,2</td><td>1,5 </td><td>57%</td></tr><tr><td>Artificielle (origine organique)</td><td>2,1</td><td>1,5 </td><td>36%</td></tr><tr><td>Artificielle (origine inorganique)</td><td>7</td><td>1,5</td><td>85%</td></tr></tbody></table>

## Calcul du complément "Microfibres"

Sur la base des types de fibres (`f`) composant un vêtement, il est possible de calculer la valeur du complément microfibres (`Comp`), exprimé en micro-points d'impacts par vêtement  :&#x20;

$$
Comp =  \sum Ref(f) * Compo(f) * masse*Coeff
$$

Avec : \
\- `Ref(f)` = % = valeurs de référence spécifique aux fibres de type (`f`),\
\-  `Compo(f)` = % = part des fibres de type (`f`) entrant dans la composition du vêtement, \
\-  `masse` = kg = masse du vêtement, \
\- `Coef` = micro-points = impact microfibres d'un vêtement proposant les pires caractéristiques = 1,000 micro-points&#x20;

{% hint style="warning" %}
Pour les vêtements muli-fibres, une somme pondérée des scénarios de référence spécifiques à chaque fibre est à effectuer.
{% endhint %}

<details>

<summary>Illustration</summary>

Dans le cas théorique d'un t-shirt (poids 170g), l'ajout du complément microfibre pèserait à hauteur de :&#x20;

* \+8% pour la version 100% coton\
  Impact initial = 915 micro-pts\
  Impact final = 915 + (42% \* 100% \* 0,17 \* 1000 ) = 986 micro-pts
* &#x20;\+19% pour la version 100% synthétique\
  Impact initial = 715 micro-pts\
  Impact final = 715 + (79% \* 100% \* 0,17 \* 1000) = 849 micro-pts

<img src="../../../.gitbook/assets/Comparaison - T-shirt 100% synthétique (170g) (1).png" alt="" data-size="original"><img src="../../../.gitbook/assets/Comparaison - T-shirt 100% coton (170g) (1).png" alt="" data-size="original">

</details>

## Affichage du complément "Microfibres"

A l'instar des autres compléments à l'analyse de cycle de vie, le complément "Microfibres" vient s'ajouter directement au score d'impacts exprimé en points.

Il est intégré au sous-score "Compléments" et à l'étape du cycle de vie "Matières".

[^1]: Source = rapport d'activité 2021 Textile Exchange    &#x20;
