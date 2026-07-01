module Data.Food.Transport exposing
    ( countriesWithDefaultRoadTransport
    , defaultKilometersRoadDistance
    )

import Data.Country.Code as CountryCode


countriesWithDefaultRoadTransport : List CountryCode.Code
countriesWithDefaultRoadTransport =
    [ "RAF", "RAS", "RLA", "RME", "RNA", "ROC" ]
        |> List.map CountryCode.fromString


defaultKilometersRoadDistance : Float
defaultKilometersRoadDistance =
    2000
