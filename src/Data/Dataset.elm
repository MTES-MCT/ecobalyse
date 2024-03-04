module Data.Dataset exposing
    ( Dataset(..)
    , datasets
    , isDetailed
    , label
    , parseSlug
    , reset
    , same
    , setIdFromString
    , toRoutePath
    )

import Data.Country as Country
import Data.Food.ExampleProduct as FoodExample
import Data.Food.Ingredient as Ingredient
import Data.Food.Process as FoodProcess
import Data.Impact.Definition as Definition
import Data.Scope as Scope exposing (Scope)
import Data.Textile.ExampleProduct as TextileExample
import Data.Textile.Material as Material
import Data.Textile.Process as Process
import Data.Textile.Product as Product
import Url.Parser as Parser exposing (Parser)


{-| A Dataset represents a target dataset and an optional id in this dataset.

It's used by Page.Explore and related routes.

-}
type Dataset
    = Countries (Maybe Country.Code)
    | Impacts (Maybe Definition.Trigram)
    | FoodExamples (Maybe FoodExample.Uuid)
    | FoodIngredients (Maybe Ingredient.Id)
    | FoodProcesses (Maybe FoodProcess.Identifier)
    | TextileExamples (Maybe TextileExample.Uuid)
    | TextileProducts (Maybe Product.Id)
    | TextileMaterials (Maybe Material.Id)
    | TextileProcesses (Maybe Process.Uuid)


datasets : Scope -> List Dataset
datasets scope =
    case scope of
        Scope.Food ->
            [ FoodExamples Nothing
            , Countries Nothing
            , Impacts Nothing
            , FoodIngredients Nothing
            , FoodProcesses Nothing
            ]

        Scope.Textile ->
            [ TextileExamples Nothing
            , Countries Nothing
            , Impacts Nothing
            , TextileProducts Nothing
            , TextileMaterials Nothing
            , TextileProcesses Nothing
            ]


fromSlug : String -> Dataset
fromSlug string =
    case string of
        "countries" ->
            Countries Nothing

        "impacts" ->
            Impacts Nothing

        "food-examples" ->
            FoodExamples Nothing

        "ingredients" ->
            FoodIngredients Nothing

        "food-processes" ->
            FoodProcesses Nothing

        "products" ->
            TextileProducts Nothing

        "materials" ->
            TextileMaterials Nothing

        "processes" ->
            TextileProcesses Nothing

        _ ->
            TextileExamples Nothing


isDetailed : Dataset -> Bool
isDetailed dataset =
    case dataset of
        Countries (Just _) ->
            True

        Impacts (Just _) ->
            True

        FoodExamples (Just _) ->
            True

        FoodIngredients (Just _) ->
            True

        FoodProcesses (Just _) ->
            True

        TextileExamples (Just _) ->
            True

        TextileProducts (Just _) ->
            True

        TextileMaterials (Just _) ->
            True

        TextileProcesses (Just _) ->
            True

        _ ->
            False


label : Dataset -> String
label =
    strings >> .label


parseSlug : Parser (Dataset -> a) a
parseSlug =
    Parser.custom "DATASET" (fromSlug >> Just)


reset : Dataset -> Dataset
reset dataset =
    case dataset of
        Countries _ ->
            Countries Nothing

        Impacts _ ->
            Impacts Nothing

        FoodExamples _ ->
            FoodExamples Nothing

        FoodIngredients _ ->
            FoodIngredients Nothing

        FoodProcesses _ ->
            FoodProcesses Nothing

        TextileExamples _ ->
            TextileExamples Nothing

        TextileProducts _ ->
            TextileProducts Nothing

        TextileMaterials _ ->
            TextileMaterials Nothing

        TextileProcesses _ ->
            TextileProcesses Nothing


same : Dataset -> Dataset -> Bool
same a b =
    case ( a, b ) of
        ( Countries _, Countries _ ) ->
            True

        ( Impacts _, Impacts _ ) ->
            True

        ( FoodExamples _, FoodExamples _ ) ->
            True

        ( FoodIngredients _, FoodIngredients _ ) ->
            True

        ( FoodProcesses _, FoodProcesses _ ) ->
            True

        ( TextileExamples _, TextileExamples _ ) ->
            True

        ( TextileProducts _, TextileProducts _ ) ->
            True

        ( TextileMaterials _, TextileMaterials _ ) ->
            True

        ( TextileProcesses _, TextileProcesses _ ) ->
            True

        _ ->
            False


setIdFromString : String -> Dataset -> Dataset
setIdFromString idString dataset =
    case dataset of
        Countries _ ->
            Countries (Just (Country.codeFromString idString))

        Impacts _ ->
            Impacts (Definition.toTrigram idString |> Result.toMaybe)

        FoodExamples _ ->
            FoodExamples (Just (FoodExample.uuidFromString idString))

        FoodIngredients _ ->
            FoodIngredients (Just (Ingredient.idFromString idString))

        FoodProcesses _ ->
            FoodProcesses (Just (FoodProcess.codeFromString idString))

        TextileExamples _ ->
            TextileExamples (Just (TextileExample.uuidFromString idString))

        TextileProducts _ ->
            TextileProducts (Just (Product.Id idString))

        TextileMaterials _ ->
            TextileMaterials (Just (Material.Id idString))

        TextileProcesses _ ->
            TextileProcesses (Just (Process.Uuid idString))


slug : Dataset -> String
slug =
    strings >> .slug


strings : Dataset -> { slug : String, label : String }
strings dataset =
    case dataset of
        Countries _ ->
            { slug = "countries", label = "Pays" }

        Impacts _ ->
            { slug = "impacts", label = "Impacts" }

        FoodExamples _ ->
            { slug = "food-examples", label = "Exemples" }

        FoodIngredients _ ->
            { slug = "ingredients", label = "Ingrédients" }

        FoodProcesses _ ->
            { slug = "food-processes", label = "Procédés" }

        TextileExamples _ ->
            { slug = "textile-examples", label = "Exemples" }

        TextileProducts _ ->
            { slug = "products", label = "Produits" }

        TextileMaterials _ ->
            { slug = "materials", label = "Matières" }

        TextileProcesses _ ->
            { slug = "processes", label = "Procédés" }


toRoutePath : Dataset -> List String
toRoutePath dataset =
    case dataset of
        Countries Nothing ->
            [ slug dataset ]

        Countries (Just code) ->
            [ slug dataset, Country.codeToString code ]

        FoodExamples Nothing ->
            [ slug dataset ]

        FoodExamples (Just id) ->
            [ slug dataset, FoodExample.uuidToString id ]

        FoodIngredients Nothing ->
            [ slug dataset ]

        FoodIngredients (Just id) ->
            [ slug dataset, Ingredient.idToString id ]

        FoodProcesses Nothing ->
            [ slug dataset ]

        FoodProcesses (Just id) ->
            [ slug dataset, FoodProcess.codeToString id ]

        Impacts Nothing ->
            [ slug dataset ]

        Impacts (Just trigram) ->
            [ slug dataset, Definition.toString trigram ]

        TextileExamples Nothing ->
            [ slug dataset ]

        TextileExamples (Just id) ->
            [ slug dataset, TextileExample.uuidToString id ]

        TextileProducts Nothing ->
            [ slug dataset ]

        TextileProducts (Just id) ->
            [ slug dataset, Product.idToString id ]

        TextileMaterials Nothing ->
            [ slug dataset ]

        TextileMaterials (Just id) ->
            [ slug dataset, Material.idToString id ]

        TextileProcesses Nothing ->
            [ slug dataset ]

        TextileProcesses (Just id) ->
            [ slug dataset, Process.uuidToString id ]
