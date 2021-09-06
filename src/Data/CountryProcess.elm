module Data.CountryProcess exposing (..)

import Data.Country as Country exposing (..)
import Data.Process as Process exposing (Process)
import Dict.Any as Dict exposing (AnyDict)


type alias CountryProcesses =
    { averageMix : Process -- Electricité
    , heat : Process -- Chaleur
    , dyeing : Process -- Teinture
    , airTransport : Process -- Transport aérien
    , seaTransport : Process -- Transport maritime
    , roadTransportPreMaking : Process -- Transport routier avant confection
    , roadTransportPostMaking : Process -- Transport routier post confection
    , distribution : Process -- Distribution
    }


get : Country -> Maybe CountryProcesses
get country =
    Dict.get country countryProcesses


countryProcesses : AnyDict String Country CountryProcesses
countryProcesses =
    -- Q: should we rather work with uuids? Process names have the advantage of readability…
    Dict.fromList Country.toString
        [ ( China
          , { averageMix = Process.findByName "Mix électrique réseau, CN"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
            , dyeing = Process.findByName "Teinture sur étoffe, procédé majorant, traitement inefficace des eaux usées"
            , airTransport = Process.findByName "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO"
            , seaTransport = Process.findByName "Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO"
            , roadTransportPreMaking = Process.findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], GLO"
            , roadTransportPostMaking = Process.findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], RER"
            , distribution = Process.findByName "Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) [tkm], FR"
            }
          )
        , ( France
          , { averageMix = Process.findByName "Mix électrique réseau, FR"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), FR"
            , dyeing = Process.findByName "Teinture sur étoffe, procédé représentatif, traitement très efficace des eaux usées"
            , airTransport = Process.findByName "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO"
            , seaTransport = Process.findByName "Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO"
            , roadTransportPreMaking = Process.findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], GLO"
            , roadTransportPostMaking = Process.findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], RER"
            , distribution = Process.findByName "Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) [tkm], FR"
            }
          )
        , ( India
          , { averageMix = Process.findByName "Mix électrique réseau, IN"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
            , dyeing = Process.findByName "Teinture sur étoffe, procédé majorant, traitement inefficace des eaux usées"
            , airTransport = Process.findByName "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO"
            , seaTransport = Process.findByName "Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO"
            , roadTransportPreMaking = Process.findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], GLO"
            , roadTransportPostMaking = Process.findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], RER"
            , distribution = Process.findByName "Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) [tkm], FR"
            }
          )
        , ( Spain
          , { averageMix = Process.findByName "Mix électrique réseau, ES"
            , heat = Process.findByName "Vapeur à partir de gaz naturel (mix de technologies de combustion et d'épuration des effluents gazeux|en sortie de chaudière|Puissance non spécifiée), ES"
            , dyeing = Process.findByName "Teinture sur étoffe, procédé représentatif, traitement très efficace des eaux usées"
            , airTransport = Process.findByName "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO"
            , seaTransport = Process.findByName "Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO"
            , roadTransportPreMaking = Process.findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], GLO"
            , roadTransportPostMaking = Process.findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], RER"
            , distribution = Process.findByName "Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) [tkm], FR"
            }
          )
        , ( Tunisia
          , { averageMix = Process.findByName "Mix électrique réseau, TN"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
            , dyeing = Process.findByName "Teinture sur étoffe, procédé majorant, traitement inefficace des eaux usées"
            , airTransport = Process.findByName "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO"
            , seaTransport = Process.findByName "Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO"
            , roadTransportPreMaking = Process.findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], GLO"
            , roadTransportPostMaking = Process.findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], RER"
            , distribution = Process.findByName "Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) [tkm], FR"
            }
          )
        , ( Turkey
          , { averageMix = Process.findByName "Mix électrique réseau, TR"
            , heat = Process.findByName "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA"
            , dyeing = Process.findByName "Teinture sur étoffe, procédé majorant, traitement inefficace des eaux usées"
            , airTransport = Process.findByName "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO"
            , seaTransport = Process.findByName "Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO"
            , roadTransportPreMaking = Process.findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], GLO"
            , roadTransportPostMaking = Process.findByName "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], RER"
            , distribution = Process.findByName "Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) [tkm], FR"
            }
          )
        ]
