module Data.LifeCycle exposing (..)

import Array exposing (Array)
import Data.Db exposing (Db)
import Data.Impact as Impact
import Data.Inputs as Inputs exposing (Inputs)
import Data.Step as Step exposing (Step)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Json.Encode as Encode
import Quantity
import Result.Extra as RE


type alias LifeCycle =
    Array Step


computeStepsTransport : Db -> Impact.Definition -> LifeCycle -> Result String LifeCycle
computeStepsTransport db impact lifeCycle =
    lifeCycle
        |> Array.indexedMap
            (\index step ->
                Step.computeTransports db
                    impact
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
                , impact = acc.impact |> Quantity.plus transport.impact
            }
        )
        Transport.default


computeFinalImpactScore : LifeCycle -> Unit.Impact
computeFinalImpactScore =
    Array.foldl
        (\{ impact, transport } finalScore ->
            Quantity.sum [ finalScore, impact, transport.impact ]
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
    Inputs.fromQuery db >> Result.map (init db)


init : Db -> Inputs -> LifeCycle
init db inputs =
    inputs.countries
        |> List.map2
            (\( label, editable ) country ->
                Step.create
                    { db = db
                    , label = label
                    , editable = editable
                    , country = country
                    }
            )
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
