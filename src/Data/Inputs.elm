module Data.Inputs exposing (..)

import Data.Country as Country exposing (Country)
import Data.Material as Material exposing (Material)
import Data.Product as Product exposing (Product)
import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)


type alias Inputs =
    { mass : Float
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
        , FormatNumber.format { frenchLocale | decimals = Exact 2 } mass ++ "\u{202F}kg"
        , "(" ++ (countries |> List.map Country.toString |> String.join "->") ++ ")"
        ]


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
