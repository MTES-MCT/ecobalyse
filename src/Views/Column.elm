module Views.Column exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown


type alias Column msg =
    ( Attributes msg, Elements msg )


type alias Attributes msg =
    List (Attribute msg)


type alias Elements msg =
    List (Html msg)


add : Attributes msg -> Elements msg -> List (Column msg) -> List (Column msg)
add attrs elements columns =
    columns ++ [ ( attrs, elements ) ]


addMd : Attributes msg -> List String -> List (Column msg) -> List (Column msg)
addMd attrs strings =
    add attrs [ toMarkdown strings ]


create : Attributes msg -> Elements msg -> List (Column msg)
create attrs elements =
    List.singleton ( attrs, elements )


createMd : Attributes msg -> List String -> List (Column msg)
createMd attrs strings =
    List.singleton ( attrs, [ toMarkdown strings ] )


render : Attributes msg -> List (Column msg) -> Html msg
render wrapAttrs columns =
    let
        nc =
            List.length columns

        mini =
            toFloat 12 / toFloat nc

        base =
            floor mini

        rest =
            ceiling (toFloat 12 - toFloat (base * (nc - 1)))
    in
    columns
        |> List.indexedMap
            (\index ( attrs, elements ) ->
                let
                    col =
                        if index == nc - 1 then
                            rest

                        else
                            base
                in
                div (attrs ++ [ class <| "py-2 col-sm-" ++ String.fromInt col ]) elements
            )
        |> div ([ class "row" ] ++ wrapAttrs)


toMarkdown : List String -> Html msg
toMarkdown =
    String.join "\n\n" >> Markdown.toHtml [ class "bottomed-paragraphs" ]
