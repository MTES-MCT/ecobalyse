module Data.Db exposing
    ( Dataset(..)
    , Db
    , buildFromJson
    , datasetLabel
    , datasetSlugWithId
    , datasets
    , empty
    , parseDatasetSlug
    , toDatasetRoutePath
    )

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


{-| A Dataset represents a target dataset and an optional id in this dataset.

It's used by Page.Explore and related routes.

-}
type Dataset
    = Countries (Maybe Country.Code)
    | Impacts (Maybe Impact.Trigram)
    | Products (Maybe Product.Id)
    | Materials (Maybe Material.Id)


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

        "products" ->
            Products Nothing

        "materials" ->
            Materials Nothing

        _ ->
            Countries Nothing


datasetLabel : Dataset -> String
datasetLabel =
    datasetStrings >> .label


datasetSlug : Dataset -> String
datasetSlug =
    datasetStrings >> .slug


parseDatasetSlug : Parser (Dataset -> a) a
parseDatasetSlug =
    Parser.custom "DATASET" <|
        \string ->
            Just (datasetFromSlug string)


datasetSlugWithId : Dataset -> String -> Dataset
datasetSlugWithId dataset idString =
    case dataset of
        Countries _ ->
            Countries (Just (Country.codeFromString idString))

        Impacts _ ->
            Impacts (Just (Impact.trg idString))

        Products _ ->
            Products (Just (Product.Id idString))

        Materials _ ->
            Materials (Just (Material.Id idString))


toDatasetRoutePath : Dataset -> List String
toDatasetRoutePath dataset =
    case dataset of
        Countries Nothing ->
            []

        Countries (Just code) ->
            [ datasetSlug dataset, Country.codeToString code ]

        Impacts Nothing ->
            [ datasetSlug dataset ]

        Impacts (Just trigram) ->
            [ datasetSlug dataset, Impact.toString trigram ]

        Products Nothing ->
            [ datasetSlug dataset ]

        Products (Just id) ->
            [ datasetSlug dataset, Product.idToString id ]

        Materials Nothing ->
            [ datasetSlug dataset ]

        Materials (Just id) ->
            [ datasetSlug dataset, Material.idToString id ]
