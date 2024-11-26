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
import Data.Food.Ingredient as Ingredient
import Data.Food.Process as FoodProcess
import Data.Impact.Definition as Definition
import Data.Object.Component as ObjectComponent
import Data.Object.Process as ObjectProcess
import Data.Scope as Scope exposing (Scope)
import Data.Textile.Material as Material
import Data.Textile.Process as Process
import Data.Textile.Product as Product
import Data.Uuid as Uuid exposing (Uuid)
import Url.Parser as Parser exposing (Parser)


{-| A Dataset represents a target dataset and an optional id in this dataset.

It's used by Page.Explore and related routes.

-}
type Dataset
    = Countries (Maybe Country.Code)
    | FoodExamples (Maybe Uuid)
    | FoodIngredients (Maybe Ingredient.Id)
    | FoodProcesses (Maybe FoodProcess.Identifier)
    | Impacts (Maybe Definition.Trigram)
    | ObjectComponents (Maybe ObjectComponent.Id)
    | ObjectExamples (Maybe Uuid)
    | ObjectProcesses (Maybe ObjectProcess.Id)
    | TextileExamples (Maybe Uuid)
    | TextileMaterials (Maybe Material.Id)
    | TextileProcesses (Maybe Process.Uuid)
    | TextileProducts (Maybe Product.Id)


datasets : Scope -> List Dataset
datasets scope =
    case scope of
        Scope.Food ->
            [ FoodExamples Nothing
            , Impacts Nothing
            , FoodIngredients Nothing
            , Countries Nothing
            , FoodProcesses Nothing
            ]

        Scope.Object ->
            [ ObjectExamples Nothing
            , ObjectComponents Nothing
            , ObjectProcesses Nothing
            , Impacts Nothing
            ]

        Scope.Textile ->
            [ TextileExamples Nothing
            , Impacts Nothing
            , TextileMaterials Nothing
            , Countries Nothing
            , TextileProcesses Nothing
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
            FoodProcesses Nothing

        "impacts" ->
            Impacts Nothing

        "ingredients" ->
            FoodIngredients Nothing

        "materials" ->
            TextileMaterials Nothing

        "object-components" ->
            ObjectComponents Nothing

        "object-examples" ->
            ObjectExamples Nothing

        "object-processes" ->
            ObjectProcesses Nothing

        "processes" ->
            TextileProcesses Nothing

        "products" ->
            TextileProducts Nothing

        _ ->
            TextileExamples Nothing


isDetailed : Dataset -> Bool
isDetailed dataset =
    case dataset of
        Countries (Just _) ->
            True

        FoodExamples (Just _) ->
            True

        FoodIngredients (Just _) ->
            True

        FoodProcesses (Just _) ->
            True

        Impacts (Just _) ->
            True

        ObjectComponents (Just _) ->
            True

        ObjectExamples (Just _) ->
            True

        ObjectProcesses (Just _) ->
            True

        TextileExamples (Just _) ->
            True

        TextileMaterials (Just _) ->
            True

        TextileProcesses (Just _) ->
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
        Countries _ ->
            Countries Nothing

        FoodExamples _ ->
            FoodExamples Nothing

        FoodIngredients _ ->
            FoodIngredients Nothing

        FoodProcesses _ ->
            FoodProcesses Nothing

        Impacts _ ->
            Impacts Nothing

        ObjectComponents _ ->
            ObjectComponents Nothing

        ObjectExamples _ ->
            ObjectExamples Nothing

        ObjectProcesses _ ->
            ObjectProcesses Nothing

        TextileExamples _ ->
            TextileExamples Nothing

        TextileMaterials _ ->
            TextileMaterials Nothing

        TextileProcesses _ ->
            TextileProcesses Nothing

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

        ( FoodProcesses _, FoodProcesses _ ) ->
            True

        ( Impacts _, Impacts _ ) ->
            True

        ( TextileExamples _, TextileExamples _ ) ->
            True

        ( ObjectComponents _, ObjectComponents _ ) ->
            True

        ( ObjectExamples _, ObjectExamples _ ) ->
            True

        ( ObjectProcesses _, ObjectProcesses _ ) ->
            True

        ( TextileMaterials _, TextileMaterials _ ) ->
            True

        ( TextileProcesses _, TextileProcesses _ ) ->
            True

        ( TextileProducts _, TextileProducts _ ) ->
            True

        _ ->
            False


setIdFromString : String -> Dataset -> Dataset
setIdFromString idString dataset =
    case dataset of
        Countries _ ->
            Countries (Just (Country.codeFromString idString))

        FoodExamples _ ->
            FoodExamples (Uuid.fromString idString)

        FoodIngredients _ ->
            FoodIngredients (Just (Ingredient.idFromString idString))

        FoodProcesses _ ->
            FoodProcesses (Just (FoodProcess.identifierFromString idString))

        Impacts _ ->
            Impacts (Definition.toTrigram idString |> Result.toMaybe)

        ObjectComponents _ ->
            ObjectComponents (ObjectComponent.idFromString idString)

        ObjectExamples _ ->
            ObjectExamples (Uuid.fromString idString)

        ObjectProcesses _ ->
            ObjectProcesses (ObjectProcess.idFromString idString)

        TextileExamples _ ->
            TextileExamples (Uuid.fromString idString)

        TextileMaterials _ ->
            TextileMaterials (Just (Material.Id idString))

        TextileProcesses _ ->
            TextileProcesses (Just (Process.Uuid idString))

        TextileProducts _ ->
            TextileProducts (Just (Product.Id idString))


slug : Dataset -> String
slug =
    strings >> .slug


strings : Dataset -> { label : String, slug : String }
strings dataset =
    case dataset of
        Countries _ ->
            { label = "Pays", slug = "countries" }

        FoodExamples _ ->
            { label = "Exemples", slug = "food-examples" }

        FoodIngredients _ ->
            { label = "Ingrédients", slug = "ingredients" }

        FoodProcesses _ ->
            { label = "Procédés", slug = "food-processes" }

        Impacts _ ->
            { label = "Impacts", slug = "impacts" }

        ObjectComponents _ ->
            { label = "Composants", slug = "object-components" }

        ObjectExamples _ ->
            { label = "Exemples", slug = "object-examples" }

        ObjectProcesses _ ->
            { label = "Procédés", slug = "object-processes" }

        TextileExamples _ ->
            { label = "Exemples", slug = "textile-examples" }

        TextileMaterials _ ->
            { label = "Matières", slug = "materials" }

        TextileProcesses _ ->
            { label = "Procédés", slug = "processes" }

        TextileProducts _ ->
            { label = "Produits", slug = "products" }


toRoutePath : Dataset -> List String
toRoutePath dataset =
    case dataset of
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

        FoodProcesses (Just id) ->
            [ slug dataset, FoodProcess.identifierToString id ]

        FoodProcesses Nothing ->
            [ slug dataset ]

        Impacts (Just trigram) ->
            [ slug dataset, Definition.toString trigram ]

        Impacts Nothing ->
            [ slug dataset ]

        ObjectComponents (Just id) ->
            [ slug dataset, ObjectComponent.idToString id ]

        ObjectComponents Nothing ->
            [ slug dataset ]

        ObjectExamples (Just id) ->
            [ slug dataset, Uuid.toString id ]

        ObjectExamples Nothing ->
            [ slug dataset ]

        ObjectProcesses (Just id) ->
            [ slug dataset, ObjectProcess.idToString id ]

        ObjectProcesses Nothing ->
            [ slug dataset ]

        TextileExamples (Just id) ->
            [ slug dataset, Uuid.toString id ]

        TextileExamples Nothing ->
            [ slug dataset ]

        TextileMaterials (Just id) ->
            [ slug dataset, Material.idToString id ]

        TextileMaterials Nothing ->
            [ slug dataset ]

        TextileProcesses (Just id) ->
            [ slug dataset, Process.uuidToString id ]

        TextileProcesses Nothing ->
            [ slug dataset ]

        TextileProducts (Just id) ->
            [ slug dataset, Product.idToString id ]

        TextileProducts Nothing ->
            [ slug dataset ]
