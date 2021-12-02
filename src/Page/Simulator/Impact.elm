module Page.Simulator.Impact exposing (..)

import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { selected : Impact
    , switch : Result String Impact -> msg
    }


type Impact
    = ClimateChange
    | FreshwaterEutrophication


impacts : List Impact
impacts =
    [ ClimateChange
    , FreshwaterEutrophication
    ]


impactToString : Impact -> String
impactToString impact =
    case impact of
        ClimateChange ->
            "Changement climatique"

        FreshwaterEutrophication ->
            "Eutrophisation d'eaux douces"


impactFromString : String -> Result String Impact
impactFromString string =
    case string of
        "Changement climatique" ->
            Ok ClimateChange

        "Eutrophisation d'eaux douces" ->
            Ok FreshwaterEutrophication

        _ ->
            Err <| "Impact inconnu: " ++ string


toFloat : Impact -> { a | co2 : Unit.Co2e, fwe : Unit.Pe } -> Float
toFloat impact { co2, fwe } =
    case impact of
        ClimateChange ->
            Unit.inKgCo2e co2

        FreshwaterEutrophication ->
            Unit.inKgPe fwe


selector : Config msg -> Html msg
selector { selected, switch } =
    impacts
        |> List.map
            (\impact ->
                option [ Attr.selected (selected == impact) ]
                    [ text <| impactToString impact ]
            )
        |> select [ class "form-select", onInput (impactFromString >> switch) ]
