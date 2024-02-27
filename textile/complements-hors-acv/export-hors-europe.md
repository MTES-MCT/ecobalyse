---
description: >-
  Introduction d'un complément à l'analyse de cycle de vie estimant l'impact des
  vêtements exportés hors Europe et non réutilisés => ce complément est à
  enrichir avec vos contributions.
---

# 🌍 Export hors Europe

## Pourquoi introduire ce complément ?

En l'état, les modélisations ACV telles que le projet de PEFCR Apparel & Footwear (v1.3) prévoient que les vêtements sont éliminés localement (France / Europe), réutilisés (en France ou à l'international) ou recyclés.&#x20;

<figure><img src="https://lh4.googleusercontent.com/mth1JAjRi1j-0I3vuOI1ZRT46XgpQNphg_D_2Sc9gCbjC8b_w7yKpNYmpIQPgMQ_zlpix0eP368T9_w5spFw1W7eOmfhB6DqCwqPzf-Zdv1jg--M9v496wmBDmlXoWJjgs-F8wGP7zeuPZOH9qqXuF6_sg=s2048" alt=""><figcaption><p>Scenario de fin de vie du PEFCR Apparel &#x26; Footwear (v1.3)</p></figcaption></figure>

Or, une part significative des vêtements exportés hors Europe sont directement jetés sans être réutilisés (entre 20% et 50% des cas selon les pays en Afrique selon une [étude ](https://changingmarkets.org/take-back-trickery/)Changing Markets de 2023). Ces vêtements, considérés comme des déchets hors Europe, représentent près de 9% des vêtements en fin de vie.

Le schéma ci-dessous présente la fin de vie moyenne des vêtements distribués sur le marché français en 2023.

<figure><img src="../../.gitbook/assets/Scénarios fin de vie .png" alt=""><figcaption><p>Scénario moyen de la fin de vie des vêtements distribués sur le marché français (source : Ecobalyse)  </p></figcaption></figure>

Le complément proposé vise à refléter l'impact des vêtements se retrouvant sous forme de déchets hors Europe. Les pays réceptionnant ces flux (e.g. Ghana, Kenya, Afghanistan, Antilles, etc.) ne bénéficient généralement pas d'une filière structurée de gestion des déchets Textile créant de nombreuse problématiques environnementales et sanitaires.

<details>

<summary>Aller plus loin</summary>

Les scénarios d'export de vêtements hors Europe pourraient être détaillés : \
\=> par zone géographique : Afrique (46%), Asie (41%), Autre (13%) (données 2019 de [European Environment Agency](https://www.eea.europa.eu/publications/eu-exports-of-used-textiles/eu-exports-of-used-textiles)),\
\=> par scénarios de fin de vie (incinération, enfouissement, déchet sauvage, etc.),\
\=> par vêtement (jean, t-shirt, sous-vêtements, etc.).

Cependant, nous faisons face à un manque de données précises sur ces différentes géographies/scénarios ainsi que sur la disponibilité d'inventaires de cycle de vie (ICV).&#x20;

En l'absence d'inventaires de cycle de vie adaptés, un complément générique moyen est proposé.

</details>

## Matérialité du complément

Le complément, exprimé en points d'impacts (pt) par kg de vêtement, reflète l'impact de la fin de vie d'un vêtement qui terminerait sa vie sous forme de déchet hors Europe. &#x20;

<details>

<summary>Aller plus loin </summary>

Il n'existe pas encore suffisament de littérature scientifique permettant d'estimer, de manière quantitative, l'impact de la fin de vie des vêtements se retrouvant sous forme de déchets hors Europe.&#x20;

Cela s'explique notamment par des problématiques d'inventaires de flux (e.g. comment se décomposent dans le temps et l'espace les vêtements jetés dans la nature sous forme de déchets sauvages) et de caractérisation d'impacts (e.g. comment évaluer l'impact sur la biodiversité et/ou les organismes aquatiques des vêtements abandonnés dans la nature sous forme de déchets sauvages).

Trois grands scénarios se dessinent pour les  vêtements "déchets hors Europe" :&#x20;

1\) incinération informelle&#x20;

2\) décharge à ciel ouvert (incinération et/ou enfouissement)

3\) déchet sauvage (vêtement abandonné dans la nature)

Un nombre croissant d'études sont publiées sur les effets nocifs de ces scénarios sur l'environnement et l'Homme. C'est par exemple le cas de [travaux ](https://www.eionet.europa.eu/etcs/etc-ce/products/etc-ce-report-2023-4-eu-exports-of-used-textiles-in-europe2019s-circular-economy)parus en 2023 par la European Environment Agency qui stipulent : "Of the exports to Africa, a portion of the textiles are reused, but a significant amount ends up in either legal or illegal landfills, causing environmental problems. In other words, the textiles collected in and export from the EU are commodities, not charity.".

Ecobalyse se doit de les intégrer afin de refléter cet "hotspot" de la chaîne de valeur Textile.

</details>

Le coefficient "Export hors Europe" retenu est :

$$
CoefDechet = 5000microPts / kg = 0,005 Pts/kg
$$

<details>

<summary>Illustration</summary>

Dans le cas théorique d'un jean (poids 450g, fabrication Inde) terminant sa vie sous forme de déchets hors Europe, la fin de vie pèserait entre 43% et 50% de l'impact total du produit (hors compléments) selon sa composition.&#x20;

Cette illustration permet de comprendre la matérialité du complément dans un "worst-case scenario" théorique.

Pour calculer le complément sur un produit réel, il faut estimer sa probabilité de terminer sa fin de vie sous forme de déchet hors Europe (cf. ci-dessous).

![](<../../.gitbook/assets/Impact d'un jean terminant sa fin de vie sous forme de déchet Hors Europe (1).png>)

</details>

## Probabilité export hors Europe, valeurs par défaut

A partir des données moyennes compilées dans le cadre de nos travaux, la probabilité qu'un vêtement en fin de vie soit exporté hors Europe puis jeté est de 9%.&#x20;

{% hint style="info" %}
Trois hypothèses permettent de comprendre ce chiffre de 9% :&#x20;

* 38% des vêtements utilisés pour la première fois sont collectés et triés (source[^1])
* 49% des vêtements triés sont exportés hors Europe (source[^2] / ce chiffre de 49% cadre par ailleurs avec les [autres scénarios](#user-content-fn-3)[^3] de fin de vie post-tri),&#x20;
* dans 50% des cas, le vêtement est directement jeté sans avoir été réutilisé (source mentionnée précédemment / fourchette haute retenue par Ecobalyse).
{% endhint %}

<details>

<summary>Pourquoi les vêtements synthétiques seraient moins réutilisés ?  </summary>

Lorsqu'ils arrivent à destination, par exemple en Afrique, les vêtements sont généralement triés une seconde fois. Des observations, rapportées par différents échanges avec des spécialistes de la fin de vie et une revue de la bibliographie à ce sujet, font état d'une valeur perçue plus importante pour les vêtements en matières naturelles. Comparativement aux vêtements en matières synthétiques, ceux-ci ont plus de chance d'être revendus, repris, rapiécés, upcyclés. Ils ont donc moins de chances d'être directement jetés. \
\
Ce constat est notamment appuyé par les [travaux ](https://www.ifmparis.fr/en/faculty/andree-anne-lemieux)et différents échanges avec Andrée-Claire Lemieux (chaire Sustainability IFM-Kering).&#x20;

Par ailleurs, l'initiative [Fashion For Good](https://fashionforgood.com/) dans son rapport [Sorting For Circularity Europe](https://fashionforgood.com/our\_news/sorting-for-circularity-europe-project-findings/) partage aussi l'hypothèse que la perception des vêtements synthétiques par le consommateur pourrait être moindre (cf. extrait du rapport ci-dessous) : \
"_The difference in fibre composition found could also reflect a preference from consumers in the focus countries for cotton products over polyester, or could be an effect of consumer disposal behaviour as they might regard polyester products as lower value and therefore, choose to dispose of them in household waste rather than giving it to charity for reuse_."

</details>

On considère donc les probabilités suivantes (P_robaDéchet_) pour la réutilisation des vêtements exportés hors Europe :&#x20;

<table><thead><tr><th width="233">Scénario</th><th width="199">Export hors Europe</th><th>Déchets</th><th>ProbaDéchet</th></tr></thead><tbody><tr><td>Moyenne</td><td>19% <br>(= 38% * 49%)</td><td>50%</td><td>9%</td></tr><tr><td>Vêtements synthétiques</td><td>cf. ci-dessus</td><td>65%</td><td>12%</td></tr><tr><td>Autres vêtements</td><td>cf. ci-dessus</td><td>27%</td><td>5%</td></tr></tbody></table>

{% hint style="info" %}
Les valeurs ProbaDéchet par type de fibre sont calculés sur la base de 3 hypothèses :&#x20;

1\) En moyenne, 50% des vêtements exportés hors Europe ne sont pas réutilisés,

2\) Les vêtements exportés hors Europe se composent à 61% de vêtements composés de fibres synthétiques vs 39% de vêtements composés d'autres matières (Source[^4] = marché mondial des fibres textile),

3\) les vêtements composés de matières synthétiques ont 60% de chance de ne pas être réutilisés (dont la probabilité des vêtements composés de matières non synthétiques d'être non réutilisés est de 34% afin de retrouver une probabilité moyenne de 50%). &#x20;
{% endhint %}

## Calcul du complément "Export hors Europe"

2 paramètres sont considérés pour calculer le complément :&#x20;

* la masse du vêtement (produit fini),
* sa probabilité de terminer sa fin de vie hors Europe sous forme de déchets, dont la valeur par défaut dépend de la classification du produit (matières synthétiques ou naturelles)&#x20;

{% hint style="warning" %}
On considère que le vêtement rentre dans la catégorie "matières synthétiques" dès lors que les matières synthétiques représentent plus de 10% de sa composition.
{% endhint %}

$$
ComplémentFDVHE (Pts) = ProbaDechet * Masse (kg) * CoefDechet (Pts/kg)
$$

<details>

<summary>Illustration</summary>

Dans le cas théorique d'un jean (poids 450g, fabrication Inde), l'impact de la fin de vie passerait de 0% (avant introduction du complément Fin de vie Hors Europe) à 5% ou 11% selon la composition du vêtement.&#x20;

<img src="../../.gitbook/assets/Comparaison - Jean 100% synthétique (450g).png" alt="" data-size="original"><img src="../../.gitbook/assets/Comparaison - Jean 100% cotton (450g).png" alt="" data-size="original">

</details>

## Affichage du complément "Export hors Europe"

A l'instar des autres compléments à l'analyse de cycle de vie, le complément "Export hors Europe" vient s'ajouter directement au score d'impacts exprimé en points.

Il est intégré au sous-score "Compléments" et à l'étape du cycle de vie "Fin de vie".

[^1]: draft PERCR Apparel & Footwear v1.3 (p.90/197) &#x20;

[^2]: Rapport 2018 "Avenir Filière REP TLC" /  données 2015 (p. 49/98)&#x20;

    \
    \
    &#x20; &#x20;

[^3]: Recyclage (31%) +Réutilisation France = (10%) +  Déchets (2%) + Réutilisation Europe (8%)= 51% => le dernier débouché étant l'Export Hors Europe (1-51%=49%)                                  \
    &#x20;&#x20;

[^4]: Textile Exchange \_ The global fiber market 2021&#x20;
