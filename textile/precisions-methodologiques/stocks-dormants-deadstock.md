# 👘 Stocks dormants&#x20;

## Définition & Contexte

[Le Règlement Ecoconception ou (« Ecodesign for sustainable products’ regulation », ESPR)](https://eur-lex.europa.eu/legal-content/FR/TXT/HTML/?uri=OJ:L_202401781), publié le 28 juin 2024,  a introduit pour la première fois en droit de l’Union européenne la notion d’invendus.&#x20;

Selon le règlement, les produits de consommation invendus correspondent aux produits qui n’ont « jamais été vendus ou utilisés » . Ils sont ensuite définis à l’article 2  : «produit de consommation invendu»: tout produit de consommation qui n’a pas été vendu, y compris les surplus de stock, les stocks en excès et les stocks dormants et les produits retournés par un consommateur sur la base de son droit de rétractation conformément à l’article 9 de la directive 2011/83/UE, ou le cas échéant pendant toute période de rétractation de plus longue durée prévue par le professionnel ».

Différents paramètres expliquent la génération de stocks dormants :&#x20;

<figure><img src="../../.gitbook/assets/image (15) (1).png" alt=""><figcaption><p>Source : Etude "A la chasse aux tissus dormants" (La Textilerie)</p></figcaption></figure>

<details>

<summary>Aller plus loin</summary>

Une revue bibliographique et différents ateliers ont été menés en 2023 afin d'estimer la matérialité des stocks dormants. Voici quelques sources/données (non exhaustif) :&#x20;

Stocks dormant de vêtements (produit fini) :&#x20;

* 15% (source : [Mc Kinsey](#user-content-fn-1)[^1])
* 16% (source : Cycleco[^2])
* 12% (source : [The Good Goods](https://www.thegoodgoods.fr/media/economie/circularite-services/tech-uptrade-marketplace-revalorise-stocks-dormants/))
* 33% (source : [EcoTextile](https://www.ecotextile.com/2016042122078/fashion-retail-news/one-third-of-all-clothing-never-sold.html) / citation[^3])

Stocks dormants de produits semi-finis :&#x20;

* 5% de marge moyenne constatée au bénéficie du fournisseur lors de commandes de la part du donneur d'ordre (marque/confectionneur) (source : [La Textilerie](#user-content-fn-4)[^4])
* 10% à 20% sur le marché danois (source : [Roadmap pour une économie circulaire](#user-content-fn-5)[^5] - Danemark)&#x20;

</details>

## Modélisation Ecobalyse

La méthode de calcul du coût environnemental applique un taux moyen de stocks dormants de 15%. \
Ce chiffre comprend les stocks dormants de vêtements (produits finis) et ceux de produits semi-finis (ex : tissus, fil).&#x20;

La modélisation des stocks dormants s'effectue via un multiplicateur. Concrètement, la quantité de matières à transformer tout au long des étapes de transformation est multipliée par 1,15.&#x20;

{% hint style="info" %}
La prise en compte des stocks dormants s'effectue au sein de l'étape Confection. Ainsi, cela revient à appliquer un second taux de perte à cette étape, avec donc 15% d'étoffe supplémentaire nécessaire avant l'étape de confection. L'application de cette modélisation conduit donc, par transitivité, à augmenter la quantité nécessaire d'étoffe, de fil et de matière nécessaire en amont de la confection.\
Pour rendre compte de la quantité d'étoffe nécessaire en entrée de la phase de confection, il faut donc à la fois considérer les stocks dormants (objet de la présente page), mais aussi les pertes strictement liées à l'étape de confection (cf. [page dédiée de la documentation](../../communaute.md)).
{% endhint %}

{% hint style="danger" %}
Les stocks dormants sont différents des taux de pertes en confection.&#x20;
{% endhint %}

### **Illustration**

L'impact d'un t-shirt 100% coton augmente de +11% suite à l'introduction des stocks dormants.

<figure><img src="../../.gitbook/assets/Impact (uPts) d&#x27;un t-shirt 100% coton par étape (avec ou sans Deadstock) (1).png" alt=""><figcaption></figcaption></figure>

[^1]: "Fashion on Climate" \_ 2020&#x20;

[^2]: "Evaluation de l'impact carbone du secteur Textile en France" \_ 2021

[^3]: "In 2016, for instance, Ecotextile News reported that only a third of all imported clothing in the EU is sold at full retail price, a third is sold at a discounted price and a third is not sold at all, although these figures remain unverified."

[^4]: Etude "A la chasse aux tissus formants" &#x20;



[^5]: "Circular economy with a focus on plastics and textiles A 2030 & 2050 Roadmap"
