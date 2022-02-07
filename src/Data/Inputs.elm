module Data.Inputs exposing
    ( CustomCountryMixes
    , Inputs
    , Query
    , b64decode
    , b64encode
    , countryList
    , defaultCustomCountryMixes
    , defaultQuery
    , encode
    , encodeQuery
    , fromQuery
    , jupeCircuitAsie
    , manteauCircuitEurope
    , pantalonCircuitEurope
    , parseBase64Query
    , presets
    , robeCircuitBangladesh
    , setCustomCountryMix
    , tShirtCotonAsie
    , tShirtCotonEurope
    , tShirtCotonFrance
    , tShirtCotonIndia
    , tShirtPolyamideFrance
    , toQuery
    , updateMaterial
    , updateProduct
    , updateStepCountry
    )

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
import Mass exposing (Mass)
import Result.Extra as RE
import Url.Parser as Parser exposing (Parser)


type alias Inputs =
    { mass : Mass
    , material : Material
    , product : Product
    , countryMaterial : Country
    , countryFabric : Country
    , countryDyeing : Country
    , countryMaking : Country
    , countryDistribution : Country
    , countryUse : Country
    , countryEndOfLife : Country
    , dyeingWeighting : Maybe Unit.Ratio
    , airTransportRatio : Maybe Unit.Ratio
    , recycledRatio : Maybe Unit.Ratio
    , customCountryMixes : CustomCountryMixes
    , quality : Maybe Unit.Quality
    }


type alias Query =
    -- a shorter version than Inputs (identifiers only)
    { mass : Mass
    , material : Process.Uuid
    , product : Product.Id
    , countryFabric : Country.Code
    , countryDyeing : Country.Code
    , countryMaking : Country.Code
    , dyeingWeighting : Maybe Unit.Ratio
    , airTransportRatio : Maybe Unit.Ratio
    , recycledRatio : Maybe Unit.Ratio
    , customCountryMixes : CustomCountryMixes
    , quality : Maybe Unit.Quality
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

        franceResult =
            Country.findByCode (Country.Code "FR") db.countries
    in
    Ok Inputs
        |> RE.andMap (Ok query.mass)
        |> RE.andMap material
        |> RE.andMap (db.products |> Product.findById query.product)
        -- The material country is constrained to be the material's default country
        |> RE.andMap (material |> Result.andThen (\{ defaultCountry } -> Country.findByCode defaultCountry db.countries))
        |> RE.andMap (db.countries |> Country.findByCode query.countryFabric)
        |> RE.andMap (db.countries |> Country.findByCode query.countryDyeing)
        |> RE.andMap (db.countries |> Country.findByCode query.countryMaking)
        -- The distribution country is always France
        |> RE.andMap franceResult
        -- The use country is always France
        |> RE.andMap franceResult
        -- The end of life country is always France
        |> RE.andMap franceResult
        |> RE.andMap (Ok query.dyeingWeighting)
        |> RE.andMap (Ok query.airTransportRatio)
        |> RE.andMap (Ok query.recycledRatio)
        |> RE.andMap (Ok query.customCountryMixes)
        |> RE.andMap (Ok query.quality)


toQuery : Inputs -> Query
toQuery inputs =
    { mass = inputs.mass
    , material = inputs.material.uuid
    , product = inputs.product.id
    , countryFabric = inputs.countryFabric.code
    , countryDyeing = inputs.countryDyeing.code
    , countryMaking = inputs.countryMaking.code
    , dyeingWeighting = inputs.dyeingWeighting
    , airTransportRatio = inputs.airTransportRatio
    , recycledRatio = inputs.recycledRatio
    , customCountryMixes = inputs.customCountryMixes
    , quality = inputs.quality
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
                    -- FIXME: index 1 is WeavingKnitting step; how could we use the step label instead?
                    { customCountryMixes | fabric = value }

                2 ->
                    -- FIXME: index 2 is Ennoblement step; how could we use the step label instead?
                    { customCountryMixes | dyeing = value }

                3 ->
                    -- FIXME: index 3 is Making step; how could we use the step label instead?
                    { customCountryMixes | making = value }

                _ ->
                    customCountryMixes
    }


countryList : Inputs -> List Country
countryList inputs =
    [ inputs.countryMaterial
    , inputs.countryFabric
    , inputs.countryDyeing
    , inputs.countryMaking
    , inputs.countryDistribution
    , inputs.countryUse
    , inputs.countryEndOfLife
    ]


updateStepCountry : Int -> Country.Code -> Query -> Query
updateStepCountry index code query =
    let
        updatedQuery =
            case index of
                1 ->
                    -- FIXME: index 1 is WeavingKnitting step; how could we use the step label instead?
                    { query | countryFabric = code }

                2 ->
                    -- FIXME: index 2 is Ennoblement step; how could we use the step label instead?
                    { query | countryDyeing = code }

                3 ->
                    -- FIXME: index 3 is Making step; how could we use the step label instead?
                    { query | countryMaking = code }

                _ ->
                    query
    in
    { updatedQuery
        | dyeingWeighting =
            -- FIXME: index 2 is Ennoblement step; how could we use th step label instead?
            if index == 2 && query.countryDyeing /= code then
                -- reset custom value as we just switched country, which dyeing weighting is totally different
                Nothing

            else
                query.dyeingWeighting
        , airTransportRatio =
            -- FIXME: index 3 is Making step; how could we use th step label instead?
            if index == 3 && query.countryMaking /= code then
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
        , quality =
            -- ensure resetting quality when product is changed
            if product.id /= query.product then
                Nothing

            else
                query.quality
    }


defaultQuery : Query
defaultQuery =
    tShirtCotonIndia


tShirtCotonFrance : Query
tShirtCotonFrance =
    -- T-shirt circuit France
    { mass = Mass.kilograms 0.17
    , material = Process.Uuid "f211bbdb-415c-46fd-be4d-ddf199575b44"
    , product = Product.Id "tshirt"
    , countryFabric = Country.Code "FR"
    , countryDyeing = Country.Code "FR"
    , countryMaking = Country.Code "FR"
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    , quality = Nothing
    }


tShirtPolyamideFrance : Query
tShirtPolyamideFrance =
    -- T-shirt polyamide (provenance France) circuit France
    { tShirtCotonFrance
        | material = Process.Uuid "182fa424-1f49-4728-b0f1-cb4e4ab36392"
        , countryFabric = Country.Code "FR"
        , countryDyeing = Country.Code "FR"
        , countryMaking = Country.Code "FR"
    }


tShirtCotonEurope : Query
tShirtCotonEurope =
    -- T-shirt circuit Europe
    { tShirtCotonFrance
        | countryFabric = Country.Code "TR"
        , countryDyeing = Country.Code "TN"
        , countryMaking = Country.Code "ES"
    }


tShirtCotonIndia : Query
tShirtCotonIndia =
    -- T-shirt circuit Inde
    { tShirtCotonFrance
        | countryFabric = Country.Code "IN"
        , countryDyeing = Country.Code "IN"
        , countryMaking = Country.Code "IN"
    }


tShirtCotonAsie : Query
tShirtCotonAsie =
    -- T-shirt circuit Asie
    { tShirtCotonFrance
        | countryFabric = Country.Code "CN"
        , countryDyeing = Country.Code "CN"
        , countryMaking = Country.Code "CN"
    }


jupeCircuitAsie : Query
jupeCircuitAsie =
    -- Jupe circuit Asie
    { mass = Mass.kilograms 0.3
    , material = Process.Uuid "aee6709f-0864-4fc5-8760-68cb644a0021"
    , product = Product.Id "jupe"
    , countryFabric = Country.Code "CN"
    , countryDyeing = Country.Code "CN"
    , countryMaking = Country.Code "CN"
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    , quality = Nothing
    }


manteauCircuitEurope : Query
manteauCircuitEurope =
    -- Manteau circuit Europe
    { mass = Mass.kilograms 0.95
    , material = Process.Uuid "380c0d9c-2840-4390-bd3f-5c960f26f5ed"
    , product = Product.Id "manteau"
    , countryFabric = Country.Code "TR"
    , countryDyeing = Country.Code "TN"
    , countryMaking = Country.Code "ES"
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    , quality = Nothing
    }


pantalonCircuitEurope : Query
pantalonCircuitEurope =
    -- Pantalon circuit Europe
    { mass = Mass.kilograms 0.45
    , material = Process.Uuid "e5a6d538-f932-4242-98b4-3a0c6439629c"
    , product = Product.Id "pantalon"
    , countryFabric = Country.Code "TR"
    , countryDyeing = Country.Code "TR"
    , countryMaking = Country.Code "TR"
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    , quality = Nothing
    }


robeCircuitBangladesh : Query
robeCircuitBangladesh =
    -- Robe circuit Bangladesh
    { mass = Mass.kilograms 0.5
    , material = Process.Uuid "7a1ccc4a-2ea7-48dc-9ef0-d57066ea8fa5"
    , product = Product.Id "robe"
    , countryFabric = Country.Code "BD"
    , countryDyeing = Country.Code "PT"
    , countryMaking = Country.Code "TN"
    , dyeingWeighting = Nothing
    , airTransportRatio = Nothing
    , recycledRatio = Nothing
    , customCountryMixes = defaultCustomCountryMixes
    , quality = Nothing
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
        , ( "countryFabric", Country.encode inputs.countryFabric )
        , ( "countryDyeing", Country.encode inputs.countryDyeing )
        , ( "countryMaking", Country.encode inputs.countryMaking )
        , ( "dyeingWeighting", inputs.dyeingWeighting |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "airTransportRatio", inputs.airTransportRatio |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "recycledRatio", inputs.recycledRatio |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "customCountryMixes", encodeCustomCountryMixes inputs.customCountryMixes )
        , ( "quality", inputs.quality |> Maybe.map Unit.encodeQuality |> Maybe.withDefault Encode.null )
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
        |> Pipe.required "countryFabric" (Decode.map Country.Code Decode.string)
        |> Pipe.required "countryDyeing" (Decode.map Country.Code Decode.string)
        |> Pipe.required "countryMaking" (Decode.map Country.Code Decode.string)
        |> Pipe.required "dyeingWeighting" (Decode.maybe Unit.decodeRatio)
        |> Pipe.required "airTransportRatio" (Decode.maybe Unit.decodeRatio)
        |> Pipe.required "recycledRatio" (Decode.maybe Unit.decodeRatio)
        |> Pipe.required "customCountryMixes" decodeCustomCountryMixes
        |> Pipe.required "quality" (Decode.maybe Unit.decodeQuality)


encodeQuery : Query -> Encode.Value
encodeQuery query =
    Encode.object
        [ ( "mass", Encode.float (Mass.inKilograms query.mass) )
        , ( "material", query.material |> Process.uuidToString |> Encode.string )
        , ( "product", query.product |> Product.idToString |> Encode.string )
        , ( "countryFabric", query.countryFabric |> Country.codeToString |> Encode.string )
        , ( "countryDyeing", query.countryDyeing |> Country.codeToString |> Encode.string )
        , ( "countryMaking", query.countryMaking |> Country.codeToString |> Encode.string )
        , ( "dyeingWeighting", query.dyeingWeighting |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "airTransportRatio", query.airTransportRatio |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "recycledRatio", query.recycledRatio |> Maybe.map Unit.encodeRatio |> Maybe.withDefault Encode.null )
        , ( "customCountryMixes", encodeCustomCountryMixes query.customCountryMixes )
        , ( "quality", query.quality |> Maybe.map Unit.encodeQuality |> Maybe.withDefault Encode.null )
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
