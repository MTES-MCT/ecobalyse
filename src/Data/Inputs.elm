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
      { mass = 0.17
      , material = Material.cotton
      , product = Product.tShirt
      , countries = []
      }

    -- Jupe circuit Asie
    , { mass = 0.17
      , material = Material.findByName "Filament d'acrylique"
      , product = Product.findByName "Jupe"
      , countries = [ Country.China, Country.China, Country.China, Country.China, Country.China ]
      }
    ]
