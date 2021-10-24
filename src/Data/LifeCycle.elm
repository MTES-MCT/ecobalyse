module Data.LifeCycle exposing (..)

import Array exposing (Array)
import Data.Db exposing (Db)
import Data.Inputs as Inputs exposing (Inputs)
import Data.Step as Step exposing (Step)
import Data.Transport as Transport
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Mass exposing (Mass)
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
        |> Array.toList
        |> RE.combine
        |> Result.map Array.fromList


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


getStepMass : Step.Label -> LifeCycle -> Mass
getStepMass label =
    getStep label >> Maybe.map .mass >> Maybe.withDefault (Mass.kilograms 0)


fromQuery : Db -> Inputs.Query -> Result String LifeCycle
fromQuery db =
    Inputs.fromQuery db >> Result.map (init db)


init : Db -> Inputs -> LifeCycle
init db inputs =
    initSteps inputs |> update db inputs


update : Db -> Inputs -> LifeCycle -> LifeCycle
update db inputs lifeCycle =
    lifeCycle
        |> Array.indexedMap
            (\index -> Step.update db inputs (Array.get (index + 1) lifeCycle))


initSteps : Inputs -> LifeCycle
initSteps inputs =
    inputs.countries
        |> List.map2
            (\( label, editable ) -> Step.create label editable)
            [ ( Step.MaterialAndSpinning, False )
            , ( Step.WeavingKnitting, True )
            , ( Step.Ennoblement, True )
            , ( Step.Making, True )
            , ( Step.Distribution, False )
            ]
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
