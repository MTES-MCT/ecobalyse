# 🚚 Transport

{% hint style="info" %}
Cette page décrit les principes communs aux différents types de produits susceptibles d'être modélisés dans Ecobalyse.&#x20;

Le cas échéant, les spécificités relatives à chaque produit sont décrites dans la documentation métier correspondante.
{% endhint %}

## Principales étapes de transport <a href="#distribution" id="distribution"></a>

Le transport est modélisé en prenant en compte les étapes suivantes : &#x20;

* Transport des matières premières (ex : coton, blé, bois) du champs ou de la foret vers le site de transformation
* Transport des produits intermédiaires (ex : tissu textile)  et composants (ex : pied de chaise, pneu) entre les sites de transformation,
* Transport du produit fini entre l'usine de production et un entrepôt de stockage en France
* Transport entre un site de stockage en France et un magasin ou centre de distribution ou client final s'il est livré directement.

A des fins de simplification, le transport entre un magasin ou un centre de distribution et le client final n'est pas pris en compte à ce jour dans Ecobalyse.

## Voies et modes de transports proposés

4 voies sont considérés, faisant appel à un ou deux modes de transport chacune :

* Voie Terrestre\
  Mode de transport : camion
* Maritime (transport international uniquement)\
  Modes de transport : bateau + camion\
  &#xNAN;_&#x44;ans le cas d'un transport par voie maritime, le transport est réalisé en trois étapes : transport par camion vers le port de départ, transport par bateau de port à port, transport par camion depuis le port d'arrivée._
* Aérienne (transport international uniquement)\
  Modes de transport : avion + camion\
  &#xNAN;_&#x44;ans le cas d'un transport par voie aérienne, le transport est réalisé en trois étapes : transport par camion vers l'aéroport de départ, transport par avion d'aéroport à aéroport, transport par camion depuis l'aéroport d'arrivée._&#x20;
* Ferroviaire (transport international uniquement)\
  Modes de transport : train

A des fins de simplification, ces 4 voies ne sont pas toujours proposés pour toutes les étapes de transport.







