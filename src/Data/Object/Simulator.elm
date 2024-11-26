module Data.Object.Simulator exposing
    ( Results(..)
    , availableComponents
    , compute
    , emptyResults
    , expandProcessItems
    , extractImpacts
    , extractItems
    , extractMass
    , toStepsImpacts
    )

import Data.Impact as Impact exposing (Impacts, noStepsImpacts)
import Data.Impact.Definition as Definition
import Data.Object.Component as Component exposing (Component, ComponentItem, ProcessItem)
import Data.Object.Process as Process exposing (Process)
import Data.Object.Query exposing (Query)
import Mass exposing (Mass)
import Quantity
import Result.Extra as RE
import Static.Db exposing (Db)


type Results
    = Results
        { impacts : Impacts
        , items : List Results
        , mass : Mass
        }


availableComponents : Db -> Query -> List Component
availableComponents { object } query =
    let
        usedIds =
            query.components
                |> List.map .id
    in
    object.components
        |> List.filter (\{ id } -> not (List.member id usedIds))
        |> List.sortBy .name


addResults : Results -> Results -> Results
addResults (Results results) (Results acc) =
    Results
        { acc
            | impacts = Impact.sumImpacts [ results.impacts, acc.impacts ]
            , items = Results results :: acc.items
            , mass = Quantity.sum [ results.mass, acc.mass ]
        }


compute : Db -> Query -> Result String Results
compute db query =
    query.components
        |> List.map (computeComponentItemResults db)
        |> RE.combine
        |> Result.map (List.foldr addResults emptyResults)


computeComponentItemResults : Db -> ComponentItem -> Result String Results
computeComponentItemResults db componentItem =
    db.object.components
        |> Component.findById componentItem.id
        |> Result.andThen (.processes >> List.map (computeProcessItemResults db) >> RE.combine)
        |> Result.map (List.foldr addResults emptyResults)
        |> Result.map
            (\(Results { impacts, mass, items }) ->
                Results
                    { impacts = Impact.sumImpacts (List.repeat (Component.quantityToInt componentItem.quantity) impacts)
                    , items = items
                    , mass = Quantity.sum (List.repeat (Component.quantityToInt componentItem.quantity) mass)
                    }
            )


computeProcessItemResults : Db -> ProcessItem -> Result String Results
computeProcessItemResults { object } { amount, processId } =
    processId
        |> Process.findById object.processes
        |> Result.map
            (\process ->
                let
                    impacts =
                        process.impacts
                            |> Impact.mapImpacts (\_ -> Quantity.multiplyBy (Component.amountToFloat amount))

                    mass =
                        Mass.kilograms <|
                            if process.unit == "kg" then
                                Component.amountToFloat amount

                            else
                                -- apply density
                                Component.amountToFloat amount * process.density
                in
                Results
                    { impacts = impacts
                    , items = [ Results { impacts = impacts, items = [], mass = mass } ]
                    , mass = mass
                    }
            )


emptyResults : Results
emptyResults =
    Results
        { impacts = Impact.empty
        , items = []
        , mass = Quantity.zero
        }


expandProcessItems : Db -> Query -> Result String (List ( Component.Quantity, Component, List ( Component.Amount, Process ) ))
expandProcessItems db =
    .components
        >> List.map
            (\componentItem ->
                db.object.components
                    |> Component.findById componentItem.id
                    |> Result.andThen
                        (\component ->
                            component.processes
                                |> expandProcesses db
                                |> Result.map (\processes -> ( componentItem.quantity, component, processes ))
                        )
            )
        >> RE.combine


expandProcesses : Db -> List ProcessItem -> Result String (List ( Component.Amount, Process ))
expandProcesses db processes =
    processes
        |> List.map (\{ amount, processId } -> ( amount, processId ))
        |> List.map (RE.combineMapSecond (Process.findById db.object.processes))
        |> RE.combine


extractImpacts : Results -> Impacts
extractImpacts (Results { impacts }) =
    impacts


extractItems : Results -> List Results
extractItems (Results { items }) =
    items


extractMass : Results -> Mass
extractMass (Results { mass }) =
    mass


toStepsImpacts : Definition.Trigram -> Results -> Impact.StepsImpacts
toStepsImpacts trigram results =
    { noStepsImpacts
      -- FIXME: for now, as we only have materials, assign everything to the material step
        | materials =
            extractImpacts results
                |> Impact.getImpact trigram
                |> Just
    }
