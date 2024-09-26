module Data.Object.Simulator exposing
    ( availableProcesses
    , compute
    , computeItemImpacts
    )

import Data.Impact as Impact exposing (Impacts)
import Data.Object.Db exposing (Db)
import Data.Object.Process as Process exposing (Process)
import Data.Object.Query as Query exposing (Item, Query)
import Quantity
import Result.Extra as RE


availableProcesses : Db -> Query -> List Process
availableProcesses db query =
    let
        usedIds =
            List.map .processId query.items
    in
    db.processes
        |> List.filter (\{ id } -> not (List.member id usedIds))


compute : Db -> Query -> Result String Impacts
compute db query =
    query.items
        |> List.map (computeItemImpacts db)
        |> RE.combine
        |> Result.map Impact.sumImpacts


computeItemImpacts : Db -> Item -> Result String Impacts
computeItemImpacts db { amount, processId } =
    processId
        |> Process.findById db.processes
        |> Result.map
            (.impacts
                >> Impact.mapImpacts (\_ -> Quantity.multiplyBy (Query.amountToFloat amount))
            )
