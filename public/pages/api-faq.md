# FAQ API

## Qu'est-ce que l'[API Ecobalyse](/#/api) et à quoi sert t-elle ?

L'[API](https://fr.wikipedia.org/wiki/Interface_de_programmation) Ecobalyse est une interface de communication informatique qui permet aux systèmes d'information d'interroger le moteur de calcul et d'obtenir des scores. Elle utilise le protocole [HTTP/REST](https://en.wikipedia.org/wiki/REST) et expose sa documentation au format [OpenAPI](https://en.wikipedia.org/wiki/OpenAPI_Specification).

## Comment puis-je accéder à la documentation de l'API ?

La documentation OpenAPI est accessible au format Web sur [la page dédiée à l'API](/#/api), le format de spécification JSON étant lui accessible sur le endpoint racine de l'API.

## Comment puis-je tester l'API ?

La [documentation est interactive](https://ecobalyse.beta.gouv.fr/versions/v7.0.0/#/api) et permet de paramétrer et exécuter des requêtes sur l'API depuis l'interface Web directement.

## L'utilisation de l'API nécessite t-elle une authentification ?

Non, l'API fonctionne sans authentification et fournit alors uniquement des scores agrégés (coût environnemental et score PEF). Pour obtenir les impacts détaillés (climat, consommation d'eau, etc), vous devez [créer un compte](https://ecobalyse.beta.gouv.fr/#/auth/) et utiliser le jeton d'API qui vous sera attribué.

## Y a-t-il un quota maximum en nombre d'appels à ne pas dépasser ?

Oui, que ce soit sur l'application Web ou l'API, le nombre maximum de requêtes par minute et par IP est plafonné à 5000 (ce chiffre peut être amené à être ajusté en fonction du trafic et des abus potentiels observés). Notre objectif est de garantir une qualité de service optimale à toutes et tous.

## Vous engagez-vous sur un taux de disponibilité du service fourni par l'API ?

Non, à ce stade de l'expérimentation, nous n'offrons aucune garantie de disponilbilité ni de continuité du service (pas de SLA).

## Quelle est la différence avec l'API disponible sur Ecobalyse ?

L'API disponible sur Ecobalyse v7 textile est figée dans le temps et dépend de la méthode de calcul validée par la règlementation. L'API sur Ecobalyse n'est pas figée et suit les évolutions de la méthode de calcul pour d'autres usages ou en préparation d'une évolution règlementaire.

## Le format de réponse d'un appel vers l'API peut-il changer ?

Non, le format des paramètres d'entrée et de réponse ne varient pas sur la version stable. Les bugs découverts sur cette API peuvent être corrigés si elles n'impliquent pas de changement de score ou de modification du format des paramètres d'entrée.

## Comment puis-je remonter un bug ou obtenir du support technique sur l'API ?

Le plus simple est de nous contacter à ce sujet sur [la plateforme d'échange Ecobalyse](https://fabrique-numerique.gitbook.io/ecobalyse/communaute).

## Les données que je mobilise pour effectuer mes calculs sur l'API sont confidentielles, quelles garanties me sont offertes sur leur protection ?

Nous ne stockons ni les paramètres passés ni les résultats fournis par l'API dans aucune base de données : le risque de fuite est inexistant. De plus, le protocole de communication avec l'API est chiffré (HTTPS) et limite quasi totalement le risque d'interception du trafic par un tiers malintentionné.

Si vous souhaitez contrôler totalement l'environnement d'exécution du serveur d'API et le projet étant [open source](https://github.com/MTES-MCT/ecobalyse), vous pouvez opter pour l'auto-hébergement du service sur votre propre infrastructure. N'hésitez pas à [prendre contact avec la communauté](https://fabrique-numerique.gitbook.io/ecobalyse/communaute) pour être aiguillé et accompagné dans cette démarche.
