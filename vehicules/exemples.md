---
description: Page introduisant la notion d'exemples proposés au début du simulateur
hidden: true
---

# Draft - Exemples

Le premier champ proposé sur le simulateur Ecobalyse propose de sélectionner un exemple.

<figure><img src="../.gitbook/assets/image (295).png" alt=""><figcaption><p>Capture d'écran (01/04/2024)</p></figcaption></figure>

Les différents exemples proposés permettent d'initier la modélisation d'un véhicule à partir d'un exemple similaire. **Ce choix initial permet de faciliter les modélisation mais ne remplace ensuite pas le paramétrage de chacun des champs proposés**. La page de documentation "[Paramétrage](https://app.gitbook.com/o/-MMQU-ngAOgQAqCm4mf3/s/-MexpTrvmqKNzuVtxdad/~/changes/887/textile/parametrage)" précise les paramètres qui peuvent ou doivent être renseignés suivant l'utilisation qui est faite de l'outil.

Deux types d'exemples sont proposés en première approche :

* des exemples paramétrés de façon "**majorante par défaut**"
* des exemples **illustrant la diversité des cas qui peuvent être attendus**

## Exemples paramétrés de façon "majorante par défaut"

Ces exemples "par défaut", sont définis par la catégorie de véhicule

Le choix de ce paramètre permet de fixer, par défaut, la valeur de nombreux autres paramètres proposés dans la suite du calculateur. L'ensemble de ces valeurs par défaut sont accessibles dans la [rubrique "Produits" de l'explorateur](https://ecobalyse-v2.osc-fr1.scalingo.io/#/explore/textile/products).

{% hint style="warning" %}
Toute modélisation doit impérativement commencer par le choix d'un exemple de la même catégorie de véhicule.
{% endhint %}

L'ensemble des autres paramètres exposés dans le calculateur Ecobalyse sont, par défaut, fixés sur une valeur majorante. C'est en particulier le cas pour :

* Les paramètres permettant d'établir le coefficient de durabilité
* Le poids et la composition du véhicule
* L'origine géographique des composants

De fait, les exemples "par défaut" vont généralement présenter un coût environnemental majorant par rapport au coût environnemental qui peut être modéliser en mobilisant des paramètres plus précis.&#x20;

{% hint style="info" %}
En partant d'un exemple paramétré de façon "majorante par défaut", toute modification du paramétrage (hormis les matières et la masse évoqués précédemment) conduit à baisser le coût environnemental modélisé.
{% endhint %}

## Exemples **représentatifs de la catégorie**

{% hint style="danger" %}
Ces exemples illustrent le fonctionnement de la méthode et de l'outil de calcul. Ils ne doivent néanmoins pas être directement appliqués pour des exemples de produits réels.
{% endhint %}

Ces exemples s'appuient sur les données recueillies auprès de constructeurs entre Octobre 2024 et Décembre 2024.

Par rapport aux exemples paramétrés de façon "majorante par défaut" (cf. [supra](exemples.md#exemples-parametres-de-facon-majorante-par-defaut)), ces exemples sont paramétrés de façon plus précise avec notamment :

* des choix de matières plus complexes
* des origines géographiques plus précises pour l'assemblage du véhicule et/ou l'origine des composants
* des paramètres spécifiques pour le calcul du coefficient de durabilité (cf. ci-après).

## Paramètres mobilisés dans les exemples&#x20;

{% hint style="danger" %}
Les paramètres exposés ci-après ont une vocation purement illustrative et pédagogique. Ils ne s'appliquent pas par défaut à chaque véhicule qui relèverait d'un de type de conception mais doivent bien être reprécisés pour chaque modélisation ou, à défaut, être fixés de façon majorante.
{% endhint %}

Les exemples de paramètres suivants sont considérés :&#x20;

<figure><img src="../.gitbook/assets/image (331).png" alt=""><figcaption><p>CC : Châssis Carrosserie, quantités exprimées en kg, sauf la capacité des batteries, quantités pour les jantes et pneumatiques exprimées par roue.</p></figcaption></figure>

Pour la catégorie "Autre", les paramètres correspondent aux données du modèle GREET pour un véhicule de 1.6t.

