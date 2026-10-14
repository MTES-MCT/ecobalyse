---
description: >-
  Cette page décrit les composants spécifiques aux véhicules, non traités dans
  les sections précédentes.
hidden: true
---

# ⚙️ Moteur

## Généralités

Le moteur représente de l'ordre de 5% du coût environnemental.

## Modélisation Ecobalyse

### Méthodologie de calcul <a href="#methodologie-de-calcul" id="methodologie-de-calcul"></a>

Des composants "moteurs" sont proposés pour modéliser des moteurs thermiques ou électriques.

Les composants sont construit de la façon suivante :&#x20;

**moteur électrique, pour 1kW :**&#x20;

* procédé : "powertrain production, for electric passenger car {GLO}" (ecoinvent)
  * Ce procédé correspond à groupe motopropulseur de 80.2kg et 100kW environ
* quantité : 0.8 kg/kW

**moteur thermique, pour 1kW :**&#x20;

* procédé : "Internal combustion engine, passenger car {GLO}" (ecoinvent)
  * Ce procédé correspond à moteur de 275kg pour une Golf A4 55 kW essence ou 66 kW diesel
* quantité pour les diesel : 2 kg/kW
* quantité pour les essence : 1.5 kg/kW

