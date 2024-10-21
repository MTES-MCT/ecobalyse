# Calcul des compléments végétaux

Pour les ingrédients végétaux le calcul des compléments utilise 3 paramètres : le groupe de culture (crop\_group), le scenario et la surface agricole mobilisée (\`land\_occupation\` ).\
\
A partir de ces 3 paramètres sont calculés les 3 compléments suivants : haies, taille de parcelle et diversité (hedges, plotSize et cropDiversity dans l'API).\
\
Le schéma suivant résume la manière dont sont fait le calculs de ces compléments. Le code du calcul des compléments est aussi disponible sur [le github du projet](https://github.com/MTES-MCT/ecobalyse/blob/master/data/food/ecosystemic\_services/ecosystemic\_services.py).



<figure><img src="../../.gitbook/assets/image (282).png" alt=""><figcaption><p>Schéma de calcul des compléments végétaux</p></figcaption></figure>
