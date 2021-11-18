module Views.Container exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


type Breakpoint
    = XS
    | SM
    | MD
    | LG
    | XL
    | XXL


centered : List (Attribute msg) -> List (Html msg) -> Html msg
centered attrs =
    div ([ class "container" ] ++ attrs)


fluid : List (Attribute msg) -> List (Html msg) -> Html msg
fluid attrs =
    div ([ class "container-fluid" ] ++ attrs)


full : List (Attribute msg) -> List (Html msg) -> Html msg
full attrs =
    div attrs


fluidUpto : Breakpoint -> List (Attribute msg) -> List (Html msg) -> Html msg
fluidUpto breakpoint attrs =
    div ([ class <| "container-" ++ breakpointToString breakpoint ] ++ attrs)


breakpointToString : Breakpoint -> String
breakpointToString breakpoint =
    case breakpoint of
        XS ->
            "xs"

        SM ->
            "sm"

        MD ->
            "md"

        LG ->
            "lg"

        XL ->
            "xl"

        XXL ->
            "xxl"
