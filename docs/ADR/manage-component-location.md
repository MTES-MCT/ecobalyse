Date: 12 mars 2026

## Etat
En cours

## Contexte

La modélisation du coût environnemental est générique à tous les produits et secteurs d'activités couverts (alimentaire et textile en migration). Cette orientation technique permet une base de code plus maintenable, une reproductibilité des modélisations sur différents secteurs.
Le modèle générique se base aussi sur une approche par composants. Ces composants sont attendus par nos utilisateurs pour modéliser des produits plus complexes (ex: doudoune, lot de pyjama, pack salades, vélos, meubles).

## Problèmatique

Le score du composant est une approximation car on ne prend pas en compte la localisation de chaque étape dans le composant.
Ce score doit être plus précis en ajoutant une localisation à chacune des étapes.

## Expérimentation sur la localisation des composants

Au printemps 2025, une approche simple de la localisation du composant a été implémentée: une localisation au niveau composant
Cette localisation pilote :
- le transport du composant vers son pays d'assemblage
- le mix énergétique (elec + chaleur) utilisés par les procédés de transformation intra-élément

La personnalisation de la localisation du composant est uniquement possible dans la modélisation du produit côté calculette front end. 
Les composants proposés dans la liste de données sources sont non-localisées par défaut. 

## Les limites de cette expérimentation : 

- l'absence de transport en intra composant (de la matière à la sa transfo 1 jusqu'à n) --> Conséquences: pour une étoffe coton d'1kg France mode éthique, le transport total jusqu'à la dernière étape de la confection en France vaut pour 40 points (dans le modèle textile v7) VS dans le modèle générique actuel, on compte 23 points de transport total.

- l'hypothèse que toutes les transformations se font dans un même pays --> Conséquences: pour une étoffe coton d'1kg France mode éthique, l'étape de tissage est en fait réalisé en Inde, soit 39 pts  Vs dans le modèle générique, on considère que le tissage est réalisé en France, soit 9 points (approximation de la localisation du composant).

Ces limites rendent impossible la modélisation d'exemples tels que réalisés dans le textile et actuellement utilisés par les entreprises pour différencier leurs produits sur un critère environnemental. (ex: t-shirt mode éthique, t-shirt mode fast-fashion)

## Décisions

Nous avons besoin de gérer le transport entre les transformations et d'avoir un modèle qui prend en compte l'impact des transformations selon le pays de transformation.
Ces nuances ont été un critère d'adoption pour les entreprises textile et le déploiement du dispositif.

- On peut localiser chaque procédé (materials et transformation) dans chaque composant. Lorsqu'il n'y pas de pays, on reprend l'hypothèse 'inconnu' avec la valeur de 18000 km, et le mix énergétique définit par défaut.
Remarque: on ne localise pas les procédés en eux-même
- Il n'y plus de champs country au niveau composant (plus de localisation composant)
- Si des procédés de transformation se passent dans une même usine ou pays, on considère tout de même qu'il y a du transport entre ces procédés
- le transport entre les composants et le lieu d'assemblage se fait en cumulant la distance entre la dernière étape de transformation de chaque élement de chaque composant vers le pays d'assemblage

## Exemple (à compléter par la méthode) :
Composant: 
nom du composant: Etoffe coton 1kg - France
Element 1:
1,xx kg coton / country: Asie
filature conventionnelle / country : Turquie
tissage / country: Turquie
blanchiement / country: 
dégraissage/ country :
teinture moyenne / country :


## Améliorations possibles à venir

- Les distances pour le pays inconnu
- Les distances pour un même pays


## Conséquences

- complexification du modèle de calcul
- complexification de l'ui (localisation géré par l'utilisateur sur chaque élément et procédé sous le composant Vs actuellement gestion au premier niveau)

## Vocabulaire et concept
- composant = une partie d'un produit lui-même composé d'éléments
- élément = une matière première au moins auquel il est possible d'ajouter des procédés de transformation en fonction du material type de la matière première
- material type = tag de classification des matières premières permettant un filtre sur les procédés de transformation et une gestion par type en fin de vie
- localisation = pays ou zone géographique auxquels sont attachés des attributs (distances géographiques, procédés de mix énergétique)
