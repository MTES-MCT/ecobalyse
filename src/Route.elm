module Route exposing (Route(..), fromUrl, href, pushUrl, toString)

import Browser.Navigation as Nav
import Data.Db as Db
import Data.Impact as Impact
import Data.Inputs as Inputs
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Home
    | Api
    | Changelog
    | Explore Db.Dataset
    | Examples
    | Simulator Impact.Trigram (Maybe Inputs.Query)
    | Stats


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Api (Parser.s "api")
        , Parser.map Changelog (Parser.s "changelog")
        , Parser.map Examples (Parser.s "examples")
        , Parser.map (Explore (Db.Countries Nothing)) (Parser.s "explore")
        , Parser.map Explore (Parser.s "explore" </> Db.parseDatasetSlug)
        , Parser.map toExploreWithId (Parser.s "explore" </> Db.parseDatasetSlug </> Parser.string)
        , Parser.map (Simulator Impact.defaultTrigram Nothing) (Parser.s "simulator")
        , Parser.map Simulator (Parser.s "simulator" </> Impact.parseTrigram </> Inputs.parseBase64Query)
        , Parser.map Stats (Parser.s "stats")
        ]


toExploreWithId : Db.Dataset -> String -> Route
toExploreWithId dataset idString =
    Explore (Db.parseDatasetSlugWithId dataset idString)


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

                Api ->
                    [ "api" ]

                Changelog ->
                    [ "changelog" ]

                Examples ->
                    [ "examples" ]

                Explore (Db.Countries Nothing) ->
                    [ "explore" ]

                Explore dataset ->
                    [ "explore", dataset |> Db.datasetStrings |> .slug ]

                Simulator trigram (Just inputs) ->
                    [ "simulator", Impact.toString trigram, Inputs.b64encode inputs ]

                Simulator (Impact.Trigram "cch") Nothing ->
                    [ "simulator" ]

                Simulator trigram Nothing ->
                    [ "simulator", Impact.toString trigram ]

                Stats ->
                    [ "stats" ]
    in
    "#/" ++ String.join "/" pieces
