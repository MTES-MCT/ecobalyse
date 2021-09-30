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
    , dyeingWeighting : Maybe Float
    }


type alias Query =
    -- a shorter version than Inputs (identifiers only)
    { mass : Mass
    , material : Process.Uuid
    , product : Product.Id
    , countries : List Country
    , dyeingWeighting : Maybe Float
    }


fromQuery : Query -> Inputs
fromQuery query =
    { mass = query.mass
    , material = Material.findByProcessUuid query.material
    , product = Product.findById query.product
    , countries = query.countries
    , dyeingWeighting = query.dyeingWeighting
    }


toQuery : Inputs -> Query
toQuery { mass, material, product, countries, dyeingWeighting } =
    { mass = mass
    , material = material.materialProcessUuid
    , product = product.id
    , countries = countries
    , dyeingWeighting = dyeingWeighting
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
    , dyeingWeighting = Nothing
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
    , dyeingWeighting = Nothing
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
    , dyeingWeighting = Nothing
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
    , dyeingWeighting = Nothing
    }


robeCircuitBangladesh : Inputs
robeCircuitBangladesh =
    -- Jupe circuit Asie
    { mass = Mass.kilograms 0.5
    , material = Material.findByName "Filament d'aramide"
    , product = Product.findByName "Robe"
    , countries =
        [ Country.China
        , Country.Bangladesh
        , Country.Portugal
        , Country.Tunisia
        , Country.France
        ]
    , dyeingWeighting = Nothing
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
    Decode.map5 Inputs
        (Decode.field "mass" (Decode.map Mass.kilograms Decode.float))
        (Decode.field "material" Material.decode)
        (Decode.field "product" Product.decode)
        (Decode.field "countries" (Decode.list Country.decode))
        (Decode.field "dyeingWeighting" (Decode.maybe Decode.float))


encode : Inputs -> Encode.Value
encode inputs =
    Encode.object
        [ ( "mass", Encode.float (Mass.inKilograms inputs.mass) )
        , ( "material", Material.encode inputs.material )
        , ( "product", Product.encode inputs.product )
        , ( "countries", Encode.list Country.encode inputs.countries )
        , ( "dyeingWeighting", inputs.dyeingWeighting |> Maybe.map Encode.float |> Maybe.withDefault Encode.null )
        ]


decodeQuery : Decoder Query
decodeQuery =
    Decode.map5 Query
        (Decode.field "mass" (Decode.map Mass.kilograms Decode.float))
        (Decode.field "material" (Decode.map Process.Uuid Decode.string))
        (Decode.field "product" (Decode.map Product.Id Decode.string))
        (Decode.field "countries" (Decode.list Country.decode))
        (Decode.field "dyeingWeighting" (Decode.maybe Decode.float))


encodeQuery : Query -> Encode.Value
encodeQuery query =
    Encode.object
        [ ( "mass", Encode.float (Mass.inKilograms query.mass) )
        , ( "material", query.material |> Process.uuidToString |> Encode.string )
        , ( "product", query.product |> Product.idToString |> Encode.string )
        , ( "countries", Encode.list Country.encode query.countries )
        , ( "dyeingWeighting", query.dyeingWeighting |> Maybe.map Encode.float |> Maybe.withDefault Encode.null )
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
