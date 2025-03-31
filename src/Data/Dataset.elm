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

import Data.Component as Component
import Data.Country as Country
import Data.Food.Ingredient as Ingredient
import Data.Impact.Definition as Definition
import Data.Process as Process
import Data.Scope as Scope exposing (Scope)
import Data.Textile.Material as Material
import Data.Textile.Product as Product
import Data.Uuid as Uuid exposing (Uuid)
import Url.Parser as Parser exposing (Parser)


{-| A Dataset represents a target dataset and an optional id in this dataset.

It's used by Page.Explore and related routes.

-}
type Dataset
    = Components Scope (Maybe Component.Id)
    | Countries (Maybe Country.Code)
    | FoodExamples (Maybe Uuid)
    | FoodIngredients (Maybe Ingredient.Id)
    | Impacts (Maybe Definition.Trigram)
    | ObjectExamples (Maybe Uuid)
    | Processes Scope (Maybe Process.Id)
    | TextileExamples (Maybe Uuid)
    | TextileMaterials (Maybe Material.Id)
    | TextileProducts (Maybe Product.Id)


datasets : Scope -> List Dataset
datasets scope =
    case scope of
        Scope.Food ->
            [ FoodExamples Nothing
            , Impacts Nothing
            , FoodIngredients Nothing
            , Countries Nothing
            , Processes Scope.Food Nothing
            ]

        Scope.Object ->
            [ ObjectExamples Nothing
            , Components Scope.Object Nothing
            , Processes Scope.Object Nothing
            , Impacts Nothing
            ]

        Scope.Textile ->
            [ TextileExamples Nothing
            , Components Scope.Textile Nothing
            , Impacts Nothing
            , TextileMaterials Nothing
            , Countries Nothing
            , Processes Scope.Textile Nothing
            , TextileProducts Nothing
            ]

        Scope.Veli ->
            [ Impacts Nothing
            ]


fromSlug : String -> Dataset
fromSlug string =
    case string of
        "countries" ->
            Countries Nothing

        "food-examples" ->
            FoodExamples Nothing

        "food-processes" ->
            Processes Scope.Food Nothing

        "impacts" ->
            Impacts Nothing

        "ingredients" ->
            FoodIngredients Nothing

        "materials" ->
            TextileMaterials Nothing

        "object-components" ->
            Components Scope.Object Nothing

        "object-examples" ->
            ObjectExamples Nothing

        "object-processes" ->
            Processes Scope.Object Nothing

        "processes" ->
            Processes Scope.Textile Nothing

        "products" ->
            TextileProducts Nothing

        "textile-components" ->
            Components Scope.Textile Nothing

        "textile-processes" ->
            Processes Scope.Textile Nothing

        _ ->
            TextileExamples Nothing


isDetailed : Dataset -> Bool
isDetailed dataset =
    case dataset of
        Components _ (Just _) ->
            True

        Countries (Just _) ->
            True

        FoodExamples (Just _) ->
            True

        FoodIngredients (Just _) ->
            True

        Impacts (Just _) ->
            True

        ObjectExamples (Just _) ->
            True

        Processes _ (Just _) ->
            True

        TextileExamples (Just _) ->
            True

        TextileMaterials (Just _) ->
            True

        TextileProducts (Just _) ->
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
        Components scope _ ->
            Components scope Nothing

        Countries _ ->
            Countries Nothing

        FoodExamples _ ->
            FoodExamples Nothing

        FoodIngredients _ ->
            FoodIngredients Nothing

        Impacts _ ->
            Impacts Nothing

        ObjectExamples _ ->
            ObjectExamples Nothing

        Processes scope _ ->
            Processes scope Nothing

        TextileExamples _ ->
            TextileExamples Nothing

        TextileMaterials _ ->
            TextileMaterials Nothing

        TextileProducts _ ->
            TextileProducts Nothing


same : Dataset -> Dataset -> Bool
same a b =
    case ( a, b ) of
        ( Countries _, Countries _ ) ->
            True

        ( FoodExamples _, FoodExamples _ ) ->
            True

        ( FoodIngredients _, FoodIngredients _ ) ->
            True

        ( Processes scope1 _, Processes scope2 _ ) ->
            scope1 == scope2

        ( Impacts _, Impacts _ ) ->
            True

        ( TextileExamples _, TextileExamples _ ) ->
            True

        ( Components scope1 _, Components scope2 _ ) ->
            scope1 == scope2

        ( ObjectExamples _, ObjectExamples _ ) ->
            True

        ( TextileMaterials _, TextileMaterials _ ) ->
            True

        ( TextileProducts _, TextileProducts _ ) ->
            True

        _ ->
            False


setIdFromString : String -> Dataset -> Dataset
setIdFromString idString dataset =
    case dataset of
        Components scope _ ->
            Components scope (Component.idFromString idString |> Result.toMaybe)

        Countries _ ->
            Countries (Just (Country.codeFromString idString))

        FoodExamples _ ->
            FoodExamples (Uuid.fromString idString)

        FoodIngredients _ ->
            FoodIngredients (Ingredient.idFromString idString)

        Impacts _ ->
            Impacts (Definition.toTrigram idString |> Result.toMaybe)

        ObjectExamples _ ->
            ObjectExamples (Uuid.fromString idString)

        Processes scope _ ->
            Processes scope (Process.idFromString idString |> Result.toMaybe)

        TextileExamples _ ->
            TextileExamples (Uuid.fromString idString)

        TextileMaterials _ ->
            TextileMaterials (Just (Material.Id idString))

        TextileProducts _ ->
            TextileProducts (Just (Product.Id idString))


slug : Dataset -> String
slug =
    strings >> .slug


strings : Dataset -> { label : String, slug : String }
strings dataset =
    case dataset of
        Components scope _ ->
            { label = "Composants", slug = Scope.toString scope ++ "-components" }

        Countries _ ->
            { label = "Pays", slug = "countries" }

        FoodExamples _ ->
            { label = "Exemples", slug = "food-examples" }

        FoodIngredients _ ->
            { label = "Ingrédients", slug = "ingredients" }

        Impacts _ ->
            { label = "Impacts", slug = "impacts" }

        ObjectExamples _ ->
            { label = "Exemples", slug = "object-examples" }

        Processes scope _ ->
            { label = "Procédés", slug = Scope.toString scope ++ "-processes" }

        TextileExamples _ ->
            { label = "Exemples", slug = "textile-examples" }

        TextileMaterials _ ->
            { label = "Matières", slug = "materials" }

        TextileProducts _ ->
            { label = "Produits", slug = "products" }


toRoutePath : Dataset -> List String
toRoutePath dataset =
    case dataset of
        Components _ (Just id) ->
            [ slug dataset, Component.idToString id ]

        Components _ Nothing ->
            [ slug dataset ]

        Countries (Just code) ->
            [ slug dataset, Country.codeToString code ]

        Countries Nothing ->
            [ slug dataset ]

        FoodExamples (Just id) ->
            [ slug dataset, Uuid.toString id ]

        FoodExamples Nothing ->
            [ slug dataset ]

        FoodIngredients (Just id) ->
            [ slug dataset, Ingredient.idToString id ]

        FoodIngredients Nothing ->
            [ slug dataset ]

        Impacts (Just trigram) ->
            [ slug dataset, Definition.toString trigram ]

        Impacts Nothing ->
            [ slug dataset ]

        ObjectExamples (Just id) ->
            [ slug dataset, Uuid.toString id ]

        ObjectExamples Nothing ->
            [ slug dataset ]

        Processes _ (Just id) ->
            [ slug dataset, Process.idToString id ]

        Processes _ Nothing ->
            [ slug dataset ]

        TextileExamples (Just id) ->
            [ slug dataset, Uuid.toString id ]

        TextileExamples Nothing ->
            [ slug dataset ]

        TextileMaterials (Just id) ->
            [ slug dataset, Material.idToString id ]

        TextileMaterials Nothing ->
            [ slug dataset ]

        TextileProducts (Just id) ->
            [ slug dataset, Product.idToString id ]

        TextileProducts Nothing ->
            [ slug dataset ]
