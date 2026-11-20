---
hidden: true
---

# Outils et pipeline data

Pour faire fonctionner le calculateur, l’équipe Ecobalyse s’appuie sur plusieurs outils. Ils servent à intégrer les bases de données ACV sources, à assurer les mises à jour et la traçabilité, et à produire certaines données manquantes. L'équipe privilégie les outils open-source/open data, dans une logique de contribution et de collaboration avec autres acteurs engagés dans cette dynamique (ex: [Départ de Sentier](https://www.d-d-s.ch/)).&#x20;

La chaîne de traitement est la suivante :

1. Ecobalyse part des inventaires (ICV) des bases sources, principalement BAFU et Agribalyse.
2. Elle complète ces bases par quelques inventaires générés par l'équipe (Ecobalyse\_custom\_lci; ex ingrédient « poulet importé » ) ou transmis par des tiers (ex : Laine woolmark) .
3. Elle adapte la structure des données pour isoler certains paramètres clés, comme les taux de perte, les quantités d'électricité consommées etc.
4. Elle calcule les impacts (LCIA) des procédés.



Outils utilisés :

[Volca](https://www.volca.run/):  travaux d'analyse préparatoires, appui aux réflexions méthodologiques et explorations des données ACV existantes + vérification des résultats finaux

* Explorations sur les données ACV, analyse des valeurs en amont de l'intégration dans ecobalyse etc.
* Transfère des données d'arrière plan depuis ecoinvent vers BAFU. Comparaison et analyse des résultats.&#x20;
* Recalcul des impacts pour contrôler la cohérence avec Brightway. Historiquement, ce contrôle se faisait avec SimaPro.

[SimaPro ](https://simapro.com/): import des ICV sources

* Export au format CSV. Historiquement, ce choix garantit une structure homogène entre les bases.
* Une migration est en cours vers un import direct des bases dans leur format natif (par exemple ecospold pour BAFU 2026). Notre souhait est de pouvoir basculer vers des outils 100% open data/open code prochainement.&#x20;

[Brightway](https://www.google.com/url?sa=t\&source=web\&rct=j\&opi=89978449\&url=https://brightway.dev/\&ved=2ahUKEwi9z9vhj5SYAxVSgP0HHTaWPH4QFnoECCgQAQ\&usg=AOvVaw1Plwsk35dLTynmW226-IMQ): construction des inventaires, gestion de la structure des données et calcul des impacts LCIA

* Construction des inventaires Ecobalyse\_custom\_lci, documentés dans le dépôt Ecobalyse.
* Calcul des impacts à partir des bases sources et des inventaires spécifiques.
* Implémentation des la méthode de caractérisation (EF 3.1 adaptée, version 1.03 issue de SimaPro)





