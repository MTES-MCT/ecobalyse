module Data.Inputs exposing (..)

import Base64
import Data.Country as Country exposing (Country)
import Data.Material as Material exposing (Material)
import Data.Product as Product exposing (Product)
import Data.Unit as Unit
import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Inputs =
    { mass : Unit.Kg
    , material : Material
    , product : Product
    , countries : List Country
    }


toLabel : Inputs -> String
toLabel { mass, material, product, countries } =
    String.join " "
        [ product.name
        , "en"
        , material.name
        , "de"
        , FormatNumber.format { frenchLocale | decimals = Exact 2 } (Unit.kgToFloat mass) ++ "\u{202F}kg"
        , "(" ++ (countries |> List.map Country.toString |> String.join "->") ++ ")"
        ]


defaults =
    { mass = Product.tShirt.mass
    , material = Material.cotton
    , product = Product.tShirt
    , countries = []
    }


presets : List Inputs
presets =
    [ -- T-shirt circuit France
      { mass = Product.tShirt.mass
      , material = Material.cotton
      , product = Product.tShirt
      , countries = []
      }

    -- T-shirt circuit Europe
    , { mass = Product.tShirt.mass
      , material = Material.cotton
      , product = Product.tShirt
      , countries = [ Country.China, Country.Turkey, Country.Tunisia, Country.Spain, Country.France ]
      }

    -- T-shirt circuit Asie
    , { mass = Product.tShirt.mass
      , material = Material.cotton
      , product = Product.tShirt
      , countries = [ Country.China, Country.China, Country.China, Country.China, Country.France ]
      }

    -- Jupe circuit Asie
    , { mass = Product.findByName "Jupe" |> .mass
      , material = Material.findByName "Filament d'acrylique"
      , product = Product.findByName "Jupe"
      , countries = [ Country.China, Country.China, Country.China, Country.China, Country.France ]
      }

    -- Manteau circuit Europe
    , { mass = Product.findByName "Manteau" |> .mass
      , material = Material.findByName "Fil de cachemire"
      , product = Product.findByName "Manteau"
      , countries = [ Country.China, Country.Turkey, Country.Tunisia, Country.Spain, Country.France ]
      }

    -- Pantalon circuit Turquie
    , { mass = Product.findByName "Pantalon" |> .mass
      , material = Material.findByName "Fil de lin (filasse)"
      , product = Product.findByName "Pantalon"
      , countries = [ Country.China, Country.Turkey, Country.Turkey, Country.Turkey, Country.France ]
      }
    ]


decode : Decoder Inputs
decode =
    Decode.map4 Inputs
        (Decode.field "mass" Unit.decodeKg)
        (Decode.field "material" Material.decode)
        (Decode.field "product" Product.decode)
        (Decode.field "countries" (Decode.list Country.decode))


encode : Inputs -> Encode.Value
encode inputs =
    Encode.object
        [ ( "mass", Unit.encodeKg inputs.mass )
        , ( "material", Material.encode inputs.material )
        , ( "product", Product.encode inputs.product )
        , ( "countries", Encode.list Country.encode inputs.countries )
        ]


b64decode : String -> Result String Inputs
b64decode =
    Base64.decode
        >> Result.andThen
            (Decode.decodeString decode
                >> Result.mapError Decode.errorToString
            )


b64encode : Inputs -> String
b64encode =
    encode >> Encode.encode 0 >> Base64.encode
