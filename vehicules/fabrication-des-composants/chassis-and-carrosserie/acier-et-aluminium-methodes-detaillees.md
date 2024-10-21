---
description: >-
  Cette page décrit le processus de fabrication des deux métaux, les facteurs
  déterminants de l'impact environnemental dans leur chaine de valeur, et la
  méthode proposée dans Ecobalyse.
---

# 🔩 Acier et Aluminium - Méthodes détaillées

## Étapes de fabrication de l'acier

1. Production de l'acier brut\
   Production de fonte puis d'acier brut, à partir de minerai de fer et de coke (charbon transformé) dans un haut fourneau.\
   L'acier recyclé (ferraille) est intégré lors de la conversion de la fonte en acier.\
   L'acier est composé de fer et de carbone (maximum 2%)\
   Il est également possible de produite du fer par un autre procédé, encore minoritaire.\
   Ce procédé nécessite beaucoup d'énergie, essentiellement apportée par la coke
2.  Production d'un alliage

    Traitement en acierie, pour fabriquer différents alliages par l'ajout d'éléments (nickel, chrome).\
    L'acier inoxydable est un alliage comportant moins de 1,2 % de carbone et plus de 10,5 % de chrome.
3. Transformation en une pièce semi-finie, avec des procédés divers.\
   Ces transformation sont la forge, la lamination, la fonderie.\
   Ces procédés sont également énergivores, avec des taux de pertes qui peuvent être significatifs.

## Étapes de fabrication de l'aluminium

1. Production de l'aluminium primaire\
   Production à partir d'Alumine (ou oxyde d'Aluminium) par électrolyse (procédé Hall-Héroult). \
   Ce procédé nécessite beaucoup d'électricité, de l'ordre de 14kWh/kg. Sont impact environnemental dépend donc du site de fabrication et de l'efficacité du procédé
2.  Production d'un alliage d'aluminium, répartis en deux grande familles :

    1. Alliage d'aluminium pour corroyage (wrought alloy en anglais), destinés à être transformés par des techniques de laminage, extrusion, filage, matriçage, forge, etc. La série 6000 est très utilisée en industrie pour fabriquer des profilés.
    2. Alliage d'aluminium pour fonderie (cast alloy en anglais), utilisé pour fabriquer des pièces à partir d'un moule, pour l'aéronautique et l'automobile par exemple

    La production des alliages se différencie par l'ajout de matériaux spécifiques en faible quantité (cuivre, magnésium, silicium, zinc), et par des taux d'intégration d'aluminium recyclé différents.
3. Transformation en une pièce semi-finie, avec des procédés divers.\
   Ces procédés sont peu énergivores en comparaison de l'électrolyse. Les taux de pertes peuvent être significatifs.

## Facteurs déterminants de l'impact environnemental

### Acier

Les facteurs les plus importants sont le sites de fabrication de l'acier brut, le taux d'intégration de métal recyclé et le procédé de transformation

Le procédé de fabrication de l'acier a également une influence notable, bien que les procédés à faible impact environnemental sont encore rares.

### Aluminium

Les deux facteurs les plus importants sont le sites de fabrication de l'aluminium primaire, ainsi que le taux d'intégration de métal recyclé.

Pour l'acier, le procédé de fabrication de l'acier a également une influence notable.

Le taux de perte et le procédé de transformation final sont également significatifs.

## Modélisation retenue dans Ecobalyse

Compte-tenu de la difficulté à connaitre le pays de fabrication de l'aluminium primaire ou de l'acier brut et le taux de recyclage, Ecobalyse ne propose pas de différencier les deux métaux sur ces critères.&#x20;

A court terme, les procédés suivants sont proposés dans Ecobalyse. Les trois premiers sont construits avec un procédé de transformation moyen proposé par Ecoinvent :

* Aluminium moyen
* Acier (moins de 5% d'éléments d'alliage)
* Acier inoxydable (68.6% Fe, 9.3% Ni, 19.0% Cr, 0.08% C)
* Aluminium extrudé (profilé)
* Aluminium laminé (tôle)

A moyen terme, il pourrait être proposé :

* ou bien de sélectionner le procédé de transformation et les pertes associées, en priorité pour l'acier.
* ou bien de proposer des procédés différenciés en fonction du pays d'achat du métal transformé, prenant en compte les sources approvisionnement en métal brut pour ce pays.

### Modélisation des pertes dans Ecoinvent

Dans Ecoinvent, les pertes lors des étapes de transformation finale de l'aluminium ou de l'acier sont intégrées dans le procédé de transformation. Par exemple, le procédé "metal working, average for aluminium product manufacturing" inclut 0.23kg d'aluminium, correspondant aux pertes supposées dans ce processus de transformation.

Les schémas ci-dessous illustre cette modélisation :&#x20;

<figure><img src="../../../../../.gitbook/assets/image (327).png" alt=""><figcaption><p>Procédés ecoinvent mis en œuvre pour modéliser 1kg d'aluminium </p></figcaption></figure>
