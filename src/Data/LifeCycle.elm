module Data.LifeCycle exposing (..)

import Array exposing (Array)
import Data.Country exposing (Country)
import Data.Process as Process
import Data.Step as Step exposing (Step)
import Data.Transport as Transport
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias LifeCycle =
    Array Step


default : LifeCycle
default =
    Array.fromList
        [ Step.materialAndSpinning
        , Step.weavingKnitting
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


stepCountryLabels : LifeCycle -> List String
stepCountryLabels =
    Array.toList >> List.map Step.countryLabel


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
    -- between the Making and Distribution and for the Distribution step itself steps.
    if List.member label [ Step.Making, Step.Distribution ] then
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
                            |> Transport.applyProcess current.mass
                                (case current.label of
                                    -- FIXME: in Excel, the distribution road distance is eventually
                                    -- substracted from the one of the making step.
                                    Step.Making ->
                                        Process.roadTransportPostMaking

                                    Step.Distribution ->
                                        Process.distribution

                                    _ ->
                                        Process.roadTransportPreMaking
                                )
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


processStepCountries : LifeCycle -> LifeCycle
processStepCountries =
    Array.map (\step -> Step.updateCountry step.country step)


updateStepCountry : Step.Label -> Country -> LifeCycle -> LifeCycle
updateStepCountry label country =
    updateStep label (Step.updateCountry country)


updateStep : Step.Label -> (Step -> Step) -> LifeCycle -> LifeCycle
updateStep label update =
    Array.map
        (\s ->
            if s.label == label then
                update s

            else
                s
        )


updateSteps : List Step.Label -> (Step -> Step) -> LifeCycle -> LifeCycle
updateSteps labels update lifeCycle =
    labels |> List.foldl (\label -> updateStep label update) lifeCycle
