module Data.Ecobalyse.Db exposing
    ( Db
    , empty
    )

import Data.Ecobalyse.Process as Process exposing (Processes)
import Data.Ecobalyse.Product exposing (Products)
import Data.Impact as Impact
import RemoteData


type alias Db =
    { impacts : List Impact.Definition
    , processes : Processes
    , products : RemoteData.WebData Products
    }


empty : Db
empty =
    { impacts = []
    , processes = Process.empty
    , products = RemoteData.NotAsked
    }
