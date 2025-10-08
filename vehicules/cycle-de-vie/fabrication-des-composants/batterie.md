---
description: Cette page décrit le calcul du coût environnemental de la batterie.
---

# 🔋 Batterie

## Contexte

La batterie représente 10% à 50% du coût environnemental d'un véhicule électrique. Ce chiffre varie principalement en fonction de l'autonomie recherchée pour le véhicule (capacité de la batterie), et du poids du véhicule.&#x20;

L'impact environnemental de la batterie dépend également de sa technologie : NMC811, LFP sont les deux principales technologies utilisées aujourd'hui.

Les sites et méthodes de fabrication des modules et cellules de batterie, ainsi que les sites et méthode d'extraction et de raffinage des matières premières ont également une réelle influence sur le coût environnemental. \
Cependant, par souci de simplification et compte-tenu de la difficulté à détailler la chaine de valeur de fabrication, ils ne sont pas utilisés comme paramètres dans Ecobalyse.

## Méthodes de calcul

Le coût environnement de la batterie est évalué d'après sa chimie et son poids (en kg), avec plusieurs origines possibles.

$$
I_{batterie} = m*I_{batterie}
$$

Avec :

* `I_batterie` : l'impact environnemental de la batterie, dans l'unité de la catégorie d'impact analysée
* `m` la masse de batterie, exprimée en kg.
* `I_batterie` : l'impact environnemental d'un kg de batterie pour la technologie retenue, dans l'unité de la catégorie d'impact analysée

Les chimies de batterie suivantes sont différenciées : NMC811, LFP.

## Paramètres retenus pour le coût environnemental

L'utilisateur renseigne les informations suivantes :&#x20;

* Poids de la batterie, en kg
* Chimie de la batterie : NMC811, LFP ou autre

### Procédés utilisés pour la modélisation

## Procédés utilisés pour le coût environnemental

Les procédés utilisés sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes).
