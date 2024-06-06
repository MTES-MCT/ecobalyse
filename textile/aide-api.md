---
description: >-
  Prenons l'exemple d'une simulation de "Jean coton (450g) - Majorant par
  défaut". Au 2024-06-06 on a les résultats suivants :
---

# Aide API



<figure><img src="../.gitbook/assets/image (100).png" alt=""><figcaption><p>UI "Jean coton (450g) - Majorant par défaut" au 2024-06-06</p></figcaption></figure>



### Comment retrouver ce résultat (7498 Pts) dans l'API ?

<figure><img src="../.gitbook/assets/image (102).png" alt="" width="363"><figcaption><p>API "Jean coton (450g) - Majorant par défaut" au 2024-06-06</p></figcaption></figure>

On retrouve bien ce chiffre dans la réponse de l'API dans /impacts/ecs (ecs = ecoscore)

### Comment le retrouver à partir des sous-impacts ?

1. Il faut faire la somme des sous-impacts en les normalisant/pondérant. On arrive à 7114 Pts.

<figure><img src="../.gitbook/assets/image (103).png" alt="" width="375"><figcaption><p>Calcul de l'écoscore "ecs" à partir des sous-impacts et des compléments</p></figcaption></figure>

2. Il faut aussi ajouter les compléments (ici microfibers et outOfEuropeEOL) que l'on retrouve dans l'API sous complementsImpacts. On a comme valeur 194 Pts pour le compléments microfibres et 190 Pts pour le compléments fin de vie hors europe.

![](<../.gitbook/assets/image (104).png>)

En additionnant les compléments aux sous-impacts on a donc : 7114 + 194 + 190 = 7498 Pts. On retrouve bien le résultat attendu :)

{% hint style="warning" %}
Remarque : on peut voir que la valeur du compléments microfibre affiché dans l'UI est de 113 Pts, ce qui est différent de ce qui est affiché dans l'API (194 Pts).

<img src="../.gitbook/assets/image (99).png" alt="" data-size="original">



En effet dans l'UI les valeurs sont affichés AVANT la prise en compte du coefficient de durabilité [durabilite.md](durabilite.md "mention"). Ainsi pour obtenir les valeurs finales il faut diviser le score par le coefficient de durabilité. \
Pour le complément microfibres par exemple 113/0.58 \~ 195. On retrouve bien l'ordre de grandeur de 194 Pts affiché dans l'API.
{% endhint %}
