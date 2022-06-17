module Data.Food.Db exposing
    ( Db
    , empty
    )

import Data.Food.Process as Process exposing (ImpactsForProcesses)
import Data.Food.Product as Products exposing (Products)
import Data.Impact as Impact


type alias Db =
    { impacts : List Impact.Definition
    , processes : ImpactsForProcesses
    , products : Products
    }


empty : Db
empty =
    { impacts = []
    , processes = Process.empty
    , products = Products.empty
    }
