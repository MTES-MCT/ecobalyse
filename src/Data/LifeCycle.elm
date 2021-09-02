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


computeSummaryBetween : Step -> Maybe Step -> Transport.Summary
computeSummaryBetween current maybeNext =
    case ( current.label, maybeNext ) of
        -- TODO: handle special case for Distribution: (Step.Distribution, Nothing)
        ( Step.Material, Just _ ) ->
            Transport.defaultInitialSummary

        ( _, Just next ) ->
            Transport.getTransportBetween current.country next.country |> Transport.toSummary

        _ ->
            Transport.getTransportBetween current.country current.country |> Transport.toSummary


computeTransportSummaries : LifeCycle -> LifeCycle
computeTransportSummaries lifeCycle =
    lifeCycle
        |> Array.toIndexedList
        |> List.map (\( index, current ) -> { current | transport = Array.get (index + 1) lifeCycle |> computeSummaryBetween current })
        |> Array.fromList


computeTransportSummary : LifeCycle -> Transport.Summary
computeTransportSummary lifeCycle =
    lifeCycle
        |> computeTransportSummaries
        |> Array.foldl
            (\{ transport } summary ->
                { summary
                    | road = summary.road + transport.road
                    , sea = summary.sea + transport.sea
                    , air = summary.air + transport.air
                }
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


updateSteps : List Step.Label -> (Step -> Step) -> LifeCycle -> LifeCycle
updateSteps labels update lifeCycle =
    labels |> List.foldl (\label -> updateStep label update) lifeCycle
