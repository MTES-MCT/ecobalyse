module Data.Db exposing (..)

import Data.Country exposing (Country2)
import Data.Material exposing (Material)
import Data.Process exposing (Process)
import Data.Product exposing (Product)


type alias Db =
    { countries : List Country2
    , materials : List Material
    , processes : List Process
    , products : List Product
    }
