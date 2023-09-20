---
description: >-
  Introduction d'un complément à l'analyse de cycle de vie traduisant la fin de
  vie hors Europe
---

# 🌍 Fin de vie hors Europe

## Pourquoi introduire ce complément ?

En l'état, les modélisations ACV telles que le projet de PEFCR Apparel & Footwear (v1.3) prévoient que les vêtements sont éliminés localement (France / Europe), réutilisés (en France ou à l'international) ou recyclés.&#x20;

<figure><img src="https://lh4.googleusercontent.com/mth1JAjRi1j-0I3vuOI1ZRT46XgpQNphg_D_2Sc9gCbjC8b_w7yKpNYmpIQPgMQ_zlpix0eP368T9_w5spFw1W7eOmfhB6DqCwqPzf-Zdv1jg--M9v496wmBDmlXoWJjgs-F8wGP7zeuPZOH9qqXuF6_sg=s2048" alt=""><figcaption><p>Scenario de fin de vie du PEFCR Apparel &#x26; Footwear (v1.3)</p></figcaption></figure>

Or, une part significative des vêtements exportés hors Europe sont directement jetés sans être réutilisés (entre 20% et 50% des cas selon les pays en Afrique selon une [étude ](https://changingmarkets.org/take-back-trickery/)Changing Markets de 2023). Ces vêtements, considérés comme des déchets hors Europe, représentent près de 9% des vêtements en fin de vie.

Le schéma ci-dessous présente la fin de vie moyenne des vêtements distribués sur le marché français en 2023.

<figure><img src="../../../.gitbook/assets/Scénarios fin de vie .png" alt=""><figcaption><p>Scénario moyen de la fin de vie des vêtements distribués sur le marché français (source : Ecobalyse)  </p></figcaption></figure>

Le complément proposé vise à refléter l'impact des vêtements se retrouvant sous forme de déchets hors Europe. Les pays réceptionnant ces flux (e.g. Ghana, Kenya, Afghanistan, Antilles, etc.) ne bénéficient généralement pas d'une filière structurée de gestion des déchets Textile créant de nombreuse problématiques environnementales et sanitaires.

<details>

<summary>Aller plus loin</summary>

Plusieurs scénarios peuvent être distingués pour modéliser les flux de vêtements exportés hors Europe : \
\=> la zone géographique considérée : Afrique (46%), Asie (41%), Autre (13%) (données 2019 de [European Environment Agency](https://www.eea.europa.eu/publications/eu-exports-of-used-textiles/eu-exports-of-used-textiles))\
\=> le devenir des déchets (incinération, enfouissement, déchet sauvage, etc.)

Cependant, nous faisons face à un manque de données précises sur ces différentes géographies/scénarios ainsi que sur la disponibilité d'inventaires de cycle de vie (ICV).&#x20;

En l'absence d'inventaires de cycle de vie adaptés, un complément générique moyen est proposé.

</details>

## Matérialité du complément

Le complément, exprimé en points d'impacts (pt) par kg de vêtement, reflète l'impact de la fin de vie d'un vêtement qui terminerait sa vie sous forme de déchet hors Europe. &#x20;

{% hint style="info" %}
Il n'existe pas encore suffisament de littérature scientifique permettant d'estimer, de manière quantitative, l'impact de la fin de vie des vêtements se retrouvant sous forme de déchets hors Europe.&#x20;

Cela s'explique notamment par des problématiques d'inventaires de flux (e.g. comment se décomposent dans le temps et l'espace les vêtements jetés dans la nature sous forme de déchets sauvages) et de caractérisation d'impacts (e.g. comment évaluer l'impact sur la biodiversité et/ou les organismes aquatiques des vêtements abandonnés dans la nature sous forme de déchets sauvages).

Trois grands scénarios se dessinent pour les  vêtements "déchets hors Europe" :&#x20;

1\) incinération informelle&#x20;

2\) décharge à ciel ouvert (incinération et/ou enfouissement)

3\) déchet sauvage (vêtement abandonné dans la nature)



Un nombre croissant d'études sont publiées sur les effets nocifs de ces scénarios sur l'environnement et l'Homme. C'est par exemple le cas de [travaux ](https://www.eionet.europa.eu/etcs/etc-ce/products/etc-ce-report-2023-4-eu-exports-of-used-textiles-in-europe2019s-circular-economy)parus en 2023 par la European Environment Agency qui stipulent : "Of the exports to Africa, a portion of the textiles are reused, but a significant amount ends up in either legal or illegal landfills, causing environmental problems. In other words, the textiles collected in and export from the EU are commodities, not charity.".

Ecobalyse se doit de les intégrer afin de refléter cet "hotspot" de la chaîne de valeur Textile.
{% endhint %}

Le coefficient "fin de vie hors Europe" retenu est :

$$
CoefDechet = 5000microPts / kg = 0,005 Pts/kg
$$

<details>

<summary>Illustration</summary>

Dans le cas théorique d'un jean (poids 450g, fabrication Inde) terminant sa vie sous forme de déchets hors Europe, la fin de vie pèserait entre 62% et 69% de l'impact total du produit (hors compléments) selon sa composition.&#x20;

![](<../../../.gitbook/assets/Impact d'un jean terminant sa fin de vie sous forme de déchet Hors Europe.png>)

</details>

## Probabilité de fin de vie hors Europe, valeurs par défaut

A partir des données moyennes compilées dans le cadre de nos travaux, la probabilité qu'un vêtement en fin de vie soit exporté hors Europe puis jeté est de 9%.&#x20;

{% hint style="info" %}
Trois hypothèses permettent de comprendre ce chiffre de 9% :&#x20;

* 38% des vêtements utilisés pour la première fois sont collectés et triés (source[^1])
* 49% des vêtements triés sont exportés hors Europe (source[^2]),&#x20;
* dans 50% des cas, le vêtement est directement jeté sans avoir été réutilisé (source mentionnée précédemment / fourchette haute retenue par Ecobalyse).
{% endhint %}

Lorsqu'ils arrivent à destination, par exemple en Afrique, les vêtements sont généralement triés une seconde fois. Les observations, rapportées par différents échanges avec des spécialistes de la fin de vie et une revue de la bibliographique à ce sujet, font état d'une valeur perçue plus importante pour les vêtements en matières naturelles. Comparativement aux vêtements en matières synthétiques, ceux-ci ont plus de chance d'être revendus, repris, rapiécés, upcyclés. Ils ont donc moins de chances d'être directement jetés.

On considère donc les probabilités suivantes (P_robaDéchet_) pour la réutilisation des vêtements exportés hors Europe :&#x20;

<table><thead><tr><th width="233">Scénario</th><th width="199">Export hors Europe</th><th>Déchets</th><th>ProbaDéchet</th></tr></thead><tbody><tr><td>Moyenne</td><td>19%</td><td>50%</td><td>9%</td></tr><tr><td>Vêtements synthétiques</td><td>19%</td><td>60%</td><td>11%</td></tr><tr><td>Autres vêtements</td><td>19%</td><td>34%</td><td>6%</td></tr></tbody></table>

{% hint style="info" %}
Les probabilités ainsi proposées, pour les matières synthétiques et les matières naturelles, permettent de retrouver la probabilité moyenne (50% des vêtements exportés hors Europe ne sont pas portés) en considérant que 61% des vêtements vendus sont en matières synthétiques et 39% avec d'autres types de fibres (naturelles, artificielles ou mix de fibres). (Source[^3])
{% endhint %}

## Calcul du complément "Fin de vie hors Europe"

2 paramètres sont considérés pour calculer le complément :&#x20;

* la masse du vêtement (produit fini),
* sa probabilité de fin de vie hors Europe, dont la valeur par défaut dépend de la classification du produit (matières synthétiques ou naturelles)&#x20;

{% hint style="warning" %}
On considère que le vêtement rentre dans la catégorie "matières synthétiques" dès lors que les matières synthétiques représentent plus de 10% de sa composition.
{% endhint %}

$$
ComplémentFDVHE (Pts) = ProbaDechet * Masse (kg) * CoefDechet (Pts/kg)
$$

<details>

<summary>Illustration</summary>

Dans le cas théorique d'un jean (poids 450g, fabrication Inde), l'impact de la fin de vie passerait de 0% (avant introduction du complément Fin de vie Hors Europe) à 5% ou 11% selon la composition du vêtement.&#x20;

![](<../../../.gitbook/assets/Comparaison avant après jean.png>)

</details>

## Modulation du complément "Fin de vie hors Europe"

La valeur de la probabilité de fin de vie hors Europe peut être modifiée par l'utilisateur qui modéliserait ainsi une probabilité s'écartant de la valeur par défaut définie en fonction du type de vêtement (matières synthétiques vs autre ). La valeur de cette probabilité peut aller de :&#x20;

* 0% --> revient à simuler une annulation du complément "fin de vie hors Europe" ;
* 200% --> revient à doubler la probabilité considérée pour les matières synthétiques, et donc à doubler la valeur du complément correspondant en points.&#x20;

## Affichage du complément "Fin de vie hors Europe"

A l'instar des autres compléments à l'analyse de cycle de vie, le complément "Fin de vie hors Europe" vient s'ajouter directement au score d'impacts exprimé en points.

Il est intégré au sous-score "Compléments" et à l'étape du cycle de vie "Fin de vie".

[^1]: draft PERCR Apparel & Footwear v1.3 (p.90/197) &#x20;

[^2]: Rapport 2018 "Avenir Filière REP TLC" /  données 2015 (p. 49/98)&#x20;

    \
    \
    &#x20; &#x20;

[^3]: Textile Exchange \_ The global fiber market 2021&#x20;
