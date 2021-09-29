module Data.Inputs exposing (..)

import Base64
import Data.Country as Country exposing (Country)
import Data.Material as Material exposing (Material)
import Data.Process as Process
import Data.Product as Product exposing (Product)
import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Mass exposing (Mass)


type alias Inputs =
    { mass : Mass
    , material : Material
    , product : Product
    , countries : List Country
    }


type alias Query =
    -- a shorter version than Inputs (identifiers only)
    { mass : Mass
    , material : Process.Uuid
    , product : Product.Id
    , countries : List Country
    }


fromQuery : Query -> Inputs
fromQuery query =
    { mass = query.mass
    , material = Material.findByProcessUuid query.material
    , product = Product.findById query.product
    , countries = query.countries
    }


toQuery : Inputs -> Query
toQuery { mass, material, product, countries } =
    { mass = mass
    , material = material.materialProcessUuid
    , product = product.id
    , countries = countries
    }


toLabel : Inputs -> String
toLabel { mass, material, product } =
    String.join " "
        [ product.name
        , "en"
        , material.name
        , "de"
        , FormatNumber.format { frenchLocale | decimals = Exact 2 } (Mass.inKilograms mass) ++ "\u{202F}kg"
        ]


defaults : Inputs
defaults =
    tShirtCotonFrance


defaultQuery : Query
defaultQuery =
    toQuery defaults


tShirtCotonFrance : Inputs
tShirtCotonFrance =
    -- T-shirt circuit France
    { mass = Product.tShirt.mass
    , material = Material.cotton
    , product = Product.tShirt
    , countries =
        [ Country.China
        , Country.France
        , Country.France
        , Country.France
        , Country.France
        ]
    }


tShirtCotonEurope : Inputs
tShirtCotonEurope =
    -- T-shirt circuit Europe
    { tShirtCotonFrance
        | countries =
            [ Country.China
            , Country.Turkey
            , Country.Tunisia
            , Country.Spain
            , Country.France
            ]
    }


tShirtCotonAsie : Inputs
tShirtCotonAsie =
    -- T-shirt circuit Europe
    { tShirtCotonFrance
        | countries =
            [ Country.China
            , Country.China
            , Country.China
            , Country.China
            , Country.France
            ]
    }


jupeCircuitAsie : Inputs
jupeCircuitAsie =
    -- Jupe circuit Asie
    { mass = Product.findByName "Jupe" |> .mass
    , material = Material.findByName "Filament d'acrylique"
    , product = Product.findByName "Jupe"
    , countries =
        [ Country.China
        , Country.China
        , Country.China
        , Country.China
        , Country.France
        ]
    }


manteauCircuitEurope : Inputs
manteauCircuitEurope =
    -- Manteau circuit Europe
    { mass = Product.findByName "Manteau" |> .mass
    , material = Material.findByName "Fil de cachemire"
    , product = Product.findByName "Manteau"
    , countries =
        [ Country.China
        , Country.Turkey
        , Country.Tunisia
        , Country.Spain
        , Country.France
        ]
    }


pantalonCircuitEurope : Inputs
pantalonCircuitEurope =
    { mass = Product.findByName "Pantalon" |> .mass
    , material = Material.findByName "Fil de lin (filasse)"
    , product = Product.findByName "Pantalon"
    , countries =
        [ Country.China
        , Country.Turkey
        , Country.Turkey
        , Country.Turkey
        , Country.France
        ]
    }


presets : List Inputs
presets =
    [ tShirtCotonFrance
    , tShirtCotonEurope
    , tShirtCotonAsie
    , jupeCircuitAsie
    , manteauCircuitEurope
    , pantalonCircuitEurope
    ]


decode : Decoder Inputs
decode =
    Decode.map4 Inputs
        (Decode.field "mass" (Decode.map Mass.kilograms Decode.float))
        (Decode.field "material" Material.decode)
        (Decode.field "product" Product.decode)
        (Decode.field "countries" (Decode.list Country.decode))


encode : Inputs -> Encode.Value
encode inputs =
    Encode.object
        [ ( "mass", Encode.float (Mass.inKilograms inputs.mass) )
        , ( "material", Material.encode inputs.material )
        , ( "product", Product.encode inputs.product )
        , ( "countries", Encode.list Country.encode inputs.countries )
        ]


decodeQuery : Decoder Query
decodeQuery =
    Decode.map4 Query
        (Decode.field "mass" (Decode.map Mass.kilograms Decode.float))
        (Decode.field "material" (Decode.map Process.Uuid Decode.string))
        (Decode.field "product" (Decode.map Product.Id Decode.string))
        (Decode.field "countries" (Decode.list Country.decode))


encodeQuery : Query -> Encode.Value
encodeQuery query =
    Encode.object
        [ ( "mass", Encode.float (Mass.inKilograms query.mass) )
        , ( "material", query.material |> Process.uuidToString |> Encode.string )
        , ( "product", query.product |> Product.idToString |> Encode.string )
        , ( "countries", Encode.list Country.encode query.countries )
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
