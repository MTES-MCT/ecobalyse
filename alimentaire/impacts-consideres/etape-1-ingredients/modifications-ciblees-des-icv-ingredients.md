# 🛠️ Modifications ciblées des ICV ingrédients

Au fil de nos analyses et de l’usage d’Ecobalyse, nous avons identifié certaines améliorations/corrections à apporter aux ICV Agribalyse. Ces améliorations sont faites en continu, en restant sur des modifications simples à mettre en œuvre. Les points identifiés seront intégrés dans les futurs versions d'Agribalyse avec des modélisations plus élaborées parfois.    &#x20;

## Vergers avec piquets en bois (ex : abricots, cerises, etc.) – Suppression de la créosote

Nous avons observé la part prépondérante de l'écotoxicité pour ces produits agricoles dans les données Agribalyse. Ceci concerne les vergers palissés à la fois en production conventionnelle et bio. Il apparaît que cette écotoxicité est liée au traitement des piquets en bois à base de créosote selon les données ecoinvent. Des émissions importantes de benzo(a)pyrène et de benzène sont comptabilisés lors de la phase de stockage des piquets. Ces émissions « dominent » tous les autres impactent, dont ceux liés aux traitements phytosanitaires dans les parcelles.

Après investigation, nous n'avons pas pu confirmer le traitement généralisé à la créosote pour les poteaux utilisés dans les vergers. Par ailleurs nous avons également des doutes sur la réalité des émissions dans les usines de fabrication lors de l'étape de stockage. Dans la modélisation Ecoinvent ces émissions seraient non traitées et massives ce qui est étonnant pour un site industriel et un produit avéré comme étant très toxique. Ces données sont anciennes et peuvent aussi correspondre à des pratiques qui n'ont plus lieu de nos jours.

Au regard de ces éléments il nous semble préférable de retirer l’usage de la créosote et les émissions de benzo(a)pyrene et de benzene associées ; afin de permettre une meilleure comparaison entre les différents fruits et légumes. Plus largement, un travail sur les différents types de poteaux et les traitements du bois (autoclave, chimique, etc.) reste à approfondir. Ce travail sera mené par le GIS Revalim et intégré dans les futures versions d’agribalyse.

## Acétamipride     &#x20;

L’ acétamipride étant interdit en France depuis 2018, nous avons veillé à ce qu'il soit bien retiré de tous les ICV de produits agricoles. La mise à jour progressive des itinéraires techniques via les nouvelles données Agribalyse évitera la présence des molécules interdites, que l'on peut parfois retrouver dans des inventaires un peu anciens.

## ICV bio construits par extrapolation     &#x20;

Pour les produits bio, nous priorisons l’usage des données issues d’Agribalyse. Cependant pour un nombre important de productions nous n'avons pas d’ICV bio disponibles en 2025. Dans ce cas nous utilisons une méthode d'extrapolation développée par Ginko21 en 2023 sur demande de l’ADEME. Une méthode et un outil ont été développés permettant de générer des ICV bio à partir d’ICV conventionnels ; en se concentrant sur les principales différences : ajustement des rendements, de l'usage des phytosanitaires, des engrais et de l'irrigation. Ce travail a bénéficié d’une revue critique, avec des propositions d’améliorations et une conclusion globalement positive.

Pour l'extrapolation, il était considéré dans le travail initial un usage systématique, et à dose "maximale" d'azadiractine dans les systèmes bio. L'azadiractine est un insecticide "naturel", puissant et peu sélectif. Son profil en terme d'ecotoxicité est donc élevé. Si l'usage de cette molécule est avéré, nous manquons de données sur la fréquence et le type d'usage selon les productions. Nous avons donc décidé de retirer cette molécule, en attendant que le GIS Revalim puisse préciser les pratiques agronomiques réelles. Nous avons bien conservé le spinosad, comme proposé dans la méthode d'extrapolation de Ginko21 afin de refléter le besoin de "protection des cultures" dans tous types de systèmes.&#x20;

L’extrapolation avait été générée initialement sur la base des données Agribalyse 3.1. Pour assurer la cohérence des données, nous avons régénérés les ICV bio  à partir d’Agribalyse 3.2 lors de la mise à jour d’Ecobalyse. &#x20;

&#x20;Un grand nombre d'ICV bio seront mis à disposition par Agribalyse dans les futures versions, conduisant à réduire l'usage de l'extrapolation.&#x20;

Sources :

[https://librairie.ademe.fr/agriculture-alimentation-foret-bioeconomie/8345-10127-construction-d-icv-des-productions-agricoles-biologiques-sur-la-base-d-icv-conventionnels.html](https://librairie.ademe.fr/agriculture-alimentation-foret-bioeconomie/8345-10127-construction-d-icv-des-productions-agricoles-biologiques-sur-la-base-d-icv-conventionnels.html)

[https://librairie.ademe.fr/agriculture-alimentation-foret-bioeconomie/8346-10128-icv-pour-la-production-agricole-biologique-evaluation-de-la-methode-de-construction.html#](https://librairie.ademe.fr/agriculture-alimentation-foret-bioeconomie/8346-10128-icv-pour-la-production-agricole-biologique-evaluation-de-la-methode-de-construction.html)\
\


## &#x20;
