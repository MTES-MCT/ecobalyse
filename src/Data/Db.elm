module Data.Db exposing (..)

import Data.Country as Country exposing (Country)
import Data.Impact as Impact
import Data.Material as Material exposing (Material)
import Data.Process as Process exposing (Process)
import Data.Product as Product exposing (Product)
import Data.Transport as Transport exposing (Distances)
import Json.Decode as Decode exposing (Decoder)
import Url.Parser as Parser exposing (Parser)


type alias Db =
    { impacts : List Impact.Definition
    , processes : List Process
    , countries : List Country
    , materials : List Material
    , products : List Product
    , transports : Distances
    }


type Dataset
    = Impacts
    | Processes
    | Countries
    | Materials
    | Products
    | Transports


empty : Db
empty =
    { impacts = []
    , processes = []
    , countries = []
    , materials = []
    , products = []
    , transports = Transport.emptyDistances
    }


buildFromJson : String -> Result String Db
buildFromJson json =
    Decode.decodeString decode json
        |> Result.mapError Decode.errorToString


decode : Decoder Db
decode =
    Decode.field "impacts" Impact.decodeList
        |> Decode.andThen
            (\impacts ->
                Decode.field "processes" (Process.decodeList impacts)
                    |> Decode.andThen
                        (\processes ->
                            Decode.map4 (Db impacts processes)
                                (Decode.field "countries" (Country.decodeList processes))
                                (Decode.field "materials" (Material.decodeList processes))
                                (Decode.field "products" (Product.decodeList processes))
                                (Decode.field "transports" Transport.decodeDistances)
                        )
            )



-- Dataset


datasets : List Dataset
datasets =
    [ Countries
    , Impacts
    , Products
    , Materials
    , Processes
    , Transports
    ]


datasetStrings : Dataset -> { slug : String, label : String }
datasetStrings dataset =
    case dataset of
        Impacts ->
            { slug = "impacts", label = "Impacts" }

        Processes ->
            { slug = "processes", label = "Procédés" }

        Countries ->
            { slug = "countries", label = "Pays" }

        Materials ->
            { slug = "materials", label = "Matières" }

        Products ->
            { slug = "products", label = "Produits" }

        Transports ->
            { slug = "transports", label = "Transports" }


datasetFromSlug : String -> Dataset
datasetFromSlug string =
    case string of
        "impacts" ->
            Impacts

        "processes" ->
            Processes

        "materials" ->
            Materials

        "products" ->
            Products

        "transports" ->
            Transports

        _ ->
            Countries


datasetLabel : Dataset -> String
datasetLabel =
    datasetStrings >> .label



-- Parser


parseDatasetSlug : Parser (Dataset -> a) a
parseDatasetSlug =
    Parser.custom "DATASET" <|
        \string ->
            Just (datasetFromSlug string)
