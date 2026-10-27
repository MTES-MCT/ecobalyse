module Views.Component.AmountInput exposing
    ( Config
    , view
    )

import Data.Component.Amount as Amount exposing (Amount)
import Data.Process as Process
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.FloatInput as FloatInput exposing (WriteAccess)


type alias Config msg =
    { id : String
    , label : String
    , noOp : msg
    , onInput : FloatInput.State -> msg
    , state : Maybe FloatInput.State
    , unit : Process.Unit
    , writeAccess : WriteAccess
    }


view : Config msg -> Amount -> Html msg
view config amount =
    div [ class "AmountInput input-group" ]
        [ FloatInput.view
            { id = config.id
            , label = config.label
            , noOp = config.noOp
            , onInput = config.onInput
            , state = config.state
            , value = Amount.toFloat amount
            , writeAccess = config.writeAccess
            }
        , small [ class "input-group-text fs-8" ]
            [ text <| Process.unitToString config.unit ]
        ]
