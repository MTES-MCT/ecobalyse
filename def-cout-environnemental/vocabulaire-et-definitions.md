---
hidden: true
---

# EN PROGRESSION Vocabulaire et définitions

{% hint style="warning" %}
Page masquée : à nettoyer avant publication (redondances dans la page)
{% endhint %}

## Paramètres et données

Les termes de paramètres et de données peuvent être utilisés :

* pour décrire une <mark style="color:green;">**méthode de calcul**</mark> qui est mobilisable pour différents produits
* pour décrire <mark style="color:red;">**un produit précis**</mark> (une référence de produit)

<table><thead><tr><th>Nom usuel ACV</th><th></th><th>Nom réglementaire</th><th width="187">Exemple ou explicitation</th><th></th></tr></thead><tbody><tr><td><strong>Données spécifiques</strong><br>Cela correspond aux données descriptives propre au produit évalué; maitrisées par le fabricant/vendeur qui réalise l'évaluation ...</td><td>Paramètres de références ?</td><td>Données spécifiques à la référence de produit<br><a href="https://www.legifrance.gouv.fr/jorf/article_jo/JORFARTI000052213054">arrêté du 6 sept - art.2</a></td><td><mark style="color:red;">Un Tshirt est composé de <strong>coton biologique</strong>. Il est tricoté en <strong>France</strong>, teint en <strong>France</strong> et confectionné en <strong>France,</strong> consomme <strong>3.18 kWh</strong> de chaleur à la teinture</mark></td><td></td></tr><tr><td><strong>Données secondaires</strong> (ie. choix fait par la méthodologie en l'absence de donnée primaire)</td><td></td><td>Valeur par défaut<br><a href="https://www.legifrance.gouv.fr/jorf/article_jo/JORFARTI000052213054">arrêté du 6 sept - art.2</a></td><td><mark style="color:red;">Il n'est pas précisé le pays d'origine du coton</mark> ⇒ <mark style="color:green;">par défaut, c'est <strong>l'Asie</strong></mark>.<br><mark style="color:red;">Il n'est pas précisé le pays de filature</mark> ⇒ <mark style="color:green;">par défaut, c'est <strong>XXX</strong></mark></td><td></td></tr><tr><td><strong>Données génériques</strong><br>Ce sont les ICV/IACV représentatifs des pratiques standards à un secteur, par opposition à des pratiques spécifiques à une entreprise ou une ferme (ex: coton utilisant X g d'engrais, Y L d'eau etc.)</td><td></td><td></td><td>L'inventaire de cycle de vie du coton représente l'impact environnemental "moyen" de la production du coton sur la planète</td><td></td></tr><tr><td>Les 17 paramètres se répartissent entre des données spécifiques ( = paramètres obligatoires) et des données semi-spécifiques (=paramètres optionnels)</td><td></td><td>Paramètre de référence<br><a href="https://www.legifrance.gouv.fr/jorf/article_jo/JORFARTI000052213059">arrêté du 6 sept - art. 7</a></td><td>La méthode de calcul permet de modéliser le coût environnemental d'un vêtement qui peut être décrit à travers 17 paramètres, 6 obligatoires et 11 optionnels.</td><td></td></tr><tr><td>Possibilité de remplacer dans les modélisations des données génériques (ex : coton moyen mondial) par des données plus spécifiques (et moins de données génériques)</td><td></td><td>Paramètre complémentaire aux paramètres de référence<br><a href="https://www.consultations-publiques.developpement-durable.gouv.fr/IMG/docx/2024-11-28_arrete-affichage-env_vpourconsultation.docx">projet d'arrêté mis en consultation fin 2024 - art.8</a></td><td>A l'avenir, il sera proposé un niveau plus précis de modélisation qui permettra de mobiliser de nouveaux paramètres, par exemple le taux de perte en confection.</td><td></td></tr><tr><td><strong>Données secondaires</strong> (ie. choix fait par la méthodologie en l'absence de donnée primaire)</td><td></td><td>Pas de nom réglementaire. Il s'agit là d'un <mark style="color:green;"><strong>choix de modélisation interne à la méthode de calcul</strong></mark>.</td><td>Lorsque la durabilité est inférieure à 1, il est considéré par défaut que <strong>100%</strong> du trajet depuis la confection hors Europe est réalisée par avion.<br>Lorsque la teinture est réalisée en France, il est considéré un taux de pollution aquatique de <strong>XX%</strong>.</td><td></td></tr></tbody></table>

Les données primaires peuvent concerner des informations de nature différente :

* des champs textuels ⇒ La confection est faite en **France**
* des nombres ⇒ Le taux de transport en avion est de **85%**
* des inventaires de cycle de vie complets, avec les 16 catégories d'impacts... ⇒ Le coton précis que je mobilise est un coton spécifique qui a fait l'objet d'une inventaire spécifique

| Calcul 👇\ Données prim. 👉 | Champs textuels et nombres                                    | Inventaires de cycle de vie                  |
| --------------------------- | ------------------------------------------------------------- | -------------------------------------------- |
| Niveau 1                    | Données mobilisables sur les seuls paramètres de référence    | Pas de mobilisation d'ICV spécifiques        |
| Niveau 2                    | Données mobilisables aussi sur des paramètres complémentaires | Pas de mobilisation d'ICV spécifiques        |
| Niveau 3                    |                                                               | Possibilité de mobiliser des ICV spécifiques |

Proposition de schéma. Les termes "données" et "paramètres" sont positionnés par rapport au cadre réglementaire mais il faut mieux y positionner les termes ACV : données primaires, données secondaires, données spécifiques / semi-spécifiques...

<figure><img src="../.gitbook/assets/vocabulaire modélisation.jpg" alt=""><figcaption></figcaption></figure>

<table><thead><tr><th width="140">Terme</th><th width="404">Définition</th><th width="196">Illustration</th></tr></thead><tbody><tr><td>Données primaires ou spécifiques</td><td>Données renseignées par l'utilisateur et spécifiques à un produit. Ces données sont souvent issues d'un usine, d'un fournisseur, etc.</td><td>Poids d'un vêtement (kg)</td></tr><tr><td>Données secondaires</td><td>Données par défaut non modifiables par l'utilisateur (souvent une "moyenne"). Ces données sont souvent issues de bases de données génériques (ex : Agribalyse, Ecoinvent, etc.) et de la littérature scientifique. Ces données sont utilisées quand on a pas accès à des données réelles ou quand ces paramètres ne sont pas significatifs en terme d'impact.</td><td>Efficacité du centre de traitement des eaux usées (%)</td></tr><tr><td>Données semi-spécifiques</td><td>Données par défaut (souvent une "moyenne") modifiables par l'utilisateur. Ce sont souvent des données secondaires personnalisées.</td><td>Pertes en confection (%)</td></tr></tbody></table>

## Méthode de calcul

<table><thead><tr><th width="163">Terme</th><th width="460">Définition</th></tr></thead><tbody><tr><td>ACV (Analyse de cycle de vie)</td><td>Méthode normalisée (ISO 14040/44) qui permet d'évaluer les impacts environnementaux d'un produit, service ou système sur l'ensemble de sa vie.</td></tr><tr><td>Unité Fonctionnelle (UF)</td><td><p>Unité de mesure utilisée pour le coût environnemental.</p><p>On ne compare pas "un t-shirt" mais "la capacité du vêtement à être porté 45 jours.</p></td></tr><tr><td>Flux (entrants et sortants)</td><td><p><em>Entrants</em> : ressources prélevées dans la nature (énergie, matières premières, eau).</p><p><em>Sortants</em> : ce qui est rejeté dans l'environnement (émissions de CO2, déchets, rejets toxiques).</p></td></tr><tr><td>Coût environnemental</td><td>Le coût environnemental est le résultat du calcul d'impacts utilisé par le dispositif français d'affichage environnemental. Il s'appuie sur le socle européen <a href="https://green-forum.ec.europa.eu/green-business/environmental-footprint-methods_en">PEF</a> (Product Environmental Footprint) pour l'Analyse de Cycle de Vie (ACV), auxquels s'ajoutent des corrections ou des compléments relatifs aux dimensions aujourd'hui mal couvertes par l'ACV.</td></tr></tbody></table>

## Cadre règlementaire

<table><thead><tr><th width="106.33331298828125">Terme</th><th>Définition</th></tr></thead><tbody><tr><td>Paramètre de calcul</td><td>Données spécifiques, semi-spécifiques ou secondaires. La notion de paramètre regroupe les 3 types de données mobilisées dans le calcul du coût environnemental d'un produit.</td></tr><tr><td>Niveau 1</td><td></td></tr><tr><td>Niveau 2</td><td></td></tr></tbody></table>
