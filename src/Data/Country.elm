module Data.Country exposing
    ( Country(..)
    , choices
    , decode
    , encode
    , fromString
    , getDistance
    , toString
    , transportData
    )

import Dict exposing (Dict)
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


toComparableDict : List ( Country, a ) -> Dict String a
toComparableDict =
    List.map (Tuple.mapFirst toString) >> Dict.fromList


transportData : Dict String (Dict String Int)
transportData =
    toComparableDict
        [ ( China, toComparableDict [ ( China, 0 ), ( France, 21548 ) ] )
        , ( France, toComparableDict [ ( France, 0 ), ( China, 21548 ) ] )
        ]


getDistance : Country -> Country -> Int
getDistance cA cB =
    transportData
        |> Dict.get (toString cA)
        |> Maybe.andThen (Dict.get (toString cB))
        |> Maybe.withDefault 0


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
