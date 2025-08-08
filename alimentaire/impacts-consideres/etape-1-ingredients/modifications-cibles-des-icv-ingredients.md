# 🛠️ Modifications ciblés des ICV ingrédients

Au fil de nos analyses et de l’usage d’Ecobalyse, nous avons identifié certaines améliorations/corrections à apporter aux ICV agribalyse. Ces améliorations sont faites en continue, En restant sur des modifications simple à mettre en œuvre. Les points identifiés seront intégré dans les futurs versions agribalyses avec des modélisations plus élaborées parfois.    &#x20;

## Vergers avec piquet en bois (ex : abricots, cerises, etc.) – Suppression de la créosote

Nous avons observé la part prépondérante de l'écotoxicité pour ces produits agricoles dans les données agribalyse. Ceci concerne les vergers palissés à la fois en production conventionnelle et bio. Il apparaît que cette écotoxicité est liée au traitement des piquets en bois à base de créosote selon les données ecoinvent. Des émissions importantes de benzo(a)pyrene et de benzene sont comptabilisés lors de la phase de stockage des piquets. Ces émissions « dominent » tous les autres impactent, dont ceux liés aux traitements phytosanitaires dans les parcelles.

Apres investigation, nous n'avons pas pu confirmer le traitement généralisé la créosote pour les poteaux utilisés dans les vergers. Par ailleurs que nous avons également tes doutes sur la réalité des émissions dans les usines de fabrication lors de l'étape de stockage. Dans la modélisation écoinvent ces émissions seraient non traitées et massives ce qui est étonnant pour un site industriel et un produit avéré comme étant très toxique. Ces données sont anciennes et peuvent aussi correspondre à des pratiques qui n'ont plus lieu de nos jours.

Au regard de ces éléments il nous semble préférable de retirer l’usage de la créosote et les émissions de benzo(a)pyrene et de benzene associées ; afin de permettre une meilleure comparaison les différents fruits et légumes. Plus largement un travail sur les différents types de poteaux et les traitements du bois (autoclave, chimique etc.) reste à approfondir. Ce travail sera mené par le GIS revalim et intégré dans les futures versions d’agribalyse.

## Acetamipride     &#x20;

L’ acetamipride étant interdit en France depuis 2018, nous avons veillé à ce qu'il soit bien retiré de tous les ICV de produits agricoles. La mise à jour progressive des itinéraires techniques via les nouvelles données agribalyse évitera la présence des molécules interdites ; que l'on peut parfois retrouver dans des inventaires un peu anciens.

## ICV bio construits par extrapolation     &#x20;

Pour les produits bio, nous priorisons l’usage des données issus d’agribalyse. Cependant pour un nombre important de productions nous n'avons pas d’ICV bio disponibles en 2025. Dans ce cas nous utilisons une méthode d'extrapolation développée par Ginko21 en 2023 sur demande de l’ADEME. Une méthode et un outil ont été développés permettant de générer d’ICV bio à partir d’ICV conventionnels ; en se concentrant sur les principales différences : ajustement des rendements, de l'usage des phytosanitaires, des engrais et de l'irrigation. Ce travail a bénéficié d’une revue critique, avec des propositions d’améliorations et une conclusion globalement positive.

L’extrapolation avait été généré initialement sur la base des données Agribalyse 3.1. Pour assurer la cohérence des données, nous avons re-générés les ICV bio  à partir d’Agribalyse 3.2 lors de la mise à jour d’ecobalyse. &#x20;

&#x20;Un grand nombre d'ICV bio seront mis à disposition par Agribalyse dans les futures versions, conduisant à réduire l'usage de l'extrapolation.&#x20;

Sources :

[https://librairie.ademe.fr/agriculture-alimentation-foret-bioeconomie/8345-10127-construction-d-icv-des-productions-agricoles-biologiques-sur-la-base-d-icv-conventionnels.html](https://librairie.ademe.fr/agriculture-alimentation-foret-bioeconomie/8345-10127-construction-d-icv-des-productions-agricoles-biologiques-sur-la-base-d-icv-conventionnels.html)

[https://librairie.ademe.fr/agriculture-alimentation-foret-bioeconomie/8346-10128-icv-pour-la-production-agricole-biologique-evaluation-de-la-methode-de-construction.html#](https://librairie.ademe.fr/agriculture-alimentation-foret-bioeconomie/8346-10128-icv-pour-la-production-agricole-biologique-evaluation-de-la-methode-de-construction.html)
