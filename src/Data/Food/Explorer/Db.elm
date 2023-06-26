module Data.Food.Explorer.Db exposing
    ( Db
    , buildFromJson
    , empty
    , isEmpty
    )

import Data.Country exposing (Country)
import Data.Food.Process as Process exposing (Process)
import Data.Food.Product as Product exposing (Products)
import Data.Textile.Db as TextileDb
import Data.Transport as Transport
import Json.Decode as Decode


type alias Db =
    { -- Common datasources
      countries : List Country
    , transports : Transport.Distances

    ---- Processes are straightforward imports of public/data/food/processes/explorer.json
    , processes : List Process

    ---- Products are imported from public/data/food/products.json with several layers:
    ---- Product
    ----    Step (consumer, packaging, ...)
    ----        Category (material, processing, waste treatment, ...)
    ----            Ingredient (amount, process -- from the processes db --)
    , products : Products
    }


empty : Db
empty =
    { countries = []
    , transports = Transport.emptyDistances
    , processes = []
    , products = Product.emptyProducts
    }


isEmpty : Db -> Bool
isEmpty db =
    db == empty


buildFromJson : TextileDb.Db -> String -> String -> Result String Db
buildFromJson { impactDefinitions, countries, transports } processesJson productsJson =
    processesJson
        |> Decode.decodeString (Process.decodeList impactDefinitions)
        |> Result.andThen
            (\processes ->
                productsJson
                    |> Decode.decodeString (Product.decodeProducts processes)
                    |> Result.map (Db countries transports processes)
            )
        |> Result.mapError Decode.errorToString
