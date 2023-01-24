module Data.Dataset exposing
    ( Dataset(..)
    , datasets
    , label
    , parseSlug
    , slugWithId
    , toRoutePath
    )

import Data.Country as Country
import Data.Food.Ingredient as Ingredient
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
    | FoodIngredients (Maybe Ingredient.Id)
    | TextileProducts (Maybe Product.Id)
    | TextileMaterials (Maybe Material.Id)


datasets : List Dataset
datasets =
    [ Impacts Nothing
    , Countries Nothing
    , FoodIngredients Nothing
    , TextileProducts Nothing
    , TextileMaterials Nothing
    ]


fromSlug : String -> Dataset
fromSlug string =
    case string of
        "countries" ->
            Countries Nothing

        "ingredients" ->
            FoodIngredients Nothing

        "products" ->
            TextileProducts Nothing

        "materials" ->
            TextileMaterials Nothing

        _ ->
            Impacts Nothing


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

        FoodIngredients _ ->
            FoodIngredients (Just (Ingredient.idFromString idString))

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

        FoodIngredients _ ->
            { slug = "ingredients", label = "Ingrédients" }

        TextileProducts _ ->
            { slug = "products", label = "Produits" }

        TextileMaterials _ ->
            { slug = "materials", label = "Matières" }


toRoutePath : Dataset -> List String
toRoutePath dataset =
    case dataset of
        Countries Nothing ->
            [ slug dataset ]

        Countries (Just code) ->
            [ slug dataset, Country.codeToString code ]

        Impacts Nothing ->
            []

        FoodIngredients Nothing ->
            [ slug dataset ]

        FoodIngredients (Just id) ->
            [ slug dataset, Ingredient.idToString id ]

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
