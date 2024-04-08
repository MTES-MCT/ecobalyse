module Route exposing
    ( Route(..)
    , fromUrl
    , href
    , toString
    )

import Data.Dataset as Dataset exposing (Dataset)
import Data.Example as Example
import Data.Food.Query as FoodQuery
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Scope as Scope exposing (Scope)
import Data.Textile.Query as TextileQuery
import Data.Uuid as Uuid exposing (Uuid)
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Home
    | Api
    | Auth { loggedIn : Bool }
    | Changelog
    | Editorial String
    | Explore Scope Dataset
    | FoodBuilder Definition.Trigram (Maybe FoodQuery.Query)
    | FoodBuilderHome
    | FoodBuilderExample Uuid
    | TextileSimulatorHome
    | TextileSimulator Definition.Trigram (Maybe TextileQuery.Query)
    | TextileSimulatorExample Uuid
    | Stats


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ --
          -- Shared routes
          --
          Parser.map Home Parser.top
        , Parser.map Api (Parser.s "api")
        , Parser.map (Auth { loggedIn = True }) (Parser.s "auth" </> Parser.s "loggedIn")
        , Parser.map (Auth { loggedIn = False }) (Parser.s "auth")
        , Parser.map Changelog (Parser.s "changelog")
        , Parser.map Editorial (Parser.s "pages" </> Parser.string)
        , Parser.map Stats (Parser.s "stats")

        --  Explorer
        , (Parser.s "explore" </> Scope.parse)
            |> Parser.map
                (\scope ->
                    Explore scope
                        (case scope of
                            Scope.Food ->
                                Dataset.FoodExamples Nothing

                            Scope.Textile ->
                                Dataset.TextileExamples Nothing
                        )
                )
        , Parser.map Explore
            (Parser.s "explore" </> Scope.parse </> Dataset.parseSlug)
        , Parser.map toExploreWithId
            (Parser.s "explore" </> Scope.parse </> Dataset.parseSlug </> Parser.string)

        --
        -- Food specific routes
        --
        , Parser.map FoodBuilderHome (Parser.s "food")
        , Parser.map FoodBuilder
            (Parser.s "food"
                </> Impact.parseTrigram
                </> FoodQuery.parseBase64Query
            )
        , Parser.map FoodBuilderExample
            (Parser.s "food"
                </> Parser.s "edit-example"
                </> Example.parseUuid
            )

        -- Textile specific routes
        , Parser.map TextileSimulatorHome
            (Parser.s "textile" </> Parser.s "simulator")
        , parseTextileSimulator
        , Parser.map TextileSimulatorExample
            (Parser.s "textile"
                </> Parser.s "edit-example"
                </> Example.parseUuid
            )
        ]


parseTextileSimulator : Parser (Route -> a) a
parseTextileSimulator =
    Parser.oneOf
        [ deprecatedTextileRouteParser
        , Parser.map TextileSimulator <|
            Parser.s "textile"
                </> Parser.s "simulator"
                </> Impact.parseTrigram
                </> TextileQuery.parseBase64Query
        ]


deprecatedTextileRouteParser : Parser (Route -> a) a
deprecatedTextileRouteParser =
    -- We keep this parser for backwards compatible reasons: we used to have the choice
    -- for a view mode between `simple` and `detailed`, but now it's only `simple`,
    -- and we used to have a functional unit parameter
    Parser.map (\trigram _ _ query -> TextileSimulator trigram query) <|
        Parser.s "textile"
            </> Parser.s "simulator"
            </> Impact.parseTrigram
            -- This is the unused "functional unit" parameter
            </> Parser.string
            -- This is the unused "viewmode" parameter
            </> Parser.string
            </> TextileQuery.parseBase64Query


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

                Auth { loggedIn } ->
                    [ "auth"
                    , if loggedIn then
                        "loggedIn"

                      else
                        ""
                    ]

                Changelog ->
                    [ "changelog" ]

                Editorial slug ->
                    [ "pages", slug ]

                Explore Scope.Food (Dataset.FoodExamples Nothing) ->
                    [ "explore", "food" ]

                Explore Scope.Textile (Dataset.TextileExamples Nothing) ->
                    [ "explore", "textile" ]

                Explore scope dataset ->
                    "explore" :: Scope.toString scope :: Dataset.toRoutePath dataset

                FoodBuilderHome ->
                    [ "food", "build" ]

                FoodBuilder trigram Nothing ->
                    [ "food", "build", Definition.toString trigram ]

                FoodBuilder trigram (Just query) ->
                    [ "food", "build", Definition.toString trigram, FoodQuery.b64encode query ]

                FoodBuilderExample uuid ->
                    [ "food", "edit-example", Uuid.toString uuid ]

                TextileSimulatorHome ->
                    [ "textile", "simulator" ]

                TextileSimulator trigram (Just query) ->
                    [ "textile"
                    , "simulator"
                    , Definition.toString trigram
                    , TextileQuery.b64encode query
                    ]

                TextileSimulator trigram Nothing ->
                    [ "textile"
                    , "simulator"
                    , Definition.toString trigram
                    ]

                TextileSimulatorExample uuid ->
                    [ "textile", "edit-example", Uuid.toString uuid ]

                Stats ->
                    [ "stats" ]
    in
    "#/" ++ String.join "/" pieces
