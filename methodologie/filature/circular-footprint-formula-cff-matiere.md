# Circular Footprint Formula (CFF) - Matière

En application de la méthodologie PEF, et plus particulièrement du projet de PEFCR Apparel & Footwear (A\&F), la CFF est prise en compte pour modéliser l'intégration de matériaux recyclés (ie. cette section) et la fin de vie (**lien à ajouter**).

Pour les matières premières, la formule à considérer est :

![PEFCR A\&F - v1.2 - ligne 1056](<../../.gitbook/assets/image (1).png>)

## Utilisation de matière recyclé - M1 et M2

On s'intéresse dans un premier temps aux 2 premiers termes de cette formule : M1 et M2

$$
(1-R1)Ev + R1(AErec + (1-A)EvQsin/Qp)
$$

### Définition des paramètres

* **R1** -  Proportion de matière recyclée en sortie de l'étape "matière". Ce nombre a déjà été introduit dans la section [Intégration d'une part de matière](circular-footprint-formula-cff-matiere.md#integration-dune-part-de-matiere-recyclee) recyclée ci-dessus.
* **Ev** - Impacts (émissions et ressources consommées) correspondant à la matière primaire vierge, non recyclée, mobilisée.
* **Erec** - Impacts (émissions et ressources consommées) correspondant à la matière recyclée utilisée mobilisée.

{% hint style="danger" %}
Les impacts Ev et Erec sont considérés pour les étapes de "Matière" et de "Filature" considérées ensemble. En toute rigueur, la formule devrait seulement s'appliquer à l'étape "Matière", ce qui pourra être fait lorsque les étapes de "Matière" et de "Filature" seront séparées.&#x20;

L'impact sur le résultat reste limité. Il est même nul lorsque Qsin/Qp = 1.
{% endhint %}

* **A** - Coefficient l'allocation des impacts et crédits entre le fournisseur et l'utilisateur de matériaux recyclés.

{% hint style="info" %}
Cas limites. Tous les impacts liés au recyclage de la matière recyclée utilisée sont imputés

* A = 1 ->  A son utilisateurs, donc à l'étape "matière" de la modélisation qui implique une part R1 de matière recyclée. Impact : **R1\*A\*Erec**
* A = 0 -> A son fournisseur, donc à l'étape "fin de vie" de la modélisation de tous les produits qui utilisent de la matière dont le recyclage va permettre la production de la part R1 de matière recyclée dans la présente modélisation. Un système de compensation conduit toutefois à introduire l'impact de la matière primaire qui n'a pas réellement été consommée dans le cas présent mais qui devra l'être dans d'autres produits vu que la matière recyclée n'est plus disponible. Impact : **R1\*(1-A)\*Ev\*Qsin/Qp**.
{% endhint %}

* **Qsin/Qp** - Rapport entre la qualité de la matière recyclée utilisée et la qualité de la matière primaire correspondante, avant recyclage donc.

{% hint style="info" %}
Cas limites :&#x20;

* Qsin/Qp = 1 -> La matière recyclée et la matière primaire ont la même qualité.
* Qsin/Qp < 1 -> La matière recyclée est de moins bonne qualité que la matière primaire. Utiliser de la matière recyclée nécessite un effort supplémentaire (ou une dégradation de la qualité), ce qui justifie une diminution de l'impact imputé.&#x20;
{% endhint %}

### Valeurs des paramètres CFF

* **R1**
  * Pour les matières de la liste principales, R1 est la position du curseur "part d'origine recyclée"
  * Pour les autres matières de la liste complète, R1=0% pour les matières primaires, R1=100% pour les matières recyclées.
* **Ev** et **Erec** correspondent aux impacts des matières primaires et recyclées tel qu'issues de la base Impacts.

$$
ImpactProcédéMFPrimaire = (1-R1) Ev
$$

$$
ImpactProcédéMFRecyclée =  R1*Erec
$$

* **A** et **Qsin/Qp** sont établis, pour chaque matière, conformément au projet de PEFCR A\&F (v1.2, table 21, ligne 1181).

| Matière recyclée                                         | A                                                                  | Qsin / Qp                                   |
| -------------------------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------- |
| Polyester issu de PET recyclé                            | <p>0,5<br>Impact partagé entre le fournisseur et l'utilisateur</p> | <p>1<br>Pas de perte de qualité</p>         |
| Polyester issu de bouteilles PET                         | <p>0,5<br>Impact partagé entre le fournisseur et l'utilisateur</p> | <p>0,7<br>Perte de qualité au recyclage</p> |
| Fibres synthétiques issues de produits textiles recyclés | <p>0,8<br>Impact majoritairement porté par l'utilisateur</p>       | <p>1<br>Pas de perte de qualité</p>         |
| Fibres naturelles\* issues de produits textiles recyclés | <p>0,8<br>Impact majoritairement porté par l'utilisateur</p>       | <p>0,5<br>Perte de qualité au recyclage</p> |

{% hint style="warning" %}
\*Le projet de PEFCR A\&F mentionne la "production of cellulosic virgin fibres" pour Ev. Par extension, il est considéré que cela couvre toutes les fibres naturelles.
{% endhint %}

L'application de ce tableau aux différentes matières présentées dans le simulateur sera bientôt visible dans la [rubrique "Produits" de l'explorateur](https://wikicarbone.beta.gouv.fr/#/explore/products).

#### Exemple de calcul

Pour un vêtement de masse m de composition 60% coton, 40% coton recyclé (post consommation)

```
Impact_matière = Impact_coton + Impact_coton_recyclé

Impact_coton =  0.6 * m * Impact_coton_par_kg

Impact_coton_recyclé = 0.4 * m ( A * Impact_coton_recyclé_par_kg + (1-A) * Qsin/Qp * Impact_coton_par_kg)

```

Pour un vêtement de masse m de composition 40% coton, 30% coton recyclé (post consommation),  20% polyester, 10% polyester recyclé.

```
Impact_matière = Impact_coton + Impact_coton_recyclé + Impact_polyester + Impact_polyester_recyclé

Impact_coton =  0.4 * m * Impact_coton_par_kg

Impact_coton_recyclé = 0.3 * m ( A * Impact_coton_recyclé_par_kg + (1-A) * Qsin/Qp * Impact_coton_par_kg)

Impact_polyester = 0.2 * m * Impact_pet_par_kg

Impact_polyester_recyclé = 0.1 * m ( A * Impact_pet_recyclé_par_kg + (1-A) * Qsin/Qp * Impact_pet_par_kg)
```

## Recyclage des vêtements en fin de vie - M3



Voici la partie de la CFF qui prend en compte l'impact du recyclage en fin de vie.

$$
M_{3} = (1-A)*R_{2}*(E_{recyEOL} - E^*_{v} * \frac{Qsout}{Qp})
$$

{% hint style="info" %}
Ce terme est négligé étant donné son impact faible. Pour plus de justification dans la section suivante
{% endhint %}

### Définition des paramètres

* **R2** - le taux de matière recyclé en fin de vie
* **ErecyEOL** - impacts dues au recyclage en fin de vie : la collecte, le tri et le processus de recyclage
* **E\*v** - impacts dues à la production de matière vierge substitué par le recyclage.&#x20;
* **Qsout/Qp** - Rapport de qualité entre la matière substitué (Qp) et la matière recyclé substituan (Qsout)

### Filières de recyclage

Il est possible qu'un produit ait plusieurs filières de recyclage. Dans ce cas il faut appliquer le terme M3 pour chaque filière de recyclage.

![PEFCR A\&F - v1.2 - ligne 1131](<../../.gitbook/assets/Screenshot 2022-03-16 at 16.27.52.png>)

3 filières de recyclage sont identifiés pour les vêtements dans le PEFCR A\&F :

* Vêtement -> Vêtement
* Vêtement -> Wiper
* Vêtement -> Insulation

![PEFCR A\&F - v1.2 - Filières de recyclage des vêtements](<../../.gitbook/assets/Screenshot 2022-03-16 at 17.09.18.png>)

On remarque que les seules filières avec un taux de recyclage non nuls sont la filière Wiper et Insulation.

#### Filière Wiper

Estimons l'impact de la prise en compte du recyclage sur la filière Wiper pour un vêtement d'1kg de coton primaire.

L'impact estimé de l'étape de matière et filature hors CFF est de `1.82 mPt` PEF.

Estimons l'impact du terme M3 de la CFF.&#x20;

On fait les hypothèses suivantes :&#x20;

Le coton recyclé remplace du coton primaire pour le wiper&#x20;

```
M3_wiper = (1-A) * R2  * ( Erecy_wiper - E*v * Qout/Qp)
M3_wiper = (1-0.8) * 5% * ( 0.44 - 1.82 * 0.3)
M3_wiper = - 0.001 mPt
```

Ainsi le terme M3\_wiper réduit l'impact 0.001 mPt soit de 0.05%.&#x20;

Etant donné cet impact négligeable, on ne prend pas en compte la filière de reyclage en wiper dans le calcul de l'impact matière des vêtements.

#### Filière Isolant

Faute de données sur l'impact de la production de laine de verre, on ne prend pas en compte cette filière de recyclage.







