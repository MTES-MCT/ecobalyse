# Politique de sécurité

Le présent document décrit la procédure de signalement d'une vulnérabilité sur le projet [Ecobalyse](https://ecobalyse.beta.gouv.fr/) et comment nous la traitons.

## Périmètre

Cette politique couvre :

- **l’application en production** : [ecobalyse.beta.gouv.fr](https://ecobalyse.beta.gouv.fr/)
- **l’API publique** Ecobalyse
- **le code source** hébergé sur GitHub : [`MTES-MCT/ecobalyse`](https://github.com/MTES-MCT/ecobalyse) sur les branches `main` (version courante) et `stable/textile` (version règlementaire)
- **les données** du projet, notamment les fichiers d’impacts détaillés chiffrés et la gestion des secrets

Les instances de recette éphémères (ou *review apps*, par exemple `https://ecobalyse-pr42.osc-fr1.scalingo.io/`) sont considérées hors périmètre : elles sont automatiquement décommissionnées et ne doivent pas faire l’objet de tests de sécurité.

## Signaler une vulnérabilité

Merci de **ne pas** ouvrir d’issue publique, de pull request ou de message public pour signaler une faille de sécurité. Privilégiez l’un des canaux confidentiels suivants :

1. **par email** : [ecobalyse@beta.gouv.fr](mailto:ecobalyse@beta.gouv.fr)
2. **via GitHub** : en utilisant le [signalement privé de vulnérabilité](https://github.com/MTES-MCT/ecobalyse/security/advisories/new) (*Private Vulnerability Reporting*) du dépôt
3. **auprès du CERT-FR** : pour un signalement gouvernemental, vous pouvez contacter le [CERT-FR](https://www.cert.ssi.gouv.fr/), CERT gouvernemental français
4. en dernier recours, sur les plateformes de *bug bounty*, mais les trois canaux mentionnés ci-dessus sont à privilégier en première intention

Pour aider l'équipe à traiter le signalement le plus efficacement possible, merci d’inclure autant que possible :

- une description de la vulnérabilité et de son impact potentiel
- les étapes détaillées permettant de la reproduire (URL, requêtes, paramètres, compte utilisateur, etc.)
- la version, le commit ou l’environnement concerné
- toute preuve de concept, captures d’écran ou logs utiles
- toute information contextuelle nous permettant de cerner les conditions permettant la compromission du système

## Délais de réponse

Nous nous engageons à :

- **accuser réception** de votre signalement sous **72 heures** par le même canal ou à défaut par email
- vous fournir un **premier retour qualifié** (évaluation, gravité, suite envisagée) sous **7 jours ouvrés**
- vous tenir informé de l’avancement de la correction jusqu’à sa résolution

## Divulgation coordonnée

Nous appliquons une politique de **divulgation coordonnée des vulnérabilités** (ou *responsible disclosure*) :

- nous vous demandons de nous laisser un délai de **90 jours** à compter de l’accusé de réception pour corriger la vulnérabilité avant toute divulgation publique
- ce délai peut être ajusté d’un commun accord selon la complexité de la correction
- une fois le correctif déployé, nous pouvons publier une note ou un avis de sécurité, et vous serez mentionné si vous le souhaitez

## Règles de test

Lors de vos recherches de vulnérabilités, vous devez :

- rester dans le périmètre défini ci-dessus
- respecter la confidentialité, l’intégrité et la disponibilité des données et des services
- limiter vos tests au strict nécessaire pour démontrer la vulnérabilité

Sont notamment interdits :

- les attaques par déni de service (DoS/DDoS), tests de charge ou toute action dégradant la disponibilité du service en production
- l’exfiltration, la modification ou la destruction de données ne vous appartenant pas
- l’accès aux données personnelles d’autres utilisateurs au-delà de ce qui est nécessaire pour démontrer la faille
- l’ingénierie sociale, le hameçonnage ou toute attaque visant les personnes (agents, contributeurs, utilisateurs)
- les tests physiques sur les infrastructures

Ecobalyse est un projet d'intérêt général, nous comptons sur votre bienveillance et votre coopération pour assurer sa qualité.
