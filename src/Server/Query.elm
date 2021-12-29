module Server.Query exposing (..)

import Data.Country as Country
import Data.Inputs as Inputs
import Data.Process as Process
import Data.Product as Product
import Data.Unit as Unit
import Mass exposing (Mass)
import Url.Parser.Query as Query



-- Query String


parseQueryString : Query.Parser (Result Inputs.QueryErrors Inputs.Query)
parseQueryString =
    -- TODO: have a global query validation function to be used in here and Inputs.fromQuery.
    -- This function would return `Result (Dict String Error) Inputs.Query` (one message per
    -- errored field) so we could render all errors at once to the user or in the API response.
    Query.map Inputs.Query
        (massParser "mass")
        |> apply (materialParser "material")
        |> apply (productParser "product")
        -- FIXME: handle countries=XX&countries=YY format…
        |> apply (countriesParser "countries[]")
        |> apply (ratioParser "dyeingWeighting")
        |> apply (ratioParser "airTransportRatio")
        |> apply (ratioParser "recycledRatio")
        |> apply customCountryMixesParser
        |> Query.map Inputs.validateQuery


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
                >> Maybe.withDefault (Product.Id "<empty>")
            )


materialParser : String -> Query.Parser Process.Uuid
materialParser key =
    Query.string key
        |> Query.map
            (Maybe.map Process.Uuid
                >> Maybe.withDefault (Process.Uuid "<empty>")
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
