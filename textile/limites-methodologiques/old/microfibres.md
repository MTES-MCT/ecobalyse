---
description: >-
  Introduction d'un complément à l'analyse de cycle de vie traduisant l'impact
  des microfibres
---

# 🐠 Microfibres

## Pourquoi introduire ce complément ?

En l'état, les modélisations ACV telles que le projet de PEFCR Apparel & Footwear (v1.3) n'intègrent pas les impacts environnementaux liés au relargage de microfibres dans l'environnement.

Le relargage de microfibres dans l'environnement concerne à la fois les compartiments eau, air et sol. De plus, les sources d'émission sont multiples et intervienne tout au long du cycle de vie du vêtement (cf. cartographie ci-dessous).&#x20;

Les microfibres relarguées dans l'environnement sont problématiques car elles peuvent être plus ou moins persistantes (non biodégradables) et toxiques pour les organismes vivants. Différents paramètres (ex : nature de la fibre, utilisation d'apprêts chimiques, conditions de lavage, etc.) influent sur le niveau d'impact des microfibres.&#x20;

{% hint style="info" %}
La recherche scientifique liée aux microfibres d'origine Textile n'est quà ses débuts. Cela s'explique notamment par l'apparition récente de préoccupations sanitaires et environnementales liées à notre consommation de plastiques (dont les microplastiques sont une conséquence).

De manière générale, la recherche sur les microfibres n’est qu’à ses débuts; les chiffres avancés sont donc à interpréter avec précaution. Cela explique l'approche qualitative retenue par Ecobalyse pour modéliser l'impact des microfibres.&#x20;
{% endhint %}

<figure><img src="../../../.gitbook/assets/Cartographie hotspots microfibres.png" alt=""><figcaption><p>Cartographie des émissions de microfibres sur le cycle de vie d'un vêtement (source : <a href="https://www.eea.europa.eu/publications/microplastics-from-textiles-towards-a">EEA</a>)</p></figcaption></figure>

Le complément proposé se concentre sur la phase d'utilisation; c'est à dire sur le relargage de microfibres dans les eaux usées lors du lavage en machine des vêtements. Cet enjeu est effectivement considéré, à date, comme la principale source d'émission des microfibres d'origine Textile dans l'environnement.&#x20;

## Matérialité du complément

Le complément, exprimé en points d'impacts (pt) par kg de vêtement, reflète l'impact d'un vêtement proposant les pires caractéristiques d'un point de vue microfibres : \
1\) vêtement composé de fibres persistantes dans l'environnement (ex : polyester),\
2\) fibres teintes et ayant subies différents apprêts chimiques (ex : traitement easy-care),\
3\) vêtement relarguant une quantité élevée de microfibres lors du lavage en machine.



La valeur de ce complément, intitulé CoefMicroF, est fixée à :&#x20;

$$
CoefMicroF. = 1000microPts / kg = 0,001 Pts/kg de vêtement
$$

<details>

<summary>En savoir plus</summary>

Il n'existe pas encore suffisament de littérature scientifique permettant d'estimer, de manière quantitative, l'impact des microfibres dans l'environnement.&#x20;

Cependant, de premiers éléments font consensus :&#x20;

1\) les microplastiques constituent l'enjeu #1 des microfibres \
En effet, les microplastiques sont persistants dans l'environnement et proviennent de fibres synthétiques qui constituent la majorité du marché textile (60% des volumes). De plus, l'essort des pratiques liées à la Fast-fashion depuis les années 2000 intensifie l'utilisation des matières synthétiques.

2\) les microfibres sont relarguées dans l'environnement lors de différentes étapes (fabrication de la fibre et de l'éttofe, confection du vêtement, utilisation, fin de vie).

3\) la phase d'utilisation constitue la source principale des émissions de microfibres dans l'eau. Le lavage en machine des vêtements constitue la principale de ces émissions aquatiques tandis que ce sont les premiers cycles de lavage qui génèrent la majorité des volumes.&#x20;

4\) les fibres naturelles, bien que biodégradables par essence, peuvent devenir plus ou moins persistantes dans l'environnement suite aux étapes d'ennoblissement.&#x20;

Dès lors, Ecobalyse adopte une approche qualitative basée sur des critères simples afin de définir les scénarios de référence permettant d'estimer l'impact microfibres des vêtements distribués sur le marché français.

</details>

## Scénarios de référence (valeurs par défaut)

Trois dimensions sont considérées pour estimer l'impact des microfibres du vêtement modélisé :&#x20;

1\) la biodagradabilité des fibres composant le vêtement (50% du total)

2\) le relargage de microfibres par le vêtement lors du lavage en machine (25% du total),

3\) la toxicité des microfibres relarguées (25% du total).&#x20;

De plus, différents paramètres sont définis pour chaque dimension afin de préciser le calcul du complément micro-fibres sur la base de données produit. &#x20;

<table><thead><tr><th width="227">Biodégradabilité</th><th width="161.33333333333331">Relargage </th><th>Toxicité  </th></tr></thead><tbody><tr><td>Non biod. = 100%</td><td>Elevé = 80%</td><td>Ecru = 50%</td></tr><tr><td>Biod. faible = 75%</td><td>Moyen = 50%</td><td>Couleur = 100%</td></tr><tr><td>Biod. moyenne = 50%</td><td>Faible = 20%</td><td></td></tr><tr><td>Biod. élevée = 10%</td><td></td><td></td></tr></tbody></table>

Dès lors, des scénarios et valeurs de référence sont définis (unité = micro-points) :&#x20;

<table><thead><tr><th width="278.3333333333333">Fibre (f)</th><th width="215">Biodégradabilité</th><th width="177">Relargage</th><th width="159">Toxicité</th><th>Total (ref)</th></tr></thead><tbody><tr><td>Référence théorique</td><td>Non biodeg. = 500</td><td>Elevé = 250</td><td>Ecru = 125<br>Autre = 250</td><td>1000</td></tr><tr><td>Synthétique</td><td>Non biod. = 500</td><td>Moyen = 125</td><td>Cf. supra</td><td>875</td></tr><tr><td>Naturelle (origine végétale)</td><td>Biod. élevée = 50</td><td>Elevé = 250</td><td>Cf. supra</td><td>550</td></tr><tr><td>Naturelle (origine animale)</td><td>Biod. moyenne = 250</td><td>Elevé = 250</td><td>Cf. supra</td><td>750</td></tr><tr><td>Artificielle (origine organique)</td><td>Biod. élevée = 50</td><td>Moyen = 125</td><td>Cf. supra</td><td>425</td></tr><tr><td>Artificielle (origine inorganique)</td><td>Non biodeg. = 500</td><td>Moyen = 125</td><td>Cf. supra</td><td>875</td></tr></tbody></table>

{% hint style="info" %}
La dimension "Toxicité" est appréhendée selon les traitements appliqués lors de l'ennoblissement. Tout vêtement est considéré subir des pre-traitements et au moins un apprêt chimique.
{% endhint %}

## Calcul du complément "Microfibres"

3 paramètres sont considérés pour calculer le complément :&#x20;

* la masse du vêtement (produit fini),
* les fibres composant le vêtement (f)
* la teinte du vêtement (écru vs couleur)

{% hint style="warning" %}
Pour les vêtements muli-fibres, une somme pondérée des scénarios de référence spécifiques à chaque fibre est à effectuer.
{% endhint %}

$$
ComplémentMicroF. (Pts) = \sum (f) = composition(f)*ref(f)*masse(kg)
$$

<details>

<summary>Illustration</summary>

Dans le cas théorique d'un t-shirt (poids 170g), l'ajout du complément microfibre pèserait à hauteur de +10% pour la version 100% coton vs +21% pour la version 100% synthétique.&#x20;

![](<../../../.gitbook/assets/Comparaison - T-shirt 100% coton (170g).png>)

![](<../../../.gitbook/assets/Comparaison - T-shirt 100% synthétique (170g).png>)

</details>

## Modulation du complément "Microfibres"

La valeur du coefficient microfibres peut être modifiée par l'utilisateur qui modéliserait ainsi un complément s'écartant des scénarios par défaut définis en fonction de la composition du vêtement. \
Le coefficient peut aller de :&#x20;

* 0% --> revient à simuler une annulation du coefficient "microfibres" ;
* 200% --> revient à doubler la matérialité du coefficient et donc à doubler la valeur du complément correspondant en points.&#x20;

## Affichage du complément "Microfibres"

A l'instar des autres compléments à l'analyse de cycle de vie, le complément "Microfibres" vient s'ajouter directement au score d'impacts exprimé en points.

Il est intégré au sous-score "Compléments" et à l'étape du cycle de vie "Matières".
