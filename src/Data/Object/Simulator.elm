module Data.Object.Simulator exposing
    ( Results(..)
    , availableComponents
    , compute
    , emptyResults
    , expandItems
    , extractImpacts
    , extractItems
    , extractMass
    , toStepsImpacts
    )

import Data.Impact as Impact exposing (Impacts, noStepsImpacts)
import Data.Impact.Definition as Definition
import Data.Object.Process as Process exposing (Process)
import Data.Object.Query as Query exposing (Item, ProcessItem, Query, quantityToInt)
import List.Extra as LE
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



-- FIX: read the components from a file
-- For now take the components from the example and consider that they are unique by name


availableComponents : Db -> Query -> List Item
availableComponents { object } query =
    let
        -- FIX: For now, consider that components are unique by name, we should
        -- replace it with ids later on
        usedNames =
            List.map .name query.items
    in
    object.examples
        |> List.concatMap (.query >> .items)
        |> LE.uniqueBy .name
        |> List.filter (\{ name } -> not (List.member name usedNames))
        |> List.sortBy .name


compute : Db -> Query -> Result String Results
compute db query =
    query.items
        |> List.map (computeItemResults db)
        |> RE.combine
        |> Result.map
            (List.foldr
                (\(Results { impacts, items, mass }) (Results acc) ->
                    Results
                        { acc
                            | impacts = Impact.sumImpacts [ impacts, acc.impacts ]
                            , items = Results { impacts = impacts, items = items, mass = mass } :: acc.items
                            , mass = Quantity.sum [ mass, acc.mass ]
                        }
                )
                emptyResults
            )


computeItemResults : Db -> Item -> Result String Results
computeItemResults db item =
    item.processes
        |> List.map (computeProcessItemResults db)
        |> RE.combine
        |> Result.map
            (List.foldr
                (\(Results results) (Results acc) ->
                    Results
                        { acc
                            | impacts = Impact.sumImpacts [ results.impacts, acc.impacts ]
                            , items = Results results :: acc.items
                            , mass = Quantity.sum [ results.mass, acc.mass ]
                        }
                )
                emptyResults
            )
        |> Result.map
            (\(Results { impacts, mass, items }) ->
                Results
                    { impacts = Impact.sumImpacts (List.repeat (quantityToInt item.quantity) impacts)
                    , items = items
                    , mass = Quantity.sum (List.repeat (quantityToInt item.quantity) mass)
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
                            |> Impact.mapImpacts (\_ -> Quantity.multiplyBy (Query.amountToFloat amount))

                    mass =
                        Mass.kilograms <|
                            if process.unit == "kg" then
                                Query.amountToFloat amount

                            else
                                -- apply density
                                Query.amountToFloat amount * process.density
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


expandItems : Db -> Query -> Result String (List ( Query.Quantity, String, List ( Query.Amount, Process ) ))
expandItems db =
    .items
        >> List.map
            (\item ->
                expandProcesses db item.processes
                    |> Result.map (\processes -> ( item.quantity, item.name, processes ))
            )
        >> RE.combine


expandProcesses : Db -> List ProcessItem -> Result String (List ( Query.Amount, Process ))
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
