module Request.Gitbook exposing (..)

import Data.Gitbook as Gitbook
import Data.Session exposing (Session)
import Http
import RemoteData exposing (WebData)


toPage : String -> String -> Gitbook.Page
toPage path markdown =
    let
        blocks =
            markdown |> String.split "\n\n"

        title =
            blocks
                |> List.filter (String.startsWith "# ")
                |> List.head
                |> Debug.log "title"

        finalTitle =
            title
                |> Maybe.map (String.replace "# " "")
                |> Maybe.withDefault "Sans titre"

        description =
            blocks
                |> List.filter (\block -> String.startsWith "---" block && String.endsWith "---" block)
                |> List.head
                |> Maybe.map (String.replace "---" "" >> String.replace "\n" "" >> String.replace "description:" "" >> String.replace ">-" "")

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


getPage : Session -> String -> (WebData Gitbook.Page -> msg) -> Cmd msg
getPage _ path event =
    Http.get
        { url = "https://raw.githubusercontent.com/MTES-MCT/wikicarbone/docs/" ++ path ++ ".md"
        , expect =
            Http.expectString
                (RemoteData.fromResult
                    >> RemoteData.map (toPage path)
                    >> event
                )
        }
