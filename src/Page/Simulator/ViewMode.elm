module Page.Simulator.ViewMode exposing
    ( ViewMode(..)
    , isDetailed
    , parse
    , toUrlSegment
    , toggle
    )

import Url.Parser as Parser exposing (Parser)


type ViewMode
    = Simple
    | DetailedAll
    | DetailedStep Int


isDetailed : ViewMode -> Bool
isDetailed viewMode =
    case viewMode of
        Simple ->
            False

        DetailedAll ->
            True

        DetailedStep _ ->
            -- Even if a step is opened in detailed mode, we consider
            -- the general view mode "simple".
            False


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
