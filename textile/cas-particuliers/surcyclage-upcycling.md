# Surcyclage / Upcycling

## Définition & Contexte

L'upcycling (surcyclage ou upcyclage) caractérise la transformation par le haut d'un objet textile d'une plus faible valeur (un vêtement usagé, des chutes de tissu, etc.). Cela correspond à revaloriser le textile afin de lui redonner vie (recyclage par le haut).&#x20;

Ce concept n'a rien de nouveau dans l'industrie et est notamment utilisé depuis longtemps par les pays en voie de développement qui récupèrent une part significative des déchets textile européens (cf. le correctif [Export Hors Europe](https://fabrique-numerique.gitbook.io/ecobalyse/textile/complements-hors-acv/export-hors-europe) à ce sujet). &#x20;

L'upcycling consiste donc à développer des vêtements autour de stocks de matières déjà existantes grâce à la créativité des designers. Cette pratique n'est donc pas adaptée aux grandes séries.&#x20;

Il n'existe pas encore de définition normée du surcyclage.&#x20;

<details>

<summary>Focus ADEME (Fonds réemploi-réutilisation et réparation de la filière TLC)</summary>

Extrait de l'étude préalable publiée en 2022

"Le terme « upcycling » (ou surcyclage en français) est de plus en plus utilisé dans la profession. Le mot désignait au départ l’exploitation des matériaux délaissés au cours de la chaîne de production, par opposition au « recyclage » qui porte sur les produits en fin de vie. Bien que la définition de l’upcycling soit encore à construire, l’upcycling englobe désormais la transformation directe des matériaux en nouveaux produits, ou la transformation de pièces conçues pour en augmenter l’attrait. Le « up », marquant l’idée de tirer les matériaux vers le haut. L’upcycling n’a pas de définition règlementaire. Cette activité est considérée exclue du périmètre des études réparation et réemploi-réutilisation."

</details>

## Modélisation Ecobalyse

L'utilisateur a la possibilité de supprimer tout ou partie des procédés mobilisés sur le cycle de vie du vêtement.

Dès lors, un vêtement upcyclé peut être modélisé dans Ecobalyse.

{% hint style="info" %}
Du fait des nombreuses possibilités de surcyclage,l'utilisateur doit s'assurer que les principales étapes du surcyclage sont bien reflétées dans la modélisation.

Par exemple, si la confection d'un vêtement surcyclé est plus complexe que la confection d'un même vêtement non-surcyclé, il est nécessaire d'adapter la complexité/durée de l'étape Confection.&#x20;
{% endhint %}

### Illustration

Pour un t-shirt 100% coton, l'upcyclage de ce dernier permet une baisse de l'impact environnemental global du vêtement de l'ordre de -57% avec les hypothèses suivantes : \
1\) Complexité en confection : passe de Faible (entre 5 et 15 minutes) à Elevée (entre 30 et 60 minutes),\
2\) Désactivation des étapes Matières, Filature, Tissage et Ennoblissement.

<figure><img src="../../.gitbook/assets/Impact (uPts) d&#x27;un t-shirt 100% coton (upcyclé ou non).png" alt=""><figcaption></figcaption></figure>
