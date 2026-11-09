module Route exposing
    ( Route(..)
    , fromUrl
    , href
    , toString
    )

import Data.Component as Component
import Data.Dataset as Dataset exposing (Dataset)
import Data.Example as Example
import Data.Food.Query as FoodQuery
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Sector as Sector exposing (Sector)
import Data.Textile.Query as TextileQuery
import Data.Uuid as Uuid exposing (Uuid)
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Api
    | Auth
    | AuthLogin String String
    | AuthSignup
    | Editorial String
    | Explore Sector Dataset
    | FoodBuilder Definition.Trigram (Maybe FoodQuery.Query)
    | FoodBuilderExample Uuid
    | FoodBuilderHome
    | GenericSimulator Sector.GenericSector Definition.Trigram (Maybe Component.Query)
    | GenericSimulatorExample Sector.GenericSector Uuid
    | GenericSimulatorHome Sector.GenericSector
    | Home
    | Stats
    | TextileSimulator Definition.Trigram (Maybe TextileQuery.Query)
    | TextileSimulatorExample Uuid
    | TextileSimulatorHome


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ --
          -- Shared routes
          --
          Parser.map Home Parser.top
        , Parser.map Api (Parser.s "api")
        , Parser.map Auth (Parser.s "auth")
        , Parser.map AuthLogin (Parser.s "auth" </> Parser.string </> Parser.string)
        , Parser.map AuthSignup (Parser.s "auth" </> Parser.s "signup")
        , Parser.map Editorial (Parser.s "pages" </> Parser.string)
        , Parser.map Stats (Parser.s "stats")

        --  Explorer
        , (Parser.s "explore" </> Sector.parse)
            |> Parser.map (\scope -> Explore scope (Dataset.defaultDatasetFor scope))
        , Parser.map Explore
            (Parser.s "explore" </> Sector.parse </> Dataset.parseSlug)

        -- Generic simulator routes
        , parseGenericSimulatorRoutes

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


parseGenericSimulatorRoutes : Parser (Route -> a) a
parseGenericSimulatorRoutes =
    Parser.oneOf
        [ Parser.map GenericSimulatorHome
            (scopeParser </> Parser.s "simulator")
        , Parser.map GenericSimulator <|
            scopeParser
                </> Parser.s "simulator"
                </> Impact.parseTrigram
                </> Component.parseBase64Query
        , Parser.map GenericSimulatorExample
            (scopeParser
                </> Parser.s "edit-example"
                </> Example.parseUuid
            )
        ]


scopeParser : Parser (Sector.GenericSector -> a) a
scopeParser =
    List.map
        (\scope ->
            scope
                |> Sector.toStringGeneric
                |> Parser.s
                |> Parser.map scope
        )
        Sector.allGeneric
        |> Parser.oneOf


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
                Api ->
                    [ "api" ]

                Auth ->
                    [ "auth" ]

                AuthLogin email token ->
                    [ "auth", email, token ]

                AuthSignup ->
                    [ "auth", "signup" ]

                Editorial slug ->
                    [ "pages", slug ]

                Explore Sector.Food (Dataset.FoodExamples Nothing) ->
                    [ "explore", "food" ]

                Explore Sector.Textile (Dataset.TextileExamples Nothing) ->
                    [ "explore", "textile" ]

                Explore scope dataset ->
                    "explore" :: Sector.toString scope :: Dataset.toRoutePath dataset

                FoodBuilder trigram Nothing ->
                    [ "food", Definition.toString trigram ]

                FoodBuilder trigram (Just query) ->
                    [ "food", Definition.toString trigram, FoodQuery.b64encode query ]

                FoodBuilderExample uuid ->
                    [ "food", "edit-example", Uuid.toString uuid ]

                FoodBuilderHome ->
                    [ "food" ]

                GenericSimulator genericScope trigram (Just query) ->
                    [ Sector.toString (Sector.Generic genericScope)
                    , "simulator"
                    , Definition.toString trigram
                    , Component.encodeBase64Query query
                    ]

                GenericSimulator genericScope trigram Nothing ->
                    [ Sector.toString (Sector.Generic genericScope)
                    , "simulator"
                    , Definition.toString trigram
                    ]

                GenericSimulatorExample genericScope uuid ->
                    [ Sector.toString (Sector.Generic genericScope)
                    , "edit-example"
                    , Uuid.toString uuid
                    ]

                GenericSimulatorHome genericScope ->
                    [ Sector.toString (Sector.Generic genericScope)
                    , "simulator"
                    ]

                Home ->
                    []

                Stats ->
                    [ "stats" ]

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

                TextileSimulatorHome ->
                    [ "textile", "simulator" ]
    in
    "#/" ++ String.join "/" pieces
