---
description: Choix du mix électrique à appliquer en fonction du pays
---

# ⚡ Electricité

## Procédés

Le mix électrique appliqué dépend du pays dans lequel l'étape correspondante est réalisée.

| Pays       | Procédé électricité       | UUID                                 |
| ---------- | ------------------------- | ------------------------------------ |
| Bangladesh | Mix électrique réseau, BD | 1ee6061e-8e15-4558-9338-94ad87abf932 |
| Chine      | Mix électrique réseau, CN | 8f923f3d-0bd2-4326-99e2-f984b4454226 |
| Espagne    | Mix électrique réseau, ES | 37301c44-c4cf-4214-a4ac-eee5785ccdc5 |
| France     | Mix électrique réseau, FR | 05585055-9742-4fff-81ff-ad2e30e1b791 |
| Inde       | Mix électrique réseau, IN | 1b470f5c-6ae6-404d-bd71-8546d33dbc17 |
| Portugal   | Mix électrique réseau, PT | a1d83202-0052-4d10-b9d2-938564be6a0b |
| Tunisie    | Mix électrique réseau, TN | f0eb64cd-468d-4f3c-a9a3-3b3661625955 |
| Turquie    | Mix électrique réseau, TR | 6fad8643-de3e-49dd-a48b-8e17b4175c23 |

## Paramétrage manuel de l'impact carbone

A chaque étape de la production qui mobilise de l'électricité, il est proposé de paramétrer manuellement l'intensité carbone du mix électrique.

Par défaut, l'intensité carbone du mix électrique est la valeur spécifiée dans la base Impacts, pour l'impact "changement climatique" (UUID : `b2ad6d9a-c78d-11e6-9d9d-cec0c932ce01)`, pour chacun des mix électriques nationaux mentionnés (ci-dessus).

Le paramétrage manuel doit notamment permettre de traduire le cas d'un site industriel dont l'électricité serait produite grâce à des panneaux photovoltaïques sur site, ce qui justifierait un mix électrique différent du réseau national.

Paramétrage :&#x20;

* unité : kg CO2e / kWh
* valeur min : 0 kg CO2e / kWh
* valeur max : 1,7 kg CO2e / kWh
* pas : 0,001 kg CO2e / kWh

{% hint style="warning" %}
* Le paramétrage manuel **ne concerne que le changement climatique** et pas les autres impacts qui pourraient être prochainement intégrés dans l'outil Ecobalyse
* La modification manuelle de l'intensité carbone du mix électrique **ne s'applique qu'à l'étape considérée** (par exemple la teinture). Elle ne modifie pas le mix électrique mobilisé pour une autre étape qui serait réalisée dans le même pays (par exemple la confection).
* La revendication d'un mix électrique différent de celui du réseau national, par exemple une énergie 100% renouvelable, **nécessite que des conditions soient remplies** \[à préciser pour lister les critères à remplir pour revendiquer une énergie verte en ACV].
{% endhint %}

### Repères utiles

Pour déterminer l'intensité carbone d'un mix électrique, il est possible de considérer :&#x20;

* l'intensité carbone des différents mix électrique nationaux telle que définie dans la base Impacts (cf. impact "changement climatique" des différents procédés de mix électriques) ;
* les intensités carbone des différents moyens de production présentés dans la base Carbone / bilan GES de l'ADEME ([lien](https://www.bilans-ges.ademe.fr/fr/basecarbone/donnees-consulter/choix-categorie/categorie/69)).

{% hint style="warning" %}
* La modification manuelle de l'intensité carbone d'un mix électrique **ne modifie pas le pays considéré pour les différentes étapes de transport**. Si l'intensité carbone d'un autre mix électrique national est renseigné dans le champ, les transports restent calculés pour le pays dans lequel l'étape est réalisée.
* Les intensités carbone des différents moyens de production présentés dans la base Carbone / bilan GES de l'ADEME concernent l'utilisation de ces moyens en France. **La transposition à d'autres pays peut impliquer des modifications**.
* Les intensités carbone des mix électriques nationaux **présentent des valeurs différentes dans la base Impacts et dans la base Carbone / bilan GES de l'ADEME** ([lien](https://www.bilans-ges.ademe.fr/fr/accueil/documentation-gene/index/page/Moyenne\_par\_pays)). Ces écarts doivent être mieux compris pour éviter des erreurs.
{% endhint %}

## Limites

Il peut être proposé :&#x20;

* d'ajouter de nouveaux pays, et donc de nouveaux mix énergétiques.
