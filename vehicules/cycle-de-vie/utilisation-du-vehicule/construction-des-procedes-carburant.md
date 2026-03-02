# 📝 Construction des procédés carburant

Il n'existe pas de procédés directement utilisables dans Ecoinvent pour modéliser les impacts environnementaux associés à la consommation de carburant.

Des procédés ont été créés par Ecobalyse pour combiner la production de carburant d'une part et les émissions à la combustion d'autre part.

## Partie production

Les carburants intègre une partie de biocarburants plus ou moins importante. A ce stade la modélisation des carburants est sommaire, le coût environnemental des véhicule étant en premier lieu développé pour les véhicules intermédiaires électriques.

<details>

<summary>Diesel</summary>

Le Diesel B7 utilisé en France est composé à 93% de gazole et à 7% de biodiesel (esters méthyliques d’acides gras - EMAG).

* Le diesel est modélisé par le procédé Ecoinvent `diesel, low-sulfur//[RER] market group for diesel, low-sulfur`
* Le biodiesel est modélisé par le procédé Ecoinvent `fatty acid methyl ester//[RoW] market for fatty acid methyl ester`.&#x20;

La densité du Diesel B7 est de 0.84 kg/L



</details>

<details>

<summary>Essence</summary>

L'Essence la plus couramment utilisée en France est l'E10, elle est composé à 90% d'essence et à 10% de biocarburant.

* L'essence est modélisé par le procédé Ecoinvent `petrol, low-sulfur//[RER] market group for petrol, low-sulfur`
* Le biocarburant est modélisé par le procédé Ecoinvent `ethyl tert-butyl ether//[RER] ethyl tert-butyl ether production, from bioethanol`. \
  En pratique, l'ETBE modélisé par ce procédé est fabriqué à partir d’éthanol (d’origine agricole) et d’isobutène (actuellement d’origine chimique). l'E10 est fabriqué à partir d'ETBE et de biocarburant, le taux de 10% correspondant au total maximum d'origine agricole.

La densité de l'essence E10 est de 0.755 kg/L

</details>

Ressources pour en savoir plus sur les biocarburants :&#x20;

* [https://www.ecologie.gouv.fr/politiques-publiques/biocarburants](https://www.ecologie.gouv.fr/politiques-publiques/biocarburants)&#x20;
* [https://www.statistiques.developpement-durable.gouv.fr/edition-numerique/chiffres-cles-energies-renouvelables/fr/22-biocarburants-](https://www.statistiques.developpement-durable.gouv.fr/edition-numerique/chiffres-cles-energies-renouvelables/fr/22-biocarburants-)

## Partie émissions

Les émissions de CO2 sont celles indiqués dans BaseEmpreinte pour chaque carburant.

Les émissions de polluants sont évaluées au regard de la norme sur les émissions des véhicules, et converties en émissions par litre au regard des [statistiques de consommation moyennes des véhicules](https://carlabelling.ademe.fr/chiffrescles/r/evolutionConsoMoyenne) (moyenne sur 3 ans, 2021-2023).

