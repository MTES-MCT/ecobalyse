---
description: Cette page est un brouillon
---

# Focus coton (draft)

## Généralités

Le coton est la seconde fibre textile la plus utilisée après le polyester (représente c.22% de la production mondiale de fibres textile 2022 \_ source[^1]).&#x20;

Les principaux pays producteurs sont la Chine, l'Inde et les Etats-Unis. Une vingtaine de pays se partagent la majorité du marché.

<details>

<summary>Production mondiale de coton par pays (source : FAO, 2021)</summary>

![](<../../../.gitbook/assets/image (83).png>)

</details>

### Différents types de coton (conventionnel, biologique, recyclé)&#x20;

* coton conventionnel (98%\* de la production mondiale)\
  Près de 25% de la production mondiale de coton est engagée dans des [programmes ](#user-content-fn-2)[^2]\(non certifiés) visant à rendre les pratiques plus soutenables.
* coton biologique certifié (1,4%)\
  Il n'existe pas de définition claire du coton bio/organique. Le périmètre de ces pratiques est flou et se caractérise par les labels et certifications internationales (ex : GOTS, Oeko-Tex, etc.). \
  Ces pratiques consistent principalement à ne pas traiter ni modifier génétiquement les graines de coton tout en utilisant du compost naturel (remplaçant les engrais chimiques) et des pesticides naturels (remplaçant les pesticides de synthèse).
* coton recyclé (1%\* de la production mondiale)\
  Réutiliser des fibres existantes permet d'économiser les pesticides, engrais et eau nécessaires pour la production de la même quantité de matière vierge. \
  \
  \* Source : Textile Exchange (_Market report 2023_ & _Organic Cotton Market Report 2022_)

### Enjeux environnementaux&#x20;

Les principaux enjeux environnementaux liés à la production de coton sont :&#x20;

* l'utilisation de pesticides et insecticides,\
  Environ 14% des insecticides et 6% des pesticides mondiaux sont utilisés pour le coton (alors que la culture du coton ne représente que 2 à 3% des terres cultivées).
* la consommation d'eau,\
  Il faut entre 4,000 et 8,000 litres d'eau pour produire 1kg de fibre de coton; cette quantite varie fortement selon les régions. Près de 3% de l'eau utilisée en agriculture est utilisée pour le coton tandis que 73% de la production mondiale est irriguée.&#x20;
* le changement climatique,\
  L'utilisation d'engrais, de pesticides/insecticides et de machines agricoles contribuent aux émissions de gaz à effet de serre.&#x20;
* la détérioritation des sols et de la biodiversité.&#x20;

## Modélisation Ecobalyse

Le production de fibres de coton consiste principalement à : \
1\) produire les graines (seed-cotton production),\
2\) égrener (fibre production, cotton, ginning).&#x20;

Deux procédés sont sont disponibles dans Ecobalyse :&#x20;

<details>

<summary>Coton conventionnel</summary>

**Procédé Ecoinvent** \
_Fibre production, cotton, ginning, RoW_

</details>

<details>

<summary>Coton organique</summary>

**Procédé Ecoinvent** \
_Fibre production, cotton, organic, ginning, RoW_

</details>

### Mieux comprendre les impacts dans Ecobalyse

<figure><img src="../../../.gitbook/assets/image (84).png" alt=""><figcaption></figcaption></figure>

**Principaux enseignements**

* La production de coton conventionnel (3,131 uPts / kg) est 3 à 4 fois plus impactante que celle du coton organique (847 uPts / kg)
* 69% de l'impact du coton conventionnel provient de l'indicateur Ecotoxicité de l'eau douce. \
  Les deux principales raisons expliquant cela sont : \
  1\) la pondération élevée de cet indicateur dans le coût environnemental (21,06%)\
  2\) l'utilisation de pesticides et insecticides (tels le Trichlorfon et Chlorpyrifos) dans la culture du coton. &#x20;
* Le complément Microfibres (420 uPts / kg de fibre naturelle d'origine végétale) explique une part significative de l'impact de la laine (13% de _Coton conventionnel_ et 50% de _Coton organique_).&#x20;
* La consommation d'eau ressort de manière significative (6% de l'impact total / 32m3 par kg) seulement pour le coton conventionnel tandis que 0m3 d'eau est considéré pour la culture du coton organique.

[^1]: Market report 2023 \_ Textile Exchange

[^2]: Cf. Market Report 2023 (Textile Exchange) pour plus d'info &#x20;
