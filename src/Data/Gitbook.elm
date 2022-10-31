module Data.Gitbook exposing
    ( IsIsnt
    , Page
    , Path(..)
    , fromMarkdown
    , handleMarkdownGitbookLink
    , parseIsIsnt
    , pathToString
    , publicUrlFromPath
    )

import Data.Env as Env
import List.Extra as LE


type alias Page =
    { title : String
    , description : Maybe String
    , markdown : String
    , path : Path
    }


type Path
    = Home -- Page d'accueil
    | MaterialAndSpinning -- Matière & filature
    | Fabric -- Tissage/Tricotage
    | Dyeing -- Teinture
    | Making -- Confection
    | Distribution -- Distribution
    | Use -- Utilisation
    | EndOfLife -- Fin de vie
    | Electricity -- Électricité
    | Transport -- Transport
    | Heat -- Chaleur
    | Waste -- Pertes et rebus
    | ImpactQuality -- Niveau de qualité d'impact
    | CountryHypothesis -- Procédés et hypothèses spécifiques aux pays


pathToString : Path -> String
pathToString path =
    case path of
        Home ->
            "README"

        MaterialAndSpinning ->
            "textile/filature"

        Fabric ->
            "textile/tricotage-tissage"

        Dyeing ->
            "textile/teinture"

        Making ->
            "textile/confection"

        Distribution ->
            "textile/distribution"

        Use ->
            "textile/etape-6-utilisation"

        EndOfLife ->
            "textile/etape-7-fin-de-vie"

        Electricity ->
            "textile/electricite"

        Transport ->
            "textile/transport"

        Heat ->
            "textile/chaleur"

        Waste ->
            "textile/pertes-et-rebus"

        ImpactQuality ->
            "textile/impacts-consideres#niveaux-de-recommandation"

        CountryHypothesis ->
            "textile/ajout-dun-pays#procedes-specifiques-au-pays"


transformMarkdown : String -> String
transformMarkdown =
    -- Map Gitbook formulas to standard preformatted code blocks
    String.replace "$$" "```"
        -- Map Gitbook hints to bootstrap alerts
        >> String.replace "{% hint style=\"danger\" %}" "<hint level=\"danger\">"
        >> String.replace "{% hint style=\"warning\" %}" "<hint level=\"warning\">"
        >> String.replace "{% hint style=\"info\" %}" "<hint level=\"info\">"
        >> String.replace "{% endhint %}" "</hint>"
        -- Typography
        >> String.replace "-->" "→"
        -- HTML entities
        >> String.replace " & " " &amp; "
        -- Gitbook preformated text escaping
        >> String.replace "\\_" "_"


fromMarkdown : Path -> String -> Page
fromMarkdown path markdown =
    let
        blocks =
            markdown |> transformMarkdown |> String.split "\n\n"

        title =
            blocks
                |> List.filter (String.startsWith "# ")
                |> List.head

        finalTitle =
            title
                |> Maybe.map (String.replace "# " "")
                |> Maybe.withDefault "Sans titre"

        description =
            blocks
                |> List.filter (\block -> String.startsWith "---" block && String.endsWith "---" block)
                |> List.head
                |> Maybe.map
                    (String.replace "---" ""
                        >> String.replace "\n" ""
                        >> String.replace "description:" ""
                        >> String.replace ">-" ""
                        >> String.trim
                    )

        final =
            blocks
                |> List.filter (\block -> not (String.startsWith "---\n" block && String.endsWith "---" block))
                |> List.filter (\block -> title /= Just block)
                |> String.join "\n\n"
    in
    { title = finalTitle
    , description = description
    , markdown = final
    , path = path
    }


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


{-| A data structure representing the Homepage content, parsed
from the Gitbook homepage markdown content string, which contains
these hierarchically structured informations:

  - What is Ecobalyse:
      - it is A
          - argument A.1
          - argument A.2
      - it is B
          - argument B.1
          - argument B.2
  - What isn't Ecobalyse:
      - it isn't C
          - argument C.1
          - argument C.2
      - it isn't D
          - argument D.1
          - argument D.2

See tests for a sample Markdown document to parse.

-}
type alias IsIsnt =
    { is : ( String, List ( String, String ) )
    , isnt : ( String, List ( String, String ) )
    }


parseIsIsnt : String -> Result String IsIsnt
parseIsIsnt markdown =
    let
        splitMap delim fn =
            String.split delim
                >> List.map String.trim
                >> LE.uncons
                >> Maybe.map fn

        toIsIsnt list =
            case list of
                [ is, isnt ] ->
                    Ok { is = is, isnt = isnt }

                _ ->
                    Err "Impossible de parser les informations édotoriales de la page d'acceuil."
    in
    markdown
        |> String.split "\n## "
        |> (\blocks ->
                if (blocks |> List.head |> Maybe.map (\s -> String.startsWith "## " s)) == Just True then
                    blocks

                else
                    List.drop 1 blocks
           )
        |> List.filterMap
            (splitMap "\n### "
                (\( title, mdrest ) ->
                    ( title
                    , mdrest
                        |> List.filterMap
                            (splitMap "\n\n" (Tuple.mapSecond (String.join "\n\n")))
                    )
                )
            )
        |> toIsIsnt
