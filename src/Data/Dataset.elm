module Data.Dataset exposing
    ( Dataset(..)
    , datasets
    , label
    , parseSlug
    , slugWithId
    , toRoutePath
    )

import Data.Country as Country
import Data.Impact as Impact
import Data.Textile.Material as Material
import Data.Textile.Product as Product
import Url.Parser as Parser exposing (Parser)


{-| A Dataset represents a target dataset and an optional id in this dataset.

It's used by Page.Explore and related routes.

-}
type Dataset
    = Countries (Maybe Country.Code)
    | Impacts (Maybe Impact.Trigram)
    | TextileProducts (Maybe Product.Id)
    | TextileMaterials (Maybe Material.Id)


datasets : List Dataset
datasets =
    [ Countries Nothing
    , Impacts Nothing
    , TextileProducts Nothing
    , TextileMaterials Nothing
    ]


fromSlug : String -> Dataset
fromSlug string =
    case string of
        "impacts" ->
            Impacts Nothing

        "products" ->
            TextileProducts Nothing

        "materials" ->
            TextileMaterials Nothing

        _ ->
            Countries Nothing


label : Dataset -> String
label =
    strings >> .label


parseSlug : Parser (Dataset -> a) a
parseSlug =
    Parser.custom "DATASET" <|
        \string ->
            Just (fromSlug string)


slug : Dataset -> String
slug =
    strings >> .slug


slugWithId : Dataset -> String -> Dataset
slugWithId dataset idString =
    case dataset of
        Countries _ ->
            Countries (Just (Country.codeFromString idString))

        Impacts _ ->
            Impacts (Just (Impact.trg idString))

        TextileProducts _ ->
            TextileProducts (Just (Product.Id idString))

        TextileMaterials _ ->
            TextileMaterials (Just (Material.Id idString))


strings : Dataset -> { slug : String, label : String }
strings dataset =
    case dataset of
        Countries _ ->
            { slug = "countries", label = "Pays" }

        Impacts _ ->
            { slug = "impacts", label = "Impacts" }

        TextileProducts _ ->
            { slug = "products", label = "Produits" }

        TextileMaterials _ ->
            { slug = "materials", label = "Matières" }


toRoutePath : Dataset -> List String
toRoutePath dataset =
    case dataset of
        Countries Nothing ->
            []

        Countries (Just code) ->
            [ slug dataset, Country.codeToString code ]

        Impacts Nothing ->
            [ slug dataset ]

        Impacts (Just trigram) ->
            [ slug dataset, Impact.toString trigram ]

        TextileProducts Nothing ->
            [ slug dataset ]

        TextileProducts (Just id) ->
            [ slug dataset, Product.idToString id ]

        TextileMaterials Nothing ->
            [ slug dataset ]

        TextileMaterials (Just id) ->
            [ slug dataset, Material.idToString id ]
