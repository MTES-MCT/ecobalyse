Date: 12 mars 2026

## Etat
En cours

## Contexte

La modélisation du coût environnemental est générique à tous les produits et secteurs d'activités couverts (alimentaire et textile en migration). Cette orientation technique permet une base de code plus maintenable, une reproductibilité des modélisations sur différents secteurs.
Le modèle générique se base aussi sur une approche par composants. Ces composants sont attendus par nos utilisateurs pour modéliser des produits plus complexes (ex: doudoune, lot de pyjama, pack salades, vélos, meubles).

## Expérimentation sur la localisation des composants

Au printemps 2025, une approche simple de la localisation du composant a été implémentée: une localisation au niveau composant
Cette localisation pilote :
- le transport du composant vers son pays d'assemblage
- le mix énergétique (elec + chaleur) utilisés par les procédés de transformation intra-élément

La personnalisation de la localisation est uniquement possible dans la modélisation du produit côté calculette front end. Les composants proposés dans la liste de composant sont non-localisées.
Conséquences: La localisation du composant se retrouve donc dans un champs country du json produit (non intégré dans l'id composant).


## Les limites de cette expérimentation : 

- l'absence de transport en intra composant --> Conséquences: pour une étoffe coton d'1kg, le transport jusque la confection vaut pour 40 points jusqu'à la confection VS dans le modèle générique actuel, on compte 23 points

- l'hypothèse que toutes les transformations se font dans un même pays --> Conséquences: tissage réalisé en Inde: 39 pts
Vs tissage réalisé en France : 9 points

Ces limites rendent impossible la modélisation d'exemples tels que réalisés dans le textile et actuellement utilisés par les entreprises pour différencier leurs produits sur un critère environnemental. (ex: t-shirt mode éthique, t-shirt mode fast-fashion)

## Décisions

Nous avons besoin de gérer le transport entre les transformations et d'avoir un modèle qui nuance l'impact des transformations selon le pays de transformation.
Ces nuances ont été un critère d'adoption pour les entreprises et le déploiement du dispositif.

- Au sein du composant (objet component dans le json produit et component.json), il y a un champs "country" pour chaque procédé.
- Le procédé (processes_generic) ne porte pas de valeur par défaut de localisation. Uniquement un paramètrage composant.
- Il n'y plus de champs country au niveau composant
- Si des procédés de transformation se passent dans une même usine ou pays, on considère tout de même qu'il y a du transport entre ces procédés
- le transport entre les composants et le lieu d'assemblage se fait en cumulant la distance entre la dernière étape de transformation de l'élement vers le pays d'assemblage
- lorsque le pays n'est pas paramétré, on reprend l'hypothèse 'inconnu' avec la valeur de 18000 km

## Conséquences

- complexification du modèle
- pas de localisation modifiable par un utilisateur au niveau composant

## Vocabulaire et concept
- composant = une partie d'un produit lui-même composé d'éléments
- élément = une matière première au moins auquel il est possible d'ajouter des procédés de transformation en fonction du material type de la matière première
- material type = tag de classification des matières premières permettant un filtre sur les procédés de transformation et une gestion par type en fin de vie
- localisation = pays ou zone géographique auxquels sont attachés des attributs (distances géographiques, procédés de mix énergétique)
