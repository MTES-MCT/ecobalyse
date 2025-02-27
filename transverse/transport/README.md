# 🚚 Transport

{% hint style="info" %}
Cette page décrit les principes communs aux différents types de produits susceptibles d'être modélisés dans Ecobalyse.&#x20;

Le cas échéant, les spécificités relatives à chaque produit sont décrites dans la documentation métier correspondante.
{% endhint %}

## _<mark style="color:red;">Implémentation en cours</mark>_ <a href="#distribution" id="distribution"></a>

La [page Transport de la section Textile](https://fabrique-numerique.gitbook.io/ecobalyse/textile/cycle-de-vie-des-produits-textiles/transport) fait à ce jour référence

## Principales étapes de transport <a href="#distribution" id="distribution"></a>

Le transport est modélisé en prenant en compte les étapes suivantes : &#x20;

1. Transport des matières premières (ex : coton, blé, bois) du champs ou de la foret vers le premier site de transformation,
2. Transport des produits intermédiaires (ex : tissu textile), ingrédients déjà transformés, et composants (ex : pied de chaise, pneu) entre les sites de transformation,
3. Transport du produit fini entre l'usine de production du produit fini et un entrepôt de stockage en France,
4. Transport entre l'entrepôt de stockage en France et un magasin ou centre de distribution ou client final s'il est livré directement.

A des fins de simplification, le transport entre un magasin ou un centre de distribution et le client final n'est pas pris en compte à ce jour dans Ecobalyse.

Pour les étapes 1 à 4, plusieurs voies de transport peuvent être utilisées. La modélisation dépend des pays concernés et des types de produits.

Pour l'étape 5, un transport terrestre est considéré, avec une distance appelée D\_terre,distriFR

## Voies et modes de transports

Afin de bien modéliser les scénarios de transport, Ecobalyse distingue les notions de voie de transport et de mode de transport :&#x20;

* Le mode de transport est le type de véhicule transportant une marchandise (bateau, camion, avion, train...)
* Quatre voies de transport sont considérées, faisant appel à un ou deux modes de transport chacune :
  * Terrestre (terre)\
    Mode de transport : camion
  * Maritime (mer)\
    Modes de transport : bateau + camion\
    &#xNAN;_&#x44;ans le cas d'un transport par voie maritime, le transport est réalisé en trois étapes : transport par camion vers le port de départ, transport par bateau de port à port, transport par camion depuis le port d'arrivée._
  * Aérienne (air)\
    Modes de transport : avion + camion\
    &#xNAN;_&#x44;ans le cas d'un transport par voie aérienne, le transport est réalisé en trois étapes : transport par camion vers l'aéroport de départ, transport par avion d'aéroport à aéroport, transport par camion depuis l'aéroport d'arrivée._&#x20;
  * Ferroviaire (fer)\
    Modes de transport : train

A des fins de simplification, ces quatre voies ne sont pas toujours proposés pour toutes les étapes de transport.

## Descriptif de la documentation Transport

* La page _Coût environnemental par voie de transport_ détaille le calcul du coût environnemental pour chacune des voies de transport, en fonction des situations.
* La page Choix des voies modes de transport détaille la façon dont une ou plusieurs voies de transport sont combinées pour une étape de transport donnée.
* Des pages dédiées par secteur décrivent les voies de transport proposées à chaque étape, et les éventuels paramètres spécifiques au secteur :
  * [Textile](https://fabrique-numerique.gitbook.io/ecobalyse/draft-documentation-transverse/transport/transport-textile)
  * Alimentaire









