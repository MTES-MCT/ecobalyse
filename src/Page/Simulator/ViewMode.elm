module Page.Simulator.ViewMode exposing
    ( ViewMode(..)
    , parse
    , toUrlSegment
    , toggle
    )

import Url.Parser as Parser exposing (Parser)


type ViewMode
    = Simple
    | DetailedAll
    | DetailedStep Int


toggle : Int -> ViewMode -> ViewMode
toggle index viewMode =
    case viewMode of
        Simple ->
            DetailedStep index

        DetailedAll ->
            Simple

        DetailedStep current ->
            if index == current then
                Simple

            else
                DetailedStep index


parse : Parser (ViewMode -> a) a
parse =
    Parser.custom "VIEW_MODE" <|
        \string ->
            if string == "detailed" then
                Just DetailedAll

            else
                Just Simple


toUrlSegment : ViewMode -> String
toUrlSegment viewMode =
    case viewMode of
        Simple ->
            "simple"

        _ ->
            "detailed"
