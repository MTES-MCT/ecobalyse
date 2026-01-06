module Data.Food.Query exposing
    ( IngredientQuery
    , PackagingAmount(..)
    , PackagingQuery
    , ProcessQuery
    , Query
    , addIngredient
    , addPackaging
    , addPreparation
    , b64encode
    , buildApiQuery
    , decode
    , deleteIngredient
    , deletePreparation
    , empty
    , encode
    , packagingAmountToFloat
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
import Data.Common.DecodeUtils as DU
import Data.Common.EncodeUtils as EU
import Data.Country as Country
import Data.Food.Ingredient as Ingredient
import Data.Food.Preparation as Preparation
import Data.Food.Retail as Retail
import Data.Process as Process
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Url.Parser as Parser exposing (Parser)


type alias IngredientQuery =
    { country : Maybe Country.Code
    , id : Ingredient.Id
    , mass : Mass
    , planeTransport : Ingredient.PlaneTransport
    }


type alias ProcessQuery =
    { id : Process.Id
    , mass : Mass
    }


type alias PackagingQuery =
    { id : Process.Id
    , amount : PackagingAmount
    }


type alias Query =
    { distribution : Maybe Retail.Distribution
    , ingredients : List IngredientQuery
    , packaging : List PackagingQuery
    , preparation : List Preparation.Id
    , transform : Maybe ProcessQuery
    }


type PackagingAmount
    = FloatAmount Float
    | IntAmount Int


packagingAmountToFloat : PackagingAmount -> Float
packagingAmountToFloat a =
    case a of
        FloatAmount v ->
            v

        IntAmount v ->
            toFloat v


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


addPackaging : PackagingQuery -> Query -> Query
addPackaging packaging query =
    { query
        | packaging =
            query.packaging
                ++ [ packaging ]
    }


buildApiQuery : String -> Query -> String
buildApiQuery clientUrl query =
    """curl -sS -X POST %apiUrl% \\
  -H "accept: application/json" \\
  -H "content-type: application/json" \\
  -d '%json%'
"""
        |> String.replace "%apiUrl%" (clientUrl ++ "/api/food")
        |> String.replace "%json%" (encode query |> Encode.encode 0)


decode : Decoder Query
decode =
    Decode.succeed Query
        |> DU.strictOptional "distribution" Retail.decode
        |> Pipe.required "ingredients" (Decode.list decodeIngredient)
        |> Pipe.optional "packaging" (Decode.list decodePackaging) []
        |> Pipe.optional "preparation" (Decode.list Preparation.decodeId) []
        |> DU.strictOptional "transform" decodeProcess


decodePlaneTransport : Decoder Ingredient.PlaneTransport
decodePlaneTransport =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "byPlane" ->
                        Decode.succeed Ingredient.ByPlane

                    "noPlane" ->
                        Decode.succeed Ingredient.NoPlane

                    _ ->
                        Decode.fail <| "Transport par avion inconnu\u{00A0}: " ++ str
            )


decodeMassInGrams : Decoder Mass
decodeMassInGrams =
    Decode.float
        |> Decode.map Mass.grams


decodePackagingAmount : Decoder PackagingAmount
decodePackagingAmount =
    Decode.oneOf
        [ Decode.float
            |> Decode.map (\float -> FloatAmount float)
        , Decode.int
            |> Decode.map (\int -> IntAmount int)
        ]


decodePackaging : Decoder PackagingQuery
decodePackaging =
    Decode.map2 PackagingQuery
        (Decode.field "id" Process.decodeId)
        (Decode.field "amount" decodePackagingAmount)


decodeProcess : Decoder ProcessQuery
decodeProcess =
    Decode.map2 ProcessQuery
        (Decode.field "id" Process.decodeId)
        (Decode.field "mass" decodeMassInGrams)


decodeIngredient : Decoder IngredientQuery
decodeIngredient =
    Decode.succeed IngredientQuery
        |> DU.strictOptional "country" Country.decodeCode
        |> Pipe.required "id" Ingredient.decodeId
        |> Pipe.required "mass" decodeMassInGrams
        |> DU.strictOptionalWithDefault "byPlane" decodePlaneTransport Ingredient.PlaneNotApplicable


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


empty : Query
empty =
    { distribution = Nothing
    , ingredients = []
    , packaging = []
    , preparation = []
    , transform = Nothing
    }


encode : Query -> Encode.Value
encode v =
    EU.optionalPropertiesObject
        [ ( "ingredients", Encode.list encodeIngredient v.ingredients |> Just )
        , ( "transform", v.transform |> Maybe.map encodeProcess )
        , ( "packaging"
          , case v.packaging of
                [] ->
                    Nothing

                list ->
                    Encode.list encodePackaging list |> Just
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


encodeIngredient : IngredientQuery -> Encode.Value
encodeIngredient v =
    EU.optionalPropertiesObject
        [ ( "id", Ingredient.encodeId v.id |> Just )
        , ( "mass", encodeMassAsGrams v.mass |> Just )
        , ( "country", v.country |> Maybe.map Country.encodeCode )
        , ( "byPlane", v.planeTransport |> Ingredient.encodePlaneTransport )
        ]


encodeMassAsGrams : Mass -> Encode.Value
encodeMassAsGrams =
    Mass.inGrams >> Encode.float


encodePackagingAmount : PackagingAmount -> Encode.Value
encodePackagingAmount v =
    case v of
        FloatAmount a ->
            Encode.float a

        IntAmount a ->
            Encode.int a


encodePackaging : PackagingQuery -> Encode.Value
encodePackaging v =
    Encode.object
        [ ( "id", Process.encodeId v.id )
        , ( "amount", encodePackagingAmount v.amount )
        ]


encodeProcess : ProcessQuery -> Encode.Value
encodeProcess v =
    Encode.object
        [ ( "id", Process.encodeId v.id )
        , ( "mass", encodeMassAsGrams v.mass )
        ]


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


updatePackaging : Process.Id -> PackagingQuery -> Query -> Query
updatePackaging oldPackagingProcessId newPackaging query =
    { query
        | packaging =
            query.packaging
                |> List.map
                    (\p ->
                        if p.id == oldPackagingProcessId then
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
