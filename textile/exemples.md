---
description: Page introduisant la notion d'exemples proposés au début du simulateur
---

# Exemples

Le premier champ proposé sur le simulateur Ecobalyse textile propose de sélectionner un exemple.

<figure><img src="../.gitbook/assets/image (295).png" alt=""><figcaption><p>Capture d'écran (01/04/2024)</p></figcaption></figure>

Les différents exemples proposés permettent d'initier la modélisation d'un vêtement à partir d'un exemple similaire (un jean pour un jean, un Tshirt pour un Tshirt...). **Ce choix initial permet de faciliter les modélisation mais ne remplace ensuite pas le paramétrage de chacun des champs proposés**. La page de documentation "[Paramétrage](https://app.gitbook.com/o/-MMQU-ngAOgQAqCm4mf3/s/-MexpTrvmqKNzuVtxdad/~/changes/887/textile/parametrage)" précise les paramètres qui peuvent ou doivent être renseignés suivant l'utilisation qui est faite de l'outil.

Deux types d'exemples sont proposés en première approche :

* des exemples paramétrés de façon "**majorante par défaut**"
* des exemples **illustrant la diversité des cas qui peuvent être attendus**, en premier lieu pour des pulls et des Tshirts (début avril 2024)

## Exemples paramétrés de façon "majorante par défaut"

Ces exemples "par défaut", sont définis, dans leur dénomination même, à travers les seuls paramètres qui les caractérisent :

<figure><img src="../.gitbook/assets/image (296).png" alt=""><figcaption></figcaption></figure>

* Catégorie de produit -> Le choix de ce paramètre permet de fixer, par défaut, la valeur de nombreux autres paramètres proposés dans la suite du calculateur. L'ensemble de ces valeurs par défaut sont accessibles dans la [rubrique "Produits" de l'explorateur](https://ecobalyse-v2.osc-fr1.scalingo.io/#/explore/textile/products).

{% hint style="info" %}
Exemple de la catégorie de produit "Jean" : Il est considéré que l'étoffe est tissée, que la teinture est faite sur fil, que la confection prend 30', qu'un délavage est appliqué, que le produit est porté en moyenne 70 jours (si le coefficient de durabilité est de 1), qu'un cycle d'entretien (lavage) est appliqué toutes les 3 utlisations...
{% endhint %}

{% hint style="warning" %}
Toute modélisation doit impérativement commencer par le choix d'un exemple de la même catégorie de produit (un jean pour un jean, un Tshirt pour un Tshirt...). Si vous ne trouvez pas de catégorie correspondant au vêtement dont vous souhaitez modéliser le coût environnemental, merci de le signaler sur le [forum Ecobalyse](https://chat.ecobalyse.fr/) pour que la création d'une nouvelle catégorie puisse être envisagée.
{% endhint %}

* Matières -> Le choix de matière est un paramètre central. Il est donc précisé, même pour un exemple paramétré de façon "majorante par défaut". Ce paramètre doit donc impérativement être modifié si le produit modélisé n'est pas composé des mêmes matières que l'exemple paramétré de façon "majorante par défaut".



L'ensemble des autres paramètres exposés dans le calculateur Ecobalyse sont, par défaut, fixés sur une valeur majorante. C'est en particulier le cas pour :

* Les paramètres permettant d'établir le coefficient de durabilité (cf. paramétrages proposés pour le cas "mode ultra fast fashion" dans le [tableau ci-après](exemples.md#parametres-mobilises-dans-les-exemples-pour-etablir-le-coefficient-de-durabilite))
* L'origine géographique des différentes étapes de transformation (filature, tissage/tricotage, ennoblissement, confection) qui est fixée à "Inconnu (par défaut)".
* La part de transport aérien depuis l'atelier qui, par défaut, est fixée à 100%

De fait, les exemples "par défaut" vont généralement présenter un coût environnemental majorant par rapport au coût environnemental qui peut être modéliser en mobilisant des paramètres plus précis. Deux exception toutefois :

* Le délavage (étape de confection) qui n'est pas sélectionné par défaut, hormis pour le jean
* L'impression (étape d'ennoblissement) qui n'est pas sélectionné par défaut

{% hint style="info" %}
En partant d'un exemple paramétré de façon "majorante par défaut", toute modification du paramétrage (hormi les matières et la masse évoqués précédemment) conduit à baisser le coût environnemental modélisé.
{% endhint %}

## Exemples **illustrant la diversité des cas qui peuvent être attendus**

Lors de la mise en ligne d'une première version de projet de méthodologie réglementaire (avril 2024), sont proposés :

* 6 exemples de Tshirts
* 7 exemples de pulls

{% hint style="danger" %}
Ces exemples illustrent le fonctionnement de la méthode et de l'outil de calcul. Ils ne doivent néanmoins pas être directement appliqués pour des exemples de produits réels.
{% endhint %}

Ces exemples s'appuient sur les données présentées, en 2022, à l'occasion des expérimentations conduites en application de la loi Climat et résilience, en particulier par En mode climat.

Par rapport aux exemples paramétrés de façon "majorante par défaut" (cf. [supra](exemples.md#exemples-parametres-de-facon-majorante-par-defaut)), ces exemples sont paramétrés de façon plus précise avec notamment :

* des choix de matières plus complexes correspondant à des produits considérés en 2022 (exemple : 75% de coton primaire et 25% de coton recyclé pour le _Tshirt coton (150g) - Chine - Mode "fast fashion" ;_
* des origines géographiques plus précises proposées pour chaque étape de transformation (attention : seule une information géographique est présentée dans le nom de l'exemple, pour accéder à l'ensemble des hypothèses, il faut regarder chaque étape de la simulation) ;
* une parte de transport par avion depuis l'atelier de confection fixé à 100% pour les exemples relevant d'une mode "fast fashion" ou "ultra fast fashion" et à 33% pour les autres (lorsque le payse de confection est hors Europe ou Turquie - cf. [documentation transport](https://fabrique-numerique.gitbook.io/ecobalyse/textile/cycle-de-vie-des-produits-textiles/transport)) ;
* des paramètres spécifiques pour le calcul du coefficient de durabilité (cf. ci-après).

## Paramètres mobilisés dans les exemples pour établir le coefficient de durabilité

{% hint style="danger" %}
Les paramètres exposés ci-après ont une vocation purement illustrative et pédagogique. Ils ne s'appliquent pas par défaut à chaque vêtement qui relèverait d'un de type de "mode" introduit mais doivent bien être reprécisés pour chaque modélisation ou, à défaut, être fixés de façon majorante.
{% endhint %}

Les exemples de paramètres suivants sont considérés :

| PARAMETRE                  | Mode "éthique" | Mode "traditionnelle"                    | Mode "fast fashion"                            | Mode "ultra fast fashion"                     |
| -------------------------- | -------------- | ---------------------------------------- | ---------------------------------------------- | --------------------------------------------- |
| Nombre de références       | 200            | 2.500                                    | 12.000                                         | 100.00                                        |
| Durée de commercialisation | 300 jours      | 115 jours                                | 115 jours                                      | 65 jours                                      |
| Entreprise                 | PME / TPE      | Grande entreprise proposant des services | Grande entreprise ne proposant pas de services | Grande entreprise ne proposant pas de service |
| Traçabilité affichée       | Oui            | Oui / Non                                | Non                                            | Non                                           |
| Prix neuf (Tshirt)         | 30 €           | 30 €                                     | 20 €                                           | 10 €                                          |
| Prix neuf (Pull)           | 95 €           | 70 €                                     | 30 €                                           | 15 €                                          |
