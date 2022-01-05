module Server.Query exposing (..)

import Data.Country as Country
import Data.Db exposing (Db)
import Data.Inputs as Inputs exposing (CustomCountryMixes)
import Data.Material as Material
import Data.Process as Process
import Data.Product as Product
import Data.Unit as Unit
import Dict exposing (Dict)
import Json.Encode as Encode
import Mass exposing (Mass)
import Url.Parser.Query as Query



-- Query String


type alias FieldName =
    String


type alias ErrorMessage =
    String


type alias Errors =
    Dict FieldName ErrorMessage


succeed : a -> Query.Parser a
succeed =
    -- Kind of a hack: we don't have access to the Query.Parser constructor, so
    -- we use Query.custom to wrap our thing in a Query.Parser
    always >> Query.custom ""


parse : Db -> Query.Parser (Result Errors Inputs.Query)
parse db =
    succeed (Ok Inputs.Query)
        |> apply (massParser "mass")
        |> apply (materialParser "material" db.materials)
        |> apply (productParser "product" db.products)
        |> apply (countryParser "countryFabric" db.countries)
        |> apply (countryParser "countryDyeing" db.countries)
        |> apply (countryParser "countryMaking" db.countries)
        |> apply (maybeRatioParser "dyeingWeighting")
        |> apply (maybeRatioParser "airTransportRatio")
        |> apply (maybeRatioParser "recycledRatio")
        |> apply (Query.map Ok customCountryMixesParser)
        |> apply (maybeUseNbCycles "useNbCycles")


toErrors : Result ( FieldName, String ) a -> Result Errors a
toErrors result =
    Result.mapError (\( key, errorMessage ) -> Dict.singleton key errorMessage) result


apply :
    Query.Parser (Result ( String, String ) a)
    -> Query.Parser (Result Errors (a -> b))
    -> Query.Parser (Result Errors b)
apply argParser funcParser =
    -- Adapted from https://package.elm-lang.org/packages/elm/url/latest/Url-Parser-Query#map8
    -- with the full list of errors returned, instead of just the first one encountered.
    let
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
    in
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


massParser : String -> Query.Parser (Result ( FieldName, String ) Mass)
massParser key =
    floatParser key
        |> Query.map
            (Maybe.andThen
                (\mass ->
                    if mass < 0 then
                        Nothing

                    else
                        Just <| Mass.kilograms mass
                )
            )
        |> Query.map (Result.fromMaybe ( key, "La masse doit être supérieure ou égale à zéro." ))


productParser : String -> List Product.Product -> Query.Parser (Result ( FieldName, String ) Product.Id)
productParser key products =
    Query.string key
        |> Query.map
            (Maybe.andThen
                (\id ->
                    case Product.findById (Product.Id id) products of
                        Err _ ->
                            Nothing

                        Ok _ ->
                            Just (Product.Id id)
                )
            )
        |> Query.map (Result.fromMaybe ( key, "Identifiant du type de produit manquant ou invalide." ))


materialParser : String -> List Material.Material -> Query.Parser (Result ( FieldName, String ) Process.Uuid)
materialParser key materials =
    Query.string key
        |> Query.map
            (Maybe.andThen
                (\uuid ->
                    case Material.findByUuid (Process.Uuid uuid) materials of
                        Err _ ->
                            Nothing

                        Ok _ ->
                            Just (Process.Uuid uuid)
                )
            )
        |> Query.map (Result.fromMaybe ( key, "Identifiant de la matière manquant ou invalide." ))


countryParser : String -> List Country.Country -> Query.Parser (Result ( FieldName, String ) Country.Code)
countryParser key countries =
    Query.string key
        |> Query.map
            (\maybeCode ->
                maybeCode
                    |> Result.fromMaybe ( key, "Code pays manquant" )
                    |> Result.andThen
                        (\code ->
                            Country.findByCode (Country.Code code) countries
                                |> Result.map .code
                                |> Result.mapError (\errorMessage -> ( key, errorMessage ))
                        )
            )


maybeRatioParser : String -> Query.Parser (Result ( FieldName, String ) (Maybe Unit.Ratio))
maybeRatioParser key =
    floatParser key
        |> Query.map
            (\maybeFloat ->
                case maybeFloat of
                    Nothing ->
                        Ok Nothing

                    Just float ->
                        if float < 0 || float > 1 then
                            Err ( key, "Un ratio doit être compris entre 0 et 1 inclus." )

                        else
                            Ok (Just (Unit.ratio float))
            )


impactParser : String -> Query.Parser (Maybe Unit.Impact)
impactParser key =
    floatParser key
        |> Query.map (Maybe.map Unit.impact)


customCountryMixesParser : Query.Parser CustomCountryMixes
customCountryMixesParser =
    Query.map3 CustomCountryMixes
        (impactParser "customCountryMix[fabric]")
        (impactParser "customCountryMix[dyeing]")
        (impactParser "customCountryMix[making]")


maybeUseNbCycles : String -> Query.Parser (Result ( FieldName, String ) (Maybe Int))
maybeUseNbCycles key =
    Query.int key
        |> Query.map
            (\maybeInt ->
                case maybeInt of
                    Nothing ->
                        Ok Nothing

                    Just int ->
                        if int < 0 || int > 100 then
                            Err ( key, "Un nombre de cycles d'entretien doit être compris entre 0 et 100 inclus." )

                        else
                            Ok (Just int)
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
