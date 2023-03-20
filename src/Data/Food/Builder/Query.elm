module Data.Food.Builder.Query exposing
    ( IngredientQuery
    , ProcessQuery
    , Query
    , Variant(..)
    , addIngredient
    , addPackaging
    , addPreparation
    , b64encode
    , carrotCake
    , decode
    , deleteIngredient
    , deletePreparation
    , emptyQuery
    , encode
    , getIngredientMass
    , parseBase64Query
    , serialize
    , setDistribution
    , setTransform
    , updateDistribution
    , updateIngredient
    , updatePackaging
    , updatePreparation
    , updateTransform
    )

import Base64
import Data.Country as Country
import Data.Food.Category as Category
import Data.Food.Ingredient as Ingredient
import Data.Food.Preparation as Preparation
import Data.Food.Process as Process
import Data.Food.Retail as Retail
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Url.Parser as Parser exposing (Parser)


type Variant
    = DefaultVariant
    | Organic


type alias IngredientQuery =
    { id : Ingredient.Id
    , mass : Mass
    , variant : Variant
    , country : Maybe Country.Code
    , planeTransport : Ingredient.PlaneTransport
    }


type alias ProcessQuery =
    { code : Process.Code
    , mass : Mass
    }


type alias Query =
    { ingredients : List IngredientQuery
    , transform : Maybe ProcessQuery
    , packaging : List ProcessQuery
    , distribution : Maybe Retail.Distribution
    , preparation : List Preparation.Id
    , category : Maybe Category.Id
    }


addPreparation : Preparation.Id -> Query -> Query
addPreparation preparationId query =
    { query
        | preparation =
            query.preparation
                ++ [ preparationId ]
    }


addIngredient : IngredientQuery -> Query -> Query
addIngredient ingredient query =
    { query
        | ingredients =
            query.ingredients
                ++ [ ingredient ]
    }
        |> updateTransformMass


addPackaging : ProcessQuery -> Query -> Query
addPackaging packaging query =
    { query
        | packaging =
            query.packaging
                ++ [ packaging ]
    }


emptyQuery : Query
emptyQuery =
    { ingredients = []
    , transform = Nothing
    , packaging = []
    , distribution = Nothing
    , preparation = []
    , category = Nothing
    }


carrotCake : Query
carrotCake =
    { ingredients =
        [ { id = Ingredient.idFromString "egg"
          , mass = Mass.grams 120
          , variant = DefaultVariant
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "wheat"
          , mass = Mass.grams 140
          , variant = DefaultVariant
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "milk"
          , mass = Mass.grams 60
          , variant = DefaultVariant
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          }
        , { id = Ingredient.idFromString "carrot"
          , mass = Mass.grams 225
          , variant = DefaultVariant
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
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
    , distribution = Just Retail.ambient
    , preparation = [ Preparation.Id "refrigeration" ]
    , category = Just (Category.Id "cakes")
    }


decode : Decoder Query
decode =
    Decode.succeed Query
        |> Pipe.required "ingredients" (Decode.list decodeIngredient)
        |> Pipe.optional "transform" (Decode.maybe decodeProcess) Nothing
        |> Pipe.required "packaging" (Decode.list decodeProcess)
        |> Pipe.custom (Decode.field "distribution" (Decode.maybe Retail.decode))
        |> Pipe.optional "preparation" (Decode.list Preparation.decodeId) []
        |> Pipe.optional "category" (Decode.maybe Category.decodeId) Nothing


decodePlaneTransport : Decoder Ingredient.PlaneTransport
decodePlaneTransport =
    Decode.maybe
        (Decode.string
            |> Decode.map
                (\str ->
                    case str of
                        "byPlane" ->
                            Ingredient.ByPlane

                        "noPlane" ->
                            Ingredient.NoPlane

                        _ ->
                            Ingredient.PlaneNotApplicable
                )
        )
        |> Decode.map
            (\maybe ->
                case maybe of
                    Just planeTransport ->
                        planeTransport

                    Nothing ->
                        Ingredient.PlaneNotApplicable
            )


decodeMass : Decoder Mass
decodeMass =
    Decode.float
        |> Decode.map Mass.kilograms


decodeProcess : Decoder ProcessQuery
decodeProcess =
    Decode.map2 ProcessQuery
        (Decode.field "code" Process.decodeCode)
        (Decode.field "mass" decodeMass)


decodeIngredient : Decoder IngredientQuery
decodeIngredient =
    Decode.map5 IngredientQuery
        (Decode.field "id" Ingredient.decodeId)
        (Decode.field "mass" decodeMass)
        (Decode.field "variant" decodeVariant)
        (Decode.field "country" (Decode.maybe Country.decodeCode))
        (Decode.field "byPlane" decodePlaneTransport)


decodeVariant : Decoder Variant
decodeVariant =
    Decode.string
        |> Decode.andThen (variantFromString >> DE.fromResult)


deletePreparation : Preparation.Id -> Query -> Query
deletePreparation preparationId query =
    { query
        | preparation =
            query.preparation
                |> List.filter ((/=) preparationId)
    }


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
        , ( "transform", v.transform |> Maybe.map encodeProcess |> Maybe.withDefault Encode.null )
        , ( "packaging", Encode.list encodeProcess v.packaging )
        , ( "distribution", v.distribution |> Maybe.map Retail.encode |> Maybe.withDefault Encode.null )
        , ( "preparation", Encode.list Preparation.encodeId v.preparation )
        , ( "category", v.category |> Maybe.map Category.encodeId |> Maybe.withDefault Encode.null )
        ]


encodeIngredient : IngredientQuery -> Encode.Value
encodeIngredient v =
    Encode.object
        [ ( "id", Ingredient.encodeId v.id )
        , ( "mass", encodeMass v.mass )
        , ( "variant", encodeVariant v.variant )
        , ( "country", v.country |> Maybe.map Country.encodeCode |> Maybe.withDefault Encode.null )
        , ( "byPlane", encodePlaneTransport v.planeTransport )
        ]


encodeMass : Mass -> Encode.Value
encodeMass =
    Mass.inKilograms >> Encode.float


encodePlaneTransport : Ingredient.PlaneTransport -> Encode.Value
encodePlaneTransport planeTransport =
    case planeTransport of
        Ingredient.PlaneNotApplicable ->
            Encode.null

        Ingredient.ByPlane ->
            Encode.string "byPlane"

        Ingredient.NoPlane ->
            Encode.string "noPlane"


encodeProcess : ProcessQuery -> Encode.Value
encodeProcess v =
    Encode.object
        [ ( "code", Process.encodeCode v.code )
        , ( "mass", encodeMass v.mass )
        ]


encodeVariant : Variant -> Encode.Value
encodeVariant =
    variantToString >> Encode.string


getIngredientMass : List { a | mass : Mass } -> Mass
getIngredientMass ingredients =
    ingredients
        |> List.map .mass
        |> Quantity.sum


setTransform : ProcessQuery -> Query -> Query
setTransform transform query =
    { query | transform = Just transform }


setDistribution : Retail.Distribution -> Query -> Query
setDistribution distribution query =
    { query | distribution = Just distribution }


updatePreparation : Preparation.Id -> Preparation.Id -> Query -> Query
updatePreparation oldId newId query =
    { query
        | preparation =
            query.preparation
                |> List.map
                    (\id ->
                        if id == oldId then
                            newId

                        else
                            id
                    )
    }


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


updatePackaging : Process.Code -> ProcessQuery -> Query -> Query
updatePackaging oldPackagingCode newPackaging query =
    { query
        | packaging =
            query.packaging
                |> List.map
                    (\p ->
                        if p.code == oldPackagingCode then
                            newPackaging

                        else
                            p
                    )
    }


updateTransform : ProcessQuery -> Query -> Query
updateTransform newTransform query =
    { query
        | transform = Just newTransform
    }


updateTransformMass : Query -> Query
updateTransformMass query =
    { query
        | transform =
            query.transform
                |> Maybe.map
                    (\transform ->
                        { transform | mass = getIngredientMass query.ingredients }
                    )
    }


updateDistribution : String -> Query -> Query
updateDistribution distribution query =
    { query
        | distribution =
            Retail.fromString distribution
                |> Result.withDefault Retail.ambient
                |> Just
    }


variantFromString : String -> Result String Variant
variantFromString string =
    case string of
        "" ->
            Ok DefaultVariant

        "organic" ->
            Ok Organic

        _ ->
            Err <| "Variante inconnnue: " ++ string


variantToString : Variant -> String
variantToString variant =
    case variant of
        DefaultVariant ->
            ""

        Organic ->
            "organic"


serialize : Query -> String
serialize =
    encode >> Encode.encode 2


b64decode : String -> Result String Query
b64decode =
    Base64.decode
        >> Result.andThen
            (Decode.decodeString decode
                >> Result.mapError Decode.errorToString
            )


b64encode : Query -> String
b64encode =
    encode >> Encode.encode 0 >> Base64.encode



-- Parser


parseBase64Query : Parser (Maybe Query -> a) a
parseBase64Query =
    Parser.custom "QUERY" <|
        b64decode
            >> Result.toMaybe
            >> Just
