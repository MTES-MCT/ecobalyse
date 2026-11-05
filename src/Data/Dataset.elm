module Data.Dataset exposing
    ( Dataset(..)
    , datasets
    , defaultDatasetFor
    , isDetailed
    , label
    , parseSlug
    , reset
    , same
    , setIdFromString
    , toRoutePath
    )

import Data.Component as Component
import Data.Component.ProductCategory as ProductCategory
import Data.Country.Code as CountryCode
import Data.Food.Ingredient as Ingredient
import Data.Impact.Definition as Definition
import Data.Process as Process
import Data.Scope as Scope exposing (Scope)
import Data.Textile.Material as Material
import Data.Textile.Product as Product
import Data.Uuid as Uuid exposing (Uuid)
import Dict exposing (Dict)
import Url.Parser as Parser exposing (Parser)


{-| A Dataset represents a target dataset and an optional id in this dataset.

It's used by Page.Explore and related routes.

-}
type Dataset
    = Components Scope (Maybe Component.Id)
    | Countries (Maybe CountryCode.Code)
    | FoodExamples (Maybe Uuid)
    | FoodIngredients (Maybe Ingredient.Id)
    | GenericExamples Scope.GenericScope (Maybe Uuid)
    | Impacts (Maybe Definition.Trigram)
    | Processes Scope (Maybe Process.Id)
    | ProductCategory Scope.GenericScope (Maybe ProductCategory.Id)
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

        Scope.Generic genericScope ->
            datasetsGeneric genericScope

        Scope.Textile ->
            [ TextileExamples Nothing
            , Components Scope.Textile Nothing
            , Impacts Nothing
            , TextileMaterials Nothing
            , Countries Nothing
            , Processes Scope.Textile Nothing
            , TextileProducts Nothing
            ]


datasetsGeneric : Scope.GenericScope -> List Dataset
datasetsGeneric scope =
    case scope of
        Scope.Apparel ->
            [ GenericExamples scope Nothing
            , Components (Scope.Generic scope) Nothing
            , Countries Nothing
            , Processes (Scope.Generic scope) Nothing
            , Impacts Nothing
            , ProductCategory scope Nothing
            ]

        Scope.Food2 ->
            [ GenericExamples scope Nothing
            , Impacts Nothing
            , Countries Nothing
            , Processes (Scope.Generic scope) Nothing
            , ProductCategory scope Nothing
            ]

        Scope.Object ->
            [ GenericExamples scope Nothing
            , Components (Scope.Generic scope) Nothing
            , Countries Nothing
            , Processes (Scope.Generic scope) Nothing
            , Impacts Nothing
            , ProductCategory scope Nothing
            ]

        Scope.Veli ->
            [ GenericExamples scope Nothing
            , Components (Scope.Generic scope) Nothing
            , Countries Nothing
            , Impacts Nothing
            , Processes (Scope.Generic scope) Nothing
            , ProductCategory scope Nothing
            ]


defaultDatasetFor : Scope -> Dataset
defaultDatasetFor scope =
    case scope of
        Scope.Food ->
            FoodExamples Nothing

        Scope.Generic genericScope ->
            GenericExamples genericScope Nothing

        Scope.Textile ->
            TextileExamples Nothing


fromSlug : String -> Dataset
fromSlug string =
    case Dict.get string datasetSlugDict of
        Just dataset ->
            dataset

        Nothing ->
            TextileExamples Nothing


datasetSlugDict : Dict String Dataset
datasetSlugDict =
    List.concat
        [ [ Countries Nothing
          , FoodExamples Nothing
          , FoodIngredients Nothing
          , Impacts Nothing
          , TextileExamples Nothing
          , TextileMaterials Nothing
          , TextileProducts Nothing
          ]
        , List.map (\s -> Components s Nothing) Scope.all
        , List.map (\s -> Processes s Nothing) Scope.all
        , List.map (\s -> GenericExamples s Nothing) Scope.allGeneric
        , List.map (\s -> ProductCategory s Nothing) Scope.allGeneric
        ]
        |> List.foldl (\dataset dict -> Dict.insert (datasetToString dataset) dataset dict) Dict.empty
        |> Dict.insert "textile-processes" (Processes Scope.Textile Nothing)


datasetToString : Dataset -> String
datasetToString string =
    case string of
        Components scope _ ->
            componentDatasetToString scope

        Countries _ ->
            "countries"

        FoodExamples _ ->
            "food-examples"

        FoodIngredients _ ->
            "ingredients"

        GenericExamples scope _ ->
            examplesDatasetToString scope

        Impacts _ ->
            "impacts"

        Processes scope _ ->
            processesDatasetToString scope

        ProductCategory scope _ ->
            productCategoryDatasetToString scope

        TextileExamples _ ->
            "textile-examples"

        TextileMaterials _ ->
            "materials"

        TextileProducts _ ->
            "products"


componentDatasetToString : Scope -> String
componentDatasetToString scope =
    case scope of
        Scope.Food ->
            "food-components"

        Scope.Generic genericScope ->
            componentGenericDatasetToString genericScope

        Scope.Textile ->
            "textile-components"


componentGenericDatasetToString : Scope.GenericScope -> String
componentGenericDatasetToString scope =
    case scope of
        Scope.Apparel ->
            "apparel-components"

        Scope.Food2 ->
            "food2-components"

        Scope.Object ->
            "object-components"

        Scope.Veli ->
            "veli-components"


processesDatasetToString : Scope -> String
processesDatasetToString scope =
    case scope of
        Scope.Food ->
            "food-processes"

        Scope.Generic genericScope ->
            processesDatasetGenericToString genericScope

        Scope.Textile ->
            "processes"


processesDatasetGenericToString : Scope.GenericScope -> String
processesDatasetGenericToString scope =
    case scope of
        Scope.Apparel ->
            "apparel-processes"

        Scope.Food2 ->
            "food2-processes"

        Scope.Object ->
            "object-processes"

        Scope.Veli ->
            "veli-processes"


examplesDatasetToString : Scope.GenericScope -> String
examplesDatasetToString scope =
    case scope of
        Scope.Apparel ->
            "apparel-examples"

        Scope.Food2 ->
            "food2-examples"

        Scope.Object ->
            "object-examples"

        Scope.Veli ->
            "veli-examples"


productCategoryDatasetToString : Scope.GenericScope -> String
productCategoryDatasetToString scope =
    case scope of
        Scope.Apparel ->
            "apparel-product-categories"

        Scope.Food2 ->
            "food2-product-categories"

        Scope.Object ->
            "object-product-categories"

        Scope.Veli ->
            "veli-product-categories"


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

        GenericExamples _ (Just _) ->
            True

        Impacts (Just _) ->
            True

        Processes _ (Just _) ->
            True

        ProductCategory _ (Just _) ->
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

        GenericExamples scope _ ->
            GenericExamples scope Nothing

        Impacts _ ->
            Impacts Nothing

        Processes scope _ ->
            Processes scope Nothing

        ProductCategory scope _ ->
            ProductCategory scope Nothing

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

        ( ProductCategory scope1 _, ProductCategory scope2 _ ) ->
            scope1 == scope2

        ( Impacts _, Impacts _ ) ->
            True

        ( TextileExamples _, TextileExamples _ ) ->
            True

        ( Components scope1 _, Components scope2 _ ) ->
            scope1 == scope2

        ( GenericExamples scope1 _, GenericExamples scope2 _ ) ->
            scope1 == scope2

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
            Countries (Just (CountryCode.fromString idString))

        FoodExamples _ ->
            FoodExamples (idString |> Uuid.fromString |> Result.toMaybe)

        FoodIngredients _ ->
            FoodIngredients (idString |> Ingredient.idFromString |> Result.toMaybe)

        GenericExamples scope _ ->
            GenericExamples scope (idString |> Uuid.fromString |> Result.toMaybe)

        Impacts _ ->
            Impacts (Definition.toTrigram idString |> Result.toMaybe)

        Processes scope _ ->
            Processes scope (Process.idFromString idString |> Result.toMaybe)

        ProductCategory scope _ ->
            ProductCategory scope (ProductCategory.idFromString idString |> Result.toMaybe)

        TextileExamples _ ->
            TextileExamples (idString |> Uuid.fromString |> Result.toMaybe)

        TextileMaterials _ ->
            TextileMaterials (Material.idFromString idString |> Result.toMaybe)

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

        GenericExamples genericScope _ ->
            { label = "Exemples", slug = Scope.toString (Scope.Generic genericScope) ++ "-examples" }

        Impacts _ ->
            { label = "Impacts", slug = "impacts" }

        Processes scope _ ->
            { label = "Procédés", slug = Scope.toString scope ++ "-processes" }

        ProductCategory genericScope _ ->
            { label = "Produits", slug = Scope.toString (Scope.Generic genericScope) ++ "-product-categories" }

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
            [ slug dataset, CountryCode.toString code ]

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

        GenericExamples _ (Just id) ->
            [ slug dataset, Uuid.toString id ]

        GenericExamples _ Nothing ->
            [ slug dataset ]

        Impacts (Just trigram) ->
            [ slug dataset, Definition.toString trigram ]

        Impacts Nothing ->
            [ slug dataset ]

        Processes _ (Just id) ->
            [ slug dataset, Process.idToString id ]

        Processes _ Nothing ->
            [ slug dataset ]

        ProductCategory _ (Just id) ->
            [ slug dataset, ProductCategory.idToString id ]

        ProductCategory _ Nothing ->
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
