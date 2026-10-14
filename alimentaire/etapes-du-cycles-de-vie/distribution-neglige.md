---
description: Après l'emballage, le produit est stocké sur une plateforme de distribution
---

# 👷‍♀️ Distribution (négligé)

Hormis les transports, cette étape du cycle de vie a un impact qui provient de :

* la consommation d'énergie de la plateforme de distribution.
  * électricité
  * chaleur
* la consommation d'eau de la plateforme de distribution
* l'émission de gaz réfrigérant (r404) (négligé pour l'instant)

Pour estimer l'impact d'un produit, on a besoin de sa densité. Les hypothèses de la doc Agribalyse

<figure><img src="../../.gitbook/assets/image (152).png" alt=""><figcaption><p>Méthodologie AGB 3.0-20200218_rapport-vf2.pdf</p></figcaption></figure>

De plus

<figure><img src="../../.gitbook/assets/image2.png" alt=""><figcaption><p>Méthodologie AGB 3.0-20200218_rapport-vf2.pdf</p></figcaption></figure>

À partir de ces données et de l'impact unitaire de chaque procédé, on peut en déduire l'impact de l'étape de distribution en µPt PEF par kg de produit.

On obtient :

* 0.37 µPt PEF pour les produits "Ambient"
* 0.14 µPt PEF pour les produits "Chilled"
* 0.38 µPt PEF pour les produits "Frozen"

Sachant que l'aliment non liquide ayant le moins d'impact est la patate douce avec un score PEF de 37 µPt PEF/kg. Même dans ce cas extrême l'impact de la distribution (0.14 µPt PEF) représente moins de 1% de l'impact du produit. C'est pourquoi on fait l'hypothèse d'ignorer ces impacts.

<br>
