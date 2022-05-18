module Data.Ecobalyse.Db exposing
    ( Db
    , Product
    , ProductName
    , empty
    , updateAmount
    )

import Data.Ecobalyse.Process as Process exposing (Amount, Process, ProcessName, Processes)
import Data.Impact as Impact
import Dict exposing (Dict)


type alias Db =
    { impacts : List Impact.Definition
    , processes : Processes

    -- , products : List Product
    }


empty : Db
empty =
    { impacts = []
    , processes = Process.empty

    -- , products = Dict.empty
    }


type alias Step =
    Dict ProcessName Process


type alias Product =
    { title : ProductName
    , consumer : Step
    , supermarket : Step
    , distribution : Step
    , packaging : Step
    , plant : Step
    }


type alias ProductName =
    String


updateAmount : ProcessName -> Amount -> Step -> Step
updateAmount processName newAmount step =
    step
        |> Dict.update processName
            (Maybe.map
                (\process ->
                    { process | amount = newAmount }
                )
            )
