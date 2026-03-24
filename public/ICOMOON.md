Icomoon
=======

[Icomoon](https://icomoon.io/) est le service en ligne qui fournit le jeu d’icônes utilisées par l’application Ecobalyse. Il donne accès à un catalogue conséquent d’icônes libres de droits et permet de générer :

- une police de caractères conterant les icônes (`public/icomoon/fonts/*`)
- la feuille de style associée (`public/icomoon/style.css`)
- la configuration du jeu d’icônes (`public/icomoon/selection.json`)

## Première importation

Dans [Icomoon](https://icomoon.io/app/) (attention à bien utiliser la _Old App_ qui contient plus d’icônes gratuites que la _New App_), choisir `Import > Select or Drop Files` et uploader `public/icomoon/selection.json`. Le catalogue d’icône Ecobalyse est chargé et modifiable.

## Mettre à jour le jeu d’icônes

1. Ajouter, retirer ou renommer les icônes dans l’interface
1. Exporter le set au format (on obtient un fichier `icomoon.zip`) en cliquant sur « Generate font » en bas à droite puis sur le lien « Download » généré au même endroit
1. Décompresser l’archive et remplacer le contenu de `public/icomoon/` avec les fichiers exportés
1. ⚠️ Bien vérifier que le fichier `selection.json` est ajouté au commit, car c'est lui qui permet aux autres développeurs de collaborer sur le set

## Intégration côté Elm

Après export, déclarer les nouvelles classes d’icônes dans `Views/Icon.elm` pour les rendre utilisables dans le code Elm.

> 💡 il peut être nécessaire de redémarrer le serveur de développement local pour prendre en compte les nouveaus fichiers dans l’UI
