---
description: >-
  Cette partie traite des opérations "au champ" (fertilisation, labour etc.) et
  s'arrête à la sortie de la ferme. Elle couvre les productions conventionnelles
  et sous label.
---

# 🍒 Ingrédients agricoles - inventaires mobilisés (impacts ACV)

Les impacts de la production des ingrédients agricoles sont issus de la base Agribalyse pour les productions françaises et des bases Ecoinvent et WFLDB pour les produits importés. Malgré la richesse de ces bases, elles sont loin de couvrir l’ensemble des pays de productions et des modes de production. Aussi une logique d'approximation par l'utilisation de proxy doit être mise en œuvre.

S’il est bien sûr souhaitable d’enrichir les bases de données à l’avenir, notamment avec les données développées dans le cadre du projet européen FOODTURE, il est déjà possible de travailler de manière satisfaisante dans la majorité des situations.&#x20;

Les ingrédients sont définis selon la logique suivante, permettant à l’utilisateur de faire un choix clair :

\-          Production FR

\-          Production UE

\-          Production hors UE

\-          Production origine inconnue

\-          Production bio&#x20;

L'association des ingrédients et des inventaires de cycle de vie (ICV) pour chaque variante a fait l'objet d'un travail a) méthodologique, de définition des règles d'association b) d'automatisation des associations ingrédient-ICV via un outil Python.

### <mark style="color:green;">**Pour les productions françaises**</mark>&#x20;

De manière générale, l’inventaire Agribalyse « national average » a été privilégié, reflétant les conditions de productions standards.

_Ex : "Pomme FR" fait appel à l'ICV "Apple, conventional, national average, at orchard (FR)" issu d'Agribalyse_&#x20;

En pratique, l'algorithme est construit sur une fonction de pertinence et une hiérarchisation des sources.

**Priorité 1 : Identifier l'inventaire de production FR en amont du mix de consommation d'un ingrédient donné**.&#x20;

La source est l'[annexe 1 d'Agribalyse](https://entrepot.recherche.data.gouv.fr/file.xhtml?persistentId=doi:10.57745/MNNUAN) sur les mix de consommation : ce document permet de récupérer les éventuels proxies ingrédients. Dans l'exemple ci-dessous, on associe l'ingrédient "Figue" au mix de consommation "Fig, consumption mix {FR} U", qui renvoie à l'inventaire {FR} "Peach conventional, national average, at orchard {FR} U".

<figure><img src="../../../.gitbook/assets/Capture d&#x27;écran 2026-01-30 143850.png" alt=""><figcaption></figcaption></figure>

En cas d'échec,

**Priorité 2 : Identifier l'inventaire le plus pertinent parmi des inventaires candidats d'Agribalyse**

Pour un ingrédient donné, on pré-sélectionne les inventaires candidats contenant le nom de l'ingrédient.  Pour chaque inventaire candidat, un score de pertinence (SP) est calculé. Il dépend de :&#x20;

* **la correspondance sémantique** entre le nom de l'ingrédient (ex: "Apple") et le nom de l'inventaire (ex: "_Apple, conventional, national average, at orchard (FR)")._ Cet élément pénalise les inventaires au nom long, qui correspondent généralement à des ingrédients transformés (ex: "_Apple crumble, processed in FR | Ambient (long) | Pack proxy | No preparation | at consumer {FR} \[Ciqual code: 23493] U_").
* **la distance D du pays de production de l'inventaire à la France** (géocentre à géocentre). Elle est caractérisée selon 4 catégories : <mark style="color:purple;">**a) D = 0**</mark> (inventaire FR): +10 au SP  ; <mark style="color:purple;">**b) 0 < D < 1000km**</mark> (inventaire Europe occidentale) : +8 au SP ; <mark style="color:purple;">**c) 999km < D < 3000km**</mark> (inventaire Europe et Maghreb) : +6 au SP ;  <mark style="color:purple;">**d) 2999km< D**</mark> : -5 au SP
* **la présence de certains mots clés**. Les mots clés faisant à l'amont de la chaine de valeur / la sortie de ferme sont valorisés (+25 au SP), par exemple "farm gate" ou "at orchard". A l'inverse, les mots clés relatifs à l'aval de la chaine de valeur sont dévalorisés (-30 au SP), par exemple "at consumer", "at supermarket". Enfin, la mention "organic" est également dévalorisée pour la variante FR conventionnelle (-8 au SP).

On identifie ainsi les cinq inventaires candidats au SP le plus important. S'il existe au moins un candidat tel que la distance D est inférieure à 3000km, on prend le candidat au SP le plus important. Si les cinq candidats sont tels que D > 3000km, on considère que le score de pertinence n'est pas suffisamment représentatif. Par exemple, le choix entre deux inventaires {US} (Etats-Unis) et {CN} (Chine) peut être arbitraire et décorrélé des modes de production. Dans une logique conservatrice, on sélectionne alors l'inventaire à l'**ECS** (**Environmental Cost Score** = socle ACV du coût environnemental) minimal.

### <mark style="color:green;">**Pour les productions de l’Union européenne (hors France)**</mark>

L’objectif de la variante « Production UE » est d’associer à chaque ingrédient un inventaire de cycle de vie représentatif des conditions moyennes de production au sein de l’Union européenne, hors France.\
Contrairement au cas français, où la base Agribalyse constitue la référence principale, la couverture géographique et thématique des productions européennes nécessite de mobiliser plusieurs bases de données complémentaires.

Les inventaires mobilisés proviennent donc des trois sources suivantes :

* **Agribalyse 3.2**, lorsque des inventaires européens sont disponibles ;
* **Ecoinvent 3.11**, qui couvre un large spectre de productions agricoles internationales ;
* **WFLDB (World Food LCA Database)**, utilisée en complément lorsque les deux premières bases ne proposent pas d’inventaire pertinent.

#### Définition du périmètre géographique

Afin de distinguer clairement les productions de l’Union européenne des autres origines, une logique de catégorisation géographique a été mise en place.

Sont considérées comme « UE » les localisations correspondant :

* aux codes ISO2 pays de l’Union européenne (AT, BE, BG, HR, CY, CZ, DK, EE, FI, DE, GR, HU, IE, IT, LV, LT, LU, MT, NL, PL, PT, RO, SK, SI, ES, SE) ;
* aux régions agrégées associées à l’UE dans les bases de données (EU, EUR, WEU, CEU, EEU).

Les autres pays européens non membres de l’UE (Suisse, Norvège, Royaume-Uni, etc.), ainsi que la France sont considérés comme « Europe hors UE », et ne sont mobilisés qu’en second niveau de priorité.

Cette distinction permet de hiérarchiser les candidats selon trois zones :

1. Union européenne (priorité maximale)
2. Europe hors UE + France
3. Monde (fallback)

#### Méthode générale de sélection des ICV

La sélection d’un inventaire pour un ingrédient donné repose sur une logique algorithmique en plusieurs étapes, similaire dans son principe à celle utilisée pour la production française, mais adaptée au contexte multi-bases et multi-pays.

<mark style="color:red;">**Étape 1 – Recherche de candidats dans les bases de données**</mark>

Pour chaque ingrédient, une recherche textuelle est effectuée de manière simultanée dans les trois bases disponibles : Agribalyse 3.2, Ecoinvent 3.11 et WFLDB.

Afin d’améliorer la robustesse des correspondances, plusieurs variantes du nom d’ingrédient sont générées (singulier/pluriel, suppression des parenthèses, normalisation lexicale).\
Chaque inventaire candidat identifié est associé à un **score de pertinence (SP)** calculé à partir de :

* la similarité sémantique entre le nom de l’ingrédient et celui de l’ICV ;
* la présence de mots-clés valorisant les étapes amont de la chaîne de valeur (ex. « at farm », « farm gate », « cultivation », « at orchard ») ;
* la pénalisation des inventaires correspondant à des étapes aval ou à des produits transformés (ex. « at consumer », « packaging », « processed », « market for ») ;
* une dévalorisation des inventaires « organic » pour la variante conventionnelle.

<mark style="color:red;">**Étape 2 – Filtrage des ICV non pertinents**</mark>

Un filtre structurel est ensuite appliqué afin d’éliminer les inventaires ne correspondant pas à une production agricole primaire, notamment :

* procédés logistiques (transport, stockage) ;
* procédés industriels ou de transformation (huile, farine, jus, conserve, etc.) ;
* étapes de distribution ou de consommation finale.

Seuls sont conservés les inventaires correspondant à des étapes « sortie de ferme » ou équivalentes.

<mark style="color:red;">**Étape 3 – Calcul de l’indicateur ECS**</mark>

Pour chaque candidat restant, l’indicateur synthétique ECS est calculé à partir de la méthode Environmental Footprint 3.1 adaptée.

Afin d’optimiser les temps de calcul, un mécanisme de mise en cache est utilisé :\
si un ICV a déjà été évalué précédemment, sa valeur ECS est réutilisée.

Ces premières étapes produisent, pour chaque ingrédient, un [fichier CSV](https://ademecloud.sharepoint.com/:x:/s/C-GroupeAffichageEnvironnemental-AffichageAlimentaire-ADEME/IQBqUiFEOU5tRa7H9nPqB-R-AZNrNlSxhs6jqIREBxnjuJ4?e=9P4XFD) qui liste exhaustivement les inventaires candidats potentiels issus des trois bases. Ce fichier est modifiable à la main pour permettre de corriger / ajouter / supprimer des inventaires candidats. Il est ensuite réinjecté dans le code pour la sélection de l'ICV final.

<mark style="color:red;">**Étape 4 – Priorisation géographique**</mark>

A partir du [fichier d'ICV candidats](https://ademecloud.sharepoint.com/:x:/s/C-GroupeAffichageEnvironnemental-AffichageAlimentaire-ADEME/IQBqUiFEOU5tRa7H9nPqB-R-AZNrNlSxhs6jqIREBxnjuJ4?e=9P4XFD), les candidats sont ensuite hiérarchisés selon leur localisation :

1. Priorité aux inventaires localisés dans l’Union européenne
2. À défaut, inventaires localisés en Europe hors UE + France
3. En dernier recours, inventaires du reste du monde

<figure><img src="../../../.gitbook/assets/image.png" alt=""><figcaption></figcaption></figure>

Cette priorisation garantit que, lorsque cela est possible, l’inventaire retenu reflète effectivement les conditions européennes de production.

<mark style="color:red;">**Étape 5 – Sélection par moyenne ECS**</mark>

Au sein de la zone géographique prioritaire identifiée, la sélection finale de l’ICV repose sur une logique statistique :

* pour chaque pays représenté, on calcule la moyenne des ECS des candidats disponibles ;
* on calcule ensuite la moyenne de ces moyennes par pays ;
* l’inventaire retenu est celui dont l’ECS est **le plus proche en absolu de cette moyenne**, considérée comme représentative d’un niveau d’impact « typique » de l’UE.

En cas d’égalité, une priorité est donnée aux bases dans l’ordre suivant : 1. Agribalyse ; 2. Ecoinvent ; 3. WFLDB.

Enfin, dans le cas de figure où des ICV candidats, dont un d'origine FR, sont à égale distance de la moyenne et qu'ils proviennent de la même base de données, on privilégie l'inventaire non FR. Par exemple, pour l'ingrédient "Chou-fleur" on retient "_Cauliflower {CH}| cauliflower production, conventional, plain region | Cut-off, U_".

Cette approche permet d’éviter le choix arbitraire d’un inventaire extrême (très favorable ou très défavorable) et de privilégier un proxy représentatif.

<mark style="color:red;">**Gestion des cas sans correspondance directe**</mark>

Il arrive qu’aucun inventaire pertinent ne soit identifié directement pour un ingrédient donné (absence de correspondance textuelle ou géographique satisfaisante).

Dans ce cas, une procédure de repli est mise en œuvre à partir des **mix de consommation Agribalyse** :

1. Recherche d’un ingrédient proxy via le fichier des mix de consommation ;
2. Identification du mot-clé principal associé à ce proxy ;
3. Relance complète de la procédure de sélection d’ICV à partir de ce mot-clé ;
4. Application des mêmes règles de priorisation UE et de sélection par moyenne ECS.

Cette logique permet de couvrir des ingrédients peu documentés tout en conservant une cohérence méthodologique avec les hypothèses d'Agribalyse et le reste du système.

#### Traçabilité et transparence

Pour chaque ingrédient traité, le processus génère :

* un fichier listant l’ensemble des candidats considérés (bases, localisations, scores, ECS) ;
* un fichier final précisant l’ICV retenu, la zone de sélection, la moyenne ECS utilisée, et la liste des inventaires conservés.

Cette traçabilité complète permet d’auditer a posteriori les choix effectués et d’améliorer progressivement les règles d’association.

_<mark style="color:$primary;">La méthode mise en œuvre pour la variante « Production UE » repose donc sur :</mark>_

* _<mark style="color:$primary;">une exploration multi-bases (Agribalyse, Ecoinvent, WFLDB) ;</mark>_
* _<mark style="color:$primary;">un scoring sémantique et fonctionnel des inventaires ;</mark>_
* _<mark style="color:$primary;">un filtrage strict vers les étapes agricoles primaires ;</mark>_
* _<mark style="color:$primary;">une priorisation géographique centrée sur l’Union européenne ;</mark>_
* _<mark style="color:$primary;">une sélection finale statistique par rapprochement à une moyenne ECS.</mark>_

_<mark style="color:$primary;">Cette approche permet d’obtenir, pour la majorité des ingrédients, des ICV cohérents, comparables et représentatifs des conditions moyennes de production au sein de l’Union européenne, tout en conservant une logique prudente et transparente lorsque les données disponibles sont limitées.</mark>_

### <mark style="color:green;">**Pour les productions hors Union européenne**</mark>

La variante **« Production hors UE »** vise à associer à chaque ingrédient un inventaire de cycle de vie représentatif des conditions moyennes de production en dehors de l’Union européenne.\
Elle correspond au cas des ingrédients importés depuis des pays tiers (Amériques, Asie, Afrique, Océanie, etc.).

Cette variante s’appuie sur le même socle méthodologique que la variante « Production UE » :\
les inventaires candidats sont issus d’un travail préalable d’identification multi-bases, et sont regroupés dans un fichier commun d’ICV candidats. La différence principale réside dans la logique de régionalisation et de hiérarchisation géographique.

Comme pour les productions UE, trois bases de données sont utilisées afin de maximiser la couverture des produits et des pays :

* **Agribalyse 3.2**, lorsque des inventaires internationaux y sont disponibles ;
* **Ecoinvent 3.11**, qui constitue la source principale pour de nombreux pays hors Europe ;
* **WFLDB**, mobilisée en complément pour des filières ou régions peu couvertes.

L’ensemble des inventaires candidats provient du même processus de génération que celui décrit pour la variante UE : recherche multi-bases, calcul des scores de pertinence, filtrage des ICV non pertinents et calcul des ECS.

#### Utilisation d’un fichier unique de candidats

Contrairement à la variante UE, il n’est pas nécessaire de relancer l’ensemble du processus de recherche et de scoring des ICV.

La variante « hors UE » utilise directement en entrée le [**fichier d’ICV candidats**](https://ademecloud.sharepoint.com/:x:/s/C-GroupeAffichageEnvironnemental-AffichageAlimentaire-ADEME/IQBqUiFEOU5tRa7H9nPqB-R-AZNrNlSxhs6jqIREBxnjuJ4) **déjà constitué** lors de l’étape précédente (sélection UE).\
Ce fichier, potentiellement enrichi ou corrigé manuellement, contient pour chaque ingrédient :

* la liste complète des inventaires candidats identifiés ;
* leur base de données d’origine ;
* leur localisation ;
* leur score de pertinence ;
* leur indicateur ECS.

La variante hors UE consiste donc essentiellement en une **ré-interprétation géographique** de ces mêmes candidats.

Pour cette variante, l’objectif est de privilégier les inventaires provenant de pays **non membres de l’Union européenne**.

Sont considérées comme appartenant à l’UE :

* les localisations correspondant aux codes pays de l’Union européenne (y compris la France) ;
* les régions agrégées associées à l’UE dans les bases de données (EU, EUR, WEU, CEU, EEU, RER).

Tout inventaire dont la localisation ne relève pas de ces catégories est considéré comme **hors UE**.

#### Méthode de sélection de l’ICV final

<mark style="color:red;">**Étape 1 – Séparation géographique des candidats**</mark>

À partir du fichier d’ICV candidats, les inventaires sont répartis en deux ensembles :

* **Candidats hors UE** : localisations non européennes (États-Unis, Canada, Chine, Brésil, etc.) ;
* **Candidats UE** : pays ou régions de l’Union européenne.

<mark style="color:red;">**Étape 2 – Hiérarchisation des zones**</mark>

La sélection s’effectue selon une règle simple :

1. **Si au moins un candidat hors UE est disponible**, seuls ces candidats sont retenus pour la suite du calcul.
2. **Si aucun candidat hors UE n’est disponible**, la sélection bascule en mode « fallback UE » et s’appuie alors sur les inventaires européens disponibles.

<figure><img src="../../../.gitbook/assets/image (387).png" alt=""><figcaption></figcaption></figure>

Cette hiérarchisation garantit que la variante « Production hors UE » reflète autant que possible des conditions de production réellement extra-européennes.

<mark style="color:red;">**Étape 3 – Calcul de la moyenne ECS**</mark>

Sur l’ensemble des candidats retenus (hors UE prioritairement), la sélection finale repose, comme pour la variante UE, sur une logique statistique :

* pour chaque pays représenté, on calcule la moyenne des ECS des inventaires disponibles ;
* on calcule ensuite la moyenne de ces moyennes par pays ;
* l’ICV retenu est celui dont l’ECS est **le plus proche en valeur absolue de cette moyenne**.

Cette approche permet d’identifier un inventaire « typique » parmi des situations parfois très hétérogènes (différences climatiques, techniques culturales, niveaux d’intensification, etc.).

<mark style="color:red;">**Étape 4 – Règles de départage**</mark>

En cas d’égalité ou de distances équivalentes à la moyenne ECS, une priorité est appliquée entre bases de données afin de favoriser les sources les plus adaptées au contexte alimentaire : **1. Agribalyse ; 2. Ecoinvent ; 3. WFLDB.**

Ce mécanisme permet d’assurer une cohérence globale avec les autres variantes.

#### Résultat et traçabilité

Pour chaque ingrédient, le processus génère :

* un inventaire final retenu ;
* la zone de sélection appliquée (« Hors UE » ou « Fallback UE ») ;
* la moyenne ECS ayant servi de référence ;
* la liste complète des candidats conservés.

Cette information est exportée dans un fichier CSV de résultats finaux, permettant une vérification et un audit complets des choix réalisés.

_<mark style="color:$primary;">La méthode mise en œuvre pour la variante</mark> <mark style="color:$primary;"></mark><mark style="color:$primary;">**« Production hors Union européenne »**</mark> <mark style="color:$primary;"></mark><mark style="color:$primary;">repose donc sur :</mark>_

* _<mark style="color:$primary;">l'utilisation du</mark>_ [_<mark style="color:$primary;">fichier commun d’ICV candidats</mark>_](https://ademecloud.sharepoint.com/:x:/s/C-GroupeAffichageEnvironnemental-AffichageAlimentaire-ADEME/IQBqUiFEOU5tRa7H9nPqB-R-AZNrNlSxhs6jqIREBxnjuJ4) _<mark style="color:$primary;">valable pour la variante UE ;</mark>_
* _<mark style="color:$primary;">une hiérarchisation géographique privilégiant explicitement les inventaires non européens ;</mark>_
* _<mark style="color:$primary;">une sélection finale fondée sur le rapprochement à une moyenne ECS représentative ;</mark>_
* _<mark style="color:$primary;">des règles de départage assurant une cohérence entre bases de données.</mark>_

_<mark style="color:$primary;">Cette approche permet d’obtenir, pour les ingrédients importés, des ICV cohérents et représentatifs de contextes de production extra-européens, tout en conservant une méthodologie homogène avec les variantes « France » et « UE ».</mark>_

### <mark style="color:green;">**Pour les productions d'origine inconnue**</mark>&#x20;

La variante **« Production origine inconnue »** s’applique lorsque l’utilisateur ne dispose d’aucune information sur la provenance géographique d’un ingrédient.\
Dans ce cas, il n’est pas possible d’appliquer une priorisation par zone (France, UE, hors UE). L’objectif est donc d’associer à l’ingrédient un ICV **conservateur**, évitant toute sous-estimation des impacts.

La sélection s’appuie sur les mêmes sources que les autres variantes :

* **Agribalyse 3.2**
* **Ecoinvent 3.11**
* **WFLDB**

La recherche d’inventaires est effectuée simultanément dans ces trois bases.

#### Méthode de sélection

<mark style="color:red;">**Recherche et filtrage des candidats**</mark>

Pour chaque ingrédient, une recherche multi-bases est réalisée à partir de plusieurs variantes lexicales du nom.\
Les inventaires identifiés sont ensuite :

* scorés selon leur pertinence sémantique ;
* filtrés pour ne conserver que des **ICV correspondant à des productions agricoles primaires** (sortie de ferme) ;
* débarrassés des procédés logistiques, industriels ou trop transformés.

<mark style="color:red;">**Calcul des impacts**</mark>

Pour les candidats conservés, l’indicateur synthétique **ECS** est calculé à partir de la méthode Environmental Footprint 3.1.\
Un système de **mise en cache** permet de réutiliser les valeurs déjà calculées.

<mark style="color:red;">**Logique raisonnablement majorante**</mark>

Contrairement aux variantes France, UE et hors UE qui visent un ICV représentatif « moyen », la variante origine inconnue adopte une approche prudente : &#x6C;**’ICV retenu est celui présentant l’ECS le plus élevé parmi les candidats valides.**

Une analyse des associations ingrédient-ICV au regard des données FAOstats permet d'ajuster les résultats du code. En effet, l'ICV final retenu doit représenter une proportion non négligeable des exportations pour un ingrédient donné. Les hypothèses au cas par cas sont précisées dans le [fichier dédié à la Variante Origine inconnue](https://ademecloud.sharepoint.com/:x:/s/C-GroupeAffichageEnvironnemental-AffichageAlimentaire-ADEME/IQBcD0PL3gFwTalP7qDF3Wy6ATmeK4nkgXW2_Ir0n3k3-h8?e=DOpwIW).

<mark style="color:red;">**Gestion des cas sans correspondance**</mark>

Si aucun inventaire pertinent n’est trouvé directement, une procédure de **fallback par proxy** est appliquée à partir des mix de consommation Agribalyse :

1. identification d’un ingrédient proxy ;
2. extraction d’un mot-clé associé ;
3. relance complète de la recherche d’ICV à partir de ce mot-clé ;
4. application de la même règle de sélection par ECS maximal.

#### Résultat

Pour chaque ingrédient, le processus produit :

* l’ICV final retenu ;
* sa base de données d’origine et sa localisation ;
* la valeur ECS correspondante ;
* la liste des candidats examinés ;
* l’indication éventuelle d’un recours à un proxy.

_<mark style="color:$primary;">La variante</mark> <mark style="color:$primary;"></mark><mark style="color:$primary;">**« Production origine inconnue »**</mark> <mark style="color:$primary;"></mark><mark style="color:$primary;">repose donc sur :</mark>_

* _<mark style="color:$primary;">une recherche multi-bases non régionalisée ;</mark>_
* _<mark style="color:$primary;">un filtrage strict vers les productions agricoles primaires ;</mark>_
* _<mark style="color:$primary;">une sélection</mark> <mark style="color:$primary;"></mark><mark style="color:$primary;">**conservatrice par ECS maximal**</mark> <mark style="color:$primary;"></mark><mark style="color:$primary;">;</mark>_
* _<mark style="color:$primary;">un mécanisme de fallback via proxies Agribalyse.</mark>_

_<mark style="color:$primary;">Elle permet ainsi de traiter les ingrédients sans information d’origine tout en garantissant une évaluation prudente et traçable des impacts environnementaux.</mark>_

### <mark style="color:green;">**Pour les ingrédients biologiques**</mark>

#### **Sources des inventaires bio**

Dans une logique de simplification et au regard du manque de données sur les produits bio, il est considéré que les conditions de productions biologiques sont similaires quelques soit le pays d'origine. Cette hypothèse se justifie en particulier du fait du cahier des charges AB harmonisé au niveau européen, et avec des équivalences internationales solides. Il n'y a donc qu'une variante "bio" proposée dans un premier temps.

Le choix des ICV bio s'est fait parmi :

1. Les ICV bio issus du travail d'extrapolation d'inventaires bio à partir des données conventionnelles d'Agribalyse, mené par le cabinet Ginko pour le compte de l'ADEME. Ceci ne concerne que les productions végétales françaises et importées. Ces ICV seront inclus dans des futures versions d'Agribalyse.&#x20;
2. Les ICV bio directement issus d'Agribalyse (ex : "Wheat, organic, national average, at farm, Agribalyse).
3. Les ICV bio construits par Ecobalyse : en l'absence de données bio moyennes, ces ICV correspondent à des moyennes pondérées d'ICV bio disponibles dans Agribalyse. &#x20;

{% file src="../../../.gitbook/assets/20221215 ICV bio moyen ecobalyse (1).xlsx" %}

{% hint style="info" %}
Les procédés construits par Ecobalyse font l'objet d'une [page dédiée](../../../def-cout-environnemental/source-des-procedes.md) présentant tous les cas de figure nécessitant la construction d'un inventaire, ainsi que le lien vers les détails du code pour la construction de ces inventaires.
{% endhint %}

#### Méthode de sélection

En pratique, les règles d'association ingrédient-ICV sont semblables  aux règles applicables à la variante France. L'algorithme est construit sur une fonction de pertinence et une hiérarchisation des sources.

_<mark style="color:$success;">**Priorité 1 : Identifier l'inventaire de production FR en amont du mix de consommation d'un ingrédient donné**</mark><mark style="color:$success;">.</mark>_&#x20;

La source est l'[annexe d'Ecobalyse](https://ademecloud.sharepoint.com/:x:/s/C-GroupeAffichageEnvironnemental-AffichageAlimentaire-ADEME/IQC7GqkQ4u2pQ6qhYU1DxySHAb0C6wSg_oSFB03jhpsLUe8) sur les mix de consommation, construite à partir de l'[annexe 1 d'Agribalyse](https://entrepot.recherche.data.gouv.fr/file.xhtml?persistentId=doi:10.57745/MNNUAN) destinée aux ingrédients conventionnels. Ce fichier fait le lien entre les mix de consommation et inventaires conventionnels et leur équivalent extrapolé bio. Il permet de récupérer facilement les éventuels proxies ingrédients.

_<mark style="color:$success;">**Priorité 2 : Identifier l'inventaire le plus pertinent parmi des inventaires candidats Ginko**</mark>_

_<mark style="color:$success;">**Priorité 3 : Identifier l'inventaire le plus pertinent parmi des inventaires candidats Agribalyse bio**</mark>_

Pour les priorités 2 et 3, on raisonne de nouveau avec une fonction qui calcule le score de pertinence d'icv, pour un ingrédient donné.

Ce score de pertinence (SP) est dépend de :&#x20;

* **la correspondance sémantique** entre le nom de l'ingrédient (ex: "Apricot") et le nom de l'inventaire (ex: "_Apricot, organic {FR}| apricot production | Cut-off, U")._
* **la présence de certains mots clés**. Les mots clés faisant à l'amont de la chaine de valeur / la sortie de ferme sont valorisés (+8 au SP), par exemple "farm gate" ou "at orchard". A l'inverse, les mots clés relatifs à l'aval de la chaine de valeur sont dévalorisés (-20 au SP), par exemple "at consumer", "at supermarket". La mention "at packaging" est moins dévalorisée (-17 au SP), car cette étape n'intervient pas en bout de la chaine de valeur. Enfin, la mention "organic" est également fortement valorisée (+30 au SP), tandis que son absence est dévalorisée (-25 au SP).

La nécessité de la présence du mot clé "organic" est encore renforcée lors de la recherche des candidats en Priorité 3, car les inventaires Ginko sont bio par défaut.

_<mark style="color:$success;">**Priorité 4 :**</mark>_ _<mark style="color:$success;">**Cas particulier :**</mark>_ _<mark style="color:$success;">**Remontée du conventionnel vers le bio**</mark>_

Il arrive que l'[annexe d'Ecobalyse](https://ademecloud.sharepoint.com/:x:/s/C-GroupeAffichageEnvironnemental-AffichageAlimentaire-ADEME/IQC7GqkQ4u2pQ6qhYU1DxySHAb0C6wSg_oSFB03jhpsLUe8) sur les mix de consommation ne permette pas d'identifier un ingrédient (ex: le topinambour bio - "Jerusalem artichoke"), et que ce dernier n'existe pas non plus dans Ginko ou dans Agribalyse en bio.

Dans ce cas de figure, on identifie l'inventaire conventionnel associé à l'ingrédient (ex: "Artichoke, consumption mix {FR} U" ---> "_<mark style="color:green;">Cauliflower, conventional, national average, at farm gate {FR} U</mark>_"). On recherche ensuite le proxy ingrédient dans la base de données Ginko, en passant par le mix de consommation. On identifie enfin l'inventaire bio en amont du mix de consommation. (ex: "Cauliflower, consumption mix, organic 2025 {FR} U" ---> "<mark style="color:green;">Cauliflower, organic 2025, national average, at farm gate {FR} U {FR}</mark>").

### <mark style="color:green;">**Autres labels**</mark>

Quelques données sous labels sont déjà disponibles dans Agribalyse et ont pu être intégrées dans Ecobalyse, c'est le cas pour les oeufs "Bleu Blanc Coeur" par exemple. Il est tout à fait possible de rajouter dans Ecobalyse d'autres labels à l'avenir. Pour cela, les porteurs de labels sont invités à se [rapprocher de l'ADEME et des travaux Agribalyse](../../../impacts-consideres.md).&#x20;



L’ensemble des appariements entre ingrédients et ICV est visible dans l’explorateur, et via le bouton "?" disponible à côté du nom de l'ingrédient.

<figure><img src="../../../.gitbook/assets/image (352).png" alt=""><figcaption></figcaption></figure>



