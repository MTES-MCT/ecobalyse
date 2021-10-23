module Data.LifeCycle exposing (..)

import Array exposing (Array)
import Data.Db exposing (Db)
import Data.Inputs exposing (Inputs)
import Data.Step as Step exposing (Step)
import Data.Transport as Transport
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Result.Extra as RE


type alias LifeCycle =
    Array Step


decode : Decoder LifeCycle
decode =
    Decode.array Step.decode


encode : LifeCycle -> Encode.Value
encode =
    Encode.array Step.encode


computeTransportSummaries : Db -> LifeCycle -> Result String LifeCycle
computeTransportSummaries db lifeCycle =
    lifeCycle
        |> Array.indexedMap
            (\index step ->
                Step.computeTransports db
                    (Array.get (index + 1) lifeCycle |> Maybe.withDefault step)
                    step
            )
        |> Array.foldl
            (\result acc ->
                case ( result, acc ) of
                    ( Ok step, Ok array ) ->
                        Ok (Array.push step array)

                    ( _, Err error ) ->
                        Err error

                    ( Err error, Ok _ ) ->
                        Err error
            )
            (Ok Array.empty)


filterMap : (a -> Maybe b) -> List a -> List b
filterMap f xs =
    List.foldr (maybeCons f) [] xs


maybeCons : (a -> Maybe b) -> a -> List b -> List b
maybeCons f mx xs =
    case f mx of
        Just x ->
            x :: xs

        Nothing ->
            xs


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


init : Db -> Inputs -> Result String LifeCycle
init db inputs =
    List.map2
        (\( label, editable ) -> Step.create db label editable)
        [ ( Step.MaterialAndSpinning, False )
        , ( Step.WeavingKnitting, True )
        , ( Step.Ennoblement, True )
        , ( Step.Making, True )
        , ( Step.Distribution, False )
        ]
        inputs.countries
        |> RE.combine
        |> Result.map Array.fromList
        |> Result.map
            -- FIXME: refactor this mess
            (\lifeCycle ->
                lifeCycle
                    |> Array.indexedMap
                        (\index step_ ->
                            Step.update db inputs (Array.get (index + 1) lifeCycle) step_
                        )
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
