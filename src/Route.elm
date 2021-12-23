module Route exposing (Route(..), fromUrl, href, pushUrl, toString)

import Browser.Navigation as Nav
import Data.Inputs as Inputs
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Home
    | Changelog
    | Editorial String
    | Examples
    | Simulator (Maybe Inputs.Query)
    | Stats


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Changelog (Parser.s "changelog")
        , Parser.map Editorial (Parser.s "content" </> Parser.string)
        , Parser.map Examples (Parser.s "examples")
        , Parser.map (Simulator Nothing) (Parser.s "simulator")
        , Parser.map (Simulator << Just) (Parser.s "simulator" </> parseInputsQuery)
        , Parser.map Stats (Parser.s "stats")
        ]


parseInputsQuery : Parser (Inputs.Query -> a) a
parseInputsQuery =
    Parser.string
        |> Parser.map
            (Inputs.b64decode
                >> Result.toMaybe
                >> Maybe.withDefault Inputs.defaultQuery
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

                Changelog ->
                    [ "changelog" ]

                Editorial slug ->
                    [ "content", slug ]

                Examples ->
                    [ "examples" ]

                Simulator (Just inputs) ->
                    [ "simulator", Inputs.b64encode inputs ]

                Simulator Nothing ->
                    [ "simulator" ]

                Stats ->
                    [ "stats" ]
    in
    "#/" ++ String.join "/" pieces
