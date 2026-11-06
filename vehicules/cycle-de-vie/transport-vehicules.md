---
description: >-
  Cette page porte sur les spécificités du transport du véhicules. Les
  informations relatives au transport de manière générale sont détaillées dans
  la documentation transverse d'Ecobalyse.
---

# 🛺 EN PROGRESSION Transport Véhicules

## Déclinaison des étapes de transport sur ce secteur

Les étapes de transport se déclinent de la façon suivante :

1. Transport des matériaux (ex : aluminium primaire, granules de plastique...) vers les sites de fabrication des composants,
2. Transport des composants (ex : pneu, batterie) depuis leur site de fabrication vers le site d'assemblage du véhicule,
3. Transport du véhicule entre l'usine d'assemblage et un entrepôt de stockage en France,
4. Transport entre le site de stockage en France et un concessionnaire ou le client final s'il est livré directement.

## 1. Transport des matériaux constitutifs des composants

Le transports des matériaux constitutifs des composants (étape 1) n'est pas calculé de façon spécifique. Il est intégré dans les procédés modélisant ces matériaux.

## 2. Transport des composants

Le transport des composants (étape 2) est modélisé avec une combinaison de voies (maritime et terrestre) non modifiable.

## 3. Transport des véhicules assemblés

### Choix de la voie de transport

Le transport se modélise avec une part de voie ferroviaire `f`. Cette part de voie ferroviaire `f` est modifiable par l'utilisateur avec un curseur "part du transport ferroviaire", proposé sous l'étape "assemblage".

### Modification de la modélisation du mode de transport

Le transport de véhicules assemblés est spécifique à ce secteur. En effet, dans la plupart des cas, le volume à transporter est conséquent par rapport au poids, ce qui implique un transport fortement sous-capacitaire en termes de poids transporté.

Les véhicules les plus grands, à l'instar des voitures, sont transportés dans des moyens de transports spécifiques.

#### Éléments de contexte sur le transport maritime de voitures

Le transport de voitures s'effectue dans des navires dédiés, dont la capacité est de 10 000 à 20 000 tonnes. Par comparaison, la capacité des portes-conteneur est de 7 000 à 300 000 t, avec une capacité moyenne de 64 000 tonnes (4600 EVP).

Comme tous les navires opérant en Europe, ces navires sont tenus de déclarer leur consommation de carburant, les émissions de gaz à effet de serre associées, ainsi que le tonnage moyen annuel.

Il en ressort des émissions essentiellement situées entre 20gCO2/tkm et 50gCO2e/tkm en 2022. Par comparaison, les émissions du transport de marchandise par conteneurs maritime sont de l'ordre de 10g/tkm.

#### Éléments de contexte sur le transport de vélos assemblés à 80%

Sur de grandes distances, les vélos sont transportés partiellement assemblés, dans des cartons. Par exemple, un vélo de 20kg sera emballé dans un carton de 0.25m3, soit 80kg/m3. Par comparaison, un conteneur est chargé en moyenne à hauteur de 200kg/m3.

### Correctif pour modéliser le transport des véhicules

Les méthodes relatives au transport s'applique au transport de véhicules, excepté le choix des procédés utilisés.

Chaque mode de transport possible est modélisé sur la base du procédé indiqué dans la documentation transversale, et multiplié par un facteur multiplicatif permettant de rendre compte du caractère faiblement capacitaire voire spécifique du transport de véhicules.

<table><thead><tr><th width="349">Mode de transport</th><th>Facteur multiplicatif</th></tr></thead><tbody><tr><td>Camion</td><td>2.0</td></tr><tr><td>Bateau</td><td>5.0</td></tr><tr><td>Train</td><td>2.0</td></tr></tbody></table>
