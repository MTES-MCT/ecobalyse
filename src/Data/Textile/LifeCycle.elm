module Data.Textile.LifeCycle exposing
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
    , sumComplementsImpacts
    , updateStep
    , updateSteps
    )

import Array exposing (Array)
import Data.Impact as Impact exposing (Impacts)
import Data.Textile.Inputs as Inputs exposing (Inputs)
import Data.Textile.Query exposing (Query)
import Data.Textile.Step as Step exposing (Step)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Transport as Transport exposing (Transport)
import Json.Encode as Encode
import List.Extra as LE
import Quantity
import Static.Db exposing (Db)


type alias LifeCycle =
    Array Step


computeStepsTransport : Db -> Inputs -> LifeCycle -> LifeCycle
computeStepsTransport db inputs lifeCycle =
    lifeCycle
        |> Array.map
            (\step ->
                if step.enabled then
                    step
                        |> Step.computeTransports db
                            inputs
                            (lifeCycle
                                |> getNextEnabledStep step.label
                                |> Maybe.withDefault step
                            )

                else
                    step
            )


computeTotalTransportImpacts : LifeCycle -> Transport
computeTotalTransportImpacts =
    Array.foldl
        (\{ transport } acc ->
            { acc
                | air = acc.air |> Quantity.plus transport.air
                , impacts =
                    acc.impacts
                        |> Impact.mapImpacts
                            (\trigram impact ->
                                Quantity.sum
                                    [ impact
                                    , Impact.getImpact trigram transport.impacts
                                    ]
                            )
                , road = acc.road |> Quantity.plus transport.road
                , sea = acc.sea |> Quantity.plus transport.sea
            }
        )
        (Transport.default Impact.empty)


computeFinalImpacts : LifeCycle -> Impacts
computeFinalImpacts =
    Array.foldl
        (\{ enabled, impacts, transport } finalImpacts ->
            if enabled then
                finalImpacts
                    |> Impact.mapImpacts
                        (\trigram impact ->
                            Quantity.sum
                                [ Impact.getImpact trigram impacts
                                , impact
                                , Impact.getImpact trigram transport.impacts
                                ]
                        )

            else
                finalImpacts
        )
        Impact.empty


sumComplementsImpacts : LifeCycle -> Impact.ComplementsImpacts
sumComplementsImpacts =
    Array.toList
        >> List.filter .enabled
        >> List.map .complementsImpacts
        >> List.foldl Impact.addComplementsImpacts Impact.noComplementsImpacts


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


fromQuery : Db -> Query -> Result String LifeCycle
fromQuery db =
    Inputs.fromQuery db >> Result.map (init db)


init : Db -> Inputs -> LifeCycle
init { textile } inputs =
    Inputs.geozoneList inputs
        |> List.map2
            (\( label, editable ) geozone ->
                Step.create
                    { editable = editable
                    , enabled = not (List.member label inputs.disabledSteps)
                    , geozone = geozone
                    , label = label
                    }
            )
            [ ( Label.Material, False )
            , ( Label.Spinning, True )
            , ( Label.Fabric, True )
            , ( Label.Ennobling, True )
            , ( Label.Making, True )
            , ( Label.Distribution, False )
            , ( Label.Use, False )
            , ( Label.EndOfLife, False )
            ]
        |> List.map (Step.updateFromInputs textile inputs)
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


updateSteps : List Label -> (Step -> Step) -> LifeCycle -> LifeCycle
updateSteps labels update_ lifeCycle =
    labels |> List.foldl (\label -> updateStep label update_) lifeCycle


encode : LifeCycle -> Encode.Value
encode =
    Encode.array Step.encode
