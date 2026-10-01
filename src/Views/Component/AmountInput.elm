module Views.Component.AmountInput exposing (Config, view)

import Data.Component.Amount as Amount exposing (Amount)
import Data.Process as Process
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { event : Maybe Amount -> msg
    , readonly : Bool
    , unit : Process.Unit
    }


view : Config msg -> Amount -> Html msg
view { event, readonly, unit } amount =
    let
        stringAmount =
            Amount.toString amount

        stepValue =
            case String.split "." stringAmount of
                -- This is an integer, increment by .1 for convenience
                [ _ ] ->
                    "0.1"

                -- This is a float, increment at the precision of the float
                [ _, decimals ] ->
                    "0." ++ String.padLeft (String.length decimals) '0' "1"

                -- Should not happen, but who knows?
                _ ->
                    "0.01"
    in
    div [ class "AmountInput input-group" ]
        [ input
            ([ type_ "number"
             , class "form-control form-control-sm text-end incdec-arrows-left"
             , value stringAmount
             , Attr.min "0"
             , step stepValue
             , onInput <| Amount.fromString >> event
             ]
                ++ (if readonly then
                        [ Attr.readonly readonly
                        , title "Cette quantité n'est pas modifiable"
                        , class "cursor-not-allowed"
                        ]

                    else
                        []
                   )
            )
            []
        , small [ class "input-group-text fs-8" ]
            [ text <| Process.unitToString unit ]
        ]
