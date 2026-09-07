# ♻️ Fin de vie Véhicules

## Contexte

### Filière Véhicules hors d’usage (VHU)

La filière Véhicules hors d’usage (VHU) couvre les voitures particulières (catégorie M), véhicules utilitaires légers (catégorie N), véhicules à deux ou trois roues et quadricycles à moteur (catégorie L).

La gestion de la fin de vie de ces véhicules est réalisée dans le cadre de l’obligation de responsabilité élargie des producteurs (REP) de véhicules.

Pour en savoir plus consulter la page suivante : [https://www.ecologie.gouv.fr/politiques-publiques/vehicules-hors-dusage-vhu](https://www.ecologie.gouv.fr/politiques-publiques/vehicules-hors-dusage-vhu)

Des objectifs de collecte, de réemploi, de recyclage et de valorisation sont fixés pour les constructeurs ([voir page ADEME sur la filière REP concernée](https://filieres-rep.ademe.fr/filieres-REP/filiere-VEHICULE))

## Méthodes de calcul

Voir page transverse :

{% content-ref url="../../methodes-transverses/fin-de-vie.md" %}
[fin-de-vie.md](../../methodes-transverses/fin-de-vie.md)
{% endcontent-ref %}

## Paramètres retenus pour le coût environnemental

#### Recyclabilité produit `r_p`  <a href="#recyclabilite-produit-r_p" id="recyclabilite-produit-r_p"></a>

Il est considéré que tous les véhicules sont recyclables. Pour mémoire cela signifie qu'il peut être démantelé et que ses matériaux sont recyclés selon les pourcentages définis pour chacun d'entre eux. Cela ne signifie pas que les matériaux sont recyclés à 100%.

#### Taux de collecte `TC` <a href="#taux-de-collecte-tc" id="taux-de-collecte-tc"></a>

Le taux de collecte par défaut de 70% est retenu. Il correspond à l'objectif indicatif de collecte fixé pour les catégories M (voiture particulière) et N (véhicule utilitaire léger) à horizon 2028 (pas d'objectif pour la catégorie L).

#### Taux de recyclage, d'incinération et de traitement hors Europe `R_FS,xxx,i` et `R_HF,xxx,i` <a href="#taux-de-recyclage-dincineration-et-de-traitement-hors-europe-r_fs-xxx-i-et-r_hf-xxx-i" id="taux-de-recyclage-dincineration-et-de-traitement-hors-europe-r_fs-xxx-i-et-r_hf-xxx-i"></a>

Les taux par défaut sont retenus ici.

## Exemple d'application

Exemple pour un véhicule très simplifié de 100kg constitué à 50% d'acier, 30% de Plastique PP et 20% de cellules de batteries : la fin de vie permet de réduire le coût environnemental de près de 19000Pts.

L'essentiel de cette réduction est permise par les 14kg de cellules de batterie, car les matériaux récupérés ont un fort impact en termes de raréfactions de ressources métalliques.

<figure><img src="../../.gitbook/assets/image (406).png" alt=""><figcaption></figcaption></figure>

Sur les cellules de batteries spécifiquement, le traitement en fin de vie permet de réduire de 15% à 20% l'impact liée à la fabrication des cellules (hors assemblage et transport) :

* La fabrication de la cellule, implique des procédés de transformations énergivores (énergie non récupérable en fin de vie)
* Il est considéré que seuls 70% des véhicules sont collectés
* Seule une partie des métaux est récupérée (90% du cuivre, du Cobalt et du Nickel, 50% du Lithium)
* Le processus de recyclage vient réduire de l'ordre d'un quart les bénéfices du recyclage&#x20;
* Sur les métaux récupérés grâce au recyclage, 80% du bénéfice est attribué à la fin de vie de ce produit, les 20% restant étant attribués au produit fabriqué à partir des métaux recyclés (règle de calcul CFF)
