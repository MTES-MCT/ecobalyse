module Route exposing (Route(..), fromUrl, href, pushUrl, toString)

import Browser.Navigation as Nav
import Data.Inputs as Inputs exposing (Inputs)
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Home
    | Simulator (Maybe Inputs)
    | Editorial String
    | Examples
    | Stats


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map (Simulator Nothing) (Parser.s "simulator")
        , Parser.map (Simulator << Just) (Parser.s "simulator" </> parseInputs)
        , Parser.map Editorial (Parser.s "content" </> Parser.string)
        , Parser.map Examples (Parser.s "examples")
        , Parser.map Stats (Parser.s "stats")
        ]


parseInputs : Parser (Inputs -> a) a
parseInputs =
    Parser.string
        |> Parser.map
            (Inputs.b64decode
                >> Result.toMaybe
                >> Maybe.withDefault Inputs.defaults
            )


{-| Note: as elm-kitten relies on URL fragment based routing, the source URL is
updated so that the `fragment` part becomes the `path` one.
-}
fromUrl : Url -> Maybe Route
fromUrl url =
    let
        protocol =
            if url.protocol == Url.Https then
                "https"

            else
                "http"

        port_ =
            case url.port_ of
                Just p ->
                    ":" ++ String.fromInt p

                Nothing ->
                    ""

        path =
            Maybe.withDefault "/" url.fragment
    in
    Url.fromString (protocol ++ "://" ++ url.host ++ port_ ++ path)
        |> Maybe.withDefault url
        |> Parser.parse parser


href : Route -> Attribute msg
href route =
    Attr.href (toString route)


pushUrl : Nav.Key -> Route -> Cmd msg
pushUrl key route =
    Nav.pushUrl key (toString route)


toString : Route -> String
toString route =
    let
        pieces =
            case route of
                Home ->
                    []

                Simulator (Just inputs) ->
                    [ "simulator", Inputs.b64encode inputs ]

                Simulator Nothing ->
                    [ "simulator" ]

                Editorial slug ->
                    [ "content", slug ]

                Examples ->
                    [ "examples" ]

                Stats ->
                    [ "stats" ]
    in
    "#/" ++ String.join "/" pieces
