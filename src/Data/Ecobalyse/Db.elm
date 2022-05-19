module Data.Ecobalyse.Db exposing
    ( Db
    , Product
    , ProductDefinition
    , ProductName
    , empty
    , productFromDefinition
    , stepFromProcesses
    , updateAmount
    )

import Data.Ecobalyse.Process as Process
    exposing
        ( Amount
        , Impacts
        , Process
        , ProcessName
        , Processes
        , findByName
        )
import Data.Impact as Impact
import Data.Unit as Unit
import Dict exposing (Dict)
import Result.Extra as RE


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


type alias Ingredient =
    ( String, Unit.Ratio )


type alias ProductDefinition =
    { title : ProductName
    , consumer : List Ingredient
    , supermarket : List Ingredient
    , distribution : List Ingredient
    , packaging : List Ingredient
    , plant : List Ingredient
    }


insertIngredient : ProcessName -> Amount -> Impacts -> Step -> Step
insertIngredient processName amount impacts step =
    Dict.insert processName (Process amount impacts) step


stepFromProcesses : List Ingredient -> Processes -> Result String Step
stepFromProcesses ingredients processes =
    ingredients
        |> List.foldl
            (\( processName, amount ) stepResult ->
                let
                    impactsResult : Result String Impacts
                    impactsResult =
                        findByName processName processes
                in
                Result.map2 (insertIngredient processName amount) impactsResult stepResult
            )
            (Ok Dict.empty)


productFromDefinition : ProductDefinition -> Processes -> Result String Product
productFromDefinition { title, consumer, supermarket, distribution, packaging, plant } processes =
    Ok (Product title)
        |> RE.andMap (stepFromProcesses consumer processes)
        |> RE.andMap (stepFromProcesses supermarket processes)
        |> RE.andMap (stepFromProcesses distribution processes)
        |> RE.andMap (stepFromProcesses packaging processes)
        |> RE.andMap (stepFromProcesses plant processes)


updateAmount : ProcessName -> Amount -> Step -> Step
updateAmount processName newAmount step =
    step
        |> Dict.update processName
            (Maybe.map
                (\process ->
                    { process | amount = newAmount }
                )
            )
