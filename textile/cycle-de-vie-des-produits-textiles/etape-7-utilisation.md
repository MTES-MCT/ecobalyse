# 🌀 Etape 7 - Utilisation

## Contexte

### Impacts pris en compte

Les impacts de la phase d'utilisation concernent l'entretien du vêtement. Conformément à la documentation textile de la Base Impacts, nous prenons en compte les impacts suivants :

* Lavage - Électricité
* Lavage - Lessive
* Lavage - Traitement des eaux usées
* Séchage - Électricité
* Repassage - Électricité

### Durée de vie des vêtements

La durée de vie se définie en nombres de jours portés. Celle-ci est spécifique à chaque catégorie de vêtement (ex : 45 jours pour un t-shirt) et définie dans Ecobalyse (cf. [explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile/products)). Ces valeurs ont été définies en s'appuyant sur les données du PEFCR Apparel & Footwear.

Le coefficient de durabilité (cf. la section [Durabilité](https://fabrique-numerique.gitbook.io/ecobalyse/textile/durabilite)) vient corriger le nombre de jours portés.&#x20;

Plus un vêtement est durable, plus élevé sera sa durée de vie et donc son nombre de jours portés.

### Repassage

Pour l'étape de repassage, le PEFCR Apparel & Footwear, propose d'appliquer un ratio de produits repassés en fonction de la catégorie de produit. Par exemple on fait l'hypothèse qu'une chemise est repassé 70% du temps tandis qu'un pull n'est jamais repassé. De plus on fait l'hypothèse que le temps de repassage est différent pour chaque type de vêtement. Ainsi on suppose qu'un t-shirt a un temps de repassage de 2 minutes tandis qu'un pantalon a un temps de repassage de 4,3 minutes.

## Méthodes de calcul

### Impact de l'utilisation

Le calcul se décompose en une partie hors électricité et une partie électricité, cette dernière étant elle-même composée d'une partie hors repassage et d'une partie repassage.

$$
I_{7} = n_{cycles}*m*I_{7,horsrepassage} +E_{7}*I_{élec}
$$

Avec :&#x20;

* `I_7` : I'impact environnemental associé à l'utilisation du vêtement sur sa durée de vie, exprimé en unité de la catégorie d'impact analysée.
* `n_cycles` : le nombre de cycles d'entretiens du vêtement, sur l'ensemble de sa durée de vie, sans unité
* `m` : la masse du vêtement, en kg
* `I_7,horsrepassage` : I'impact environnemental associé à l'entretien d'1kg de vêtement de la catégorie i, exprimé en unité de la catégorie d'impact analysée par kg. Il s'agit de l'impact des procédés  `Utilisation : Impact hors repassage (i)`&#x20;
* `I_elec` : l'impact environnemental pour 1 kWh d'électricité, exprimé en unité de la catégorie d'impact analysée
* `E_7` : la quantité d'électricité consommée pour l'entretien du vêtement, sur l'ensemble de sa durée de vie, en kWh. Cette quantité est affichée dans l'interface utilisateur dans le mode exploratoire. \
  Cette valeur se calcule comme suit :

$$
E_{7} = n_{cycles}*m*E_{7,hors repassage,i} + n_{cycles}*E_{7,repassage,i}
$$

* `E_7,horsrepassage,i` : la quantité d'électricité consommée (hors repassage) pour le cycle d'entretien d'un kg de vêtement de la catégorie `i`, en kWh/kg. Cette quantité est définie dans le procédé `Utilisation : Impact hors repassage (i)` comme flux externe.
* `E_7,repassage,i` : la quantité d'électricité consommée associée au repassage, pour le cycle d'entretien d'un vêtement de la catégorie i, en kWh/vêtement.

### Durée de vie et nombre de cycles d'entretien

#### Nombre de cycles par défaut

Un nombre de cycle d'entretien par défaut est calculé pour chaque catégorie de vêtement i, en fonction de la durée de vie du vêtement (en nombre de jours portés) et de la durée entre deux cycles d'entretien (en jours) :

$$
n_{cycles,i,defaut}= \frac{d_{portés,i}}{d_{cycle.entretien,i}}
$$

Avec :&#x20;

* `n_cycles,i,defaut` : le nombre de cycles d'entretien par défaut pour la catégorie de produit i ;
* `d_portés,i` : la durée de vie du vêtement, en nombre de jours portés ;
* `d_cycle.entretien,i` : la durée entre deux cycles d'entretiens, en nombre de jours.

#### Nombre de cycles d'entretien du vêtement

Un nombre de cycle est calculé pour chaque vêtement, calculé en fonction du nombre de cycle par défaut et de son coefficient de durabilité :&#x20;

$$
n_{cycles}= n_{cycles,i,defaut}*C_{Durabilité}
$$

Avec :&#x20;

* `n_cycles` : le nombre de cycles d'entretien pour la catégorie de produit i ;
* `n_cycles,i,defaut` : le nombre de cycles d'entretien par défaut pour la catégorie de produit i ;
* `C_Durabilité` : le coefficient de durabilité du produit, sans unité ;

{% hint style="info" %}
Par exemple, pour un t-shirt avec une durabilité élevée (coefficient de x1,35); le nombre de cycles d'entretiens retenu dans le calcul serait de 61 jours (45\*1,35).
{% endhint %}

## Paramètres retenus pour le coût environnemental

### Calcul du nombre de cycles d'entretien

Les paramètres suivants sont fournis pour chaque catégorie de produit dans l'[Explorateur ](https://ecobalyse.beta.gouv.fr/#/explore/textile/products):&#x20;

* `n_cycles,i,defaut` : colonne _Cycles d'entretien (par défaut)_ ;
* `d_portés,i` : colonne _Nombre de jours portés_ ;
* `d_cycle.entretien,i` : colonne _Utilisations avant lavage_.

### Energie pour le repassage

Le paramètre `E_repassage,i` est fourni pour chaque catégorie de produit dans l'[Explorateur produits](https://ecobalyse.beta.gouv.fr/#/explore/textile/products), colonne _Repassage._ Ce chiffre se retrouve dans l'interface utilisateur en mode exploratoire.

{% hint style="info" %}
Les valeurs "Repassage" affichées dans l'explorateur produit sont affichées avec 2 chiffres après la virgule, et ne correspondent pas à la valeur exacte du paramètre (la valeur n'est pas arrondies à deux chiffres après la virgule).

Les valeurs exactes peuvent être retrouvées dans l'interface utilisateur en mode exploratoire.

Leur calcul est indiqué ci-dessous pour information :

$$
E_{repassage_i} = r_{repassage,i}*t_{repassage,i}*E_{repassage,heure}
$$

Avec :&#x20;

* `E_repassage,i` : la quantité d'électricité moyenne consommée associée au repassage, pour le cycle d'entretien d'un vêtement de la catégorie i, en kWh/vêtement ;
* `r_repassage,i` : la part des vêtements de la catégorie i faisant l'objet d'un repassage, exprimé en pourcentage et situé entre 0% et 100% ;
  * Ce paramètre est fournis pour chaque catégorie de produit dans l'[Explorateur produits](https://ecobalyse.beta.gouv.fr/#/explore/textile/products), colonne _Repassage, part_ ;
* `t_repassage,i` : le temps de repassage d'un vêtement de la catégorie i, exprimé en heures ;
  * Ce paramètre est fournis pour chaque catégorie de produit dans l'[Explorateur produits](https://ecobalyse.beta.gouv.fr/#/explore/textile/products), colonne _Repassage, temps_ ;
* `P_repassage,heure` : la puissance électrique nécessaire au repassage (ou consommation d'électricité moyenne pour une heure de repassage), en kWh ;
  * valeur : 1,5 kW (documentation Base Impacts ADEME) ;
{% endhint %}

## Procédés utilisés pour le coût environnemental

### Impacts hors repassage : `Utilisation : Impact hors repassage (i)`&#x20;

Des procédés dédiés nommés `Utilisation : Impact hors repassage (i)`, avec `i` la catégorie de produit, ont été créés pour chaque catégorie de produit i. Ces procédés sont identifiés pour chaque catégorie de produit dans l'[Explorateur produits](https://ecobalyse.beta.gouv.fr/#/explore/textile/products), dans la colonne "_Procédé d'utilisation hors-repassage_". sous la dénomination ".

Ces procédés sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes).

Ils ont été construits spécifiquement par Ecobalyse.

Ils précisent une consommation d'électricité, modélisée comme flux externe, ainsi que des impacts environnementaux.

Les calculs de ces deux composantes sont précisés pour information dans les deux encadrés suivants.

{% hint style="info" %}
#### Consommation d'énergie pour 1kg de vêtement (hors repassage)

Les valeurs "Electricité" affichées dans les procédés `Utilisation : Impact hors repassage (i)` sont affichées avec 2 chiffres après la virgule, et ne correspondent pas à la valeur exacte du paramètre (la valeur n'est pas arrondies à deux chiffres après la virgule).

Les valeurs exactes peuvent être retrouvées avec le calcul ci-dessous :&#x20;

$$
E_{7,horsrepassage,i}=E_{lavage}+r_{séchage,i}*E_{sechage}
$$

Avec :

* `E_7,horsrepassage,i` : la quantité d'électricité consommée (hors repassage) pour le cycle d'entretien d'un kg de vêtement de la catégorie `i`, en kWh/kg. Cette quantité est définie dans le procédé `Utilisation : Impact hors repassage (i)` comme flux externe. Elle intervient directement dans le calcul de l'impact environnemental de l'utilisation du vêtement.
* `E_lavage` : la quantité d'électricité nécessaire pour laver 1 kg de vêtement, exprimé en kWh/kg.&#x20;
  * Une valeur de 0.1847 kWh/kg est retenue, en accord avec la documentation Base Impacts - ADEME
* `r_sechage,i` : la part de vêtement qui va être séché en sèche-linge, pour la catégorie de vêtement `i`, sans unité.
  * En accord avec le PEFCR Apparel & Footwear (Table 33 - version de l'été 2021) on applique un ratio de produits séchés en sèche-linge différent pour chaque type de produit. Par exemple on fait l'hypothèse qu'un t-shirt est séché en sèche-linge 30% du temps tandis qu'une jupe n'est séchée en sèche-linge que 12% du temps. Ces ratios sont précisé dans l'[Explorateur produits](https://ecobalyse.beta.gouv.fr/#/explore/textile/products);
* `E_sechage` : la quantité d'électricité nécessaire pour sécher 1 kg de vêtement, exprimé en kWh/kg.&#x20;
  * Une valeur de 0.335 kWh/kg est retenue, en accord avec la documentation Base Impacts - ADEME
{% endhint %}

{% hint style="info" %}
#### Impact environnemental pour 1kg de vêtement (hors repassage)

Cet impact est le même pour toutes les catégories de vêtement. Il est calculé comme suit :

$$
I_{7,hors repassage}=m_{lessive}*I_{lessive}+V_{eau}*I_{traitementEau}
$$

Avec :

* `I_7,horsrepassage` : I'impact environnemental associé à l'entretien d'1kg de vêtement de la catégorie i, exprimé en unité de la catégorie d'impact analysée par kg.&#x20;
* `m_lessive` : la quantité de lessive nécessaire pour laver 1 kg de linge, exprimé en kg/kg.&#x20;
  * Une valeur de 0.036 kWh/kg est retenue, en accord avec la documentation Base Impacts- ADEME
* `I_lessive` : I'impact environnemental d'1kg de lessive, exprimé en unité de la catégorie d'impact analysée par kg.
  *
* `V_eau` : le volume d'eau de vêtement nécessaire pour laver 1 kg de linge, exprimé en m3/kg.
  * &#x20;Une valeur de 0.0097 kWh/kg est retenue, en accord avec la documentation Base Impacts - ADEME
* `I_traitementEau` : I'impact environnemental associé au traitement d'1m3 d'eau, exprimé en unité de la catégorie d'impact analysée par m3.&#x20;
{% endhint %}

### Procédé de modélisation de l'électricité

Le procédé utilisé pour modéliser l'électricité est indiqué dans la page [Electricité à l'utilisation](https://app.gitbook.com/u/9QFiIxzi1NajCEGcTK2jJf967VI2).

## Exemple d'application

La méthode est détaillée ci-dessous avec l'exemple d'une jupe :

* Catégorie : Jupe
  * Paramètres associés : voir [Explorateur produit pour la jupe](https://ecobalyse.beta.gouv.fr/#/explore/textile/products/jupe)
  * Procédé associé à l'utilisation : voir [procédé `Utilisation : Impact hors repassage (Jupe)` dans l'Explorateur procédés](https://ecobalyse.beta.gouv.fr/#/explore/textile/products/jupe)
* Coefficient de durabilité `C_Durabilité` = 1,&#x20;
* Poids `m` = 0.3 kg
* nombre de cycles d'entretien : `n_cycles` = 23

### Consommation d'électricité

Rappel de la formule de calcul :

$$
E_{7} = n_{cycles}*m*E_{7,hors repassage,i} + n_{cycles}*E_{7,repassage,i}
$$

Calcul pour la jupe :

$$
E_{7} = 23*0.3*0.225+23*0.0203=2.02 kWh
$$

Pour rentrer dans le détail :

* `E_7,horsrepassage,i = 0.1847 + 12%*0.335 = 0.225 kWh/kg` (voir procédé [`Utilisation : Impact hors repassage (Jupe)`](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes/5ca66e62-356c-57ea-81e9-82951cb7f473))

### Calcul du coût environnemental

Rappel de la formule de calcul :&#x20;

$$
I_{7} = n_{cycles}*m*I_{7,horsrepassage} +E_{7}*I_{élec}
$$

Calcul pour la jupe :

$$
I_{7} = 23*0.3*15.13+2.02*19.33 = 143 Pts
$$
