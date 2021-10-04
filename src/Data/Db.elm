module Data.Db exposing (..)

import Data.Country as Country exposing (Country)
import Data.CountryProcess as CountryProcess exposing (CountryProcess, CountryProcesses)
import Data.Material as Material exposing (Material)
import Data.Process as Process exposing (Process)
import Data.Product as Product exposing (Product)


type Db
    = Empty
    | Errored String
    | ProcessesLoaded (List Process)
    | CountryProcessesLoaded (List Process) (List Country) CountryProcesses
    | ProductsLoaded (List Process) (List Country) CountryProcesses (List Product)
    | Ready Data


type alias Data =
    { countries : List Country
    , countryProcesses : CountryProcesses
    , materials : List Material
    , processes : List Process
    , products : List Product
    }


default : Data
default =
    { countries = Country.choices
    , countryProcesses = CountryProcess.countryProcesses
    , materials = Material.choices
    , processes = Process.processes
    , products = Product.choices
    }


setProcesses : Result String (List Process) -> Db -> Db
setProcesses result db =
    case ( db, result ) of
        ( Empty, Ok processes ) ->
            ProcessesLoaded processes

        ( _, Err error ) ->
            Errored error

        _ ->
            Errored "Invalid db state"


setCountries : Result String CountryProcesses -> Db -> Db
setCountries result db =
    case ( db, result ) of
        ( ProcessesLoaded processes, Ok countryProcesses ) ->
            CountryProcessesLoaded
                processes
                (CountryProcess.countries countryProcesses)
                countryProcesses

        ( _, Err error ) ->
            Errored error

        _ ->
            Errored "Invalid db state"



-- setProducts : Result String (List Product) -> Db -> Db
-- setProducts result db =
--     case ( db, result ) of
--         ( ProcessesLoaded processes, Ok products ) ->
--             ProductsLoaded processes products
--         _ ->
--             Errored "Processes can only be set from the Empty state"
