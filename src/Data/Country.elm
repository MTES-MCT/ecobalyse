module Data.Country exposing (Country(..), choices, decode, encode, fromString, toString)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Country
    = China
    | France
    | Germany
    | Greece
    | India
    | Italy
    | Morocco
    | Spain
    | Tunisia
    | Turkey
    | UnitedStates
    | Vietnam


choices : List Country
choices =
    List.sortBy toString
        [ China
        , France
        , Germany
        , Greece
        , India
        , Italy
        , Morocco
        , Spain
        , Tunisia
        , Turkey
        , UnitedStates
        , Vietnam
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
        "Chine" ->
            China

        "France" ->
            France

        "Allemagne" ->
            Germany

        "Grèce" ->
            Greece

        "Inde" ->
            India

        "Italie" ->
            Italy

        "Maroc" ->
            Morocco

        "Espagne" ->
            Spain

        "Tunisie" ->
            Tunisia

        "Turquie" ->
            Turkey

        "États-Unis" ->
            UnitedStates

        "Vietnam" ->
            Vietnam

        _ ->
            France


toString : Country -> String
toString country =
    case country of
        China ->
            "Chine"

        France ->
            "France"

        Germany ->
            "Allemagne"

        Greece ->
            "Grèce"

        India ->
            "Inde"

        Italy ->
            "Italie"

        Morocco ->
            "Maroc"

        Spain ->
            "Espagne"

        Tunisia ->
            "Tunisie"

        Turkey ->
            "Turquie"

        UnitedStates ->
            "États-Unis"

        Vietnam ->
            "Vietnam"
