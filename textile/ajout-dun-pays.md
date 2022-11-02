---
description: >-
  Quelles informations doivent être apportées pour ajouter un choix de pays dans
  Wikicarbone ?
---

# 🌎 Ajout d'un pays

Un utilisateur du simulateur peut souhaiter qu'un nouveau choix de pays lui soit proposé. Cette page précise les informations à apporter. 2 modalités sont ensuite envisagées pour intégrer le nouveau pays dans l'outil :&#x20;

* Un ajout direct du pays dans le code via Gitub
* L'envoi des informations nécessaires à l'équipe Wikicarbone, laquelle se charge ensuite d'intégrer dans le code. La mise à disposition d'un formulaire, reprenant les informations détaillées ci-après, peut être envisagée.

## Pays et code pays

Informations à fournir :&#x20;

* **Nom du pays**, en français, tel que devant apparaître dans les menus déroulants du simulateur - _**Exemple : Grèce**_
* **Code pays**, généralement 2-3 lettre, tel que défini dans la base Impacts (table BI\_2.01\_\_10\_Zone\_Geographiques.csv dans la documentation de la base) - _**Exemple : GR**_

## Procédés spécifiques au pays

Un certain nombre de procédés sont ensuite à confirmer, ou à choisir :&#x20;

* **Le mix électrique**. Généralement, le mix électrique national est disponible dans la base Impacts et peut être choisi (table BI\_2.01\_\_02\_Procedes\_Details.xlsx - Catégorie : Energie / Electricité / Mix moyen / National) - _**Exemple : Mix électrique réseau, GR**_
* **La production de chaleur**_**.**_ Contrairement à l'électricité, seuls 3 mix moyens sont proposés dans la base Impacts : Europe (RER), Asie-Pacifique (RSA) et France (FR). Il est en revanche possible de choisir un type d'énergie (fuel lourd, fuel léger, charbon, bois) avec, pour chacun de ces choix, différentes options géographiques ou techniques proposées. Les procédés retenus pour les premiers pays proposés dans l'outil sont listés sur la page [Chaleur](chaleur.md)

{% hint style="warning" %}
Le choix de la source de chaleur est un paramètre important, notamment sur l'étape de teinture, et qui impose un choix complexe.
{% endhint %}

* **Le procédé de teinture.** En première approche, le choix du procédé de teinture peut nécessiter de se positionner sur 3 questions. Les choix retenus pour les premiers pays proposés dans l'outil sont listés sur la page [Teinture](teinture.md) :&#x20;
  * Quel support ? Fil, étoffe, article ? Par défaut, une teinture sur étoffe est considérée.
  * Quel positionnement, notamment en matière de consommation d'électricité et de chaleur ? Majorant ou représentatif ?
  * Quelle efficacité pour le système de traitement des eaux ? Inefficace, moyen ou très efficace ?

{% hint style="warning" %}
Le choix de procédé de teinture est un paramètre important, notamment sur l'étape de teinture, et qui impose un choix complexe. Ce choix doit être fait en tenant compte des orientations générales listées sur la page [Hypothèses par défaut](hypotheses-par-defaut.md).
{% endhint %}

* **La part de transport aérien**, si la confection est réalisé dans le pays ajouté. La part de transport aérien depuis la confection réalisée dans un pays déjà intégré à l'outil est détaillée dans la page [Transport](ajout-dun-pays.md#transports).

Exemple pour le Bangladesh :&#x20;

| Paramètre                                                           | Choix                                                                          | Justification                    |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------------ | -------------------------------- |
| Mix électrique                                                      | Mix électrique réseau, BD                                                      | Mix national                     |
| Production de chaleur                                               | Mix Vapeur (mix technologique\|mix de production, en sortie de chaudière), RSA | Mix continental                  |
| Teinture - Positionnement représentatif/majorant                    | Majorant (100%)                                                                | Valeur majorante par défaut      |
| Teinture - Efficacité du système de traitement des eaux             | Inefficace                                                                     | Valeur majorante par défaut      |
| Transport - Part de transport aérien vers la France post confection | 33%                                                                            | Valeur par défaut pays lointains |

## Distances

Enfin, il convient de spécifier toutes les distances entre le nouveau pays ajouté et les autres pays proposés dans Wikicarbone.

Ces distances doivent être proposées pour les trois types de transport (terrestre, maritime et aérien), en s'appuyant sur les simulateurs de distance de référence identifiés dans la page [Transport](transport.md).

Un large tableau doit donc être complété :&#x20;

| Autre pays | Distance terrestre | Distance maritime | Distance aérien |
| ---------- | ------------------ | ----------------- | --------------- |
| Bangladesh |                    |                   |                 |
| Chine      |                    |                   |                 |
| Espagne    |                    |                   |                 |
| France     |                    |                   |                 |
| Inde       |                    |                   |                 |
| Portugal   |                    |                   |                 |
| Tunisie    |                    |                   |                 |
| Turquie    |                    |                   |                 |

