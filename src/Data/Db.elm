module Data.Db exposing (..)

import Data.Country as Country exposing (Country)
import Data.Material as Material exposing (Material)
import Data.Process as Process exposing (Process)
import Data.Product as Product exposing (Product)
import RemoteData exposing (WebData)



-- TODO:
-- - refactor to have two types: Db and Data:
--   * Data has all its members Maybe(WebData x)
--   * Db has all its members set
--
-- Loading order:
-- 1. processes (so we get materials)
-- 2. country processes (so we get countries as well)
-- 3. products
--
-- Notes:
-- - investigate using RemoteData.fromList https://package.elm-lang.org/packages/krisajenkins/remotedata/latest/RemoteData#fromList


type alias LoadingState =
    { processes : WebData (List Process)
    , countries : WebData (List Country)
    , products : WebData (List Product)
    }


type alias Db =
    { countries : List Country
    , materials : List Material
    , processes : List Process
    , products : List Product
    }


default : Db
default =
    { countries = Country.choices
    , materials = Material.choices
    , processes = Process.processes
    , products = Product.choices
    }
