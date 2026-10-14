---
description: >-
  Comment calculer l'impact matière en prenant en compte les termes M1 et M2 de
  la CFF ?
---

# Utilisation de matière recyclée - M1 et M2

On s'intéresse dans un premier temps aux deux premiers termes de cette formule : M1 et M2

$$
(1-R1)Ev + R1(AErec + (1-A)EvQsin/Qp)
$$

### Définition des paramètres

* **R1** - Proportion de matière recyclée en sortie de l'étape "matière". Ce nombre a déjà été introduit dans la section [Intégration d'une part de matière](circular-footprint-formula-cff-matiere.md#integration-dune-part-de-matiere-recyclee) recyclée ci-dessus.
* **Ev** - Impacts (émissions et ressources consommées) correspondant à la matière primaire vierge, non recyclée, mobilisée.
* **Erec** - Impacts (émissions et ressources consommées) correspondant à la matière recyclée utilisée mobilisée.

{% hint style="danger" %}
Les impacts Ev et Erec pour les étapes de "Matière" et de "Filature" sont considérés ensemble. En toute rigueur, la formule devrait seulement s'appliquer à l'étape "Matière", ce qui pourra être fait lorsque les étapes de "Matière" et de "Filature" seront séparées.

L'impact sur le résultat reste limité. Il est même nul lorsque Qsin/Qp = 1.
{% endhint %}

* **A** - Coefficient d'allocation des impacts et crédits entre le fournisseur et l'utilisateur de matériaux recyclés.

{% hint style="info" %}
Cas limites. Tous les impacts liés au recyclage de la matière recyclée utilisée sont imputés

* A = 1 -> À son utilisateur, donc à l'étape "matière" de la modélisation qui implique une part R1 de matière recyclée. Impact : **R1\*A\*Erec**
* A = 0 -> À son fournisseur, donc à l'étape "fin de vie" de la modélisation de tous les produits qui utilisent de la matière dont le recyclage va permettre la production de la part R1 de matière recyclée dans la présente modélisation. Un système de compensation conduit toutefois à introduire l'impact de la matière primaire qui n'a pas réellement été consommée dans le cas présent mais qui devra l'être dans d'autres produits vu que la matière recyclée n'est plus disponible. Impact : **R1\*(1-A)\*Ev\*Qsin/Qp**.
{% endhint %}

* **Qsin/Qp** - Rapport entre la qualité de la matière recyclée utilisée et la qualité de la matière primaire correspondante avant recyclage.

{% hint style="info" %}
Cas limites :

* Qsin/Qp = 1 -> La matière recyclée et la matière primaire ont la même qualité.
* Qsin/Qp < 1 -> La matière recyclée est de moins bonne qualité que la matière primaire. Utiliser de la matière recyclée nécessite un effort supplémentaire (ou une dégradation de la qualité), ce qui justifie une diminution de l'impact imputé.
{% endhint %}

### Valeurs des paramètres CFF

* **R1**
  * Pour les matières de la liste principale, R1 est la position du curseur "part d'origine recyclée"
  * Pour les autres matières de la liste complète, R1=0% pour les matières primaires, R1=100% pour les matières recyclées.
* **Ev** et **Erec** correspondent aux impacts des matières primaires et recyclées telles qu'issues de la base Impacts.

$$
ImpactProcédéMFPrimaire = (1-R1) Ev
$$

$$
ImpactProcédéMFRecyclée = R1*Erec
$$

* **A** et **Qsin/Qp** sont établis, pour chaque matière, conformément au projet de PEFCR A\&F (v1.2, table 21, ligne 1181).

| Matière recyclée                                         | A                                                                  | Qsin / Qp                                   |
| -------------------------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------- |
| Polyester issu de PET recyclé                            | <p>0,5<br>Impact partagé entre le fournisseur et l'utilisateur</p> | <p>1<br>Pas de perte de qualité</p>         |
| Polyester issu de bouteilles PET                         | <p>0,5<br>Impact partagé entre le fournisseur et l'utilisateur</p> | <p>0,7<br>Perte de qualité au recyclage</p> |
| Fibres synthétiques issues de produits textiles recyclés | <p>0,8<br>Impact majoritairement porté par l'utilisateur</p>       | <p>1<br>Pas de perte de qualité</p>         |
| Fibres naturelles\* issues de produits textiles recyclés | <p>0,8<br>Impact majoritairement porté par l'utilisateur</p>       | <p>0,5<br>Perte de qualité au recyclage</p> |

{% hint style="warning" %}
\*Le PEFCR A\&F mentionne la "production of cellulosic virgin fibres" pour Ev. Par extension, il est considéré que cela couvre toutes les fibres naturelles.
{% endhint %}

L'application de ce tableau aux différentes matières présentées dans le simulateur sera bientôt visible dans [la rubrique "Produits" de l'explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile/products).

### Exemples de calcul

* Pour un T-shirt de masse m = 0.17 kg de composition 100% laine recyclée

```
On applique la CFF :
Impact_matière = m * ( A * Impact_laine_recyclé + (1-A)*Qsin/Qp*Impact_laine_vierge))

On a R1 = 100%, A = 0.8, Qsin/Qp = 0.5, m = 0.207 kg (la masse est plus importante à cette étape car il y a des pertes) 
Sur le changement climatique on a avec les données de la base impacts : 
Impact_laine_recyclé = 0.5 kgCO2e/kg_laine_recyclé
Impact_laine_vierge = 80.3 kgCO2e/kg_laine_vierge

Donc 
Impact_matière = 0.207 * [0.8*0.5 + (1-0.8)*0.5*80.3]
Impact_matière = 1.75 kgCO2e
```

* Pour un vêtement de masse m de composition 60% coton, 40% coton recyclé (post consommation)

```
Il faut d'abord calculer m', la masse de fil nécessaire pour faire un tshirt de masse m 
m' > m car il y a des pertes lors de la fabrication


Impact_matière_filature = Impact_coton + Impact_coton_recyclé

Impact_coton =  0.6 * m'  * Impact_fil_coton_par_kg

Impact_coton_recyclé = 0.4 * m' ( A * Impact_fil_coton_recyclé_par_kg + (1-A) * Qsin/Qp * Impact_fil_coton_par_kg)
```

* Pour un vêtement de masse m de composition 40% coton, 30% coton recyclé (post consommation), 20% polyester, 10% polyester recyclé.

```
Il faut d'abord calculer m', la masse de fil nécessaire pour faire un tshirt de masse m 
m' > m car il y a des pertes lors de la fabrication

Impact_matière = Impact_coton + Impact_coton_recyclé + Impact_polyester + Impact_polyester_recyclé

Impact_coton =  0.4 * m' * Impact_fil_coton_par_kg

Impact_coton_recyclé = 0.3 * m' ( A * Impact_fil_coton_recyclé_par_kg + (1-A) * Qsin/Qp * Impact_fil_coton_par_kg)

Impact_polyester = 0.2 * m' * Impact_fil_pet_par_kg

Impact_polyester_recyclé = 0.1 * m' ( A * Impact_fil_pet_recyclé_par_kg + (1-A) * Qsin/Qp * Impact_fil_pet_par_kg
```
