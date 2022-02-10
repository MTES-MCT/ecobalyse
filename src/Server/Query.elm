module Server.Query exposing
    ( Errors
    , encodeErrors
    , parse
    )

import Data.Country as Country exposing (Country)
import Data.Db exposing (Db)
import Data.Inputs as Inputs
import Data.Material as Material exposing (Material)
import Data.Product as Product exposing (Product)
import Data.Unit as Unit
import Dict exposing (Dict)
import Json.Encode as Encode
import Mass exposing (Mass)
import Result.Extra as RE
import Url.Parser.Query as Query



-- Query String


type alias FieldName =
    String


type alias ErrorMessage =
    String


type alias Errors =
    Dict FieldName ErrorMessage


type alias ParseResult a =
    Result ( FieldName, String ) a


succeed : a -> Query.Parser a
succeed =
    -- Kind of a hack: we don't have access to the Query.Parser constructor, so
    -- we use Query.custom to wrap our thing in a Query.Parser
    always >> Query.custom ""


parse : Db -> Query.Parser (Result Errors Inputs.Query)
parse db =
    succeed (Ok Inputs.Query)
        |> apply (massParser "mass")
        |> apply (materialListParser "materials" db.materials)
        |> apply (productParser "product" db.products)
        |> apply (countryParser "countryFabric" db.countries)
        |> apply (countryParser "countryDyeing" db.countries)
        |> apply (countryParser "countryMaking" db.countries)
        |> apply (maybeRatioParser "dyeingWeighting")
        |> apply (maybeRatioParser "airTransportRatio")
        |> apply (maybeRatioParser "recycledRatio")
        |> apply (maybeQuality "quality")


toErrors : ParseResult a -> Result Errors a
toErrors =
    Result.mapError
        (\( key, errorMessage ) ->
            Dict.singleton key errorMessage
        )


builder :
    Result (Dict comparable v) a
    -> Result (Dict comparable v) (a -> b)
    -> Result (Dict comparable v) b
builder result accumulator =
    case ( result, accumulator ) of
        ( Err a, Err b ) ->
            -- Merge the error dicts
            Err <| Dict.union a b

        ( Ok _, Err b ) ->
            -- No error in "result", but the accumulator is errored: return the errored accumulator
            Err b

        ( valueOrError, Ok fn ) ->
            Result.map fn valueOrError


apply :
    Query.Parser (ParseResult a)
    -> Query.Parser (Result Errors (a -> b))
    -> Query.Parser (Result Errors b)
apply argParser funcParser =
    -- Adapted from https://package.elm-lang.org/packages/elm/url/latest/Url-Parser-Query#map8
    -- with the full list of errors returned, instead of just the first one encountered.
    Query.map2
        builder
        (Query.map toErrors argParser)
        funcParser


floatParser : String -> Query.Parser (Maybe Float)
floatParser key =
    Query.custom key <|
        \stringList ->
            case stringList of
                [ str ] ->
                    String.toFloat str

                _ ->
                    Nothing


massParser : String -> Query.Parser (ParseResult Mass)
massParser key =
    floatParser key
        |> Query.map (Result.fromMaybe ( key, "La masse est manquante." ))
        |> Query.map
            (Result.andThen
                (\mass ->
                    if mass < 0 then
                        Err ( key, "La masse doit être supérieure ou égale à zéro." )

                    else
                        Ok <| Mass.kilograms mass
                )
            )


productParser : String -> List Product -> Query.Parser (ParseResult Product.Id)
productParser key products =
    Query.string key
        |> Query.map (Result.fromMaybe ( key, "Identifiant du type de produit manquant." ))
        |> Query.map
            (Result.andThen
                (\id ->
                    products
                        |> Product.findById (Product.Id id)
                        |> Result.map .id
                        |> Result.mapError (\err -> ( key, err ))
                )
            )


materialListParser : String -> List Material -> Query.Parser (ParseResult (List Inputs.MaterialQuery))
materialListParser key materials =
    Query.custom (key ++ "[]")
        (List.map (parseMaterial_ materials)
            >> RE.combine
            >> Result.andThen validateMaterialList
            >> Result.mapError (\err -> ( key, err ))
        )


parseMaterial_ : List Material -> String -> Result String Inputs.MaterialQuery
parseMaterial_ materials string =
    case String.split ";" string of
        [ id, share, recycledRatio ] ->
            Ok Inputs.MaterialQuery
                |> RE.andMap (parseMaterialId_ materials id)
                |> RE.andMap (parseRatio_ share)
                |> RE.andMap (parseRatio_ recycledRatio)

        [ "" ] ->
            Err <| "Format de matière vide."

        _ ->
            Err <| "Format de matière invalide ou incomplet : " ++ string ++ "."


parseMaterialId_ : List Material -> String -> Result String Material.Id
parseMaterialId_ materials string =
    materials
        |> Material.findById (Material.Id string)
        |> Result.map .id


parseRatio_ : String -> Result String Unit.Ratio
parseRatio_ string =
    string
        |> String.toFloat
        |> Result.fromMaybe ("Ratio invalide : " ++ string)
        |> Result.andThen
            (\ratio ->
                if ratio < 0 || ratio > 1 then
                    Err <|
                        "Un ratio doit être compris entre 0 et 1 inclus (ici : "
                            ++ String.fromFloat ratio
                            ++ ")."

                else
                    Ok ratio
            )
        |> Result.map Unit.ratio


validateMaterialList : List Inputs.MaterialQuery -> Result String (List Inputs.MaterialQuery)
validateMaterialList list =
    if list == [] then
        Err "La liste des matières est vide."

    else
        let
            total =
                list |> List.map (.share >> Unit.ratioToFloat) |> List.sum
        in
        if total /= 1 then
            Err <|
                "La somme des parts de matières doit être égale à 1 (ici : "
                    ++ String.fromFloat total
                    ++ ")"

        else
            Ok list


countryParser : String -> List Country -> Query.Parser (ParseResult Country.Code)
countryParser key countries =
    Query.string key
        |> Query.map (Result.fromMaybe ( key, "Code pays manquant." ))
        |> Query.map
            (Result.andThen
                (\code ->
                    countries
                        |> Country.findByCode (Country.Code code)
                        |> Result.map .code
                        |> Result.mapError (\err -> ( key, err ))
                )
            )


maybeRatioParser : String -> Query.Parser (ParseResult (Maybe Unit.Ratio))
maybeRatioParser key =
    floatParser key
        |> Query.map
            (Maybe.map
                (\float ->
                    if float < 0 || float > 1 then
                        Err ( key, "Un ratio doit être compris entre 0 et 1 inclus." )

                    else
                        Ok (Just (Unit.ratio float))
                )
                >> Maybe.withDefault (Ok Nothing)
            )


maybeQuality : String -> Query.Parser (ParseResult (Maybe Unit.Quality))
maybeQuality key =
    floatParser key
        |> Query.map
            (Maybe.map
                (\float ->
                    let
                        ( min, max ) =
                            ( Unit.qualityToFloat Unit.minQuality
                            , Unit.qualityToFloat Unit.maxQuality
                            )
                    in
                    if float < min || float > max then
                        Err
                            ( key
                            , "Le coefficient de qualité intrinsèque doit être compris entre "
                                ++ String.fromFloat min
                                ++ " et "
                                ++ String.fromFloat max
                                ++ "."
                            )

                    else
                        Ok (Just (Unit.quality float))
                )
                >> Maybe.withDefault (Ok Nothing)
            )



-- Encoders


encodeErrors : Errors -> Encode.Value
encodeErrors errors =
    Encode.object
        [ ( "errors"
          , errors
                |> Encode.dict identity Encode.string
          )
        ]
