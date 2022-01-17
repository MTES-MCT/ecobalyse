module Data.Inputs exposing (..)

import Array
import Base64
import Data.Country as Country exposing (Country)
import Data.Db exposing (Db)
import Data.Material as Material exposing (Material)
import Data.Process as Process
import Data.Product as Product exposing (Product)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import List.Extra as LE
import Mass exposing (Mass)
import Result.Extra as RE
import Url.Parser as Parser exposing (Parser)


type alias Inputs =
    { mass : Mass
    , material : Material
    , product : Product
    , countries : List Country
    , dyeingWeighting : Maybe Unit.Ratio
    , airTransportRatio : Maybe Unit.Ratio
    , recycledRatio : Maybe Unit.Ratio
    , customCountryMixes : CustomCountryMixes
    , useNbCycles : Maybe Int
    }


type alias Query =
    -- a shorter version than Inputs (identifiers only)
    { mass : Mass
    , material : Process.Uuid
    , product : Product.Id
    , countries : List Country.Code
    , dyeingWeighting : Maybe Unit.Ratio
    , airTransportRatio : Maybe Unit.Ratio
    , recycledRatio : Maybe Unit.Ratio
    , customCountryMixes : CustomCountryMixes
    , useNbCycles : Maybe Int
    }


type alias CustomCountryMixes =
    { fabric : Maybe Unit.Impact
    , dyeing : Maybe Unit.Impact
    , making : Maybe Unit.Impact
    }


fromQuery : Db -> Query -> Result String Inputs
fromQuery db query =
    let
        material =
            db.materials |> Material.findByUuid query.material
    in
    Ok Inputs
        |> RE.andMap (Ok query.mass)
        |> RE.andMap material
        |> RE.andMap (db.products |> Product.findById query.product)
        |> RE.andMap (updatedCountryList material db.countries query.countries)
        |> RE.andMap (Ok query.dyeingWeighting)
        |> RE.andMap (Ok query.airTransportRatio)
        |> RE.andMap (Ok query.recycledRatio)
        |> RE.andMap (Ok query.customCountryMixes)
        |> RE.andMap (Ok query.useNbCycles)
        |> Result.andThen
            (\inputs ->
                -- TODO: revamp countries typing & validation
                if List.length inputs.countries /= 6 then
                    Err "La liste des pays est incomplète."

                else
                    Ok inputs
            )


toQuery : Inputs -> Query
toQuery inputs =
    { mass = inputs.mass
    , material = inputs.material.uuid
    , product = inputs.product.id
    , countries = inputs.countries |> List.map .code
    , dyeingWeighting = inputs.dyeingWeighting
    , airTransportRatio = inputs.airTransportRatio
    , recycledRatio = inputs.recycledRatio
    , customCountryMixes = inputs.customCountryMixes
    , useNbCycles = inputs.useNbCycles
    }


defaultCustomCountryMixes : CustomCountryMixes
defaultCustomCountryMixes =
    { fabric = Nothing
    , dyeing = Nothing
    , making = Nothing
    }


setCustomCountryMix : Int -> Maybe Unit.Impact -> Query -> Query
setCustomCountryMix index value ({ customCountryMixes } as query) =
    { query
        | customCountryMixes =
            case index of
                1 ->
                    -- FIXME: index 1 is WeavingKnitting step; how could we use th step label instead?
                    { customCountryMixes | fabric = value }

                2 ->
                    -- FIXME: index 2 is Ennoblement step; how could we use th step label instead?
                    { customCountryMixes | dyeing = value }

                3 ->
                    -- FIXME: index 3 is Making step; how could we use th step label instead?
                    { customCountryMixes | making = value }

                _ ->
                    customCountryMixes
    }


updatedCountryList : Result String Material -> List Country -> List Country.Code -> Result String (List Country)
updatedCountryList material countriesDB countries =
    material
        |> Result.andThen
            (\{ defaultCountry } ->
                countries
                    -- Update the list of countries: the first country (from the material step) is constrained to be the material's default country
                    |> LE.setAt 0 defaultCountry
                    |> (\updatedCountries -> Country.findByCodes updatedCountries countriesDB)
            )


updateStepCountry : Int -> Country.Code -> Query -> Query
updateStepCountry index code query =
    { query
        | countries = LE.setAt index code query.countries
        , dyeingWeighting =
            -- FIXME: index 2 is Ennoblement step; how could we use th step label instead?
            if index == 2 && Array.get index (Array.fromList query.countries) /= Just code then
                -- reset custom value as we just switched country, which dyeing weighting is totally different
                Nothing

            else
                query.dyeingWeighting
        , airTransportRatio =
            -- FIXME: index 3 is Making step; how could we use th step label instead?
            if index == 3 && Array.get index (Array.fromList query.countries) /= Just code then
                -- reset custom value as we just switched country
                Nothing

            else
                query.airTransportRatio
    }
        |> setCustomCountryMix index Nothing


updateMaterial : Material -> Query -> Query
updateMaterial material query =
    { query
        | material = material.uuid
        , recycledRatio =
            -- ensure resetting recycledRatio when material is changed
            if material.uuid /= query.material then
                Nothing

            else
                query.recycledRatio
    }


updateProduct : Product -> Query -> Query
updateProduct product query =
    { query
        | product = product.id
        , useNbCycles =
            -- ensure resetting useNbCycles when product is changed
            if product.id /= query.product then
                Nothing

            else
                query.useNbCycles
    }


defaultQuery : Query
defaultQuery =
    tShirtCotonIndia


tShirtCotonFrance : Query
tShirtCotonFrance =
    -- T-shirt circuit France
    { mass = Mass.kilograms 0.17
    , material = Process.Uuid "f211bbdb-415c-46fd-be4d-ddf199575b44"
    , product = Product.Id "13"
    , countries =
        [ Country.Code "CN"
        , Country.Code "FR"
        , Country.Code "FR"
        , Country.Code "FR"
        , Country.Code "FR"
        , Country.Code "FR"
        ]
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    , useNbCycles = Nothing
    }


tShirtPolyamideFrance : Query
tShirtPolyamideFrance =
    -- T-shirt polyamide (provenance France) circuit France
    { tShirtCotonFrance
        | material = Process.Uuid "182fa424-1f49-4728-b0f1-cb4e4ab36392"
        , countries =
            [ Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            ]
    }


tShirtCotonEurope : Query
tShirtCotonEurope =
    -- T-shirt circuit Europe
    { tShirtCotonFrance
        | countries =
            [ Country.Code "CN"
            , Country.Code "TR"
            , Country.Code "TN"
            , Country.Code "ES"
            , Country.Code "FR"
            , Country.Code "FR"
            ]
    }


tShirtCotonIndia : Query
tShirtCotonIndia =
    -- T-shirt circuit Inde
    { tShirtCotonFrance
        | countries =
            [ Country.Code "CN"
            , Country.Code "IN"
            , Country.Code "IN"
            , Country.Code "IN"
            , Country.Code "FR"
            , Country.Code "FR"
            ]
    }


tShirtCotonAsie : Query
tShirtCotonAsie =
    -- T-shirt circuit Asie
    { tShirtCotonFrance
        | countries =
            [ Country.Code "CN"
            , Country.Code "CN"
            , Country.Code "CN"
            , Country.Code "CN"
            , Country.Code "FR"
            , Country.Code "FR"
            ]
    }


jupeCircuitAsie : Query
jupeCircuitAsie =
    -- Jupe circuit Asie
    { mass = Mass.kilograms 0.3
    , material = Process.Uuid "aee6709f-0864-4fc5-8760-68cb644a0021"
    , product = Product.Id "8"
    , countries =
        [ Country.Code "CN"
        , Country.Code "CN"
        , Country.Code "CN"
        , Country.Code "CN"
        , Country.Code "FR"
        , Country.Code "FR"
        ]
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    , useNbCycles = Nothing
    }


manteauCircuitEurope : Query
manteauCircuitEurope =
    -- Manteau circuit Europe
    { mass = Mass.kilograms 0.95
    , material = Process.Uuid "380c0d9c-2840-4390-bd3f-5c960f26f5ed"
    , product = Product.Id "9"
    , countries =
        [ Country.Code "CN"
        , Country.Code "TR"
        , Country.Code "TN"
        , Country.Code "ES"
        , Country.Code "FR"
        , Country.Code "FR"
        ]
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    , useNbCycles = Nothing
    }


pantalonCircuitEurope : Query
pantalonCircuitEurope =
    -- Pantalon circuit Europe
    { mass = Mass.kilograms 0.45
    , material = Process.Uuid "e5a6d538-f932-4242-98b4-3a0c6439629c"
    , product = Product.Id "10"
    , countries =
        [ Country.Code "CN"
        , Country.Code "TR"
        , Country.Code "TR"
        , Country.Code "TR"
        , Country.Code "FR"
        , Country.Code "FR"
        ]
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    , useNbCycles = Nothing
    }


robeCircuitBangladesh : Query
robeCircuitBangladesh =
    -- Robe circuit Bangladesh
    { mass = Mass.kilograms 0.5
    , material = Process.Uuid "7a1ccc4a-2ea7-48dc-9ef0-d57066ea8fa5"
    , product = Product.Id "12"
    , countries =
        [ Country.Code "CN"
        , Country.Code "BD"
        , Country.Code "PT"
        , Country.Code "TN"
        , Country.Code "FR"
        , Country.Code "FR"
        ]
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    , useNbCycles = Nothing
    }


presets : List Query
presets =
    [ tShirtCotonFrance
    , tShirtCotonEurope
    , tShirtCotonAsie
    , jupeCircuitAsie
    , manteauCircuitEurope
    , pantalonCircuitEurope
    ]


encode : Inputs -> Encode.Value
encode inputs =
    Encode.object
        [ ( "mass", Encode.float (Mass.inKilograms inputs.mass) )
        , ( "material", Material.encode inputs.material )
        , ( "product", Product.encode inputs.product )
        , ( "countries", Encode.list Country.encode inputs.countries )
        , ( "dyeingWeighting", inputs.dyeingWeighting |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "airTransportRatio", inputs.airTransportRatio |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "recycledRatio", inputs.recycledRatio |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "customCountryMixes", encodeCustomCountryMixes inputs.customCountryMixes )
        ]


decodeCustomCountryMixes : Decoder CustomCountryMixes
decodeCustomCountryMixes =
    Decode.map3 CustomCountryMixes
        (Decode.field "fabric" (Decode.maybe Unit.decodeImpact))
        (Decode.field "dyeing" (Decode.maybe Unit.decodeImpact))
        (Decode.field "making" (Decode.maybe Unit.decodeImpact))


encodeCustomCountryMixes : CustomCountryMixes -> Encode.Value
encodeCustomCountryMixes v =
    Encode.object
        [ ( "fabric", v.fabric |> Maybe.map Unit.encodeImpact |> Maybe.withDefault Encode.null )
        , ( "dyeing", v.dyeing |> Maybe.map Unit.encodeImpact |> Maybe.withDefault Encode.null )
        , ( "making", v.making |> Maybe.map Unit.encodeImpact |> Maybe.withDefault Encode.null )
        ]


decodeQuery : Decoder Query
decodeQuery =
    Decode.succeed Query
        |> Pipe.required "mass" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "material" (Decode.map Process.Uuid Decode.string)
        |> Pipe.required "product" (Decode.map Product.Id Decode.string)
        |> Pipe.required "countries" (Decode.list (Decode.map Country.Code Decode.string))
        |> Pipe.required "dyeingWeighting" (Decode.maybe Unit.decodeRatio)
        |> Pipe.required "airTransportRatio" (Decode.maybe Unit.decodeRatio)
        |> Pipe.required "recycledRatio" (Decode.maybe Unit.decodeRatio)
        |> Pipe.required "customCountryMixes" decodeCustomCountryMixes
        |> Pipe.required "useNbCycles" (Decode.maybe Decode.int)


encodeQuery : Query -> Encode.Value
encodeQuery query =
    Encode.object
        [ ( "mass", Encode.float (Mass.inKilograms query.mass) )
        , ( "material", query.material |> Process.uuidToString |> Encode.string )
        , ( "product", query.product |> Product.idToString |> Encode.string )
        , ( "countries", Encode.list (Country.codeToString >> Encode.string) query.countries )
        , ( "dyeingWeighting", query.dyeingWeighting |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "airTransportRatio", query.airTransportRatio |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "recycledRatio", query.recycledRatio |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "customCountryMixes", encodeCustomCountryMixes query.customCountryMixes )
        , ( "useNbCycles", query.useNbCycles |> Maybe.map Encode.int |> Maybe.withDefault Encode.null )
        ]


b64decode : String -> Result String Query
b64decode =
    Base64.decode
        >> Result.andThen
            (Decode.decodeString decodeQuery
                >> Result.mapError Decode.errorToString
            )


b64encode : Query -> String
b64encode =
    encodeQuery >> Encode.encode 0 >> Base64.encode



-- Parser


parseBase64Query : Parser (Maybe Query -> a) a
parseBase64Query =
    Parser.custom "QUERY" <|
        b64decode
            >> Result.toMaybe
            >> Just
