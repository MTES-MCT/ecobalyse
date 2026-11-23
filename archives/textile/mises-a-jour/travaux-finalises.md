---
description: L'objectif est de finaliser la méthode d'ici fin 2023.
hidden: true
---

# Travaux finalisés

## Base de données (mars 2024)

<details>

<summary>Eléments de contexte</summary>

Les données Base Impacts (Ademe) ont été remplacées par des données Ecoinvent dans le cadre de la mise en place de la Base Empreinte (Ademe).&#x20;

</details>

## Durabilité (mars 2024)

<details>

<summary>Eléments de contexte</summary>

Intégration d'un coefficient de durabilité afin de préciser la durée de vie des vêtements sur la base de critères non-physiques.&#x20;

</details>

## Matières (mars 2024)

<details>

<summary>Eléments de contexte</summary>

Suite à la mise en place de données Ecoinvent, certaines modélisations de matières ont été enrichies (ex : ajout d'eau d'irrigation dans le procédé "coton organique" qui n'en comprenait pas). Plus d'info dans la section [Matières](https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-1-matieres).

</details>

## Inventaires enrichis (toxicité) (novembre 2023)

<details>

<summary>Eléments de contexte</summary>

Enrichissement de certains inventaires/procédés d'ennoblissement (1 blanchinement, 2 teintures, 2 impressions) afin de mieux évaluer l'impact des substances chimique.

Plus d'info dans cette [page](https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/ennoblissement/inventaires-enrichis).&#x20;

</details>

## Complément _Microfibres (octobre 2023)_

<details>

<summary>Eléments de contexte</summary>

Introduction d'un complément "hors-ACV" destiné à estimer l'impact des microfibres relarguées tout au long du cycle de vie dans différents compartiments (eau, air, sol).&#x20;

Plus d'info dans cette [page](https://fabrique-numerique.gitbook.io/ecobalyse/textile/complements-hors-acv/microfibres).&#x20;

</details>

## Complément _Export Hors Europe (septembre 2023)_

<details>

<summary>Eléments de contexte</summary>

Introduction d'un complément "hors-ACV" destiné à estimer l'impact des vêtements exportés hors Europe et non réutilisés.

Pourquoi un tel complément ?\
En l'état, les modélisations ACV telles que le projet de PEFCR Apparel & Footwear (v1.3) prévoient que les vêtements sont éliminés localement (France / Europe), réutilisés (en France ou à l'international) ou recyclés.\
Or, une part significative des vêtements exportés hors Europe sont directement jetés sans être réutilisés et ont un impact significatif sur les écosystèmes locaux.&#x20;

Ce complément proposé par Ecobalyse a vocation à être débattu/enrichi avec la communauté.

Aller plus loin => [https://fabrique-numerique.gitbook.io/ecobalyse/textile/complements-hors-acv/export-hors-europe](https://fabrique-numerique.gitbook.io/ecobalyse/textile/complements-hors-acv/export-hors-europe)

</details>

## Filature (mai 2023)

<details>

<summary>Eléments de contexte </summary>

La modélisation de l'étape de Filature était limitée car le socle technique historique (Base Impacts) ne permettait pas de différencier les procédés Matière et Filature. Ces derniers étaient regroupés dans des procédés génériques.

L'étape de filature est complexe car les propriétés recherchées par le donneur d'ordre sont nombreuses (coût, finesse, élasticité, régularité, etc.).&#x20;

La prise en compte de paramètres plus précis pour cette étape fut nécessaire afin de mieux refléter/différencier les réalités métier. Illustration de paramètres pris en compte :&#x20;

* procédé utilisé (Filature vs Filage)
* technique de filature (open-end vs ring)
* titrage du fil&#x20;

**Support de travail (illustratif)**\
[**https://docs.google.com/presentation/d/1NKjkK9IiWRp7aMC\_lmG6cju2XWMgExHR5t-\_GTsq\_jY/edit?usp=sharing**](https://docs.google.com/presentation/d/1NKjkK9IiWRp7aMC_lmG6cju2XWMgExHR5t-_GTsq_jY/edit?usp=sharing)

</details>

## Confection (mars 2023)

<details>

<summary>Eléments de contexte </summary>

L'étape de confection constitue un enjeu majeur pour les entreprises à plusieurs égards :&#x20;

* la découpe implique des chutes (on parle d'emploi-matière) qui impactent d'autant la quantité de matière à produire,
* le temps-homme est élevé (et donc le coût de production) car l'assemblage des parties d'un vêtement est complexe et généralement effectué manuellement.

D'un point de vue environnemental, ces deux réalités peuvent être significatives dans une ACV.&#x20;

Dès lors, appréhender correctement ces paramètres (% pertes & temps-minute <=> kWh) est clé.

**Exemple de questions/enjeux abordés avec les experts de l'industrie**

* Quels sont les temps-minutes / SMV de vos vêtements ( # de minutes de confection) ?
* Avez-vous déjà estimé la consommation d’électricité de vos vêtements sur l’étape confection ?
* Quels sont vos taux de chute/pertes lors de la découpe/confection ?&#x20;

**Support de travail (illustratif)**\
[https://docs.google.com/presentation/d/1KhKaYWgYFO4pTx0AfE3RcErAU9fkl1Iw\_t9MdmJi9xk/edit?usp=sharing](https://docs.google.com/presentation/d/1KhKaYWgYFO4pTx0AfE3RcErAU9fkl1Iw_t9MdmJi9xk/edit?usp=sharing)

</details>

## Tissage / Tricotage (mars 2023)

<details>

<summary>Eléments de contexte </summary>

L'étape tissage/tricotage contribue de manière significative à l'impact environnemental global d'un vêtement (entre 2% et 15% en moyenne); principalement du fait de la consommation d'électricité nécessaire pour actionner les machines.&#x20;

Ecobalyse mène des travaux poussés sur cette étape avec différents experts de l'industrie afin de retranscrire les réalités industrielles dans l'outil.&#x20;

**Exemple de questions/enjeux abordés avec les experts de l'industrie**

* Quelles sont les consommations moyennes d'électricitité (kWh / kg) constatées sur les principales machines de tissage et de tricotage ?&#x20;
* Quels sont les principaux procédés/techniques de tissage et tricotage utilisés dans l'industrie ?
* Quels sont les principaux grammages (g/m2) de tissu utilisés dans l'industrie ?
* Pourquoi à masse constante (1 kg) les procédés de tricotage consomment-ils généralement moins d'énergie (MJ) que ceux de tissage ?
* \[...]

**Support de travail (illustratif)** [https://docs.google.com/presentation/d/1y5Qkbz1IOwQB5678qgTio\_1fon1Cj9hHFQIfe4lm5y4/edit?usp=sharing](https://docs.google.com/presentation/d/1y5Qkbz1IOwQB5678qgTio_1fon1Cj9hHFQIfe4lm5y4/edit?usp=sharing)

</details>

## Module Ennoblissement (novembre 2022)

<details>

<summary>Eléments de contexte </summary>

Les étapes d'ennoblissement (pré-traitement, teinture, finition) contribuent de manière élevée à l'impact environnemental global d'un vêtement.

Quelques données chiffrées :&#x20;

* Changement climatique (kg CO2 eq.) => entre 10% et 40% du total&#x20;
* Ecotoxicité aquatique => l'industrie Textile contribue de manière significative sur la pollution aquatique dans le monde (les chiffres proposés dans la littérature spécialisée varient entre 10% et 20%).&#x20;

**Exemple de questions/enjeux abordés avec les experts de l'industrie**

* De quelle manière le choix des fibres (cellulosique, synthétique, etc.) influe-t-il sur les procédés ?&#x20;
* Quels sont les principaux procédés (discontinu vs continu) et technologies (jet, batch, etc.) de teinture utilisés par type de vêtement/tissu ?
* Quels sont les principaux procédés d'impression utilisés dans l'industrie ?
* Comment s'effectue le choix du support de teinture (sur bourre/fil/tissu/article) ?
* Quelles sont les compositions chimiques des principaux bains de teinture utilisés dans l'industrie ?
* &#x20;\[...]

**Support de travail (illustratif)** [https://docs.google.com/presentation/d/1\_0nDBLbwXsdeb\_u9JdoawuPg3CiWNwzkhSDTwPGiTt4/edit?usp=sharing](https://docs.google.com/presentation/d/1_0nDBLbwXsdeb_u9JdoawuPg3CiWNwzkhSDTwPGiTt4/edit?usp=sharing)

</details>
