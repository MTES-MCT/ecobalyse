---
hidden: true
---

# 🚚 Etape 6 - Distribution (New)

## Contexte

La distribution correspond au transport entre l'entrepôt de stockage du produit final (après confection et transport), et un magasin ou centre de distribution. Il est considéré que l'entrepôt est en France.

Ce type de transport se fait presque exclusivement par camion.

A des fins de simplification, le transport entre un magasin ou un centre de distribution et le client final n'est pas pris en compte à ce jour dans Ecobalyse.

## Méthodes de calcul

$$
I_{distribution} = \frac{m}{1000}*D_{distribution,camion}*I_{camion}
$$

Avec :

* `I_distribution` : l'impact environnemental de la distribution, dans l'unité de la catégorie d'impact analysée
* `m` la masse du produit final, exprimée en kg.
* `D_distribution,camion` : la distance effectuée en camion entre l’entrepôt de stockage en France (ou l'industriel en France le cas échéant) et le point de vente ou de livraison locale, en km
* `I_camion` : l'impact environnemental du transport par camion, dans l'unité de la catégorie d'impact analysée, rapportée à tonne.km

## Paramètres retenus pour le coût environnemental

`D_distribution,camion` = 500km

La distance de 500 km est reprise du socle technique ADEME (Méthodologie d'évaluation des impacts environnementaux des articles d'habillement - Annexe A.2.b - p30).

## Procédé utilisé pour le coût environnemental

Le procédé utilisé est identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes) sous le nom "transport routier" :&#x20;

* market group for transport, freight, lorry, unspecified, GLO, source Ecoinvent 3.9.1

