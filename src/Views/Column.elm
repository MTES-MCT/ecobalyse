module Views.Column exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Markdown as Markdown


type alias Column msg =
    ( Attributes msg, Elements msg )


type alias Attributes msg =
    List (Attribute msg)


type alias Elements msg =
    List (Html msg)


add : Attributes msg -> Elements msg -> List (Column msg) -> List (Column msg)
add attrs elements columns =
    columns ++ [ ( attrs, elements ) ]


addMd : Attributes msg -> String -> List (Column msg) -> List (Column msg)
addMd attrs md =
    add attrs [ toMarkdown md ]


create : List (Column msg)
create =
    []


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

        breakpoint =
            if nc <= 2 then
                "sm"

            else
                "md"
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
                div (attrs ++ [ class <| "py-2 col-" ++ breakpoint ++ "-" ++ String.fromInt col ]) elements
            )
        |> div ([ class "row" ] ++ wrapAttrs)


toMarkdown : String -> Html msg
toMarkdown =
    String.split "\n\n"
        >> List.map String.trim
        >> String.join "\n\n"
        >> Markdown.view [ class "bottomed-paragraphs" ]
