# 🐖 Jambon



{% hint style="danger" %}
**Page en construction**
{% endhint %}

## Construction de l'ingrédient jambon à partir du procédé agricole

Le jambon correspond à l'ICV suivant :&#x20;

* 'Cooked ham, case ready, at plant' (kilogram, FR, None)

$$
JambonREF
$$

Ce procédé est construit à partir du procédé :&#x20;

* Pig, conventional, national average, at farm gate

$$
PorcREF
$$

* de procédés d'abattage etc. :

<figure><img src="../../.gitbook/assets/porc.png" alt=""><figcaption></figcaption></figure>

On construit différents procédés de jambon **(N)**, sur la base du procédé de référence ('Cooked ham, case ready, at plant' (kilogram, FR, None)), en appliquant les opérations d'abattage à différents procédés de porc sortie de ferme **(N)**.

$$
ImpactJambon_N = (ImpactJambonREF - ImpactPorcREF )+ImpactPorc_N
$$

## Procédés retenus

| Label / Origine        | France                                                                                                                                                                    | Autres pays                                                                                                                                                               |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Conventionnelle        | <p><strong>JambonREF</strong><br><strong></strong>'Cooked ham, case ready, at plant' (kilogram, FR, None)<br>Porc : Pig, conventional, national average, at farm gate</p> | <p><strong>JambonREF</strong><br><strong></strong>'Cooked ham, case ready, at plant' (kilogram, FR, None)<br>Porc : Pig, conventional, national average, at farm gate</p> |
| Agriculture biologique | <p><strong>JambonBio</strong><br>Procédé construit (cf. formule)<br>Porc : </p>                                                                                           | <p><strong>JambonBio</strong><br>Procédé construit (cf. formule)<br>Porc : </p>                                                                                           |

{% hint style="info" %}
Le porc bio considéré dans un premier temps pour le calcul de la viande de boeuf hachée bio est celui dont l'impact est proche de l'impact moyen des porc bio ci-dessous
{% endhint %}

Pig, organic, at farm gate

Pig, organic, system n°1, at farm gate

Pig, organic, system n°2, at farm gate

Pig, organic, system n°3, at farm gate

Pig, organic, system n°4, at farm gate

(attente des graphes d'impacts)

_<mark style="color:red;">\[Intégration d'un graphique comparant les scores PEF décomposés des deux Farines qui seraient considérées]</mark>_&#x20;

