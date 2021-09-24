module Views.Markdown exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Markdown.Parser as Markdown
import Markdown.Renderer exposing (Renderer, defaultHtmlRenderer)


clean : String -> String
clean =
    String.split "\n\n"
        >> List.map String.trim
        >> String.join "\n\n"


renderer : Renderer (Html msg)
renderer =
    { defaultHtmlRenderer | link = renderLink }


renderLink : { title : Maybe String, destination : String } -> List (Html msg) -> Html msg
renderLink { title, destination } =
    let
        attrs =
            [ Just [ Attr.href destination ]
            , title |> Maybe.map (Attr.title >> List.singleton)
            , if String.startsWith "http" destination then
                Just [ target "_blank", rel "noopener noreferrer" ]

              else
                Nothing
            ]
                |> List.filterMap identity
                |> List.concat
    in
    Html.a attrs


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
