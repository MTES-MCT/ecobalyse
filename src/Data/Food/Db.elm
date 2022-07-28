module Data.Food.Db exposing
    ( Db
    , empty
    )

import Data.Food.Product as Products exposing (Processes, Products)
import Data.Impact as Impact


type alias Db =
    { impacts : List Impact.Definition

    ---- Processes are straightforward imports of public/data/food/processes.json
    , processes : Processes

    ---- Products are imported from public/data/food/products.json with several layers:
    ---- Product
    ----    Step (consumer, packaging, ...)
    ----        Category (material, processing, waste treatment, ...)
    ----            Ingredient (amount, process -- from the processes db --)
    , products : Products
    }


empty : Db
empty =
    { impacts = []
    , processes = Products.emptyProcesses
    , products = Products.emptyProducts
    }
