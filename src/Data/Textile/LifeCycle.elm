module Data.Textile.LifeCycle exposing
    ( LifeCycle
    , computeFinalImpacts
    , computeStagesTransport
    , computeTotalTransportImpacts
    , encode
    , fromQuery
    , getNextEnabledStage
    , getStage
    , getStageProp
    , init
    , sumComplementsImpacts
    , updateStage
    , updateStages
    )

import Array exposing (Array)
import Data.Impact as Impact exposing (Impacts)
import Data.Textile.Inputs as Inputs exposing (Inputs)
import Data.Textile.Query exposing (Query)
import Data.Textile.Stage as Stage exposing (Stage)
import Data.Textile.Stage.Label as Label exposing (Label)
import Data.Transport as Transport exposing (Transport)
import Json.Encode as Encode
import List.Extra as LE
import Quantity
import Static.Db exposing (Db)


type alias LifeCycle =
    Array Stage


computeStagesTransport : Db -> Inputs -> LifeCycle -> LifeCycle
computeStagesTransport db inputs lifeCycle =
    lifeCycle
        |> Array.map
            (\stage ->
                if stage.enabled then
                    stage
                        |> Stage.computeTransports db
                            inputs
                            (lifeCycle
                                |> getNextEnabledStage stage.label
                                |> Maybe.withDefault stage
                            )

                else
                    stage
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


getNextEnabledStage : Label -> LifeCycle -> Maybe Stage
getNextEnabledStage label =
    Array.toList
        >> LE.splitWhen (.label >> (==) label)
        >> Maybe.map Tuple.second
        >> Maybe.andThen (List.filter .enabled >> List.drop 1 >> List.head)


getStage : Label -> LifeCycle -> Maybe Stage
getStage label =
    Array.filter (.label >> (==) label) >> Array.get 0


getStageProp : Label -> (Stage -> a) -> a -> LifeCycle -> a
getStageProp label prop default =
    getStage label >> Maybe.map prop >> Maybe.withDefault default


fromQuery : Db -> Query -> Result String LifeCycle
fromQuery db =
    Inputs.fromQuery db >> Result.map (init db)


init : Db -> Inputs -> LifeCycle
init { textile } inputs =
    Inputs.countryList inputs
        |> List.map2
            (\( label, editable ) country ->
                Stage.create
                    { country = country
                    , editable = editable
                    , enabled = not (List.member label inputs.disabledStages)
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
        |> List.map (Stage.updateFromInputs textile inputs)
        |> Array.fromList


updateStage : Label -> (Stage -> Stage) -> LifeCycle -> LifeCycle
updateStage label update_ =
    Array.map
        (\stage ->
            if stage.label == label then
                update_ stage

            else
                stage
        )


updateStages : List Label -> (Stage -> Stage) -> LifeCycle -> LifeCycle
updateStages labels update_ lifeCycle =
    labels |> List.foldl (\label -> updateStage label update_) lifeCycle


encode : LifeCycle -> Encode.Value
encode =
    Encode.array Stage.encode
