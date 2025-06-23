module Views.Markdown exposing
    ( parse
    , simple
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown.Parser as Parser
import Markdown.Renderer exposing (defaultHtmlRenderer)


clean : String -> String
clean =
    String.split "\n\n" >> List.map String.trim >> String.join "\n\n"


simple : List (Attribute msg) -> String -> Html msg
simple attrs content =
    case parse content of
        Err errors ->
            div [ class "fr-alert fr-alert--warning" ]
                [ text errors ]

        Ok rendered ->
            div (class "Markdown bottomed-paragraphs" :: attrs) rendered


parse : String -> Result String (List (Html msg))
parse =
    clean
        >> Parser.parse
        >> Result.mapError (List.map Parser.deadEndToString >> String.join "\n")
        >> Result.andThen (Markdown.Renderer.render defaultHtmlRenderer)
