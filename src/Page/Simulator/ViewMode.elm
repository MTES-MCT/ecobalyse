module Page.Simulator.ViewMode exposing
    ( ViewMode(..)
    , isActive
    , parse
    , toUrlSegment
    , toggle
    )

import Url.Parser as Parser exposing (Parser)


type ViewMode
    = Dataviz
    | DetailedAll
    | DetailedStep Int
    | Simple


isActive : ViewMode -> ViewMode -> Bool
isActive vm1 vm2 =
    case ( vm1, vm2 ) of
        ( Dataviz, Dataviz ) ->
            True

        ( DetailedAll, DetailedAll ) ->
            True

        ( DetailedStep _, DetailedStep _ ) ->
            True

        ( Simple, Simple ) ->
            True

        _ ->
            False


toggle : Int -> ViewMode -> ViewMode
toggle index viewMode =
    case viewMode of
        Dataviz ->
            Dataviz

        DetailedAll ->
            Simple

        DetailedStep current ->
            if index == current then
                Simple

            else
                DetailedStep index

        Simple ->
            DetailedStep index


parse : Parser (ViewMode -> a) a
parse =
    Parser.custom "VIEW_MODE" <|
        \string ->
            case string of
                "dataviz" ->
                    Just Dataviz

                "detailed" ->
                    Just DetailedAll

                _ ->
                    Just Simple


toUrlSegment : ViewMode -> String
toUrlSegment viewMode =
    case viewMode of
        Dataviz ->
            "dataviz"

        Simple ->
            "simple"

        _ ->
            "detailed"
