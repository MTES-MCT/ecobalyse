# 🌎 Pays

## Pays disponibles

### Liste

| Pays       | Procédé électricité | Procédé chaleur      |
| ---------- | ------------------- | -------------------- |
| Bangladesh | Mix national        | Asie-Pacifique (RSA) |
| Chine      | Mix national        | Asie-Pacifique (RSA) |
| Espagne    | Mix national        | Europe (RER)         |
| France     | Mix national        | France (FR)          |
| Inde       | Mix national        | Asie-Pacifique (RSA) |
| Portugal   | Mix national        | Europe (RER)         |
| Tunisie    | Mix national        | Asie-Pacifique (RSA) |
| Turquie    | Mix national        | Asie-Pacifique (RSA) |

### Procédés spécifiques au pays

Un certain nombre d'hypothèses par défaut sont directement fonction du pays où s'effectue le procédé :

* **Mix électrique** : le mix électrique national est appliqué&#x20;
* **Mix chaleur :** Contrairement à l'électricité, seulement 3 mix moyens sont proposés dans la base Impacts et sont appliqués selon le pays. Plus d'info [ici](chaleur.md).&#x20;
* **Transport aérien (confection)** : si l'étape de confection est réalisée dans un pays hors-Europe (ou Turqui), un % de la distance parcourue par le produit fini est considérée effectuée par avion. Plus d'info [ici](transport.md).&#x20;

## Ajout d'un pays

Un utilisateur du simulateur peut souhaiter qu'un nouveau choix de pays lui soit proposé. Cette page précise les informations à apporter. 2 modalités sont ensuite envisagées pour intégrer le nouveau pays dans l'outil :

* Un ajout direct du pays dans le code via Gitub
* L'envoi des informations nécessaires à l'équipe Wikicarbone, laquelle se charge ensuite d'intégrer dans le code. La mise à disposition d'un formulaire, reprenant les informations détaillées ci-après, peut être envisagée.

### Pays et code pays

Informations à fournir :

* **Nom du pays**, en français, tel que devant apparaître dans les menus déroulants du simulateur - _**Exemple : Grèce**_
* **Code pays**, généralement 2-3 lettre, tel que défini dans la base Impacts (table BI\_2.01\_\_10\_Zone\_Geographiques.csv dans la documentation de la base) - _**Exemple : GR**_

Exemple pour le Bangladesh :

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

Un large tableau doit donc être complété :

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
