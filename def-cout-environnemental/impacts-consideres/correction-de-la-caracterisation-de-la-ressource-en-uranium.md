# Correction de la caractérisation de la ressource en Uranium

## Contexte

### Méthodes de caractérisation de la ressource en Uranium

Le choix de la méthode de caractérisation de la ressource en Uranium représente un enjeu significatif dans le contexte français, où le nucléaire est la source d'énergie majoritaire dans la production d'électricité.

Il existe deux façons de caractériser la ressource en Uranium :

* Comme ressource énergétique, au même titre que les énergies fossiles. C'est la méthode retenue par les méthodes IMPACT World+ v2.1, Ecological Scarcity 2021, Crustal scarcity Indicator 2020 et Cumulative Exergy Demand ;
* Comme ressource minérale, c'est le choix fait dans le cadre des méthodes CML v.4.8, EPS 2020d et ReCiPe 2016 v3.01 ;
* GLAM 3 ne semble pas adresser spécifiquement la catégorie d'impact "épuisement des ressources énergétiques" mais fait plutôt le choix de se concentrer sur les ressources biotiques et abiotiques.&#x20;

Lorsque l'Uranium est caractérisé comme ressource énergétique, il en ressort un impact en score unique bien plus élevé pour l'électricité d'origine nucléaire, en comparaison de l'électricité produite à partir d'autres sources d'énergies.

Le cas de l'EF 3.1 est assez spécifique. L'EF 3.1 utilise l'indicateur Abiotic resource depletion – fossil fuels (ADP-fossil), de la méthode CML v.4.8 (issue de van Oers et al., 2002), mais en modifiant cette méthode pour caractériser l'Uranium de la même manière que les ressources énergétiques fossiles. Ainsi, l'uranium n'est pas caractérisé en tant qu'élément (1.40E-3kg-eSq/kgU dans la méthode CML 4.8), mais comme énergie (560 000 MJ / kg d'uranium naturel). Voir ressources en bas de page pour plus de détails.

De plus, parmi les méthodes où l'Uranium est caractérisé comme ressource énergétique, la méthode EF3.1 est la plus défavorable à cette ressource.

_Ressources :_&#x20;

* _JCR Technical reports, Supporting information to the characterisation factors of recommended EF Life Cycle Impact Assessment method, 4.10 Resource use, p24 :_ [_https://eplca.jrc.ec.europa.eu/permalink/supporting\_Information\_final.pdf_](https://eplca.jrc.ec.europa.eu/permalink/supporting_Information_final.pdf)
* _Page de Universität Leiden sur les facteurs de caractérisation CML :_ [_https://www.universiteitleiden.nl/en/research/research-output/science/cml-ia-characterisation-factors_](https://www.universiteitleiden.nl/en/research/research-output/science/cml-ia-characterisation-factors)
* _Article présentant les méthodes d'évaluation de la raréfaction des ressources en Analyse de Cycle de vie :_ [_https://www.researchgate.net/publication/256484853\_Assessing\_resource\_depletion\_in\_LCA\_A\_review\_of\_methods\_and\_methodological\_issues_](https://www.researchgate.net/publication/256484853_Assessing_resource_depletion_in_LCA_A_review_of_methods_and_methodological_issues)

### Analyse et choix Ecobalyse

Le choix de caractériser l'Uranium comme une ressource fossile tend donc à défavoriser fortement le nucléaire.&#x20;

L'indicateur EF Fossil Ressource Use (FRU) raisonne sur la base de l’énergie primaire "fossile" totale disponible (somme du pétrole, charbon, gaz, nucléaire) et indique le prélèvement réalisé par chaque opération (ex: production d’électricité, usage de carburant etc.).&#x20;

Ceci implique plusieurs hypothèses sous-jacentes fortes : toutes les énergies sont substituables (pour l’électricité, le chauffage, le carburant etc.), le prélèvement énergétique est "définitif" (c'est raisonnablement le cas lors de la combustion d'essence ou de gaz).

Ce raisonnement est discutable pour l’énergie nucléaire en particulier :  il semble peut réaliste d'utiliser le combustible nucléaire pour du chauffage en direct; la nature de cette énergie fait qu'il est nécessaire de passer par le vecteur "électricité" pour la rendre utilisable par l'homme. Aussi contrairement aux sources d'énergies fossiles, le recyclage des combustibles nucléaires est envisageable, et les technologies de production voient leur efficacité s'améliorer.&#x20;

Les tests montrent qu'au final le FRU, contrairement à ce que son nom laisse penser,  reflète avant tout "l'efficacité" de conversion entre les ressources fossiles et l'usage, et non pas la rareté et la pression sur la ressource.  Ceci est frappant quand on met en parallèle le graphique ci-dessous et les scénarios présentant la tension actuelle sur les ressources.

<figure><img src="../../.gitbook/assets/image (346).png" alt=""><figcaption><p>Impact "Fossil Ressource Use" (en MJ) de l'électricité opur plusieurs zones géographiques et moyens de production</p></figcaption></figure>

<figure><img src="../../.gitbook/assets/image (345).png" alt=""><figcaption><p><a href="https://fr.wikipedia.org/wiki/Ressources_et_consommation_%C3%A9nerg%C3%A9tiques_mondiales">https://fr.wikipedia.org/wiki/Ressources_et_consommation_%C3%A9nerg%C3%A9tiques_mondiales</a></p></figcaption></figure>

L'uranium a le FRU le plus élevé, alors que c'est bien le pétrole et le gaz qui sont les ressources les plus critiques actuellement.&#x20;

Pour ces différentes raisons, il apparait pertinent de corriger la caractérisation du FRU de l'Uranium. En l'absence d'élément quantitatif faisant référence, et pour tenir compte de l'enjeu tout de même réel sur la ressource en uranium,  la suppression de cet impact serait inapproprié. **Aussi Ecobalyse retient une réduction de la caractérisation de l'Uranium de telle sorte que le FRU d'1 kWh d'électricité d'origine nucléaire est égal à celui d'1kWh d'électricité d'une centrale gaz à cycle combiné,** conservant ainsi une approche "conservatrice. A terme il est souhaitable que cet indicateur FRU soit revu lors d'une prochaines mise à jour de la méthode EF.&#x20;

### Éléments chiffrés sur l'impact de l'électricité en matière de raréfaction des ressources énergétiques

La méthode EF 3.1 donne les impacts suivants pour l'électricité :&#x20;

* Électricité produite à partir du nucléaire : 13.2 MJ/kWh pour la plupart des pays du monde
  * 1.22e-7 kg Sb-Eq
  * jeu de données de référence : _electricity production, nuclear, pressure water reactor_, ecoinvent
* Électricité produite à partir de gaz, centrale à cycle combiné : forte variabilité en fonction de l'origine du gaz et de l'efficacité des centrales
  * moins de 7 MJ/kWh pour les pays producteurs de gaz
  * 7 à 8 MJ/kWh pour la plupart des pays occidentaux dont le gaz est une source significative de production d'électricité
  * plus de 10MJ/kWh pour le cas de pays où le parc est particulièrement de faible efficacité
  * donnée de référence : _electricity production, natural gas, combined cycle power plant_, ecoinvent

Il y a donc un impact de l'ordre de 40% plus faible pour l'électricité produite à partir de gaz sur le FRU.

## Modification apportée

Ecobalyse réduit le facteur de caractérisation de l’Uranium de 40% pour placer le FRU de l’électricité d’origine nucléaire au même niveau que le FRU de l’électricité produite par cycle combiné gaz.

* facteur de caractérisation actuel : 560 000 MJ/kg d'Uranium naturel
* facteur corrigé : 336 000 MJ/kg d'Uranium naturel

## Exemple : incidence sur l'électricité française

Illustration du cumul en points d'impact des catégories d'impact raréfaction des ressources énergétiques et raréfaction des ressources minérales et métalliques :&#x20;

<figure><img src="../../.gitbook/assets/image (334).png" alt=""><figcaption></figcaption></figure>

Données sources :&#x20;

* _electricity production, nuclear, pressure water reactor, FR_, ecoinvent 3.9.1
* _electricity production, natural gas, combined cycle power plant, FR_ ecoinvent 3.9.1

<figure><img src="../../.gitbook/assets/image (335).png" alt=""><figcaption></figcaption></figure>

Au final, voici le coût environnemental par kWh pour 1 kWh d'électricité en France, en fonction de la source de production :&#x20;

<figure><img src="../../.gitbook/assets/image.png" alt=""><figcaption></figcaption></figure>



