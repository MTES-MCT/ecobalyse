module Data.Gitbook exposing
    ( Page
    , Path(..)
    , handleMarkdownGitbookLink
    , publicUrlFromPath
    )

import Data.Env as Env


type alias Page =
    { title : String
    , description : Maybe String
    , markdown : String
    , path : Path
    }


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
    | ImpactQuality -- Niveau de qualité d'impact
    | TextileAerialTransport -- Part du transport aérien textile
    | TextileComplementMicrofibers -- Complément textile microfibres
    | TextileDistribution -- Distribution textile
    | TextileDurability -- Durabilité textile
    | TextileElectricity -- Électricité textile
    | TextileEndOfLife -- Fin de vie textile
    | TextileEndOfLifeOutOfEuropeComplement -- Complément Fin de vie textile hors-Europe
    | TextileEnnobling -- Ennoblissement textile
    | TextileEnnoblingCountriesAquaticPollution -- Pollution aquatique lors de l'ennoblissement par pays
    | TextileEnnoblingToxicity -- Inventaires enrichis pour le blanchiment, la teinture et l'impression
    | TextileFabric -- Tissage/Tricotage textile
    | TextileHeat -- Chaleur textile
    | TextileMaterial -- Matière textile
    | TextileMaking -- Confection textile
    | TextileMakingComplexity -- Complexité de la confection textile
    | TextileMakingDeadStock -- Deadstock lors de la confection textile
    | TextileMakingMakingWaste -- Taux de perte en confection textile
    | TextileSpinning -- Filature textile
    | TextileTransport -- Transport textile
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

        ImpactQuality ->
            "textile/impacts-consideres#niveaux-de-recommandation"

        TextileAerialTransport ->
            "textile/parametres-transverses/transport#part-du-transport-aerien"

        TextileComplementMicrofibers ->
            "textile/complements-hors-acv/microfibres"

        TextileDistribution ->
            "textile/etapes-du-cycle-de-vie/distribution"

        TextileDurability ->
            -- FIXME: this page doesn't exist, there is no docs for durability just yet
            "textile/durabilite"

        TextileElectricity ->
            "textile/parametres-transverses/electricite"

        TextileEndOfLife ->
            "textile/etapes-du-cycle-de-vie/etape-7-fin-de-vie"

        TextileEndOfLifeOutOfEuropeComplement ->
            "textile/limites-methodologiques/fin-de-vie-hors-europe"

        TextileEnnobling ->
            "textile/etapes-du-cycle-de-vie/ennoblissement"

        TextileEnnoblingToxicity ->
            "textile/etapes-du-cycle-de-vie/ennoblissement/inventaires-enrichis"

        TextileEnnoblingCountriesAquaticPollution ->
            "textile/etapes-du-cycle-de-vie/ennoblissement/inventaires-enrichis#pays-less-than-greater-than-taux-de-pollution-aquatique"

        TextileFabric ->
            "textile/etapes-du-cycle-de-vie/tricotage-tissage"

        TextileHeat ->
            "textile/parametres-transverses/chaleur"

        TextileMaterial ->
            "textile/etapes-du-cycle-de-vie/etape-1-matieres"

        TextileMaking ->
            "textile/etapes-du-cycle-de-vie/confection"

        TextileMakingComplexity ->
            "textile/etapes-du-cycle-de-vie/confection#electricite-consommee-mj-kwh"

        TextileMakingDeadStock ->
            "textile/cas-particuliers/stocks-dormants-deadstock"

        TextileMakingMakingWaste ->
            "textile/parametres-transverses/pertes-et-rebus"

        TextileSpinning ->
            "textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil-new"

        TextileTransport ->
            "textile/parametres-transverses/transport"

        TextileUse ->
            "textile/etapes-du-cycle-de-vie/etape-6-utilisation"


pathPrefixes : List String
pathPrefixes =
    [ "faq", "glossaire", "methodologie" ]


publicUrlFromPath : Path -> String
publicUrlFromPath =
    pathToString >> publicUrlFromString


publicUrlFromString : String -> String
publicUrlFromString path =
    Env.gitbookUrl ++ "/" ++ path


handleMarkdownGitbookLink : Maybe Path -> String -> String
handleMarkdownGitbookLink maybePath link =
    if List.any (\x -> String.startsWith x link) pathPrefixes then
        publicUrlFromString link

    else if String.endsWith ".md" link then
        case maybePath of
            Just path ->
                -- check for current folder, eg. "filature.md", "../faq.md", "methodologie/transport.md"
                (extractLinkFolder path ++ [ String.replace ".md" "" link ])
                    |> String.join "/"
                    |> publicUrlFromString

            Nothing ->
                publicUrlFromString link

    else
        link


extractLinkFolder : Path -> List String
extractLinkFolder path =
    case String.split "/" (pathToString path) of
        folder :: _ ->
            if folder == ".." then
                []

            else
                [ folder ]

        _ ->
            []
