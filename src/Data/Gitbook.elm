module Data.Gitbook exposing
    ( Path(..)
    , publicUrlFromPath
    )

import Data.Env as Env


type Path
    = FoodComplements -- Bonus et compléments hors-ACV
    | FoodDistribution -- Distribution
    | FoodInediblePart -- Part non-comestible
    | FoodIngredients -- Ingrédients alimentaires
    | FoodPackaging -- Emballages
    | FoodRawToCookedRatio -- Rapport cru/cuit alimentaire
    | FoodTransformation -- Transformation des ingrédients
    | FoodTransport -- Transport entre étapes
    | FoodUse -- Consommation
    | TextileCircularFootprintFormula -- Circular Footprint Formula (CFF)
    | TextileComplementMicrofibers -- Complément textile microfibres
    | TextileDistribution -- Distribution textile
    | TextileDurability -- Durabilité textile
    | TextileElectricity -- Électricité textile
    | TextileEndOfLife -- Fin de vie textile
    | TextileEndOfLifeOutOfEuropeComplement -- Complément Fin de vie textile hors-Europe
    | TextileEnnobling -- Ennoblissement textile
    | TextileEnnoblingCountriesAquaticPollution -- Pollution aquatique lors de l'ennoblissement par pays
    | TextileEnnoblingToxicity -- Inventaires enrichis pour le blanchiment, la teinture et l'impression
    | TextileExamples -- Exemples de produits textile
    | TextileFabric -- Tissage/Tricotage textile
    | TextileFabricWaste -- Taux de perte en tissage/tricotage textile
    | TextileHeat -- Chaleur textile
    | TextileMaking -- Confection textile
    | TextileMakingComplexity -- Complexité de la confection textile
    | TextileMakingDeadStock -- Deadstock lors de la confection textile
    | TextileMakingWaste -- Taux de perte en confection textile
    | TextileMaterial -- Matière textile
    | TextileSpinning -- Filature textile
    | TextileTransport -- Transport textile
    | TextileTrims -- Accessoires textiles
    | TextileUse -- Utilisation textile


pathToString : Path -> String
pathToString path =
    case path of
        FoodComplements ->
            "alimentaire/impacts-consideres/complements-hors-acv-en-construction"

        FoodDistribution ->
            "alimentaire/etapes-du-cycles-de-vie/vente-au-detail"

        FoodInediblePart ->
            "alimentaire/part-non-comestible"

        FoodIngredients ->
            "alimentaire/donnees"

        FoodPackaging ->
            "alimentaire/etapes-du-cycles-de-vie/emballage"

        FoodRawToCookedRatio ->
            "alimentaire/rapport-cru-cuit"

        FoodTransformation ->
            "alimentaire/etapes-du-cycles-de-vie/transformation"

        FoodTransport ->
            "alimentaire/transport"

        FoodUse ->
            "alimentaire/etapes-du-cycles-de-vie/consommation"

        TextileCircularFootprintFormula ->
            "textile/cycle-de-vie-des-produits-textiles/circular-footpring-formula-cff"

        TextileComplementMicrofibers ->
            "textile/complements-hors-acv/microfibres"

        TextileDistribution ->
            "textile/etapes-du-cycle-de-vie/distribution"

        TextileDurability ->
            "textile/complements-hors-acv/durabilite"

        TextileElectricity ->
            "textile/parametres-transverses/electricite"

        TextileEndOfLife ->
            "textile/etapes-du-cycle-de-vie/etape-7-fin-de-vie"

        TextileEndOfLifeOutOfEuropeComplement ->
            "textile/limites-methodologiques/fin-de-vie-hors-europe"

        TextileEnnobling ->
            "textile/cycle-de-vie-des-produits-textiles/ennoblissement-1"

        TextileEnnoblingCountriesAquaticPollution ->
            "textile/etapes-du-cycle-de-vie/ennoblissement/inventaires-enrichis#pays-less-than-greater-than-taux-de-pollution-aquatique"

        TextileEnnoblingToxicity ->
            "textile/etapes-du-cycle-de-vie/ennoblissement/inventaires-enrichis"

        TextileExamples ->
            "textile/exemples"

        TextileFabric ->
            "textile/etapes-du-cycle-de-vie/tricotage-tissage"

        TextileFabricWaste ->
            "textile/cycle-de-vie-des-produits-textiles/tricotage-tissage#taux-de-perte"

        TextileHeat ->
            "textile/parametres-transverses/chaleur"

        TextileMaking ->
            "textile/etapes-du-cycle-de-vie/confection"

        TextileMakingComplexity ->
            "textile/etapes-du-cycle-de-vie/confection#electricite-consommee-mj-kwh"

        TextileMakingDeadStock ->
            "textile/cas-particuliers/stocks-dormants-deadstock"

        TextileMakingWaste ->
            "textile/parametres-transverses/pertes-et-rebus"

        TextileMaterial ->
            "textile/etapes-du-cycle-de-vie/etape-1-matieres"

        TextileSpinning ->
            "textile/cycle-de-vie-des-produits-textiles/etape-2-fabrication-du-fil"

        TextileTransport ->
            "textile/parametres-transverses/transport"

        TextileTrims ->
            "textile/cycle-de-vie-des-produits-textiles/accessoires"

        TextileUse ->
            "textile/etapes-du-cycle-de-vie/etape-6-utilisation"


publicUrlFromPath : Path -> String
publicUrlFromPath =
    pathToString >> publicUrlFromString


publicUrlFromString : String -> String
publicUrlFromString path =
    Env.gitbookUrl ++ "/" ++ path
