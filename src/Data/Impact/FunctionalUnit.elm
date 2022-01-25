module Data.Impact.FunctionalUnit exposing
    ( FunctionalUnit(..)
    , toString
    )

-- FIXME: move to Data.Unit?


type FunctionalUnit
    = PerDayOfWear
    | PerItem


toString : FunctionalUnit -> String
toString unit =
    case unit of
        PerDayOfWear ->
            "Jour porté"

        PerItem ->
            "Vêtement"
