# 🚚 Transport

{% hint style="warning" %}
Ces méthodes s'appliquent pour la version courante d'Ecobalyse, pas pour la version réglementaire Textile.
{% endhint %}

{% hint style="warning" %}
Le calcul du transport est en cours de développement. Une partie des méthodes décrites ci-dessous ne sont pas encore implémentées.&#x20;
{% endhint %}

## Principales étapes de transport <a href="#distribution" id="distribution"></a>

Le transport est modélisé en prenant en compte les étapes suivantes : &#x20;

1. Transport des matières premières (ex : coton, blé, bois) du champs ou de la foret vers le premier site de transformation,
2. Transport des produits intermédiaires (ex : tissu textile), ingrédients déjà transformés, et composants (ex : pied de chaise, pneu) entre les sites de transformation,
3. Transport du produit fini entre l'usine de production du produit fini et un entrepôt de stockage en France,
4. Transport entre l'entrepôt de stockage en France et un magasin ou centre de distribution ou client final s'il est livré directement.

A des fins de simplification, le transport entre un magasin ou un centre de distribution et le client final n'est pas pris en compte à ce jour dans Ecobalyse.

Pour les étapes 1 à 3, plusieurs voies de transport peuvent être utilisées. La modélisation dépend des pays concernés et des types de produits.

Pour l'étape 4, un transport terrestre est considéré, avec une distance appelée D\_terre,distriFR

## Un transport international modélisé en 3 phases

Ecobalyse modélise chaque étape de transport sous la forme de trois phases distinctes :&#x20;

1. Transport du site de départ au hub régional de départ (hub routier, port ou aéroport), en camion
2. Transport du hub de départ au hub d'arrivée, avec un mode de transport dépendant de divers paramètres (type de produit, régions concernées).&#x20;
3. Transport du hub régional de départ au site d'arrivée, en camion

_A titre d'exemple, un transport par voie maritime se décompose comme suit, avec deux modes de transport (bateau et camion) :_&#x20;

<figure><img src="../../.gitbook/assets/image (372).png" alt=""><figcaption></figcaption></figure>

### Voies et modes de transports

Afin de bien modéliser les scénarios de transport, Ecobalyse distingue ainsi les notions de voie de transport et de mode de transport :&#x20;

* Le mode de transport permettant de transporter une marchandise (bateau, camion, avion, train...)
* Quatre voies de transport sont considérées, faisant chacune appel à un ou deux modes de transport :
  * Terrestre (terre)\
    Mode de transport : camion
  * Maritime (mer)\
    Modes de transport : bateau + camion
  * Aérienne (air)\
    Modes de transport : avion + camion<br>

A des fins de simplification, ces quatre voies ne sont pas toujours proposés pour toutes les étapes de transport.

## Descriptif de la documentation Transport

* La page [Coût environnemental par voie de transport](https://fabrique-numerique.gitbook.io/ecobalyse/transverse/transport/cout-environnemental-par-voie-de-transport) détaille le calcul du coût environnemental pour chacune des voies de transport, en fonction des situations.
* La page [Choix des voies de transport](https://fabrique-numerique.gitbook.io/ecobalyse/transverse/transport/choix-des-voies-de-transport) détaille la façon dont une ou plusieurs voies de transport sont combinées pour une étape de transport donnée.
* Des pages dédiées par secteur décrivent si besoin les voies de transport proposées à chaque étape, et les éventuels paramètres spécifiques au secteur.

