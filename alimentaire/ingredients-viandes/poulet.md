# 🐣 Poulet

{% hint style="danger" %}
**Page en construction**
{% endhint %}

## Construction de l'ingrédient jambon à partir du procédé agricole

Le jambon correspond à l'ICV suivant :&#x20;

* Chicken, breast, without skin, raw, processed in FR |

$$
BlancPouletREF
$$

Ce procédé est construit à partir du procédé :&#x20;

* Broiler, conventional, at farm gate

$$
PouletREF
$$

* de procédés intermédiaires (abattage, desossage) :

<figure><img src="../../.gitbook/assets/chicken.png" alt=""><figcaption></figcaption></figure>

<figure><img src="../../.gitbook/assets/broiler 1.jpg" alt=""><figcaption></figcaption></figure>

On construit différents procédés de blanc de poulet **(N)**, sur la base du procédé de référence (Chicken, breast, without skin, raw, processed in FR |), en appliquant les opérations intermédiaires à différents procédés de poulet sortie de ferme **(N)**.

$$
ImpactBlancPoulet_N = (ImpactBlancPouletREF - ImpactPouletREF )+ImpactPoulet_N
$$

## Procédés retenus

| Label / Origine        | France                                                                                                                                                           | Autres pays                                                                                                                                                      |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Conventionnelle        | <p><strong>BlancPouletREF</strong><br><strong></strong>Chicken, breast, without skin, raw, processed in FR |<br>Poulet : Broiler, conventional, at farm gate</p> | <p><strong>BlancPouletREF</strong><br><strong></strong>Chicken, breast, without skin, raw, processed in FR |<br>Poulet : Broiler, conventional, at farm gate</p> |
| Agriculture biologique | <p><strong>BlancPouletBio</strong><br>Procédé construit (cf. formule)<br>Poulet : </p>                                                                           | <p><strong>BlancPouletBio</strong><br>Procédé construit (cf. formule)<br>Poulet : </p>                                                                           |

{% hint style="info" %}
Le poulet bio considéré dans un premier temps pour le calcul du blanc de poulet bio est celui dont l'impact est proche de l'impact moyen des poulets bio listés ci-dessous
{% endhint %}

Broiler, organic, at farm gate

Broiler, organic, system n°1, at farm gate

Broiler, organic, system n°2, at farm gate

(attente des graphes d'impacts)

_<mark style="color:red;">\[Intégration d'un graphique comparant les scores PEF décomposés des deux Farines qui seraient considérées]</mark>_&#x20;

