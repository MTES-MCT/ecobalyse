# FAQ API

## Qu’est-ce que l’[API Ecobalyse](/#/api) et à quoi sert t-elle ?

L’[API](https://fr.wikipedia.org/wiki/Interface_de_programmation) Ecobalyse est une interface de communication informatique qui permet aux systèmes d’information d’interroger le moteur de calcul et d’obtenir des scores. Elle utilise le protocole [HTTP/REST](https://en.wikipedia.org/wiki/REST) et expose sa documentation au format [OpenAPI](https://en.wikipedia.org/wiki/OpenAPI_Specification).

## Comment puis-je accéder à la documentation de l’API ?

La documentation OpenAPI est accessible au format Web sur [la page dédiée à l’API](/#/api), le format de spécification JSON étant lui accessible sur le endpoint racine de l’API.

## Comment puis-je tester l’API ?

La [documentation est interactive](/#/api) et permet de paramétrer et exécuter des requêtes sur l’API depuis l’interface Web directement.

## L’utilisation de l’API nécessite t-elle une authentification ?

Oui, l’utilisation de l’API nécessite une authentification. Pour vous authentifier, créez ou accédez à votre compte Ecobalyse et générez un jeton d'API. Pour obtenir les impacts détaillés de vos simulations, veuillez accepter les conditions d’utilisation ecoinvent depuis votre compte Ecobalyse.

## Y a-t-il un quota maximum en nombre d’appels à ne pas dépasser ?

Oui, que ce soit sur l’application Web ou l’API, le nombre maximum de requêtes par minute et par IP est plafonné à 5000 (ce chiffre peut être amené à être ajusté en fonction du trafic et des abus potentiels observés). Notre objectif est de garantir une qualité de service optimale à toutes et tous.

## Vous engagez-vous sur un taux de disponibilité du service fourni par l’API ?

Non, à ce stade de l’expérimentation, nous n’offrons aucune garantie de disponilbilité ni de continuité du service (pas de SLA).

## Est-ce que l’API est versionnée ?

L’API Ecobalyse *n’est pas versionnée*, c’est à dire qu’aucune stabilité n’est garantie en fonction de chaque incrément de la méthode de calcul du coût environnemental.
Lorsqu’une méthode est prête au déploiement ou est testée à grande échelle, nous hébergeons l’application à une date donnée sur une URL dédiée afin de garantir une compatibilité et une stabilité d’interfaçage avec vos systèmes d’information. Pour accéder à l’API stable et règlementaire textile, rendez-vous sur [https://ecobalyse.beta.gouv.fr/versions/v7.0.0/](https://ecobalyse.beta.gouv.fr/versions/v7.0.0/).
Vous pouvez tout de même faire des requêtes sur l’API Ecobalyse, nous ne garantissons pas la pérennité de ses paramètres et de l’interfaçage.

## Le format de réponse d’un appel vers une version de l’API peut-il changer avec le temps ?

Oui, Ecobalyse offre une API qui reflète les évolutions de la méthode de calcul du coût environnemental. Certains paramètres peuvent être ajoutés, supprimés, modifiés en lien avec la coconstruction du coût environnemental et des retours des expérimentations. Les méthodes en fin d’expérimentation ou prêtes à être testées à grande échelle sont hébergées sur des sous-domaine d’Ecobalyse dont le format de réponse de l’API est stable.

## Peut-on se fier à une version API stable hébergée sur un sous-domaine d’Ecobalyse ?’

Oui, c’est même tout l’objectif. Et si d’aventure une version particulière devenait indisponible ou fournissait des résultats différents d’un appel à l’autre sur un même jeu de paramètres, c’est un bug qu’il conviendra de nous signaler.
La version stable et règlementaire de l’API textile est disponible sur [https://ecobalyse.beta.gouv.fr/versions/v7.0.0/](https://ecobalyse.beta.gouv.fr/versions/v7.0.0/).

## Comment puis-je remonter un bug ou obtenir du support technique sur l’API ?

Le plus simple est de nous contacter à ce sujet sur [la plateforme d’échange Ecobalyse](https://fabrique-numerique.gitbook.io/ecobalyse/communaute).

## Les données que je mobilise pour effectuer mes calculs sur l’API sont confidentielles, quelles garanties me sont offertes sur leur protection ?

Nous ne stockons ni les paramètres passés ni les résultats fournis par l’API dans aucune base de données : le risque de fuite est inexistant. De plus, le protocole de communication avec l’API est chiffré (HTTPS) et limite quasi totalement le risque d’interception du trafic par un tiers malintentionné.

Si vous souhaitez contrôler totalement l’environnement d’exécution du serveur d’API et le projet étant [open source](https://github.com/MTES-MCT/ecobalyse), vous pouvez opter pour l’auto-hébergement du service sur votre propre infrastructure. N’hésitez pas à [prendre contact avec la communauté](https://fabrique-numerique.gitbook.io/ecobalyse/communaute) pour être aiguillé et accompagné dans cette démarche.
