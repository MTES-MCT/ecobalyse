module Data.LifeCycle exposing
    ( LifeCycle
    , computeFinalImpacts
    , computeStepsTransport
    , computeTotalTransportImpacts
    , encode
    , fromQuery
    , getNextEnabledStep
    , getStep
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
import Data.Step.Label as Label exposing (Label)
import Data.Transport as Transport exposing (Transport)
import Json.Encode as Encode
import List.Extra as LE
import Quantity
import Result.Extra as RE


type alias LifeCycle =
    Array Step


computeStepsTransport : Db -> LifeCycle -> Result String LifeCycle
computeStepsTransport db lifeCycle =
    lifeCycle
        |> Array.map
            (\step ->
                if step.enabled then
                    step
                        |> Step.computeTransports db
                            (lifeCycle
                                |> getNextEnabledStep step.label
                                |> Maybe.withDefault step
                            )

                else
                    Ok step
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


getNextEnabledStep : Label -> LifeCycle -> Maybe Step
getNextEnabledStep label =
    Array.toList
        >> LE.splitWhen (.label >> (==) label)
        >> Maybe.map Tuple.second
        >> Maybe.andThen (List.filter .enabled >> List.drop 1 >> List.head)


getStep : Label -> LifeCycle -> Maybe Step
getStep label =
    Array.filter (.label >> (==) label) >> Array.get 0


getStepProp : Label -> (Step -> a) -> a -> LifeCycle -> a
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
                    , enabled = not (List.member label inputs.disabledSteps)
                    }
            )
            [ ( Label.Material, False )
            , ( Label.Spinning, True )
            , ( Label.Fabric, True )
            , ( Label.Dyeing, True )
            , ( Label.Making, True )
            , ( Label.Distribution, False )
            , ( Label.Use, False )
            , ( Label.EndOfLife, False )
            ]
        |> List.map (Step.updateFromInputs db inputs)
        |> Array.fromList


updateStep : Label -> (Step -> Step) -> LifeCycle -> LifeCycle
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


updateSteps : List Label -> (Step -> Step) -> LifeCycle -> LifeCycle
updateSteps labels update_ lifeCycle =
    labels |> List.foldl (\label -> updateStep label update_) lifeCycle


encode : LifeCycle -> Encode.Value
encode =
    Encode.array Step.encode
