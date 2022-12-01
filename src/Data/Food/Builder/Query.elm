module Data.Food.Builder.Query exposing
    ( IngredientQuery
    , PackagingQuery
    , Query
    , TransformQuery
    , Variant(..)
    , addIngredient
    , carrotCake
    , decode
    , deleteIngredient
    , emptyQuery
    , encode
    , updateIngredient
    )

import Data.Food.Ingredient as Ingredient
import Data.Food.Process as Process
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity


type Variant
    = Default
    | Organic


type alias IngredientQuery =
    { id : Ingredient.Id
    , name : String
    , mass : Mass
    , variant : Variant
    }


type alias PackagingQuery =
    { code : Process.Code
    , mass : Mass
    }


type alias Query =
    { ingredients : List IngredientQuery
    , transform : Maybe TransformQuery
    , packaging : List PackagingQuery
    }


type alias TransformQuery =
    { code : Process.Code
    , mass : Mass
    }


addIngredient : IngredientQuery -> Query -> Query
addIngredient ingredient query =
    { query
        | ingredients =
            query.ingredients
                ++ [ ingredient ]
    }
        |> updateTransformMass


emptyQuery : Query
emptyQuery =
    { ingredients = []
    , transform = Nothing
    , packaging = []
    }


carrotCake : Query
carrotCake =
    { ingredients =
        [ { id = Ingredient.idFromString "egg"
          , name = "oeuf"
          , mass = Mass.grams 120
          , variant = Default
          }
        , { id = Ingredient.idFromString "wheat"
          , name = "blé tendre"
          , mass = Mass.grams 140
          , variant = Default
          }
        , { id = Ingredient.idFromString "milk"
          , name = "lait"
          , mass = Mass.grams 60
          , variant = Default
          }
        , { id = Ingredient.idFromString "carrot"
          , name = "carotte"
          , mass = Mass.grams 225
          , variant = Default
          }
        ]
    , transform =
        Just
            { -- Cooking, industrial, 1kg of cooked product/ FR U
              code = Process.codeFromString "aded2490573207ec7ad5a3813978f6a4"
            , mass = Mass.grams 545
            }
    , packaging =
        [ { -- Corrugated board box {RER}| production | Cut-off, S - Copied from Ecoinvent
            code = Process.codeFromString "23b2754e5943bc77916f8f871edc53b6"
          , mass = Mass.grams 105
          }
        ]
    }


decode : Decoder Query
decode =
    Decode.map3 Query
        (Decode.field "ingredients" (Decode.list decodeIngredient))
        (Decode.field "transform" (Decode.maybe decodeTransform))
        (Decode.field "packaging" (Decode.list decodePackaging))


decodeMass : Decoder Mass
decodeMass =
    Decode.float
        |> Decode.map Mass.kilograms


decodePackaging : Decoder PackagingQuery
decodePackaging =
    Decode.map2 PackagingQuery
        (Decode.field "code" Process.decodeCode)
        (Decode.field "mass" decodeMass)


decodeIngredient : Decoder IngredientQuery
decodeIngredient =
    Decode.map4 IngredientQuery
        (Decode.field "id" Ingredient.decodeId)
        (Decode.field "name" Decode.string)
        (Decode.field "mass" decodeMass)
        (Decode.field "variant" decodeVariant)


decodeTransform : Decoder TransformQuery
decodeTransform =
    Decode.map2 TransformQuery
        (Decode.field "code" Process.decodeCode)
        (Decode.field "mass" decodeMass)


decodeVariant : Decoder Variant
decodeVariant =
    Decode.string
        |> Decode.andThen (variantFromString >> DE.fromResult)


deleteIngredient : IngredientQuery -> Query -> Query
deleteIngredient ingredientQuery query =
    { query
        | ingredients =
            query.ingredients
                |> List.filter ((/=) ingredientQuery)
    }
        |> updateTransformMass


encode : Query -> Encode.Value
encode v =
    Encode.object
        [ ( "ingredients", Encode.list encodeIngredient v.ingredients )
        , ( "transform", v.transform |> Maybe.map encodeTransform |> Maybe.withDefault Encode.null )
        , ( "packaging", Encode.list encodePackaging v.packaging )
        ]


encodeIngredient : IngredientQuery -> Encode.Value
encodeIngredient v =
    Encode.object
        [ ( "id", Ingredient.encodeId v.id )
        , ( "name", Encode.string v.name )
        , ( "mass", encodeMass v.mass )
        , ( "variant", encodeVariant v.variant )
        ]


encodeMass : Mass -> Encode.Value
encodeMass =
    Mass.inKilograms >> Encode.float


encodePackaging : PackagingQuery -> Encode.Value
encodePackaging v =
    Encode.object
        [ ( "code", Process.encodeCode v.code )
        , ( "mass", encodeMass v.mass )
        ]


encodeTransform : TransformQuery -> Encode.Value
encodeTransform v =
    Encode.object
        [ ( "code", Process.encodeCode v.code )
        , ( "mass", encodeMass v.mass )
        ]


encodeVariant : Variant -> Encode.Value
encodeVariant =
    variantToString >> Encode.string


getIngredientMass : Query -> Mass
getIngredientMass query =
    query.ingredients
        |> List.map .mass
        |> Quantity.sum


updateIngredient : Ingredient.Id -> IngredientQuery -> Query -> Query
updateIngredient oldIngredientId newIngredient query =
    { query
        | ingredients =
            query.ingredients
                |> List.map
                    (\ingredient ->
                        if ingredient.id == oldIngredientId then
                            newIngredient

                        else
                            ingredient
                    )
    }
        |> updateTransformMass


updateTransformMass : Query -> Query
updateTransformMass query =
    { query
        | transform =
            query.transform
                |> Maybe.map
                    (\transform ->
                        { transform | mass = getIngredientMass query }
                    )
    }


variantFromString : String -> Result String Variant
variantFromString string =
    case string of
        "default" ->
            Ok Default

        "organic" ->
            Ok Organic

        _ ->
            Err <| "Variante inconnnue: " ++ string


variantToString : Variant -> String
variantToString variant =
    case variant of
        Default ->
            "default"

        Organic ->
            "organic"
