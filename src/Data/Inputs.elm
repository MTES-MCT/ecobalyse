module Data.Inputs exposing (..)

import Array
import Base64
import Data.Country as Country exposing (Country)
import Data.Db exposing (Db)
import Data.Impact as Impact exposing (Impact)
import Data.Material as Material exposing (Material)
import Data.Process as Process
import Data.Product as Product exposing (Product)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)


type alias Inputs =
    { impact : Impact
    , mass : Mass
    , material : Material
    , product : Product
    , countries : List Country
    , dyeingWeighting : Maybe Float
    , airTransportRatio : Maybe Float
    , recycledRatio : Maybe Float
    , customCountryMixes : CustomCountryMixes
    }


type alias Query =
    -- a shorter version than Inputs (identifiers only)
    { impact : Impact.Trigram
    , mass : Mass
    , material : Process.Uuid
    , product : Product.Id
    , countries : List Country.Code
    , dyeingWeighting : Maybe Float
    , airTransportRatio : Maybe Float
    , recycledRatio : Maybe Float
    , customCountryMixes : CustomCountryMixes
    }


type alias CustomCountryMixes =
    { fabric : Maybe Unit.Impact
    , dyeing : Maybe Unit.Impact
    , making : Maybe Unit.Impact
    }


fromQuery : Db -> Query -> Result String Inputs
fromQuery db query =
    let
        lookups =
            { impact = db.impacts |> Impact.get query.impact
            , material = db.materials |> Material.findByUuid query.material
            , product = db.products |> Product.findById query.product
            , countries = db.countries |> Country.findByCodes query.countries
            }

        build impact_ material_ product_ countries_ =
            { impact = impact_
            , mass = query.mass
            , material = material_
            , product = product_
            , countries = countries_
            , dyeingWeighting = query.dyeingWeighting
            , airTransportRatio = query.airTransportRatio
            , recycledRatio = query.recycledRatio
            , customCountryMixes = query.customCountryMixes
            }
    in
    Result.map4 build
        lookups.impact
        lookups.material
        lookups.product
        lookups.countries


toQuery : Inputs -> Query
toQuery inputs =
    { impact = inputs.impact.trigram
    , mass = inputs.mass
    , material = inputs.material.uuid
    , product = inputs.product.id
    , countries = inputs.countries |> List.map .code
    , dyeingWeighting = inputs.dyeingWeighting
    , airTransportRatio = inputs.airTransportRatio
    , recycledRatio = inputs.recycledRatio
    , customCountryMixes = inputs.customCountryMixes
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


updateStepCountry : Int -> Country.Code -> Query -> Query
updateStepCountry index code query =
    { query
        | countries = query.countries |> Array.fromList |> Array.set index code |> Array.toList
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
        |> updateStepCountry 0 material.defaultCountry


setQueryImpact : Impact.Trigram -> Query -> Query
setQueryImpact trigram query =
    { query | impact = trigram }


defaultQuery : Impact.Trigram -> Query
defaultQuery =
    -- FIXME: provide a query |> setQueryImpact (Trigram "xxx") helper
    tShirtCotonIndia


tShirtCotonFrance : Impact.Trigram -> Query
tShirtCotonFrance trigram =
    -- T-shirt circuit France
    { impact = trigram
    , mass = Mass.kilograms 0.17
    , material = Process.Uuid "f211bbdb-415c-46fd-be4d-ddf199575b44"
    , product = Product.Id "13"
    , countries =
        [ Country.Code "CN"
        , Country.Code "FR"
        , Country.Code "FR"
        , Country.Code "FR"
        , Country.Code "FR"
        ]
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    }


tShirtPolyamideFrance : Impact.Trigram -> Query
tShirtPolyamideFrance trigram =
    let
        query =
            tShirtCotonFrance trigram
    in
    -- T-shirt polyamide (provenance France) circuit France
    { query
        | material = Process.Uuid "182fa424-1f49-4728-b0f1-cb4e4ab36392"
        , countries =
            [ Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            ]
    }


tShirtCotonEurope : Impact.Trigram -> Query
tShirtCotonEurope trigram =
    let
        query =
            tShirtCotonFrance trigram
    in
    -- T-shirt circuit Europe
    { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "TR"
            , Country.Code "TN"
            , Country.Code "ES"
            , Country.Code "FR"
            ]
    }


tShirtCotonIndia : Impact.Trigram -> Query
tShirtCotonIndia trigram =
    let
        query =
            tShirtCotonFrance trigram
    in
    -- T-shirt circuit Inde
    { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "IN"
            , Country.Code "IN"
            , Country.Code "IN"
            , Country.Code "FR"
            ]
    }


tShirtCotonAsie : Impact.Trigram -> Query
tShirtCotonAsie trigram =
    let
        query =
            tShirtCotonFrance trigram
    in
    -- T-shirt circuit Europe
    { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "CN"
            , Country.Code "CN"
            , Country.Code "CN"
            , Country.Code "FR"
            ]
    }


jupeCircuitAsie : Impact.Trigram -> Query
jupeCircuitAsie trigram =
    -- Jupe circuit Asie
    { impact = trigram
    , mass = Mass.kilograms 0.3
    , material = Process.Uuid "aee6709f-0864-4fc5-8760-68cb644a0021"
    , product = Product.Id "8"
    , countries =
        [ Country.Code "CN"
        , Country.Code "CN"
        , Country.Code "CN"
        , Country.Code "CN"
        , Country.Code "FR"
        ]
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    }


manteauCircuitEurope : Impact.Trigram -> Query
manteauCircuitEurope trigram =
    -- Manteau circuit Europe
    { impact = trigram
    , mass = Mass.kilograms 0.95
    , material = Process.Uuid "380c0d9c-2840-4390-bd3f-5c960f26f5ed"
    , product = Product.Id "9"
    , countries =
        [ Country.Code "CN"
        , Country.Code "TR"
        , Country.Code "TN"
        , Country.Code "ES"
        , Country.Code "FR"
        ]
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    }


pantalonCircuitEurope : Impact.Trigram -> Query
pantalonCircuitEurope trigram =
    -- Pantalon circuit Europe
    { impact = trigram
    , mass = Mass.kilograms 0.45
    , material = Process.Uuid "e5a6d538-f932-4242-98b4-3a0c6439629c"
    , product = Product.Id "10"
    , countries =
        [ Country.Code "CN"
        , Country.Code "TR"
        , Country.Code "TR"
        , Country.Code "TR"
        , Country.Code "FR"
        ]
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    }


robeCircuitBangladesh : Impact.Trigram -> Query
robeCircuitBangladesh trigram =
    -- Robe circuit Bangladesh
    { impact = trigram
    , mass = Mass.kilograms 0.5
    , material = Process.Uuid "7a1ccc4a-2ea7-48dc-9ef0-d57066ea8fa5"
    , product = Product.Id "12"
    , countries =
        [ Country.Code "CN"
        , Country.Code "BD"
        , Country.Code "PT"
        , Country.Code "TN"
        , Country.Code "FR"
        ]
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    }


presets : Impact.Trigram -> List Query
presets trigram =
    [ tShirtCotonFrance trigram
    , tShirtCotonEurope trigram
    , tShirtCotonAsie trigram
    , jupeCircuitAsie trigram
    , manteauCircuitEurope trigram
    , pantalonCircuitEurope trigram
    ]


encode : Inputs -> Encode.Value
encode inputs =
    Encode.object
        [ ( "impact", Impact.encodeImpact inputs.impact )
        , ( "mass", Encode.float (Mass.inKilograms inputs.mass) )
        , ( "material", Material.encode inputs.material )
        , ( "product", Product.encode inputs.product )
        , ( "countries", Encode.list Country.encode inputs.countries )
        , ( "dyeingWeighting", inputs.dyeingWeighting |> Maybe.map Encode.float |> Maybe.withDefault Encode.null )
        , ( "airTransportRatio", inputs.airTransportRatio |> Maybe.map Encode.float |> Maybe.withDefault Encode.null )
        , ( "recycledRatio", inputs.recycledRatio |> Maybe.map Encode.float |> Maybe.withDefault Encode.null )
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
        |> Pipe.required "impact" (Decode.map Impact.Trigram Decode.string)
        |> Pipe.required "mass" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "material" (Decode.map Process.Uuid Decode.string)
        |> Pipe.required "product" (Decode.map Product.Id Decode.string)
        |> Pipe.required "countries" (Decode.list (Decode.map Country.Code Decode.string))
        |> Pipe.required "dyeingWeighting" (Decode.maybe Decode.float)
        |> Pipe.required "airTransportRatio" (Decode.maybe Decode.float)
        |> Pipe.required "recycledRatio" (Decode.maybe Decode.float)
        |> Pipe.required "customCountryMixes" decodeCustomCountryMixes


encodeQuery : Query -> Encode.Value
encodeQuery query =
    Encode.object
        [ ( "mass", Encode.float (Mass.inKilograms query.mass) )
        , ( "material", query.material |> Process.uuidToString |> Encode.string )
        , ( "product", query.product |> Product.idToString |> Encode.string )
        , ( "countries", Encode.list (Country.codeToString >> Encode.string) query.countries )
        , ( "dyeingWeighting", query.dyeingWeighting |> Maybe.map Encode.float |> Maybe.withDefault Encode.null )
        , ( "airTransportRatio", query.airTransportRatio |> Maybe.map Encode.float |> Maybe.withDefault Encode.null )
        , ( "recycledRatio", query.recycledRatio |> Maybe.map Encode.float |> Maybe.withDefault Encode.null )
        , ( "customCountryMixes", encodeCustomCountryMixes query.customCountryMixes )
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
