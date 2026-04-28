module Data.Food.Transport exposing (countriesWithDefaultRoadTransport, defaultKilometersRoadDistance)

import Data.Country as Country


countriesWithDefaultRoadTransport : List Country.Code
countriesWithDefaultRoadTransport =
    [ "RAF", "RAS", "RLA", "RME", "RNA", "ROC" ] |> List.map Country.codeFromString


defaultKilometersRoadDistance : Float
defaultKilometersRoadDistance =
    2000
