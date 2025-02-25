# 🚚 Transport des véhicules

Cette page porte sur les spécificités du transport du véhicule (produit fini) depuis le site d'assemblage vers le site de distribution en France (le cas échéant), puis vers le consommateur final.

Les informations relatives au transport de manière générale sont détaillées dans la [documentation transverse d'Ecobalyse](../../documentation-transverse/transport/).

## Généralités

Le transport de véhicules assemblés est spécifique à ce secteur. En effet, dans la plupart des cas, le volume à transporter est conséquent par rapport au poids, ce qui implique un transport fortement sous-capacitaire en termes de poids transporté.&#x20;

Les véhicules les plus grands, à l'instar des voitures, sont transportés dans des moyens de transports spécifiques.

### Éléments sur l'impact environnemental du transport de véhicules

#### Transport maritime de voitures

Le transport de voitures s'effectue dans des navires dédiés, dont la capacité est de 10 000 à 20 000 tonnes. Par comparaison, la capacité des portes-conteneur est de 7 000 à 300 000 t, avec une capacité moyenne de 64 000 tonnes (4600 EVP).

Comme tous les navires opérant en Europe, ces navires sont tenus de déclarer leur consommation de carburant, les émissions de gaz à effet de serre associées, ainsi que le tonnage moyen annuel.

Il en ressort des émissions essentiellement situées entre 20gCO2/tkm et 50gCO2e/tkm en 2022. Par comparaison, les émissions du transport de marchandise par conteneurs maritime sont de l'ordre de 10g/tkm.

#### Transport de vélos assemblés à 80%

Sur de grandes distances, les vélos sont transportés partiellement assemblés, dans des cartons. Par exemple, un vélo de 20kg sera emballé dans un carton de 0.25m3, soit 80kg/m3. Par comparaison, un conteneur est chargé en moyenne à hauteur de 200kg/m3.

## Modification de la modélisation du transport pour les véhicules

Les méthodes relatives au transport s'applique au transport de véhicules, excepté le choix des procédés utilisés.

Chaque mode de transport possible est modélisé sur la base du procédé Ecoinvent indiqué dans la documentation transversale, et multiplié par un facteur multiplicatif permettant de rendre compte du caractère faiblement capacitaire voire spécifique du transport de véhicules.

<table><thead><tr><th width="349">Type de transport</th><th>Facteur multiplicatif</th></tr></thead><tbody><tr><td>Terrestre</td><td>2.0</td></tr><tr><td>Maritime</td><td>5.0</td></tr><tr><td>Ferroviaire</td><td>2.0</td></tr></tbody></table>

