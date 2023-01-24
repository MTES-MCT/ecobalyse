module Route exposing
    ( Route(..)
    , fromUrl
    , href
    , toString
    )

import Data.Dataset as Dataset exposing (Dataset)
import Data.Food.Builder.Query as FoodQuery
import Data.Impact as Impact
import Data.Scope as Scope
import Data.Textile.Inputs as TextileQuery
import Data.Unit as Unit
import Html exposing (Attribute)
import Html.Attributes as Attr
import Page.Textile.Simulator.ViewMode as ViewMode exposing (ViewMode)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Home
    | Api
    | Changelog
    | Editorial String
    | Explore Dataset
    | FoodBuilder Impact.Trigram (Maybe FoodQuery.Query)
    | FoodExplore
    | TextileExamples
    | TextileSimulator Impact.Trigram Unit.Functional ViewMode (Maybe TextileQuery.Query)
    | Stats


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ --
          -- Shared routes
          --
          Parser.map Home Parser.top
        , Parser.map Api (Parser.s "api")
        , Parser.map Changelog (Parser.s "changelog")
        , Parser.map Editorial (Parser.s "pages" </> Parser.string)
        , Parser.map Stats (Parser.s "stats")

        --  Explorer
        , Parser.map (Explore (Dataset.Impacts Nothing))
            (Parser.s "explore")
        , Parser.map Explore
            (Parser.s "explore" </> Dataset.parseSlug)
        , Parser.map toExploreWithId
            (Parser.s "explore" </> Dataset.parseSlug </> Parser.string)

        --
        -- Food specific routes
        --
        , Parser.map (FoodBuilder Impact.defaultFoodTrigram Nothing) (Parser.s "food" </> Parser.s "build")
        , Parser.map FoodBuilder
            (Parser.s "food"
                </> Parser.s "build"
                </> Impact.parseTrigram Scope.Food
                </> FoodQuery.parseBase64Query
            )
        , Parser.map FoodExplore (Parser.s "food")

        --
        -- Textile specific routes
        --
        , Parser.map TextileExamples (Parser.s "textile" </> Parser.s "examples")

        -- Textile Simulator
        , Parser.map (TextileSimulator Impact.defaultTextileTrigram Unit.PerItem ViewMode.Simple Nothing)
            (Parser.s "textile" </> Parser.s "simulator")
        , Parser.map TextileSimulator
            (Parser.s "textile"
                </> Parser.s "simulator"
                </> Impact.parseTrigram Scope.Textile
                </> Unit.parseFunctional
                </> ViewMode.parse
                </> TextileQuery.parseBase64Query
            )
        ]


toExploreWithId : Dataset -> String -> Route
toExploreWithId dataset idString =
    Explore (Dataset.slugWithId dataset idString)


{-| Note: as the app relies on URL fragment based routing, the source URL is
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

                Editorial slug ->
                    [ "pages", slug ]

                Explore (Dataset.Impacts Nothing) ->
                    [ "explore" ]

                Explore dataset ->
                    "explore" :: Dataset.toRoutePath dataset

                FoodBuilder (Impact.Trigram "ecs") Nothing ->
                    [ "food", "build" ]

                FoodBuilder trigram Nothing ->
                    [ "food", "build", Impact.toString trigram ]

                FoodBuilder trigram (Just query) ->
                    [ "food", "build", Impact.toString trigram, FoodQuery.b64encode query ]

                FoodExplore ->
                    [ "food" ]

                TextileExamples ->
                    [ "textile", "examples" ]

                TextileSimulator trigram funit viewMode (Just query) ->
                    [ "textile"
                    , "simulator"
                    , Impact.toString trigram
                    , Unit.functionalToSlug funit
                    , ViewMode.toUrlSegment viewMode
                    , TextileQuery.b64encode query
                    ]

                TextileSimulator (Impact.Trigram "pef") Unit.PerItem _ Nothing ->
                    [ "textile", "simulator" ]

                TextileSimulator trigram funit viewMode Nothing ->
                    [ "textile"
                    , "simulator"
                    , Impact.toString trigram
                    , Unit.functionalToSlug funit
                    , ViewMode.toUrlSegment viewMode
                    ]

                Stats ->
                    [ "stats" ]
    in
    "#/" ++ String.join "/" pieces
