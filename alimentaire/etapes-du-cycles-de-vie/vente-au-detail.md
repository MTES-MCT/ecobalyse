# 🏪 Vente au détail

## Impact

L'impact de cette étape provient de :

* la consommation d'énergie du magasin.
  * électricité
  * chaleur
* la consommation d'eau du magasin
* l'émission de gaz réfrigérant (r404) (négligé pour l'instant)

## Calcul du volume

On calcule le volume du produit à partir de sa densité. Ce calcul est détaillée sur la page [Densité](../impacts-consideres/densite.md).

## Calcul de l'impact

L'impact est la multiplication du volume par les différentes consommations détaillées dans le tableau ci-dessous :

<figure><img src="../../.gitbook/assets/image (208).png" alt=""><figcaption><p>Méthodologie AGB 3.0-20200218_rapport-vf2.pdf</p></figcaption></figure>

<details>

<summary>Exemple de calcul</summary>

Pour 1 kg de produit surgelé, de densité 1 kg/L. Notons son volume V. On a V = 1 L = 0.001 m3. Calculons l'impact de la vente au détail I\_vente. Cela dépend de :

* I\_energy : l'impact de l'énergie consommé dans le magasin (éclairage,...)
* I\_cooling : l'impact du maintien au froid du produit congelé
* I\_water : l'impact de la consommation d'eau

Ces impacts se calculent à partir des impacts unitaires suivant :

* Iu\_élec : l'impact d'un kWh d'électricité
* Iu\_water : l'impact d'un m3 d'eau

et des quantités suivantes :

* Q\_energy : la quantité d'énergie consommée par notre produit au magasin (éclairage,...)
* Q\_cooling : la quantité d'énergie nécessa:ire pour conserver au froid notre produit au magasin
* Q\_water : la quantité d'eau nécessaire pour notre produit au magasin

Ces quantités se calculent à partir de :

* Qu\_energy\_frozen : la quantité d'eau nécessaire pour 1m3 de produit surgelé
* Qu\_cooling\_frozen : la quantité d'énergie nécessaire pour conserver au froid notre produit au magasin
* Qu\_water\_frozen : la quantité d'énergie consommé par notre produit au magasin (éclairage,...)

```
I_vente = I_energy + I_cooling + I_water
I_vente = Q_energy * Iu_élec + Q_cooling * Iu_élec + Q_water * Iu_water)

I_vente = V * Qu_energy_frozen * Iu_élec + V * Qu_cooling_frozen * Iu_élec
 + V * Qu_water_frozen * Iu_water

**I_vente** = V * [(Qu_energy_frozen + Qu_cooling_frozen)* Iu_élec
 + Qu_water_frozen * Iu_water]


I_vente = 0.001 * [(61.54 + 415.38)* Iu_élec
 + 280.8 * Iu_water]
```

</details>

## Pertes (à venir)
