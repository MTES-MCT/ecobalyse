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
    = FoodBonuses -- Bonus et compléments hors-ACV
    | FoodRawToCookedRatio -- Rapport cru/cuit alimentaire
    | ImpactQuality -- Niveau de qualité d'impact
    | TextileAerialTransport -- Part du transport aérien textile
    | TextileDistribution -- Distribution textile
    | TextileElectricity -- Électricité textile
    | TextileEndOfLife -- Fin de vie textile
    | TextileEnnobling -- Ennoblissement textile
    | TextileFabric -- Tissage/Tricotage textile
    | TextileHeat -- Chaleur textile
    | TextileMaking -- Confection textile
    | TextileMakingComplexity -- Complexité de la confection textile
    | TextileMaterialAndSpinning -- Matière & filature textile
    | TextileTransport -- Transport textile
    | TextileUse -- Utilisation textile


pathToString : Path -> String
pathToString path =
    case path of
        FoodBonuses ->
            "alimentaire/impacts-consideres/complements-hors-acv-en-construction"

        FoodRawToCookedRatio ->
            "alimentaire/rapport-cru-cuit"

        ImpactQuality ->
            "textile/impacts-consideres#niveaux-de-recommandation"

        TextileAerialTransport ->
            "textile/parametres-transverses/transport#part-du-transport-aerien"

        TextileDistribution ->
            "textile/etapes-du-cycle-de-vie/distribution"

        TextileElectricity ->
            "textile/parametres-transverses/electricite"

        TextileEndOfLife ->
            "textile/etapes-du-cycle-de-vie/etape-7-fin-de-vie"

        TextileEnnobling ->
            "textile/etapes-du-cycle-de-vie/ennoblissement"

        TextileFabric ->
            "textile/etapes-du-cycle-de-vie/tricotage-tissage"

        TextileHeat ->
            "textile/parametres-transverses/chaleur"

        TextileMaking ->
            "textile/etapes-du-cycle-de-vie/confection"

        TextileMakingComplexity ->
            "textile/etapes-du-cycle-de-vie/confection#electricite-consommee-mj-kwh"

        TextileMaterialAndSpinning ->
            "textile/etapes-du-cycle-de-vie/filature/"

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
