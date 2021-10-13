---
description: >-
  Opérations et circuits permettant de mettre le produit à disposition des
  consommateurs.
---

# Distribution

## Distance et procédé

En première approche, le modèle de distribution considéré est très simple :

* il est considéré que l'entrepôt est en France ;
* il est considéré, en moyenne, que 500 km sont parcourus en moyenne, en camion, pour distribuer le vêtement de l'entrepôt au point de vente ou de livraison.

La distance de 500 km est conforme à la documentation ADEME (Méthodologie d'évaluation des impacts environnementaux des articles d'habillement - Annexe A.2.b - p30).

Un unique procédé est considéré pour modéliser la distribution, de l'entrepôt au point de vente ou de livraison :

| Procédé par défaut                                                                                  | UUID                                 |
| --------------------------------------------------------------------------------------------------- | ------------------------------------ |
| Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) \[tkm], FR | f49b27fa-f22e-c6e1-ab4b-e9f873e2e648 |

Les modalités de calcul de l'impact environnemental de ce transport sont précisées dans la page [transport](transport.md).

## Limites

Pour améliorer l'outil, il serait possible de :

* différencier des circuits de livraison (e-commerce notamment) ou de distribution en magasin (cf. projet de PEFCR - Apparel & Footwear) ;
* intégrer, outre le transport, l'impact du stockage en entrepôt ou en magasin du vêtement.
