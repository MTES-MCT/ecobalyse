module Data.Db exposing (..)

import Data.Country exposing (Country2)
import Data.Material exposing (Material)
import Data.Process exposing (Process)
import Data.Product exposing (Product)



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


type alias Db =
    { countries : List Country2
    , materials : List Material
    , processes : List Process
    , products : List Product
    }
