module Route exposing
    ( Route(..)
    , fromUrl
    , href
    , toString
    )

import Data.Dataset as Dataset exposing (Dataset)
import Data.Food.Builder.Query as FoodQuery
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Scope as Scope exposing (Scope)
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
    | Explore Scope Dataset
    | FoodBuilder Definition.Trigram (Maybe FoodQuery.Query)
    | FoodExplore
    | TextileExamples
    | TextileSimulator Definition.Trigram Unit.Functional ViewMode (Maybe TextileQuery.Query)
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
        , Parser.map (\scope -> Explore scope (Dataset.Impacts Nothing))
            (Parser.s "explore" </> Scope.parseSlug)
        , Parser.map Explore
            (Parser.s "explore" </> Scope.parseSlug </> Dataset.parseSlug)
        , Parser.map toExploreWithId
            (Parser.s "explore" </> Scope.parseSlug </> Dataset.parseSlug </> Parser.string)

        --
        -- Food specific routes
        --
        , Parser.map (FoodBuilder Definition.Ecs Nothing) (Parser.s "food" </> Parser.s "build")
        , Parser.map FoodBuilder
            (Parser.s "food"
                </> Parser.s "build"
                </> Impact.parseTrigram
                </> FoodQuery.parseBase64Query
            )
        , Parser.map FoodExplore (Parser.s "food")

        --
        -- Textile specific routes
        --
        , Parser.map TextileExamples (Parser.s "textile" </> Parser.s "examples")

        -- Textile Simulator
        , Parser.map (TextileSimulator Definition.Ecs Unit.PerItem ViewMode.Simple Nothing)
            (Parser.s "textile" </> Parser.s "simulator")
        , Parser.map TextileSimulator
            (Parser.s "textile"
                </> Parser.s "simulator"
                </> Impact.parseTrigram
                </> Unit.parseFunctional
                </> ViewMode.parse
                </> TextileQuery.parseBase64Query
            )
        ]


toExploreWithId : Scope -> Dataset -> String -> Route
toExploreWithId scope dataset idString =
    dataset
        |> Dataset.setIdFromString
            (idString
                |> Url.percentDecode
                |> Maybe.withDefault idString
            )
        |> Explore scope


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

                Explore Scope.Food (Dataset.Impacts Nothing) ->
                    [ "explore", "food" ]

                Explore scope dataset ->
                    "explore" :: Scope.toString scope :: Dataset.toRoutePath dataset

                FoodBuilder Definition.Ecs Nothing ->
                    [ "food", "build" ]

                FoodBuilder trigram Nothing ->
                    [ "food", "build", Definition.toString trigram ]

                FoodBuilder trigram (Just query) ->
                    [ "food", "build", Definition.toString trigram, FoodQuery.b64encode query ]

                FoodExplore ->
                    [ "food" ]

                TextileExamples ->
                    [ "textile", "examples" ]

                TextileSimulator trigram funit viewMode (Just query) ->
                    [ "textile"
                    , "simulator"
                    , Definition.toString trigram
                    , Unit.functionalToSlug funit
                    , ViewMode.toUrlSegment viewMode
                    , TextileQuery.b64encode query
                    ]

                TextileSimulator Definition.Pef Unit.PerItem _ Nothing ->
                    [ "textile", "simulator" ]

                TextileSimulator trigram funit viewMode Nothing ->
                    [ "textile"
                    , "simulator"
                    , Definition.toString trigram
                    , Unit.functionalToSlug funit
                    , ViewMode.toUrlSegment viewMode
                    ]

                Stats ->
                    [ "stats" ]
    in
    "#/" ++ String.join "/" pieces
