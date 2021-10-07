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


computeSummaryBetween : Step -> Step -> Transport.Summary
computeSummaryBetween current next =
    let
        transport =
            Transport.getTransportBetween current.country next.country
    in
    case ( current.label, next.label ) of
        ( Step.MaterialAndSpinning, Step.WeavingKnitting ) ->
            -- Note: First initial material step has specific defaults
            transport |> Transport.addToSummary Transport.defaultInitialSummary

        _ ->
            Transport.toSummary transport


handleAirTransport : Step -> Transport.Summary -> Transport.Summary
handleAirTransport { label } summary =
    -- Air transport can only concern finished products, so we only keep air travel distance
    -- between the Making and Distribution steps.
    if List.member label [ Step.Making ] then
        summary

    else
        { summary | air = 0 }


computeTransportSummaries : LifeCycle -> LifeCycle
computeTransportSummaries lifeCycle =
    lifeCycle
        |> Array.indexedMap
            (\index current ->
                { current
                    | transport =
                        lifeCycle
                            |> Array.get (index + 1)
                            |> Maybe.withDefault current
                            |> computeSummaryBetween current
                            |> handleAirTransport current
                            |> Step.computeTransports current
                }
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
