# ⚡ Electricité

## Fonctionnement

### Généralités

La consommation d'électricité s'exprime en kilowattheures (kWh).\
Certains procédés nécessitent l'utilisation de l'unité mégajoule (MJ) pour la quantité d'électricité; une conversion est alors appliquée (1 kWh = 3,6 MJ).&#x20;

Deux scénarios existent pour modéliser la consommation d'électricité des procédés mobilisés :&#x20;

**Scénario 1** :  l'électricité est déjà intégrée dans le procédé mobilisé en tant que Flux Interne&#x20;

**Scénario 2** : l'électricité n'est pas intégrée dans le procédé mobilisé et doit être intégrée en tant que Flux Externe\
Dans ce cas précis, la quantité d'électricité nécessaire pour actionner le procédé mobilisé correspond au produit de la masse "sortante" du procédé mobilisé (ex : masse d'étoffe en sortie du tissage) avec le coefficient du flux intermédiaire correspondant à l'électricité (`de442ef0-d725-4c3a-a5e2-b29f51a1186c`).

### Spécificités

#### Source d'électricité < = >  pays&#x20;

L'impact environnemental de la production d'électricité varie significativement selon le mix électrique utilisé.

Ecobalyse applique par défaut les mix électriques nationaux des pays disponibles dans le calculateur.&#x20;

#### Paramétrage manuel de l'impact carbone

A chaque étape de la production qui mobilise de l'électricité, il est proposé de paramétrer manuellement l'intensité carbone du mix électrique.

Par défaut, l'intensité carbone du mix électrique est la valeur spécifiée dans la base Impacts, pour l'impact "changement climatique" (UUID : `b2ad6d9a-c78d-11e6-9d9d-cec0c932ce01)`, pour chacun des mix électriques nationaux mentionnés (ci-dessus).

Le paramétrage manuel doit notamment permettre de traduire le cas d'un site industriel dont l'électricité serait produite grâce à des panneaux photovoltaïques sur site, ce qui justifierait un mix électrique différent du réseau national.

Paramétrage :

* unité : kg CO2e / kWh
* valeur min : 0 kg CO2e / kWh
* valeur max : 1,7 kg CO2e / kWh
* pas : 0,001 kg CO2e / kWh

{% hint style="warning" %}
* Le paramétrage manuel **ne concerne que le changement climatique** et pas les autres impacts qui pourraient être prochainement intégrés dans l'outil Wikicarbone
* La modification manuelle de l'intensité carbone du mix électrique **ne s'applique qu'à l'étape considérée** (par exemple la teinture). Elle ne modifie pas le mix électrique mobilisé pour une autre étape qui serait réalisée dans le même pays (par exemple la confection).
* La revendication d'un mix électrique différent de celui du réseau national, par exemple une énergie 100% renouvelable, **nécessite que des conditions soient remplies** \[à préciser pour lister les critères à remplir pour revendiquer une énergie verte en ACV].
{% endhint %}

Pour déterminer l'intensité carbone d'un mix électrique, il est possible de considérer :

* l'intensité carbone des différents mix électrique nationaux telle que définie dans la base Impacts (cf. impact "changement climatique" des différents procédés de mix électriques) ;
* les intensités carbone des différents moyens de production présentés dans la base Carbone / bilan GES de l'ADEME ([lien](https://www.bilans-ges.ademe.fr/fr/basecarbone/donnees-consulter/choix-categorie/categorie/69)).

{% hint style="warning" %}
* La modification manuelle de l'intensité carbone d'un mix électrique **ne modifie pas le pays considéré pour les différentes étapes de transport**. Si l'intensité carbone d'un autre mix électrique national est renseigné dans le champ, les transports restent calculés pour le pays dans lequel l'étape est réalisée.
* Les intensités carbone des différents moyens de production présentés dans la base Carbone / bilan GES de l'ADEME concernent l'utilisation de ces moyens en France. **La transposition à d'autres pays peut impliquer des modifications**.
* Les intensités carbone des mix électriques nationaux **présentent des valeurs différentes dans la base Impacts et dans la base Carbone / bilan GES de l'ADEME** ([lien](https://www.bilans-ges.ademe.fr/fr/accueil/documentation-gene/index/page/Moyenne\_par\_pays)). Ces écarts doivent être mieux compris pour éviter des erreurs.
{% endhint %}

## Limites

Il peut être proposé d'ajouter de nouveaux pays, et donc de nouveaux mix énergétiques.
