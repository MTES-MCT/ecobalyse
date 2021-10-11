module Data.Gitbook exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias Page =
    { title : String
    , description : Maybe String
    , markdown : String
    , path : String
    }


transformMarkdown : String -> String
transformMarkdown =
    -- Map Gitbook formulas to standard preformatted code blocks
    String.replace "$$" "```"
        -- Map Gitbook hints to bootstrap alerts
        >> String.replace "{% hint style=\"danger\" %}" "<hint level=\"danger\">"
        >> String.replace "{% hint style=\"warning\" %}" "<hint level=\"warning\">"
        >> String.replace "{% hint style=\"info\" %}" "<hint level=\"info\">"
        >> String.replace "{% endhint %}" "</hint>"


fromMarkdown : String -> String -> Page
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


publicUrl : String -> String
publicUrl path =
    "https://fabrique-numerique.gitbook.io/wikicarbone/" ++ path


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


decodePage : String -> Decoder Page
decodePage path =
    Decode.map4 Page
        (Decode.field "title" Decode.string)
        (Decode.field "description" decodeMaybeString)
        (Decode.field "document" Decode.string)
        (Decode.succeed path)
