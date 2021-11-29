module Data.LifeCycle exposing (..)

import Array exposing (Array)
import Data.Co2 exposing (Co2e)
import Data.Db exposing (Db)
import Data.FwE exposing (Pe)
import Data.Inputs as Inputs exposing (Inputs)
import Data.Step as Step exposing (Step)
import Data.Transport as Transport exposing (Transport)
import Json.Encode as Encode
import Quantity
import Result.Extra as RE


type alias LifeCycle =
    Array Step


computeStepsTransport : Db -> LifeCycle -> Result String LifeCycle
computeStepsTransport db lifeCycle =
    lifeCycle
        |> Array.indexedMap
            (\index step ->
                Step.computeTransports db
                    (Array.get (index + 1) lifeCycle |> Maybe.withDefault step)
                    step
            )
        |> Array.toList
        |> RE.combine
        |> Result.map Array.fromList


computeTotalTransports : LifeCycle -> Transport
computeTotalTransports =
    Array.foldl
        (\{ transport } acc ->
            { acc
                | road = acc.road |> Quantity.plus transport.road
                , sea = acc.sea |> Quantity.plus transport.sea
                , air = acc.air |> Quantity.plus transport.air
                , co2 = acc.co2 |> Quantity.plus transport.co2
            }
        )
        Transport.default


computeFinalCo2Score : LifeCycle -> Co2e
computeFinalCo2Score =
    Array.foldl
        (\{ co2, transport } finalScore ->
            Quantity.sum [ finalScore, co2, transport.co2 ]
        )
        Quantity.zero


computeFinalFwEScore : LifeCycle -> Pe
computeFinalFwEScore =
    Array.foldl
        (\{ fwe, transport } finalScore ->
            Quantity.sum [ finalScore, fwe, transport.fwe ]
        )
        Quantity.zero


getStep : Step.Label -> LifeCycle -> Maybe Step
getStep label =
    Array.filter (.label >> (==) label) >> Array.get 0


getStepProp : Step.Label -> (Step -> a) -> a -> LifeCycle -> a
getStepProp label prop default =
    getStep label >> Maybe.map prop >> Maybe.withDefault default


fromQuery : Db -> Inputs.Query -> Result String LifeCycle
fromQuery db =
    Inputs.fromQuery db >> Result.map init


init : Inputs -> LifeCycle
init inputs =
    inputs.countries
        |> List.map2
            (\( label, editable ) country -> Step.create label editable country)
            [ ( Step.MaterialAndSpinning, False )
            , ( Step.WeavingKnitting, True )
            , ( Step.Ennoblement, True )
            , ( Step.Making, True )
            , ( Step.Distribution, False )
            ]
        |> List.map (Step.updateFromInputs inputs)
        |> Array.fromList


updateStep : Step.Label -> (Step -> Step) -> LifeCycle -> LifeCycle
updateStep label update_ =
    Array.map
        (\step ->
            if step.label == label then
                update_ step

            else
                step
        )


updateSteps : List Step.Label -> (Step -> Step) -> LifeCycle -> LifeCycle
updateSteps labels update_ lifeCycle =
    labels |> List.foldl (\label -> updateStep label update_) lifeCycle


encode : LifeCycle -> Encode.Value
encode =
    Encode.array Step.encode
