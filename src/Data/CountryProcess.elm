module Data.CountryProcess exposing (..)

import Data.Country as Country exposing (..)
import Data.Process as Process exposing (Process)
import Dict.Any as Dict exposing (AnyDict)
import Json.Encode as Encode


type alias CountryProcess =
    { electricity : Process -- Electricité
    , heat : Process -- Chaleur
    , dyeingWeighting : Float -- Caractère majorant de la teinture (vs représentatif)
    }


type alias CountryProcesses =
    AnyDict String Country CountryProcess


get : Country -> Maybe CountryProcess
get country =
    Dict.get country countryProcesses


countries : CountryProcesses -> List Country
countries =
    Dict.keys


encodeAll : String
encodeAll =
    countryProcesses
        |> Dict.toList
        |> Encode.list
            (\( c, v ) ->
                Encode.object
                    [ ( "name", c |> Country.toString |> Encode.string )
                    , ( "electricity", v.electricity.uuid |> Process.uuidToString |> Encode.string )
                    , ( "heat", v.heat.uuid |> Process.uuidToString |> Encode.string )
                    , ( "dyeingWeighting", Encode.float v.dyeingWeighting )
                    ]
            )
        |> Encode.encode 0


countryProcesses : CountryProcesses
countryProcesses =
    -- Q: should we rather work with uuids? Process names have the advantage of readability…
    Dict.fromList Country.toString
        [ ( Bangladesh
          , { electricity = Process.findByName "Mix électrique réseau, BD"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
            , dyeingWeighting = 1
            }
          )
        , ( China
          , { electricity = Process.findByName "Mix électrique réseau, CN"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
            , dyeingWeighting = 1
            }
          )
        , ( France
          , { electricity = Process.findByName "Mix électrique réseau, FR"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), FR"
            , dyeingWeighting = 0
            }
          )
        , ( India
          , { electricity = Process.findByName "Mix électrique réseau, IN"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
            , dyeingWeighting = 1
            }
          )
        , ( Portugal
          , { electricity = Process.findByName "Mix électrique réseau, PT"
            , heat = Process.findByName "Vapeur à partir de gaz naturel (mix de technologies de combustion et d'épuration des effluents gazeux|en sortie de chaudière|Puissance non spécifiée), RER"
            , dyeingWeighting = 0
            }
          )
        , ( Spain
          , { electricity = Process.findByName "Mix électrique réseau, ES"
            , heat = Process.findByName "Vapeur à partir de gaz naturel (mix de technologies de combustion et d'épuration des effluents gazeux|en sortie de chaudière|Puissance non spécifiée), ES"
            , dyeingWeighting = 0
            }
          )
        , ( Tunisia
          , { electricity = Process.findByName "Mix électrique réseau, TN"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
            , dyeingWeighting = 1
            }
          )
        , ( Turkey
          , { electricity = Process.findByName "Mix électrique réseau, TR"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
            , dyeingWeighting = 1
            }
          )
        ]
