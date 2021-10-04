module Views.Markdown exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Markdown.Parser as Markdown
import Markdown.Renderer exposing (Renderer, defaultHtmlRenderer)
import Views.Link as Link


clean : String -> String
clean =
    String.split "\n\n"
        >> List.map String.trim
        >> String.join "\n\n"


renderer : Renderer (Html msg)
renderer =
    { defaultHtmlRenderer
        | link = renderLink
        , image = renderImage
    }


renderLink : { title : Maybe String, destination : String } -> List (Html msg) -> Html msg
renderLink { title, destination } =
    let
        attrs =
            List.filterMap identity
                [ Just (Attr.href destination)
                , Maybe.map Attr.title title
                ]
    in
    if String.startsWith "http" destination then
        Link.external attrs

    else
        Link.internal attrs


renderImage imageInfo =
    case imageInfo.title of
        Just title ->
            Html.img
                [ Attr.src imageInfo.src
                , Attr.alt imageInfo.alt
                , Attr.title title
                , attribute "crossorigin" "anonymous"
                ]
                []

        Nothing ->
            Html.img
                [ Attr.src imageInfo.src
                , Attr.alt imageInfo.alt
                , attribute "crossorigin" "anonymous"
                ]
                []


view : List (Attribute msg) -> String -> Html msg
view attrs markdown =
    case
        markdown
            |> clean
            |> Markdown.parse
            |> Result.mapError (List.map Markdown.deadEndToString >> String.join "\n")
            |> Result.andThen (Markdown.Renderer.render renderer)
    of
        Ok rendered ->
            div ([ class "Markdown bottomed-paragraphs" ] ++ attrs) rendered

        Err errors ->
            div [ class "alert alert-warning" ] [ text errors ]
