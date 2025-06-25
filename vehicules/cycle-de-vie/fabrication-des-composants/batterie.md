---
description: Cette page décrit le calcul du coût environnemental de la batterie.
---

# 🔋 Batterie

## Généralités

La batterie représente 10% à 50% du coût environnemental d'un véhicule électrique. Ce chiffre varie principalement en fonction de l'autonomie recherchée pour le véhicule (capacité de la batterie), et du poids du véhicule.

## Modélisation Ecobalyse

### Méthodologie de calcul <a href="#methodologie-de-calcul" id="methodologie-de-calcul"></a>

Le coût environnement de la batterie est évalué d'après sa chimie et son poids (en kg), avec plusieurs origines possibles.

Les chimies de batterie suivantes sont différenciées : NMC811, LFP.

Les sites et méthodes de fabrication des modules et cellules de batterie, ainsi que les sites et méthode d'extraction et de raffinage des matières premières ont également une réelle influence sur le coût environnemental. \
Cependant, par souci de simplification et compte-tenu de la difficulté à détailler la chaine de valeur de fabrication, ils ne sont pas utilisés comme paramètres dans Ecobalyse.

Dans un second temps, le coût environnemental sera calculé par la base de la capacité de la batterie (en kWh). En plus de la capacité et du pays de fabrication, l'utilisateur devra renseigner le poids de la batterie, pour le calcul du poids des composants non directement quantifié, et pour le calcul du coût environnemental du transport.

## Paramètres retenus pour le coût environnemental

### Paramètres précisés par l'utilisateur

L'utilisateur renseigne les informations suivantes :&#x20;

* Poids de la batterie, en kg
* Chimie et origine de la batterie

### Procédés utilisés pour la modélisation

Les procédés disponibles sont identifiés dans l'Explorateur de procédé.
