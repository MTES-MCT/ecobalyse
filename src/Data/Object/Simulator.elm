module Data.Object.Simulator exposing
    ( Results(..)
    , availableProcesses
    , compute
    , emptyResults
    , expandItems
    , extractImpacts
    , extractItems
    , extractMass
    )

import Data.Impact as Impact exposing (Impacts)
import Data.Object.Process as Process exposing (Process)
import Data.Object.Query as Query exposing (Item, Query)
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


availableProcesses : Db -> Query -> List Process
availableProcesses { object } query =
    let
        usedIds =
            List.map .processId query.items
    in
    object.processes
        |> List.filter (\{ id } -> not (List.member id usedIds))


compute : Db -> Query -> Result String Results
compute db query =
    query.items
        |> List.map (computeItemResults db)
        |> RE.combine
        |> Result.map
            (List.foldr
                (\(Results { impacts, mass }) (Results acc) ->
                    Results
                        { acc
                            | impacts = Impact.sumImpacts [ impacts, acc.impacts ]
                            , items = Results { impacts = impacts, items = [], mass = mass } :: acc.items
                            , mass = Quantity.sum [ mass, acc.mass ]
                        }
                )
                emptyResults
            )


computeItemResults : Db -> Item -> Result String Results
computeItemResults { object } { amount, processId } =
    processId
        |> Process.findById object.processes
        |> Result.map
            (\process ->
                Results
                    { impacts =
                        process.impacts
                            |> Impact.mapImpacts (\_ -> Quantity.multiplyBy (Query.amountToFloat amount))
                    , items = []
                    , mass =
                        Mass.kilograms <|
                            if process.unit == "kg" then
                                Query.amountToFloat amount

                            else
                                -- apply density
                                Query.amountToFloat amount * process.density
                    }
            )


emptyResults : Results
emptyResults =
    Results
        { impacts = Impact.empty
        , items = []
        , mass = Quantity.zero
        }


expandItems : Db -> Query -> Result String (List ( Query.Amount, Process ))
expandItems db =
    .items
        >> List.map (\{ amount, processId } -> ( amount, processId ))
        >> List.map (RE.combineMapSecond (Process.findById db.object.processes))
        >> RE.combine


extractImpacts : Results -> Impacts
extractImpacts (Results { impacts }) =
    impacts


extractItems : Results -> List Results
extractItems (Results { items }) =
    items


extractMass : Results -> Mass
extractMass (Results { mass }) =
    mass
