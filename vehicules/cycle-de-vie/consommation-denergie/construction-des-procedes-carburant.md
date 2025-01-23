# 📝 Construction des procédés carburant



<details>

<summary>Diesel</summary>

Pas de procédé disponible satisfaisant.

Procédé créé par Ecobalyse : `diesel, low-sulfur, including Euro5 emissions (RER)`&#x20;

Ce procédé comprend la consommation de carburant et les émissions directes du véhicule associées.

Ce nouveau procédé est construit à partir du procédé Ecoinvent `transport, passenger car, medium size, diesel, EURO 5, RER`. Ce procédé inclut la consommation de carburant, d'autres intrant, et un ensemble d'émissions sortant directement dans l'environnement. Dans ce procédé Ecoinvent, 5.564796E-2 kg du procédé `market group for diesel, low-sulfur, RER` sont utilisés pour 1 km de transport.

Le procédé est donc construit de la façon suivante :&#x20;

* 14.915 km de `transport, passenger car, medium size, diesel, EURO 5, RER`
  * 5.564796E-2 kg/km ; densité de 0.83kg/L
* suppression de l'ensemble des flux intermédiaires de la technoshère, exepté `market group for diesel, low-sulfur, GLO`
  * market for passenger car, diesel, GLO
  * maintenance, passenger car, RER
  * market for road, GLO
  * market for road maintenance, GLO
  * market for tyre wear emissions, passenger car, GLO
  * market for brake wear emissions, passenger car, GLO
  * market for road wear emissions, passenger car, GLO
* unité : Litre

</details>

<mark style="color:red;">Hydrogène : market for hydrogen, gaseous, medium pressure, merchant RER</mark>

Reconstruire Hydrogène + convertir kg essence diesel en litres



