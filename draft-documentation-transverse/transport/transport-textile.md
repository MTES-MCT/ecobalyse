---
description: >-
  Cette page porte sur les spécificités du transport des produits textiles. Les
  informations relatives au transport de manière générale sont détaillées dans
  la documentation transverse d'Ecobalyse.
---

# 👕 Transport Textile

## Déclinaison des étapes de transport sur ce secteur

Les étapes de transport se déclinent de la façon suivante :

1. Transport des matières premières (ex : coton, granules de plastiques) vers le site de filature,
2. Transport des produits intermédiaires (ex : tissu textile) entre les sites de transformation, jusqu'au site de confection
3. Transport du produit fini entre l'usine de confection et un entrepôt de stockage en France,
4. Transport entre un site de stockage en France et un magasin ou centre de distribution ou client final s'il est livré directement.

## 1-2. Transport des matières premières et produits intermédiaires&#x20;

Le transport des matières premières et produits intermédiaire (étapes 1 et 2) est modélisé avec une combinaison de voies (maritime et terrestre) non modifiable.

## 3. Transport des produits finis entre le site de production et un lieu de stockage en France

Le transport se modélise avec une part de voie aérienne `a`. Cette part de voie aérienne `a`est modifiable par l'utilisateur avec un curseur "part du transport aérien", proposé sous l'étape "confection".

Des valeurs par défaut sont définies en fonction du pays d'origine et du coefficient de durabilité (voir ci-dessous).

{% hint style="info" %}
**L'aérien est-il un mode de transport privilégié pour les acteurs Textile ?**

Une récente étude de l'ONG suisse "Public Eye" parue fin 2023 met en lumière l'importance du secteur Textile dans le fret aérien. De manière générale, peu de données précises sont disponibles sur ces pratiques car les entreprises Textile sont discrètes à ce sujet.

Quelques enseignements clés de l'étude :&#x20;

* le fret aérien est utilisé au sein même de l'UE alors que l'avantage en termes de temps reste faible (c. 42,658 tonnes de vêtements transportées par avion au sein de l'UE en 2022 d'après les estimations de l'étude),
* Shein a signé un partenariat stratégique avec China Southern Airlines afin d'optimiser ses flux logistiques aériens,
* Le groupe espagnol Inditex (propriétaire de Zara) affrète près de 1,600 vols par an depuis l'aéroport de Saragosse,
* Même au sein de l’UE, où le fret aérien n’offre qu’un faible avantage en termes de temps, des vêtements sont tout de même transportés par avion (en 2022, il s’agissait d’au moins 42 658 tonnes).

L'article complet est accessible ici => [https://www.publiceye.ch/fr/thematiques/industrie-textile/en-mode-avion-zara-attise-la-crise-climatique](https://www.publiceye.ch/fr/thematiques/industrie-textile/en-mode-avion-zara-attise-la-crise-climatique)
{% endhint %}

### Paramètres retenus pour l'affichage environnemental

La part de **transport aérien (`a`)**, par rapport au transport "aérien + terrestre + maritime" est considérée comme suit : &#x20;

**Si le coefficient de durabilité est supérieur ou égal à 1**

* 0% pour les pays situés en Europe ou Turquie,
* 33% pour les autres pays.

**Si le coefficient de durabilité est strictement inférieur à 1**

* 0% pour les pays situés en Europe ou Turquie,
* 100% pour les autres pays.
