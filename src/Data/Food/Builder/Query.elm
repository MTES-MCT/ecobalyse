module Data.Food.Builder.Query exposing
    ( IngredientQuery
    , ProcessQuery
    , Query
    , Variant(..)
    , addIngredient
    , addPackaging
    , addPreparation
    , b64encode
    , buildApiQuery
    , carrotCake
    , decode
    , deleteIngredient
    , deletePreparation
    , emptyQuery
    , encode
    , parseBase64Query
    , serialize
    , setDistribution
    , setTransform
    , updateBonusesFromVariant
    , updateDistribution
    , updateIngredient
    , updatePackaging
    , updatePreparation
    , updateTransform
    )

import Base64
import Data.Country as Country
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Ingredient.Category as IngredientCategory
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
    , bonuses : Maybe Ingredient.Bonuses
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


buildApiQuery : String -> Query -> String
buildApiQuery clientUrl query =
    """curl -X POST %apiUrl% \\
  -H "accept: application/json" \\
  -H "content-type: application/json" \\
  -d '%json%'
"""
        |> String.replace "%apiUrl%" (clientUrl ++ "api/food/recipe")
        |> String.replace "%json%" (encode query |> Encode.encode 0)


emptyQuery : Query
emptyQuery =
    { ingredients = []
    , transform = Nothing
    , packaging = []
    , distribution = Nothing
    , preparation = []
    }


carrotCake : Query
carrotCake =
    { ingredients =
        [ { id = Ingredient.idFromString "egg"
          , mass = Mass.grams 120
          , variant = DefaultVariant
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          , bonuses = Nothing
          }
        , { id = Ingredient.idFromString "wheat"
          , mass = Mass.grams 140
          , variant = DefaultVariant
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          , bonuses = Nothing
          }
        , { id = Ingredient.idFromString "milk"
          , mass = Mass.grams 60
          , variant = DefaultVariant
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          , bonuses = Nothing
          }
        , { id = Ingredient.idFromString "carrot"
          , mass = Mass.grams 225
          , variant = DefaultVariant
          , country = Nothing
          , planeTransport = Ingredient.PlaneNotApplicable
          , bonuses = Nothing
          }
        ]
    , transform =
        Just
            { -- Cooking, industrial, 1kg of cooked product/ FR U
              code = Process.codeFromString "AGRIBALU000000003103966"
            , mass = Mass.grams 545
            }
    , packaging =
        [ { -- Corrugated board box {RER}| production | Cut-off, S - Copied from Ecoinvent
            code = Process.codeFromString "AGRIBALU000000003104019"
          , mass = Mass.grams 105
          }
        ]
    , distribution = Just Retail.ambient
    , preparation = [ Preparation.Id "refrigeration" ]
    }


decode : Decoder Query
decode =
    Decode.succeed Query
        |> Pipe.required "ingredients" (Decode.list decodeIngredient)
        |> Pipe.optional "transform" (Decode.maybe decodeProcess) Nothing
        |> Pipe.optional "packaging" (Decode.list decodeProcess) []
        |> Pipe.optional "distribution" (Decode.maybe Retail.decode) Nothing
        |> Pipe.optional "preparation" (Decode.list Preparation.decodeId) []


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


decodeMassInGrams : Decoder Mass
decodeMassInGrams =
    Decode.float
        |> Decode.map Mass.grams


decodeProcess : Decoder ProcessQuery
decodeProcess =
    Decode.map2 ProcessQuery
        (Decode.field "code" Process.decodeCode)
        (Decode.field "mass" decodeMassInGrams)


decodeIngredient : Decoder IngredientQuery
decodeIngredient =
    Decode.succeed IngredientQuery
        |> Pipe.required "id" Ingredient.decodeId
        |> Pipe.required "mass" decodeMassInGrams
        |> Pipe.optional "variant" decodeVariant DefaultVariant
        |> Pipe.optional "country" (Decode.maybe Country.decodeCode) Nothing
        |> Pipe.optional "byPlane" decodePlaneTransport Ingredient.PlaneNotApplicable
        |> Pipe.optional "bonuses" (Decode.maybe Ingredient.decodeBonuses) Nothing


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


deleteIngredient : Ingredient.Id -> Query -> Query
deleteIngredient id query =
    { query
        | ingredients =
            query.ingredients |> List.filter (.id >> (/=) id)
    }
        |> updateTransformMass


encode : Query -> Encode.Value
encode v =
    [ ( "ingredients", Encode.list encodeIngredient v.ingredients |> Just )
    , ( "transform", v.transform |> Maybe.map encodeProcess )
    , ( "packaging"
      , case v.packaging of
            [] ->
                Nothing

            list ->
                Encode.list encodeProcess list |> Just
      )
    , ( "distribution", v.distribution |> Maybe.map Retail.encode )
    , ( "preparation"
      , case v.preparation of
            [] ->
                Nothing

            list ->
                Encode.list Preparation.encodeId list |> Just
      )
    ]
        -- For concision, drop keys where no param is defined
        |> List.filterMap (\( key, maybeVal ) -> maybeVal |> Maybe.map (\val -> ( key, val )))
        |> Encode.object


encodeIngredient : IngredientQuery -> Encode.Value
encodeIngredient v =
    [ ( "id", Ingredient.encodeId v.id |> Just )
    , ( "mass", encodeMassAsGrams v.mass |> Just )
    , ( "variant"
      , case v.variant of
            DefaultVariant ->
                Nothing

            Organic ->
                encodeVariant v.variant |> Just
      )
    , ( "country", v.country |> Maybe.map Country.encodeCode )
    , ( "byPlane", v.planeTransport |> Ingredient.encodePlaneTransport )
    , ( "bonuses", v.bonuses |> Maybe.map Ingredient.encodeBonuses )
    ]
        -- For concision, drop keys where no param is defined
        |> List.filterMap (\( key, maybeVal ) -> maybeVal |> Maybe.map (\val -> ( key, val )))
        |> Encode.object


encodeMassAsGrams : Mass -> Encode.Value
encodeMassAsGrams =
    Mass.inGrams >> Encode.float


encodeProcess : ProcessQuery -> Encode.Value
encodeProcess v =
    Encode.object
        [ ( "code", Process.encodeCode v.code )
        , ( "mass", encodeMassAsGrams v.mass )
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


updateBonusesFromVariant : List Ingredient -> Ingredient.Id -> Variant -> Ingredient.Bonuses
updateBonusesFromVariant ingredients ingredientId variant =
    let
        ingredientResult =
            ingredients
                |> Ingredient.findByID ingredientId

        defaultVariantBonuses =
            ingredientResult
                |> Result.map Ingredient.defaultBonuses
                |> Result.withDefault (Ingredient.defaultBonuses { categories = [ IngredientCategory.Misc ] })
    in
    case variant of
        Organic ->
            ingredientResult
                |> Result.map Ingredient.getDefaultOrganicBonuses
                |> Result.withDefault defaultVariantBonuses

        DefaultVariant ->
            defaultVariantBonuses


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
