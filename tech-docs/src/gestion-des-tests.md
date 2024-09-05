> 💡 **Prérequis**
>
> Pour exécuter et régler les problèmes de tests en échec suite à la mise à jour d’impacts, il convient de disposer d’une installation locale du projet. Les instructions d’installation et de configuration sont décrites [dans le README sur le dépôt.](https://github.com/MTES-MCT/ecobalyse/blob/master/README.md)

**Si suite à une mise à jour des impacts ou des coefficients de complément les tests échouent, voici la méthode pour régler la situation :**

- Depuis votre branche à jour en local et depuis un terminal, lancez `npm test`
- Vérifiez dans les rapports de tests si les échecs ou différences relevés sont attendus ou non
- Si les échecs **ne sont pas attendus**, réglez le problème et soumettez les modifications sur la branche afin que les tests passent à nouveau
- Si les échecs **sont attendus** — par exemple lorsque vous mettez à jour des impacts ou des compléments — et que vous vous souhaitez mettre à jour les tests afin de prendre en compte les nouvelles valeurs obtenues :
    - Pour les tests unitaires, mettez à jour les valeurs en échecs directement dans les tests Elm (`tests/**/*Test.elm`)
    - Pour les tests e2e (serveur), il faudra copier le ou les fichiers suivants, générés automatiquement à chaque lancement de la suite de tests via `npm test`:
        - Pour le textile : `cp tests/e2e-textile-output.json tests/e2e-textile.json`
        - Pour l’alimentaire : `cp tests/e2e-food-output.json tests/e2e-food.json`
    - Une fois que les tests passent tous à nouveau, vous pouvez commiter et pousser les changements sur votre branche distante, le build de votre pull-request devrait revenir au vert et être déployé automatiquement en recette.💡C’est toujours une bonne idée d’aller sur la recette Web vérifier que tout fonctionne comme prévu.


> 💡 **Cas particulier de la détection d’évolutions inhabituelles d’impacts**
>
> Si vous obtenez des échecs sur les tests de type `Food ingredients ecoscore deviation`, il vous faut également vérifier si ces écarts sont attendus ou non.
>
> S’ils sont attendus, il vous faut commenter le test en question, merger votre branche dans master, puis pousser un commit sur master qui décommente le test à nouveau afin que le contrôle puisse être effectué sur les branches et pull-requests créées par la suite.
