module Views.Container exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


type Size
    = Xs
    | Sm
    | Md
    | Lg
    | Xl
    | Xxl


centered : List (Attribute msg) -> List (Html msg) -> Html msg
centered attrs =
    div ([ class "container" ] ++ attrs)


fluid : List (Attribute msg) -> List (Html msg) -> Html msg
fluid attrs =
    div ([ class "container-fluid" ] ++ attrs)


full : List (Attribute msg) -> List (Html msg) -> Html msg
full attrs =
    div attrs


fluidUntil : Size -> List (Attribute msg) -> List (Html msg) -> Html msg
fluidUntil size attrs =
    let
        vp =
            case size of
                Xs ->
                    "xs"

                Sm ->
                    "sm"

                Md ->
                    "md"

                Lg ->
                    "lg"

                Xl ->
                    "xl"

                Xxl ->
                    "xxl"
    in
    div ([ class <| "container-" ++ vp ] ++ attrs)
