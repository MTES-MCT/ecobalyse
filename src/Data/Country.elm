module Data.Country exposing (..)

import Data.Process as Process
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Country
    = Bangladesh
    | China
    | France
    | India
    | Portugal
    | Spain
    | Tunisia
    | Turkey


type alias Country2 =
    { name : String
    , electricity : Process.Uuid
    , heat : Process.Uuid
    , dyeingWeighting : Float
    }


choices : List Country
choices =
    List.sortBy toString
        [ Bangladesh
        , China
        , France
        , India
        , Portugal
        , Spain
        , Tunisia
        , Turkey
        ]


choices2 : List Country2
choices2 =
    [ { name = "Bangladesh"
      , electricity = Process.Uuid "Mix électrique réseau, BD"
      , heat = Process.Uuid "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
      , dyeingWeighting = 1
      }
    , { name = "China"
      , electricity = Process.Uuid "Mix électrique réseau, CN"
      , heat = Process.Uuid "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
      , dyeingWeighting = 1
      }
    , { name = "France"
      , electricity = Process.Uuid "Mix électrique réseau, FR"
      , heat = Process.Uuid "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), FR"
      , dyeingWeighting = 0
      }
    , { name = "India"
      , electricity = Process.Uuid "Mix électrique réseau, IN"
      , heat = Process.Uuid "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
      , dyeingWeighting = 1
      }
    , { name = "Portugal"
      , electricity = Process.Uuid "Mix électrique réseau, PT"
      , heat = Process.Uuid "Vapeur à partir de gaz naturel (mix de technologies de combustion et d'épuration des effluents gazeux|en sortie de chaudière|Puissance non spécifiée), RER"
      , dyeingWeighting = 0
      }
    , { name = "Spain"
      , electricity = Process.Uuid "Mix électrique réseau, ES"
      , heat = Process.Uuid "Vapeur à partir de gaz naturel (mix de technologies de combustion et d'épuration des effluents gazeux|en sortie de chaudière|Puissance non spécifiée), ES"
      , dyeingWeighting = 0
      }
    , { name = "Tunisia"
      , electricity = Process.Uuid "Mix électrique réseau, TN"
      , heat = Process.Uuid "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
      , dyeingWeighting = 1
      }
    , { name = "Turkey"
      , electricity = Process.Uuid "Mix électrique réseau, TR"
      , heat = Process.Uuid "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
      , dyeingWeighting = 1
      }
    ]


decode : Decoder Country
decode =
    Decode.string
        |> Decode.andThen (fromString >> Decode.succeed)


encode : Country -> Encode.Value
encode country =
    Encode.string (toString country)


fromString : String -> Country
fromString country =
    case country of
        "Bangladesh" ->
            Bangladesh

        "Chine" ->
            China

        "France" ->
            France

        "Inde" ->
            India

        "Espagne" ->
            Spain

        "Portugal" ->
            Portugal

        "Tunisie" ->
            Tunisia

        "Turquie" ->
            Turkey

        _ ->
            France


toString : Country -> String
toString country =
    case country of
        Bangladesh ->
            "Bangladesh"

        China ->
            "Chine"

        France ->
            "France"

        India ->
            "Inde"

        Portugal ->
            "Portugal"

        Spain ->
            "Espagne"

        Tunisia ->
            "Tunisie"

        Turkey ->
            "Turquie"
