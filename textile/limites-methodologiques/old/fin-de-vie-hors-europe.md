---
description: >-
  Introduction d'un complément à l'analyse de cycle de vie traduisant la fin de
  vie hors Europe
---

# 🌍 Fin de vie hors Europe

## Pourquoi introduire ce complément ?

En l'état, les modélisations ACV telles que le projet de PEFCR Apparel & Footwear (v1.3) prévoient que les vêtements sont éliminés localement (France / Europe), réutilisés (en France ou à l'international) ou recyclés.&#x20;

<figure><img src="https://lh4.googleusercontent.com/mth1JAjRi1j-0I3vuOI1ZRT46XgpQNphg_D_2Sc9gCbjC8b_w7yKpNYmpIQPgMQ_zlpix0eP368T9_w5spFw1W7eOmfhB6DqCwqPzf-Zdv1jg--M9v496wmBDmlXoWJjgs-F8wGP7zeuPZOH9qqXuF6_sg=s2048" alt=""><figcaption><p>Scenario de fin de vie du PEFCR Apparel &#x26; Footwear (v1.3)</p></figcaption></figure>

Or, une part significative des vêtements exportés hors Europe sont directement jetés sans être réutilisés (entre 40% et 60% des cas selon les pays). Ces vêtements, considérés comme des déchets hors Europe, représentent près de 7% des vêtements en fin de vie.

Le schéma ci-dessous présente la fin de vie moyenne des vêtements distribués sur le marché français en 2023.

<figure><img src="../../../.gitbook/assets/Scénarios fin de vie .png" alt=""><figcaption><p>Scénario moyen de la fin de vie des vêtements distribués sur le marché français (source : Ecobalyse)  </p></figcaption></figure>

Le complément proposé vise à refléter l'impact des vêtements se retrouvant sous forme de déchets hors Europe. Les pays receptionnant ces flux (e.g. Ghana, Kenya, Afghanistan, Thaïlande, etc.) ne bénéficient généralement pas d'une filière structurée de gestion des déchets Textile créant de nombreuse problématiques environnementales et sanitaires.

<details>

<summary>Aller plus loin</summary>

Plusieurs scénarios peuvent être distingués pour modéliser les flux de vêtements exportés hors Europe : \
\=> la zone géographique considérée : Afrique (46%), Asie (41%), Autre (13%) (source[^1])\
\=> le sort des déchets : incinération informelle, décharge (enfouissement ou incinération), déchet sauvage.

Cependant, nous faisons face à un manque de données précises sur ces différentes géographies/scénarios ainsi que sur la disponibilité d'inventaires de cycle de vie (ICV).&#x20;

En l'absence d'inventaires de cycle de vie adaptés, un complément générique moyen est proposé.

</details>

## Matérialité du complément

Le complément, exprimé en points d'impacts (pt), est calculé selon l'hypothèse suivante : **50%** de l'impact total d'un vêtement doit être imputable à sa fin de vie lorsqu'il se retrouve sous forme de déchet hors Europe.&#x20;

{% hint style="info" %}
Il n'existe pas encore suffisament de littérature scientifique permettant d'estimer, de manière quantitative, l'impact de la fin de vie des vêtements se retrouvant sous forme de déchets hors Europe.&#x20;

Cela s'explique notamment par des problématiques d'inventaires de flux (e.g. comment se décomposent dans le temps et l'espace les vêtements jetés dans la nature sous forme de déchets sauvages) et de caractérisation d'impacts (e.g. comment évaluer l'impact des microfibres relarguées dans l'environnement).

Trois grands scénarios se dessinent pour les  vêtements "déchets hors Europe" :&#x20;

1\) incinération informelle&#x20;

2\) décharge à ciel ouvert (incinération et/ou enfouissement)

3\) déchet sauvage (vêtement abandonné dans la nature)



Un nombre croissant d'études sont publiées sur les effets nocifs de ces scénarios sur l'environnement et l'Homme. Ecobalyse se doit de les intégrer afin de refléter cet "hotspot" de la chaîne de valeur Textile.
{% endhint %}

Sur la base des ordres de grandeur des vêtements standards proposés dans l'Explorateur Produit de l'outil Ecobalyse, le complément "fin de vie hors Europe" retenu est :

$$
CoefDechet = 4861microPts / kg = 0,004861 Pts/kg
$$

<details>

<summary>En savoir plus sur le calcul du CoefDechet </summary>

Le coefficient "fin de vie hors Europe" correspond à la moyenne des coefficients calculés pour les 7 vêtements disponibles dans l'[Explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile/products) en date du 8 septembre 2023. &#x20;

Chacun de ces vêtements a été décliné "100% coton" et "100% polyesther" afin de générer 14 configurations de vêtement.&#x20;

Dès lors, la moyenne des 14 _Scores d'impacts_ "Fin de vie Hors Europe" a été retenue pour estimer le _CoefDechet_.&#x20;

![](<../../../.gitbook/assets/image (21).png>)

Prenons l'exemple du T-shirt en coton de 170 g terminant sa vie sous forme de déchet hors Europe. Son impact hors fin de vie est de 909 micro-points. On considère que l'impact fin de vie doit représenter 50% de l'impact total du vêtement. Dès lors, le CoefDechet (hors Europe) de ce t-shirt pèse autant que les autres étapes du cycle de vie du produit; c'est à dire 909 micro-points par kg.

</details>



## Probabilité de fin de vie hors Europe, valeurs par défaut

A partir des données moyennes compilées dans le cadre de nos travaux, la probabilité qu'un vêtement en fin de vie soit exporté hors Europe puis jeté est de 9%.&#x20;

{% hint style="info" %}
Deux hypothèses permettent de comprendre ce chiffre de 9% :&#x20;

* 18% des vêtements jetés pour la première fois en France sont exportés hors Europe,
* dans 50% des cas, le vêtement est directement jeté sans avoir été réutilisé.
{% endhint %}

Pour en savoir plus sur les principales sources utilisées par Ecobalyse => cf. cette [liste](https://docs.google.com/spreadsheets/d/149SUIRoqNgP8W6FjLDY4Rm6I1qfW\_o7f9ThpUPlE6OY/edit?usp=sharing). &#x20;

Lorsqu'ils arrivent à destination, par exemple en Afrique, les vêtements sont généralement triés une seconde fois. Les observations, rapportées par différents échanges avec des spécialistes de la fin de vie et une revue de la bibliographique à ce sujet, font état d'une valeur perçue plus importante pour les vêtements en matières naturelles. Comparativement aux vêtements en matières synthétiques, ceux-ci ont plus de chance d'être revendus, repris, rapiécés, upcyclés. Ils ont donc moins de chances d'être directement jetés. Voici une [liste](https://docs.google.com/spreadsheets/d/1dGGVrQ8yT2vv7XYGQYBx5hLjcSxy3qIxgLfm5\_5jt8A/edit?usp=sharing) des principales sources mobilisées à ce sujet.

On considère donc les probabilités suivantes (P_robaDechet_) pour la réutilisation des vêtements exportés hors Europe :&#x20;

<table><thead><tr><th width="241">Scénario</th><th>ProbaDechet(%)</th></tr></thead><tbody><tr><td>Moyenne</td><td>50%</td></tr><tr><td>Vêtements synthétiques</td><td>60%</td></tr><tr><td>Autres vêtements</td><td>34%</td></tr></tbody></table>

{% hint style="info" %}
Les probabilités ainsi proposées, pour les matières synthétiques et les matières naturelles, permettent de retrouver la probabilité moyenne en considérant que 61% des vêtements vendus sont en matières synthétiques et 39% avec d'autres types de fibres (naturelles, artificielles ou mix de fibres). (Source[^2])
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

<summary>Illustration Avant vs Après</summary>

![](<../../../.gitbook/assets/image (24).png>)

![](<../../../.gitbook/assets/image (23).png>)

</details>

## Modulation du complément "Fin de vie hors Europe"

La valeur de la probabilité de fin de vie hors Europe peut être modifiée par l'utilisateur qui modéliserait ainsi une probabilité s'écartant de la valeur par défaut définie en fonction du type de vêtement (matières synthétiques vs autre ). La valeur de cette probabilité peut aller de :&#x20;

* 0% --> revient à simuler une annulation du complément "fin de vie hors Europe" ;
* 200% --> revient à doubler la probabilité considérée pour les matières synthétiques, et donc à doubler la valeur du complément correspondant en points.&#x20;

## Affichage du complément "Fin de vie hors Europe"

A l'instar des autres compléments à l'analyse de cycle de vie, le complément "Fin de vie hors Europe" vient s'ajouter directement au score d'impacts exprimé en points.

Il est intégré au sous-score "Compléments" et à l'étape du cycle de vie "Fin de vie".

[^1]: Année 2019 / European Environment Agency

[^2]: Textile Exchange \_ The global fiber market 2021&#x20;
