Icomoon
=======

[Icomoon](https://icomoon.io/) est le service en ligne qui fournit le jeu d’icônes utilisée par l’application Ecobalyse. Il donne accès à un catalogue conséquent d’icônes libres de droits et permet de générer :

- une police de caractère conterant les icônes (`public/icomoon/fonts/*`)
- la feuille de style associée (`public/icomoon/style.css`)
- la configuration du jeu d’icônes (`public/icomoon/selection.json`)

## Première importation

Dans Icomoon, choisir `Import > Select or Drop Files` et uploader `public/icomoon/selection.json`. Le catalogue d’icône Ecobalyse est chargé et modifiable.

## Mettre à jour le jeu d’icônes

1. Ajouter, retirer ou renommer les icônes dans l’interface
1. Exporter le set au format (on obtient un fichier `icomoon.zip`)
1. Décompresser l’archive et remplacer le contenu de `public/icomoon/` avec les fichiers exportés
1. ⚠️ Bien vérifier que le fichier `selection.json` est ajouté au commit, car c'est lui qui permet aux autres développeurs de collaborer sur le set

## Intégration côté Elm

Après export, déclarer les nouvelles classes d’icônes dans `Views/Icon.elm` pour les rendre utilisables dans le code Elm.

> 💡 il peut être nécessaire de redémarrer le serveur de développement local pour prendre en compte les nouveau fichiers dans l’UI
