# Stocks dormants / Deadstock

## Définition & Contexte

Il n'existe pas encore de définition harmonisée concernant les stocks dormants (deadstock).

Au niveau européen, la dernière version du PEFCR Apparel & Footwear (v. 1.3) reprend la définition proposée par le décret français n°2020-1609 1724 : "produits qui n'ont pas pu être vendus dans les circuits traditionnels de vente, des soldes ou des ventes privées.". Il a été précisé que les "produits qui n'ont pas pu être vendus" sont ceux qui ont été dépréciés du bilan de l'entreprise où les stocks dormants depuis plus de trois ans.&#x20;

Cependant, cette définition est trop restrictive car elle n'inclut pas les stocks dormants générés lors des étapes de fabrication d'un vêtement.&#x20;

Différents paramètres expliquent la génération de stocks dormants :&#x20;

<figure><img src="../../.gitbook/assets/image (1).png" alt=""><figcaption><p>Source : Etude "A la chasse aux tissus dormants" (La Textilerie)</p></figcaption></figure>

<details>

<summary>Aller plus loin</summary>

Une revue bibliographique et différents ateliers ont été menés en 2023 afin d'estimer la matérialité des stocks dormants. Voici quelques sources/données (non exhaustif) :&#x20;

Stocks dormant de vêtements (produit fini) :&#x20;

* 15% (source : [Mc Kinsey](#user-content-fn-1)[^1])
* 16% (source : Cycleco[^2])
* 12% (source : [The Good Goods](https://www.thegoodgoods.fr/media/economie/circularite-services/tech-uptrade-marketplace-revalorise-stocks-dormants/))
* 33% (source : [EcoTextile](https://www.ecotextile.com/2016042122078/fashion-retail-news/one-third-of-all-clothing-never-sold.html) / citation[^3])

Stocks dormans de produits semi-finis :&#x20;

* 5% de marge moyenne constatée au bénéficie du fournisseur lors de commandes de la part du donneur d'ordre (marque/confectionneur) (source : [La Textilerie](#user-content-fn-4)[^4])
* 10% à 20% sur le marché dannois (source : [Roadmap pour une économie circulaire](#user-content-fn-5)[^5] - Danemark)&#x20;

</details>

## Modélisation Ecobalyse

Ecobalyse applique un taux moyen de stocks dormants de 15%. \
Ce chiffre comprend les stocks dormants de vêtements (produits finis) et ceux de produits semi-finis (ex : tissus, fil).&#x20;

La modélisation des stocks dormants s'effectue via un multiplicateur. Concrètement, la quantité de matières à transformer tout au long des étapes de transformation est multipliée par 1,15.&#x20;

{% hint style="info" %}
L'affichage des deadstock s'effectue au sein de l'étape Confection. A date, l'utilisateur a la possibilité de modifier le taux de stocks dormants.
{% endhint %}

{% hint style="danger" %}
Les stocks dormants sont différents des taux de pertes en confection.&#x20;
{% endhint %}

### **Illustration**

L'impact d'un t-shirt 100% coton augmente de +11% suite à l'introduction des deadstock.

<figure><img src="../../.gitbook/assets/Impact (uPts) d&#x27;un t-shirt 100% coton par étape (avec ou sans Deadstock) (1).png" alt=""><figcaption></figcaption></figure>

[^1]: "Fashion on Climate" \_ 2020&#x20;

[^2]: "Evaluation de l'impact carbone du secteur Textile en France" \_ 2021

[^3]: "In 2016, for instance, Ecotextile News reported that only a third of all imported clothing in the EU is sold at full retail price, a third is sold at a discounted price and a third is not sold at all, although these figures remain unverified."

[^4]: Etude "A la chasse aux tissus formants" &#x20;



[^5]: "Circular economy with a focus on plastics and textiles A 2030 & 2050 Roadmap"
