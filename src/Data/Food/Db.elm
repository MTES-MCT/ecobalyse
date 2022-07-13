module Data.Food.Db exposing
    ( Db
    , empty
    )

import Data.Food.Product as Products exposing (ImpactsForProcesses, Products)
import Data.Impact as Impact


type alias Db =
    { impacts : List Impact.Definition
    , processes : ImpactsForProcesses
    , products : Products
    }


empty : Db
empty =
    { impacts = []
    , processes = Products.emptyImpactsForProcesses
    , products = Products.emptyProducts
    }
