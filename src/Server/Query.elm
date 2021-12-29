module Server.Query exposing (..)

import Data.Country as Country
import Data.Inputs as Inputs
import Data.Process as Process
import Data.Product as Product
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)
import Url.Parser.Query as Query



-- Query String


fromQueryString : Query.Parser Inputs.Query
fromQueryString =
    Query.map Inputs.Query
        (massParser "mass")
        |> apply (materialParser "material")
        |> apply (productParser "product")
        |> apply (countriesParser "countries")
        |> apply (ratioParser "dyeingWeighting")
        |> apply (ratioParser "airTransportRatio")
        |> apply (ratioParser "recycledRatio")
        |> apply customCountryMixesParser


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
    Query.custom key <|
        \stringList ->
            -- if List.length countries == 0 && not (String.contains "[]" key) then
            List.map Country.Code stringList


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



-- Express JSON Query


expressQueryDecoder : Decoder Inputs.Query
expressQueryDecoder =
    let
        decodeStringFloat =
            Decode.string
                |> Decode.andThen
                    (String.toFloat
                        >> Result.fromMaybe "Valeur décimale invalide."
                        >> DecodeExtra.fromResult
                    )

        decodeMassString =
            decodeStringFloat
                |> Decode.andThen
                    (\float ->
                        if float <= 0 then
                            Decode.fail "La masse doit être strictement supérieure à zéro."

                        else
                            Decode.succeed (Mass.kilograms float)
                    )

        decodeCountries =
            Decode.string
                |> Decode.map Country.Code
                |> Decode.list
                |> Decode.andThen
                    (\countries ->
                        if List.length countries /= 5 then
                            Decode.fail "La liste de pays doit contenir 5 pays."

                        else
                            Decode.succeed countries
                    )

        decodeRatioString =
            decodeStringFloat
                |> Decode.andThen (Unit.validateRatio >> DecodeExtra.fromResult)

        decodeImpactString =
            decodeStringFloat
                |> Decode.andThen
                    (\float ->
                        if float < 0 then
                            Decode.fail "Un impact de mix énergétique ne peut être négatif."

                        else
                            Decode.succeed (Unit.impact float)
                    )
    in
    Decode.succeed Inputs.Query
        |> Pipe.required "mass" decodeMassString
        |> Pipe.required "material" (Decode.map Process.Uuid Decode.string)
        |> Pipe.required "product" (Decode.map Product.Id Decode.string)
        |> Pipe.required "countries" decodeCountries
        |> Pipe.optional "dyeingWeighting" (Decode.map Just decodeRatioString) Nothing
        |> Pipe.optional "airTransportRatio" (Decode.map Just decodeRatioString) Nothing
        |> Pipe.optional "recycledRatio" (Decode.map Just decodeRatioString) Nothing
        |> Pipe.optional "customCountryMixes"
            (Decode.succeed Inputs.CustomCountryMixes
                |> Pipe.optional "fabric" (Decode.map Just decodeImpactString) Nothing
                |> Pipe.optional "dyeing" (Decode.map Just decodeImpactString) Nothing
                |> Pipe.optional "making" (Decode.map Just decodeImpactString) Nothing
            )
            Inputs.defaultCustomCountryMixes


decodeExpressQuery : Encode.Value -> Result String Inputs.Query
decodeExpressQuery =
    Decode.decodeValue expressQueryDecoder
        >> Result.mapError Decode.errorToString
