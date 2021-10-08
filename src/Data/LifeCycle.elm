module Data.LifeCycle exposing (..)

import Array exposing (Array)
import Data.Country as Country
import Data.Inputs exposing (Inputs)
import Data.Step as Step exposing (Step)
import Data.Transport as Transport
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias LifeCycle =
    Array Step


default : LifeCycle
default =
    Array.fromList
        [ Step.create Step.MaterialAndSpinning False Country.China
        , Step.create Step.WeavingKnitting True Country.France
        , Step.create Step.Ennoblement True Country.France
        , Step.create Step.Making True Country.France
        , Step.create Step.Distribution False Country.France
        ]


decode : Decoder LifeCycle
decode =
    Decode.array Step.decode


encode : LifeCycle -> Encode.Value
encode =
    Encode.array Step.encode


computeTransportSummaries : LifeCycle -> LifeCycle
computeTransportSummaries lifeCycle =
    lifeCycle
        |> Array.indexedMap
            (\index step ->
                Step.computeTransports
                    (Array.get (index + 1) lifeCycle
                        |> Maybe.withDefault step
                    )
                    step
            )


computeTransportSummary : LifeCycle -> Transport.Summary
computeTransportSummary =
    Array.foldl
        (\{ transport } summary ->
            { summary
                | road = summary.road + transport.road
                , sea = summary.sea + transport.sea
                , air = summary.air + transport.air
                , co2 = summary.co2 + transport.co2
            }
        )
        Transport.defaultSummary


computeFinalCo2Score : LifeCycle -> Float
computeFinalCo2Score =
    Array.foldl
        (\{ co2, transport } finalScore -> finalScore + co2 + transport.co2)
        0


getStep : Step.Label -> LifeCycle -> Maybe Step
getStep label =
    Array.filter (.label >> (==) label) >> Array.get 0


init : Inputs -> LifeCycle -> LifeCycle
init inputs lifeCycle =
    lifeCycle
        |> Array.indexedMap
            (\index step ->
                { step
                    | country =
                        inputs.countries
                            |> Array.fromList
                            |> Array.get index
                            |> Maybe.withDefault step.country
                }
                    |> Step.update inputs (Array.get (index + 1) lifeCycle)
            )


updateStep : Step.Label -> (Step -> Step) -> LifeCycle -> LifeCycle
updateStep label update =
    Array.map
        (\step ->
            if step.label == label then
                update step

            else
                step
        )


updateSteps : List Step.Label -> (Step -> Step) -> LifeCycle -> LifeCycle
updateSteps labels update lifeCycle =
    labels |> List.foldl (\label -> updateStep label update) lifeCycle
