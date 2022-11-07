# 🤓 3 - Calcul de l'impact matière : Circular Footprint Formula (CFF)

{% hint style="info" %}
**Pourquoi une Circular Footprint Formula ?**

Prenons le cas d'un pull 1 en coton. Lors de sa fin de vie, ce pull 1 est recyclé en fil de coton recyclé. Ce fil de coton recyclé est utilisé pour un faire un tshirt 2.

Si l'on fait l'analyse de cycle de vie (ACV) du pull 1, il faut prendre en compte l'impact du recyclage du pull 1, c'est l'étape de fin de vie.

D'autre part si l'on fait l'ACV du tshirt 2, il faut prendre en compte la production de la matière utilisée, soit le recyclage du pull 1.

Mais en faisant ceci on compte 2 fois l'impact du recyclage du pull 1. Donc il existe un problème de double compte lorsque l'on utilise de la matière recyclé.

La circular footprint formula intervient pour régler ce problème de double compte. La CFF propose de répartir l'impact du recyclage entre la fin de vie du pull 1 et la production de matière du tshirt 2 (c'est le coefficient A entre 0 et 1 qui va faire varier la répartition de cet impact entre le producteur de matière recyclé (pull 1) ou l'utilisateur de matière recyclé (tshirt 2)).
{% endhint %}

En application de la méthodologie PEF, et plus particulièrement du projet de PEFCR Apparel & Footwear (A\&F), la CFF est prise en compte pour modéliser l'intégration de matériaux recyclés (ie. cette section) et [la fin de vie](../../etape-7-fin-de-vie.md#incineration-cff).

Pour les matières premières, la formule à considérer est :

![PEFCR A\&F - v1.2 - ligne 1056](<../../../../.gitbook/assets/image (1) (2).png>)

Ainsi dans le cas d'un vêtement comportant des matières recyclés, le calcul de l'impact matière est plus compliqué.&#x20;

Il faut prendre en compte 3 termes : M1, M2 et M3. \
Dans les faits M3 semble peu important pour les vêtements c'est pourquoi nous négligeons ce terme. [Plus d'informations sur cette page](circular-footprint-formula-cff-matiere-1.md).

Pour calculer l'impact d'un vêtement avec de la matière recyclé, il suffit donc de calculer M1 et M2. [Nous expliquons le calcul sur cette page](circular-footprint-formula-cff-matiere.md).
