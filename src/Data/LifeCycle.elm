module Data.LifeCycle exposing
    ( LifeCycle
    , computeFinalImpacts
    , computeStepsTransport
    , computeTotalTransportImpacts
    , encode
    , fromQuery
    , getStepProp
    , init
    , mapSteps
    , updateStep
    , updateSteps
    )

import Array exposing (Array)
import Data.Db exposing (Db)
import Data.Impact as Impact exposing (Impacts)
import Data.Inputs as Inputs exposing (Inputs, countryList)
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


computeTotalTransportImpacts : Db -> LifeCycle -> Transport
computeTotalTransportImpacts db =
    Array.foldl
        (\{ transport } acc ->
            { acc
                | road = acc.road |> Quantity.plus transport.road
                , sea = acc.sea |> Quantity.plus transport.sea
                , air = acc.air |> Quantity.plus transport.air
                , impacts =
                    acc.impacts
                        |> Impact.mapImpacts
                            (\trigram impact ->
                                Quantity.sum
                                    [ impact
                                    , Impact.getImpact trigram transport.impacts
                                    ]
                            )
            }
        )
        (Transport.default (Impact.impactsFromDefinitons db.impacts))


computeFinalImpacts : Db -> LifeCycle -> Impacts
computeFinalImpacts db =
    Array.foldl
        (\{ impacts, transport } finalImpacts ->
            finalImpacts
                |> Impact.mapImpacts
                    (\trigram impact ->
                        Quantity.sum
                            [ Impact.getImpact trigram impacts
                            , impact
                            , Impact.getImpact trigram transport.impacts
                            ]
                    )
        )
        (Impact.impactsFromDefinitons db.impacts)


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
    inputs
        |> countryList
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
            , ( Step.Use, False )
            , ( Step.EndOfLife, False )
            ]
        |> List.map (Step.updateFromInputs db inputs)
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


mapSteps : (Step -> Step) -> LifeCycle -> LifeCycle
mapSteps =
    Array.map


updateSteps : List Step.Label -> (Step -> Step) -> LifeCycle -> LifeCycle
updateSteps labels update_ lifeCycle =
    labels |> List.foldl (\label -> updateStep label update_) lifeCycle


encode : LifeCycle -> Encode.Value
encode =
    Encode.array Step.encode
