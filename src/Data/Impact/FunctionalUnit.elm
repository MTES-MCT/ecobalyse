module Data.Impact.FunctionalUnit exposing
    ( FunctionalUnit(..)
    , fromString
    , toString
    )


type FunctionalUnit
    = PerDayOfWear
    | PerItem


fromString : String -> FunctionalUnit
fromString string =
    case string of
        "Jour porté" ->
            PerDayOfWear

        _ ->
            PerItem


toString : FunctionalUnit -> String
toString unit =
    case unit of
        PerDayOfWear ->
            "Jour porté"

        PerItem ->
            "Vêtement"
