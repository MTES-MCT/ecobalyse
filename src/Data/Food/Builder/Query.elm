module Data.Food.Builder.Query exposing
    ( ConservationQuery
    , ConservationType(..)
    , IngredientQuery
    , ProcessQuery
    , Query
    , Variant(..)
    , addIngredient
    , addPackaging
    , b64encode
    , carrotCake
    , conservationTypes
    , conservationTypetoString
    , decode
    , deleteIngredient
    , emptyQuery
    , encode
    , parseBase64Query
    , setTransform
    , updateConservation
    , updateIngredient
    , updatePackaging
    , updateTransform
    )

import Base64
import Data.Country as Country
import Data.Food.Ingredient as Ingredient
import Data.Food.Process as Process
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Result.Extra as RE
import Url.Parser as Parser exposing (Parser)


type Variant
    = Default
    | Organic


type alias IngredientQuery =
    { id : Ingredient.Id
    , name : String
    , mass : Mass
    , variant : Variant
    , country : Maybe Country.Code
    }


type alias ProcessQuery =
    { code : Process.Code
    , mass : Mass
    }


type ConservationType
    = Ambient
    | Chilled
    | Frozen


conservationTypes : List ConservationType
conservationTypes =
    [ Ambient, Chilled, Frozen ]


conservationTypetoString : ConservationType -> String
conservationTypetoString t =
    case t of
        Ambient ->
            "Sec"

        Chilled ->
            "Frais"

        Frozen ->
            "Surgelé"


type alias ConservationQuery =
    { type_ : ConservationType
    }


type alias Query =
    { ingredients : List IngredientQuery
    , transform : Maybe ProcessQuery
    , packaging : List ProcessQuery
    , conservation : Maybe ConservationQuery
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
    , conservation = Nothing
    }


carrotCake : Query
carrotCake =
    { ingredients =
        [ { id = Ingredient.idFromString "egg"
          , name = "Oeuf"
          , mass = Mass.grams 120
          , variant = Default
          , country = Nothing
          }
        , { id = Ingredient.idFromString "wheat"
          , name = "Blé tendre"
          , mass = Mass.grams 140
          , variant = Default
          , country = Nothing
          }
        , { id = Ingredient.idFromString "milk"
          , name = "Lait"
          , mass = Mass.grams 60
          , variant = Default
          , country = Nothing
          }
        , { id = Ingredient.idFromString "carrot"
          , name = "Carotte"
          , mass = Mass.grams 225
          , variant = Default
          , country = Nothing
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
    , conservation =
        Just
            { type_ = Ambient
            }
    }


decode : Decoder Query
decode =
    Decode.map4 Query
        (Decode.field "ingredients" (Decode.list decodeIngredient))
        (Decode.field "transform" (Decode.maybe decodeProcess))
        (Decode.field "packaging" (Decode.list decodeProcess))
        (Decode.field "conservation" (Decode.maybe decodeConservation))


decodeMass : Decoder Mass
decodeMass =
    Decode.float
        |> Decode.map Mass.kilograms


decodeProcess : Decoder ProcessQuery
decodeProcess =
    Decode.map2 ProcessQuery
        (Decode.field "code" Process.decodeCode)
        (Decode.field "mass" decodeMass)


decodeConservation : Decoder ConservationQuery
decodeConservation =
    Decode.map ConservationQuery
        (Decode.field "type" decodeConservationType)


decodeConservationType : Decoder ConservationType
decodeConservationType =
    Decode.string
        |> Decode.andThen (conservationTypeFromString >> RE.unpack Decode.fail Decode.succeed)


conservationTypeFromString : String -> Result String ConservationType
conservationTypeFromString str =
    case str of
        "Sec" ->
            Ok Ambient

        "Frais" ->
            Ok Chilled

        "Surgelé" ->
            Ok Frozen

        _ ->
            Err "Type de conservation incorrect"


decodeIngredient : Decoder IngredientQuery
decodeIngredient =
    Decode.map5 IngredientQuery
        (Decode.field "id" Ingredient.decodeId)
        (Decode.field "name" Decode.string)
        (Decode.field "mass" decodeMass)
        (Decode.field "variant" decodeVariant)
        (Decode.field "country" (Decode.maybe Country.decodeCode))


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
        , ( "transform", v.transform |> Maybe.map encodeProcess |> Maybe.withDefault Encode.null )
        , ( "packaging", Encode.list encodeProcess v.packaging )
        , ( "conservation", v.conservation |> Maybe.map encodeConservation |> Maybe.withDefault Encode.null )
        ]


encodeIngredient : IngredientQuery -> Encode.Value
encodeIngredient v =
    Encode.object
        [ ( "id", Ingredient.encodeId v.id )
        , ( "name", Encode.string v.name )
        , ( "mass", encodeMass v.mass )
        , ( "variant", encodeVariant v.variant )
        , ( "country", v.country |> Maybe.map Country.encodeCode |> Maybe.withDefault Encode.null )
        ]


encodeMass : Mass -> Encode.Value
encodeMass =
    Mass.inKilograms >> Encode.float


encodeProcess : ProcessQuery -> Encode.Value
encodeProcess v =
    Encode.object
        [ ( "code", Process.encodeCode v.code )
        , ( "mass", encodeMass v.mass )
        ]


encodeConservation : ConservationQuery -> Encode.Value
encodeConservation c =
    Encode.object
        [ ( "type", encodeConservationType c.type_ )
        ]


encodeConservationType : ConservationType -> Encode.Value
encodeConservationType =
    Encode.string << conservationTypetoString


encodeVariant : Variant -> Encode.Value
encodeVariant =
    variantToString >> Encode.string


getIngredientMass : Query -> Mass
getIngredientMass query =
    query.ingredients
        |> List.map .mass
        |> Quantity.sum


setTransform : ProcessQuery -> Query -> Query
setTransform transform query =
    { query | transform = Just transform }


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
                        { transform | mass = getIngredientMass query }
                    )
    }


updateConservation : String -> Query -> Query
updateConservation newConservation query =
    { query
        | conservation =
            conservationTypeFromString newConservation
                |> Result.toMaybe
                |> Maybe.map ConservationQuery
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
