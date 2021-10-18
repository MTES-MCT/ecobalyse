module Data.Db exposing (..)

import Data.Country as Country exposing (Country)
import Data.CountryProcess as CountryProcess exposing (CountryProcesses)
import Data.Material as Material exposing (Material)
import Data.Process as Process exposing (Process)
import Data.Product as Product exposing (Product)
import Dict.Any as Dict exposing (AnyDict)
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


type alias LoadingCountryProcesses =
    AnyDict
        String
        Country
        { electricity : Process.Uuid
        , heat : Process.Uuid
        , dyeingWeighting : Float
        }


type alias LoadingState =
    { processes : WebData (List Process)
    , countryProcesses : WebData LoadingCountryProcesses
    , products : WebData (List Product)
    }


type alias Db =
    { countries : List Country
    , countryProcesses : CountryProcesses
    , materials : List Material
    , processes : List Process
    , products : List Product
    }


default : Db
default =
    { countries = Country.choices
    , countryProcesses = CountryProcess.countryProcesses
    , materials = Material.choices
    , processes = Process.processes
    , products = Product.choices
    }
