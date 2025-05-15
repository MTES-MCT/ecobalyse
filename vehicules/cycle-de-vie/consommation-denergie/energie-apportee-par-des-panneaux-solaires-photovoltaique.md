# ☀️ Energie apportée par des panneaux solaires photovoltaïque

## Méthodologie de référence

Ecobalyse a construit sa méthode sur la base de la méthode détaillée dans le document suivant :

[https://eur-lex.europa.eu/legal-content/FR/TXT/PDF/?uri=CELEX:32016D1926\&qid=1694748250886](https://eur-lex.europa.eu/legal-content/FR/TXT/PDF/?uri=CELEX:32016D1926\&qid=1694748250886)

## Calcul de la quantité d'électricité maximale fournie

La quantité maximale d'électricité fournie par les panneaux solaires photovoltaïque se calcule de la façon suivante : &#x20;

$$
Epv.m=\frac{S.ir*UF.ir*η.ss}{S.ir.stc}*mP.p*cos(Φ)*SCC*\frac{24*365*100}{1000*K.an}
$$

Avec :&#x20;

* Epv : énergie apportée par le système solaire photovoltaïque, en kWh/100km]&#x20;
* S.ir : irradiation solaire annuelle moyenne en Europe, en W/m2, fixée à 120 W/m2&#x20;
* UF.ir : facteur d'usage (effet d'ombre), sans unité, fixé à 0,51&#x20;
* η.ss : rendement du système photovoltaïque, en pourcentage, fixé à 76 %&#x20;
* S.ir.stc : irradiation globale dans les conditions d'essai standard, en W/m2, qui est de 1 000 W/m2 (Norme IEC 61836-2007)
* mP.p : puissance maximale moyenne de sortie mesurée du toit solaire, en Wc (Puissance selon la norme IEC 61836-2007), définit dans la partie fabrication du système photovoltaïque ([documentation](../fabrication-des-composants/systeme-photovoltaiques.md))
* Phi l'angle d'inclinaison du système photovoltaïque par rapport à l'horizontale, en radian, calculé à partie de l'angle Phi\_d exprimé en radian, définit dans la partie fabrication du système photovoltaïque ([documentation](../fabrication-des-composants/systeme-photovoltaiques.md))
* SCC : coefficient de correction solaire tel que défini au tableau suivant. La capacité totale de stockage disponible du système de batteries ou la valeur du coefficient de correction solaire doit être fournie par le constructeur du véhicule
* D.an le kilométrage annuel du véhicule, en km/an, défini dans la partie "utilisation du véhicule"

### Définition de SCC

Le coefficient de correction solaire SCC est défini d'après la table de correspondance suivante, en fonction d'un ratio entre la capacité de stockage de la batterie et la puissance du système photovoltaïque

<table><thead><tr><th width="372">Rref, en Wh/Wp</th><th>SCC</th></tr></thead><tbody><tr><td>0</td><td>0</td></tr><tr><td>1.2</td><td>0.481</td></tr><tr><td>2.4</td><td>0.656</td></tr><tr><td>3.6</td><td>0.784</td></tr><tr><td>4.8</td><td>0.873</td></tr><tr><td>6</td><td>0.934</td></tr><tr><td>7.2</td><td>0.977</td></tr><tr><td>7.992</td><td>1</td></tr></tbody></table>

Rref est défini de la façon suivante :

$$
Rref=K_b*1000*\frac{D.an*C}{Cref*365*100}*\frac{1}{mP.p}
$$

Avec :&#x20;

* Rref : le ratio de référence, en Wh/Wp
* K\_b : la capacité de la batterie, en kWh, définie dans la partie fabrication de la batterie&#x20;
* Cref : la consommation de référence utilisée pour définir le SCC dans le document de référence identifié en haut de page, en kWh/j, fixée à 0.75 kWh/j
* D.an : le kilométrage annuel, en km/an, défini dans la partie Utilisation du véhicule
* C : la consommation du véhicule, en kWh/100km, défini dans la partie Utilisation du véhicule
* mP.p : puissance maximale moyenne de sortie mesurée du toit solaire, en Wc (Puissance selon la norme IEC 61836-2007), définit dans la partie fabrication du système photovoltaïque ([documentation](../fabrication-des-composants/systeme-photovoltaiques.md))

