# Focus coton

## Généralités

Le coton est la seconde fibre textile la plus utilisée après le polyester (représente c.22% de la production mondiale de fibres textile 2022 \_ source[^1]).&#x20;

Les principaux pays producteurs sont la Chine, l'Inde et les Etats-Unis. Une vingtaine de pays se partagent la majorité du marché.

<details>

<summary>Production mondiale de coton par pays (source : FAO, 2021)</summary>

![](<../../../.gitbook/assets/image (270).png>)

</details>

### Différents types de coton (conventionnel, biologique, recyclé)&#x20;

* coton conventionnel (98%\* de la production mondiale)\
  Près de 25% de la production mondiale de coton est engagée dans des [programmes ](#user-content-fn-2)[^2]\(non certifiés) visant à rendre les pratiques plus soutenables.
* coton biologique certifié (1,4%)\
  Il n'existe pas de définition claire du coton biologique. Le périmètre de ces pratiques est flou et se caractérise par les labels et certifications internationales (ex : GOTS, Oeko-Tex, etc.). \
  Ces pratiques consistent principalement à ne pas modifier génétiquement les graines de coton tout en utilisant du compost naturel (remplaçant les engrais chimiques) et des pesticides naturels (remplaçant les pesticides de synthèse).
* coton recyclé (1%\* de la production mondiale)\
  Réutiliser des fibres existantes permet d'économiser les pesticides, engrais et eau nécessaires pour la production de la même quantité de matière vierge. \
  \
  \* Source : Textile Exchange (_Market report 2023_ & _Organic Cotton Market Report 2022_)

### Enjeux environnementaux&#x20;

Les principaux enjeux environnementaux liés à la production de coton sont :&#x20;

* la toxicité humaine et l'écotoxicité aquatique,\
  Environ 14% des insecticides et 6% des pesticides mondiaux sont utilisés pour le coton\
  (alors que la culture du coton ne représente que 2 à 3% des terres cultivées).
* la consommation d'eau,\
  Il faut entre 4,000 et 8,000 litres d'eau pour produire 1kg de fibre de coton; cette quantité varie fortement selon les régions et est à préciser selon l'origine de l'eau (_blue_ vs _green_ water). Près de 3% de l'eau utilisée en agriculture est utilisée pour le coton tandis que 73% de la production mondiale est irriguée.&#x20;
* le changement climatique,\
  L'utilisation d'engrais, de pesticides/insecticides et de machines agricoles contribuent aux émissions de gaz à effet de serre.&#x20;
* la dégradation des sols et de la biodiversité.&#x20;

## Modélisation Ecobalyse

Le production de fibres de coton consiste principalement à : \
1\) produire les graines de coton (seed-cotton production),\
2\) égrener (fibre production, cotton, ginning).

Quatre procédés sont disponibles dans Ecobalyse :&#x20;

<details>

<summary>Coton conventionnel</summary>

**Procédé Ecoinvent** \
&#xNAN;_&#x46;ibre production, cotton, ginning, RoW_

Procédé basé sur une moyenne pondérée des trois principaux pays producteurs (Chine, Inde, Etats-Unis).&#x20;

</details>

<details>

<summary>Coton biologique</summary>

**Procédé Ecoinvent** \
&#xNAN;_&#x46;ibre production, cotton, organic, ginning, RoW_

Ecobalyse a enrichi ce procédé avec une consommation d'eau liée à une irrigation moyenne mondiale de 0,75m3[^3] / kg de fibre de cotton organique (source : [Textile Echange](#user-content-fn-4)[^4]).&#x20;

</details>

<details>

<summary>Coton recyclé (déchets post-consommation)</summary>

Ce procédé est issu de la Base Impacts (ADEME) auquel a été retranché l'impact de la filature. [Ce correctif est documenté ici](https://app.gitbook.com/o/-MMQU-ngAOgQAqCm4mf3/s/-MexpTrvmqKNzuVtxdad/~/changes/1001/textile/correctifs-donnees/corr1-coton-recycle).

</details>

<details>

<summary>Coton recyclé (déchets de production)</summary>

Ce procédé est issu de la Base Impacts (ADEME) auquel a été retranché l'impact de la filature. [Ce correctif est documenté ici.](../../correctifs-donnees/corr1-coton-recycle.md)



</details>

<figure><img src="../../../.gitbook/assets/Coût environnemental (uPts _ kg) des différents types de coton disponibles dans Ecobalyse (1).png" alt=""><figcaption></figcaption></figure>

[^1]: Market report 2023 \_ Textile Exchange

[^2]: Cf. Market Report 2023 (Textile Exchange) pour plus d'info &#x20;

[^3]: "The global average total of water consumed while producing 1 metric ton of organic cotton fiber is 15,000 m3. While total water use and consumption are almost the same implying that almost all water used is consumed; 95 percent of water used is green water (rainwater and moisture stored in soil and used for plant growth)." \
    Calcul => 15000/1000 \* (1-0,95) = 0,75 m3 / kg&#x20;

[^4]: "The LCA of organic cotton fiber _A global average_ Summary of findings"
