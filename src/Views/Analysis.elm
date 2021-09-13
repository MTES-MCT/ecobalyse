module Views.Analysis exposing (..)

import Array
import Data.Country as Country
import Data.Inputs as Inputs
import Data.Simulator as Simulator exposing (Simulator)
import Data.Step as Step exposing (Step)
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Page exposing (ActivePage(..))


stepAnalysis : Step -> Html msg
stepAnalysis step =
    div []
        [ h5 [] [ text <| Step.labelToString step.label ++ " (" ++ Country.toString step.country ++ ")" ]
        ]


story : Simulator -> Html msg
story simulator =
    div []
        [ p [] [ simulator |> Simulator.toInputs |> Inputs.toLabel |> text ]
        , simulator.lifeCycle
            |> Array.map stepAnalysis
            |> Array.toList
            |> div []
        ]


view : Simulator -> Html msg
view simulator =
    div [ class "card shadow-sm mb-3" ]
        [ div [ class "card-header" ] [ text "Analyse" ]
        , div [ class "card-body" ]
            [ story simulator
            ]
        ]
