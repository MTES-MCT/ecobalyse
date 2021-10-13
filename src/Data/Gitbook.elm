module Data.Gitbook exposing (..)

import Json.Decode as Decode exposing (Decoder)


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
    | Electricity -- Électricité
    | Transport -- Transport
    | Heat -- Chaleur
    | Waste -- Pertes et rebus


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

        Electricity ->
            "methodologie/electricite"

        Transport ->
            "methodologie/transport"

        Heat ->
            "methodologie/chaleur"

        Waste ->
            "methodologie/pertes-et-rebus"


transformMarkdown : String -> String
transformMarkdown =
    -- Map Gitbook formulas to standard preformatted code blocks
    String.replace "$$" "```"
        -- Map Gitbook hints to bootstrap alerts
        >> String.replace "{% hint style=\"danger\" %}" "<hint level=\"danger\">"
        >> String.replace "{% hint style=\"warning\" %}" "<hint level=\"warning\">"
        >> String.replace "{% hint style=\"info\" %}" "<hint level=\"info\">"
        >> String.replace "{% endhint %}" "</hint>"


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


handleMarkdownGitbookLink : String -> String
handleMarkdownGitbookLink link =
    if List.any (\x -> String.startsWith x link) pathPrefixes then
        publicUrlFromString link

    else
        link


decodeMaybeString : Decoder (Maybe String)
decodeMaybeString =
    Decode.maybe Decode.string
        |> Decode.andThen
            (\maybeString ->
                case maybeString of
                    Just string ->
                        if String.trim string == "" then
                            Decode.succeed Nothing

                        else
                            Decode.succeed (Just string)

                    Nothing ->
                        Decode.succeed Nothing
            )


decodePage : Path -> Decoder Page
decodePage path =
    Decode.map4 Page
        (Decode.field "title" Decode.string)
        (Decode.field "description" decodeMaybeString)
        (Decode.field "document" Decode.string)
        (Decode.succeed path)
