module Data.Gitbook exposing
    ( Page
    , Path(..)
    , fromMarkdown
    , handleMarkdownGitbookLink
    , pathToString
    , publicUrlFromPath
    )


type alias Page =
    { title : String
    , description : Maybe String
    , markdown : String
    , path : Path
    }


type Path
    = MaterialAndSpinning -- Matière & filature
    | WeavingKnitting -- Tissage/Tricotage
    | Dyeing -- Teinture
    | Making -- Confection
    | Distribution -- Distribution
    | Use -- Utilisation
    | EndOfLife -- Fin de vie
    | Electricity -- Électricité
    | Transport -- Transport
    | Heat -- Chaleur
    | Waste -- Pertes et rebus
    | ComparativeScale -- Échelle comparative


pathToString : Path -> String
pathToString path =
    case path of
        MaterialAndSpinning ->
            "methodologie/filature"

        WeavingKnitting ->
            "methodologie/tricotage-tissage"

        Dyeing ->
            "methodologie/teinture"

        Making ->
            "methodologie/confection"

        Distribution ->
            "methodologie/distribution"

        Use ->
            "methodologie/etape-6-utilisation"

        EndOfLife ->
            "methodologie/etape-7-fin-de-vie"

        Electricity ->
            "methodologie/electricite"

        Transport ->
            "methodologie/transport"

        Heat ->
            "methodologie/chaleur"

        Waste ->
            "methodologie/pertes-et-rebus"

        ComparativeScale ->
            "methodologie/echelle-comparative"


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
                |> List.map String.trim
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
    "https://fabrique-numerique.gitbook.io/wikicarbone/" ++ path


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
