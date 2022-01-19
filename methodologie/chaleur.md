---
description: Choix du procédé de chaleur en fonction du pays
---

# 🔥 Chaleur

## Procédés

Le procédé de chaleur appliqué dépend du pays dans lequel l'étape correspondante est réalisée.

| Pays       | Procédé chaleur                                                                                                                                              | UUID                                 |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------ |
| Bangladesh | Mix Vapeur (mix technologique\|mix de production, en sortie de chaudière), RSA                                                                               | 2e8de6f6-0ea1-455b-adce-ea74d307d222 |
| Chine      | Mix Vapeur (mix technologique\|mix de production, en sortie de chaudière), RSA                                                                               | 2e8de6f6-0ea1-455b-adce-ea74d307d222 |
| Espagne    | Vapeur à partir de gaz naturel (mix de technologies de combustion et d'épuration des effluents gazeux\|en sortie de chaudière\|Puissance non spécifiée), ES  | 618440a9-f4aa-65bc-21cb-ea40eee53f3d |
| France     | Mix Vapeur (mix technologique\|mix de production, en sortie de chaudière), FR                                                                                | 12fc43f2-a007-423b-a619-619d725793ea |
| Inde       | Mix Vapeur (mix technologique\|mix de production, en sortie de chaudière), RSA                                                                               | 2e8de6f6-0ea1-455b-adce-ea74d307d222 |
| Portugal   | Vapeur à partir de gaz naturel (mix de technologies de combustion et d'épuration des effluents gazeux\|en sortie de chaudière\|Puissance non spécifiée), RER | 59c4c64c-0916-868a-5dd6-a42c4c42222f |
| Tunisie    | Mix Vapeur (mix technologique\|mix de production, en sortie de chaudière), RSA                                                                               | 2e8de6f6-0ea1-455b-adce-ea74d307d222 |
| Turquie    | Mix Vapeur (mix technologique\|mix de production, en sortie de chaudière), RSA                                                                               | 2e8de6f6-0ea1-455b-adce-ea74d307d222 |

{% hint style="warning" %}
Ces choix de procédés doivent être discutés. Ils sont sélectionnés parmi les procédés proposés dans la base Impacts. Plusieurs points discutables apparaissent :&#x20;

* La Tunisie et la Turquie se voient appliquer, par défaut, un procédé de mix vapeur pensé plutôt pour les pays asiatiques (RSA).
* Pour l'Espagne et le Portugal, on est sur des procédés de vapeur produite à partir de gaz naturel. Le procédé est spécifique à l'Espagne mais Européen pour le Portugal (faute de procédé spécifique).
* Dans le cas de la France, un procédé de mix vapeur spécifique à ce pays est proposé. La France est le seul pays pour lequel un tel procédé est proposé dans la base Impacts.
{% endhint %}

## Limites

Il peut être proposé :&#x20;

* d'ajouter de nouveaux pays ;
* de proposer une source de chaleur paramétrable, en tirant profit des procédés disponibles dans la base Impacts (Gaz naturel, Fuel lourd, Fuel léger, Charbon, Bois) ;
* une analyse de sensibilité serait utile pour apprécier l'impact de ces paramétrages sur la simulation et, le cas échéant, les faire mieux ressortir dans l'outil.
