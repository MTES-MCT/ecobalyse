module Request.Db exposing (..)

import Data.Country as Country exposing (Country2)
import Data.Db as Db exposing (Db)
import Data.Process as Process exposing (Process)
import Data.Product as Product exposing (Product)
import Data.Session exposing (Session)
import RemoteData exposing (WebData)
import RemoteData.Http as Http exposing (defaultConfig)


config : Http.Config
config =
    -- drop ALL headers because Parcel's proxy messes with them
    -- see https://stackoverflow.com/a/47840149/330911
    { defaultConfig | headers = [] }


getProcesses : Session -> (WebData (List Process) -> msg) -> Cmd msg
getProcesses _ event =
    Http.getWithConfig config "data/processes.json" event Process.decodeList


getCountries : Session -> (WebData (List Country2) -> msg) -> Cmd msg
getCountries _ event =
    Http.getWithConfig config "data/countries.json" event Country.decodeList2


getProducts : Session -> (WebData (List Product) -> msg) -> Cmd msg
getProducts _ event =
    Http.getWithConfig config "data/products.json" event Product.decodeList
