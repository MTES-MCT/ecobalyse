module Data.CountryProcess exposing (..)

import Data.Country as Country exposing (..)
import Data.Process as Process exposing (Process)
import Dict.Any as Dict exposing (AnyDict)


type alias CountryProcess =
    { electricity : Process -- Electricité
    , heat : Process -- Chaleur
    , dyeing : Process -- Teinture
    }


get : Country -> Maybe CountryProcess
get country =
    Dict.get country countryProcesses


countryProcesses : AnyDict String Country CountryProcess
countryProcesses =
    -- Q: should we rather work with uuids? Process names have the advantage of readability…
    Dict.fromList Country.toString
        [ ( China
          , { electricity = Process.findByName "Mix électrique réseau, CN"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
            , dyeing = Process.findByName "Teinture sur étoffe, procédé majorant, traitement inefficace des eaux usées"
            }
          )
        , ( France
          , { electricity = Process.findByName "Mix électrique réseau, FR"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), FR"
            , dyeing = Process.findByName "Teinture sur étoffe, procédé représentatif, traitement très efficace des eaux usées"
            }
          )
        , ( India
          , { electricity = Process.findByName "Mix électrique réseau, IN"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
            , dyeing = Process.findByName "Teinture sur étoffe, procédé majorant, traitement inefficace des eaux usées"
            }
          )
        , ( Spain
          , { electricity = Process.findByName "Mix électrique réseau, ES"
            , heat = Process.findByName "Vapeur à partir de gaz naturel (mix de technologies de combustion et d'épuration des effluents gazeux|en sortie de chaudière|Puissance non spécifiée), ES"
            , dyeing = Process.findByName "Teinture sur étoffe, procédé représentatif, traitement très efficace des eaux usées"
            }
          )
        , ( Tunisia
          , { electricity = Process.findByName "Mix électrique réseau, TN"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
            , dyeing = Process.findByName "Teinture sur étoffe, procédé majorant, traitement inefficace des eaux usées"
            }
          )
        , ( Turkey
          , { electricity = Process.findByName "Mix électrique réseau, TR"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
            , dyeing = Process.findByName "Teinture sur étoffe, procédé majorant, traitement inefficace des eaux usées"
            }
          )
        ]
