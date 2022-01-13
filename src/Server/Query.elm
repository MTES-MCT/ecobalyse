module Server.Query exposing (..)

import Data.Country as Country
import Data.Db exposing (Db)
import Data.Inputs as Inputs
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


parse : Db -> Query.Parser (Result Errors Inputs.Query)
parse db =
    Query.map Inputs.Query
        (massParser "mass")
        |> apply (materialParser "material")
        |> apply (productParser "product")
        |> apply (countriesParser "countries")
        |> apply (ratioParser "dyeingWeighting")
        |> apply (ratioParser "airTransportRatio")
        |> apply (ratioParser "recycledRatio")
        |> apply customCountryMixesParser
        |> apply (Query.int "useNbCycles")
        |> Query.map (validateQuery db)



-- Parsers


apply : Query.Parser a -> Query.Parser (a -> b) -> Query.Parser b
apply argParser funcParser =
    -- See https://package.elm-lang.org/packages/elm/url/latest/Url-Parser-Query#map8
    Query.map2 (<|) funcParser argParser


floatParser : String -> Query.Parser (Maybe Float)
floatParser key =
    Query.custom key <|
        \stringList ->
            case stringList of
                [ str ] ->
                    String.toFloat str

                _ ->
                    Nothing


massParser : String -> Query.Parser Mass
massParser key =
    floatParser key
        |> Query.map
            (Maybe.map Mass.kilograms
                >> Maybe.withDefault (Mass.kilograms -1)
            )


productParser : String -> Query.Parser Product.Id
productParser key =
    Query.string key
        |> Query.map
            (Maybe.map Product.Id
                >> Maybe.withDefault (Product.Id "")
            )


materialParser : String -> Query.Parser Process.Uuid
materialParser key =
    Query.string key
        |> Query.map
            (Maybe.map Process.Uuid
                >> Maybe.withDefault (Process.Uuid "")
            )


countriesParser : String -> Query.Parser (List Country.Code)
countriesParser key =
    Query.string key
        |> Query.map
            (Maybe.map
                (String.split "," >> List.map Country.Code)
                >> Maybe.withDefault []
            )


ratioParser : String -> Query.Parser (Maybe Unit.Ratio)
ratioParser key =
    floatParser key
        |> Query.map (Maybe.map Unit.ratio)


impactParser : String -> Query.Parser (Maybe Unit.Impact)
impactParser key =
    floatParser key
        |> Query.map (Maybe.map Unit.impact)


customCountryMixesParser : Query.Parser Inputs.CustomCountryMixes
customCountryMixesParser =
    Query.map3 Inputs.CustomCountryMixes
        (impactParser "customCountryMix[fabric]")
        (impactParser "customCountryMix[dyeing]")
        (impactParser "customCountryMix[making]")



-- Validation


validateQuery : Db -> Inputs.Query -> Result Errors Inputs.Query
validateQuery db query =
    let
        errorsList =
            List.filterMap (\( f, msg ) -> msg |> Maybe.map (\m -> ( f, m )))
                [ ( "mass", validateMass query.mass )
                , ( "material", validateMaterial db query.material )
                , ( "product", validateProduct db query.product )
                , ( "countries", validateCountries db query.countries )
                , ( "dyeingWeighting", validateRatio query.dyeingWeighting )
                , ( "airTransportRatio", validateRatio query.airTransportRatio )
                , ( "recycledRatio", validateRatio query.recycledRatio )
                , ( "useNbCycles", validateUseNbCycles query.useNbCycles )
                ]
    in
    case errorsList of
        [] ->
            Ok query

        errors ->
            Err (Dict.fromList errors)


validateMass : Mass -> Maybe ErrorMessage
validateMass mass =
    if Mass.inKilograms mass < 0 then
        Just "La masse doit être supérieure ou égale à zéro."

    else
        Nothing


validateMaterial : Db -> Process.Uuid -> Maybe ErrorMessage
validateMaterial db uuid =
    case Material.findByUuid uuid db.materials of
        Err _ ->
            Just "Identifiant de la matière manquant ou invalide."

        Ok _ ->
            Nothing


validateProduct : Db -> Product.Id -> Maybe ErrorMessage
validateProduct db id =
    case Product.findById id db.products of
        Err _ ->
            Just "Identifiant du type de produit manquant ou invalide."

        Ok _ ->
            Nothing


validateCountries : Db -> List Country.Code -> Maybe ErrorMessage
validateCountries db countries =
    if List.length countries /= 6 then
        Just "La liste de pays doit contenir 6 pays."

    else
        case Country.findByCodes countries db.countries of
            Err error ->
                Just error

            Ok _ ->
                Nothing


validateRatio : Maybe Unit.Ratio -> Maybe ErrorMessage
validateRatio maybeRatio =
    maybeRatio
        |> Maybe.andThen
            (\(Unit.Ratio float) ->
                if float < 0 || float > 1 then
                    Just "Un ratio doit être compris entre 0 et 1 inclus."

                else
                    Nothing
            )


validateUseNbCycles : Maybe Int -> Maybe ErrorMessage
validateUseNbCycles maybeUseNbCycles =
    maybeUseNbCycles
        |> Maybe.andThen
            (\int ->
                if int < 0 || int > 100 then
                    Just "Un nombre de cycles d'entretien doit être compris entre 0 et 100 inclus."

                else
                    Nothing
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
