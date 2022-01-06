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
    = Impacts (Maybe Impact.Trigram)
    | Countries (Maybe Country.Code)
    | Materials (Maybe Process.Uuid)
    | Products (Maybe Product.Id)


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
    [ Countries Nothing
    , Impacts Nothing
    , Products Nothing
    , Materials Nothing
    ]


datasetStrings : Dataset -> { slug : String, label : String }
datasetStrings dataset =
    case dataset of
        Countries _ ->
            { slug = "countries", label = "Pays" }

        Impacts _ ->
            { slug = "impacts", label = "Impacts" }

        Products _ ->
            { slug = "products", label = "Produits" }

        Materials _ ->
            { slug = "materials", label = "Matières" }


datasetFromSlug : String -> Dataset
datasetFromSlug string =
    case string of
        "impacts" ->
            Impacts Nothing

        "materials" ->
            Materials Nothing

        "products" ->
            Products Nothing

        _ ->
            Countries Nothing


datasetLabel : Dataset -> String
datasetLabel =
    datasetStrings >> .label



-- Parser


parseDatasetSlug : Parser (Dataset -> a) a
parseDatasetSlug =
    Parser.custom "DATASET" <|
        \string ->
            Just (datasetFromSlug string)
