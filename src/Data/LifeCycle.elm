module Data.LifeCycle exposing (..)

import Array exposing (Array)
import Data.Country exposing (Country)
import Data.Step as Step exposing (Step)
import Data.Transport as Transport
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias LifeCycle =
    Array Step


default : LifeCycle
default =
    Array.fromList
        [ Step.material
        , Step.spinning
        , Step.weaving
        , Step.ennoblement
        , Step.confection
        , Step.distribution
        ]


decode : Decoder LifeCycle
decode =
    Decode.array Step.decode


encode : LifeCycle -> Encode.Value
encode =
    Encode.array Step.encode


computeTransportSummary : LifeCycle -> Transport.Summary
computeTransportSummary lifeCycle =
    lifeCycle
        |> Array.toIndexedList
        |> List.foldl
            (\( index, current ) summary ->
                case
                    lifeCycle
                        |> Array.get (index - 1)
                        |> Maybe.map (.country >> Transport.getTransportBetween current.country)
                of
                    Just transport ->
                        Transport.addToSummary transport summary

                    Nothing ->
                        summary
            )
            Transport.defaultSummary


getStep : Step.Label -> LifeCycle -> Maybe Step
getStep label =
    Array.filter (.label >> (==) label) >> Array.get 0


updateStepCountry : Step.Label -> Country -> LifeCycle -> LifeCycle
updateStepCountry label country =
    updateStep label (\s -> { s | country = country })


updateStep : Step.Label -> (Step -> Step) -> LifeCycle -> LifeCycle
updateStep label update =
    Array.map
        (\s ->
            if s.label == label then
                update s

            else
                s
        )
