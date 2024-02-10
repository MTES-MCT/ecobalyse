module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Data.Food.Query as FoodQuery
import Data.Impact as Impact
import Data.Session as Session exposing (Session)
import Data.Textile.Inputs as TextileInputs
import Html
import Page.Api as Api
import Page.Changelog as Changelog
import Page.Editorial as Editorial
import Page.Explore as Explore
import Page.Food as FoodBuilder
import Page.Home as Home
import Page.Stats as Stats
import Page.Textile.Simulator as TextileSimulator
import Ports
import RemoteData exposing (WebData)
import Request.Version
import Route
import Static.Db exposing (Db, rcountries, rdefinitions, rdistances, rfood, rtextile)
import Url exposing (Url)
import Views.Page as Page


type alias Flags =
    { clientUrl : String
    , matomo : { host : String, siteId : String }
    , rawStore : String
    }


type Page
    = ApiPage Api.Model
    | LoadingPage
    | ChangelogPage Changelog.Model
    | EditorialPage Editorial.Model
    | ExplorePage Explore.Model
    | FoodBuilderPage FoodBuilder.Model
    | HomePage Home.Model
    | NotFoundPage
    | StatsPage Stats.Model
    | TextileSimulatorPage TextileSimulator.Model
    | BadData String


type alias Model =
    { db : Result String Db
    , page : Page
    , session : Session
    , mobileNavigationOpened : Bool

    -- Duplicate the nav key in the model so Parcel's hot module reloading finds it always in the same place.
    , navKey : Nav.Key
    }


type Msg
    = ApiMsg Api.Msg
    | ChangelogMsg Changelog.Msg
    | CloseMobileNavigation
    | CloseNotification Session.Notification
    | EditorialMsg Editorial.Msg
    | ExploreMsg Explore.Msg
    | FoodBuilderMsg FoodBuilder.Msg
    | HomeMsg Home.Msg
    | LoadUrl String
    | OpenMobileNavigation
    | ReloadPage
    | StatsMsg Stats.Msg
    | StoreChanged String
    | TextileSimulatorMsg TextileSimulator.Msg
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest
    | VersionPoll
    | VersionReceived (WebData String)


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        session =
            { clientUrl = flags.clientUrl
            , navKey = navKey
            , store = Session.deserializeStore flags.rawStore
            , currentVersion = Request.Version.Unknown
            , matomo = flags.matomo
            , notifications = []
            , queries =
                { food = FoodQuery.carrotCake
                , textile = TextileInputs.defaultQuery
                }
            }
    in
    setRoute url <|
        ( { db = Result.map5 Db rdefinitions rtextile rfood rcountries rdistances
          , page = LoadingPage
          , session = session
          , mobileNavigationOpened = False
          , navKey = navKey
          }
        , Cmd.batch
            [ Ports.appStarted ()
            , Request.Version.loadVersion VersionReceived
            ]
        )


setRoute : Url -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
setRoute url ( model, cmds ) =
    let
        -- TODO: factor this with `update` internal `toPage`
        toPage page subMsg ( subModel, newSession, subCmds ) =
            let
                storeCmd =
                    if model.session.store /= newSession.store then
                        newSession.store |> Session.serializeStore |> Ports.saveStore

                    else
                        Cmd.none
            in
            ( { model
                | session = newSession
                , page = page subModel
              }
            , Cmd.batch
                [ cmds
                , Cmd.map subMsg subCmds
                , storeCmd
                ]
            )
    in
    case model.db of
        Ok db ->
            Route.fromUrl url
                |> Maybe.map
                    (\route ->
                        case route of
                            Route.Home ->
                                Home.init model.session
                                    |> toPage HomePage HomeMsg

                            Route.Api ->
                                Api.init model.session
                                    |> toPage ApiPage ApiMsg

                            Route.Changelog ->
                                Changelog.init model.session
                                    |> toPage ChangelogPage ChangelogMsg

                            Route.Editorial slug ->
                                Editorial.init slug model.session
                                    |> toPage EditorialPage EditorialMsg

                            Route.Explore scope dataset ->
                                Explore.init scope dataset model.session
                                    |> toPage ExplorePage ExploreMsg

                            Route.FoodBuilderHome ->
                                FoodBuilder.init db model.session Impact.default Nothing
                                    |> toPage FoodBuilderPage FoodBuilderMsg

                            Route.FoodBuilder trigram maybeQuery ->
                                FoodBuilder.init db model.session trigram maybeQuery
                                    |> toPage FoodBuilderPage FoodBuilderMsg

                            Route.Stats ->
                                Stats.init model.session
                                    |> toPage StatsPage StatsMsg

                            Route.TextileSimulatorHome ->
                                TextileSimulator.init db Impact.default Nothing model.session
                                    |> toPage TextileSimulatorPage TextileSimulatorMsg

                            Route.TextileSimulator trigram maybeQuery ->
                                TextileSimulator.init db trigram maybeQuery model.session
                                    |> toPage TextileSimulatorPage TextileSimulatorMsg
                    )
                |> Maybe.withDefault
                    ( { model | page = NotFoundPage }, Cmd.none )

        Err error ->
            ( { model | page = BadData error }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.db of
        Ok db ->
            let
                -- TODO: factor this with `setRoute` internal `toPage`
                toPage toModel toMsg ( newModel, newSession, newCmd ) =
                    let
                        storeCmd =
                            if model.session.store /= newSession.store then
                                newSession.store |> Session.serializeStore |> Ports.saveStore

                            else
                                Cmd.none
                    in
                    ( { model | session = newSession, page = toModel newModel }
                    , Cmd.map toMsg (Cmd.batch [ newCmd, storeCmd ])
                    )

                session =
                    model.session
            in
            case ( msg, model.page ) of
                -- Pages
                ( HomeMsg homeMsg, HomePage homeModel ) ->
                    Home.update session homeMsg homeModel
                        |> toPage HomePage HomeMsg

                ( ApiMsg changelogMsg, ApiPage changelogModel ) ->
                    Api.update session changelogMsg changelogModel
                        |> toPage ApiPage ApiMsg

                ( ChangelogMsg changelogMsg, ChangelogPage changelogModel ) ->
                    Changelog.update session changelogMsg changelogModel
                        |> toPage ChangelogPage ChangelogMsg

                ( EditorialMsg editorialMsg, EditorialPage editorialModel ) ->
                    Editorial.update session editorialMsg editorialModel
                        |> toPage EditorialPage EditorialMsg

                ( ExploreMsg examplesMsg, ExplorePage examplesModel ) ->
                    Explore.update session examplesMsg examplesModel
                        |> toPage ExplorePage ExploreMsg

                -- Food
                ( FoodBuilderMsg foodMsg, FoodBuilderPage foodModel ) ->
                    FoodBuilder.update db session foodMsg foodModel
                        |> toPage FoodBuilderPage FoodBuilderMsg

                ( TextileSimulatorMsg counterMsg, TextileSimulatorPage counterModel ) ->
                    TextileSimulator.update db session counterMsg counterModel
                        |> toPage TextileSimulatorPage TextileSimulatorMsg

                -- Stats
                ( StatsMsg statsMsg, StatsPage statsModel ) ->
                    Stats.update session statsMsg statsModel
                        |> toPage StatsPage StatsMsg

                -- Notifications
                ( CloseNotification notification, currentPage ) ->
                    ( { model
                        | page = currentPage
                        , session = session |> Session.closeNotification notification
                      }
                    , Cmd.none
                    )

                -- Store
                ( StoreChanged json, currentPage ) ->
                    ( { model
                        | page = currentPage
                        , session = { session | store = Session.deserializeStore json }
                      }
                    , Cmd.none
                    )

                -- Mobile navigation menu
                ( CloseMobileNavigation, _ ) ->
                    ( { model | mobileNavigationOpened = False }, Cmd.none )

                ( OpenMobileNavigation, _ ) ->
                    ( { model | mobileNavigationOpened = True }, Cmd.none )

                -- Url
                ( LoadUrl url, _ ) ->
                    ( model, Nav.load url )

                ( ReloadPage, _ ) ->
                    ( model, Nav.reloadAndSkipCache )

                ( UrlChanged url, _ ) ->
                    ( { model | mobileNavigationOpened = False }, Cmd.none )
                        |> setRoute url

                ( UrlRequested (Browser.Internal url), _ ) ->
                    ( model, Nav.pushUrl model.session.navKey (Url.toString url) )

                ( UrlRequested (Browser.External href), _ ) ->
                    ( model, Nav.load href )

                -- Version check
                ( VersionReceived webData, currentPage ) ->
                    ( { model
                        | page = currentPage
                        , session = { session | currentVersion = Request.Version.updateVersion session.currentVersion webData }
                      }
                    , Cmd.none
                    )

                ( VersionPoll, _ ) ->
                    ( model, Request.Version.loadVersion VersionReceived )

                -- Catch-all
                ( _, NotFoundPage ) ->
                    ( { model | page = NotFoundPage }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Err error ->
            ( { model | page = BadData error }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.storeChanged StoreChanged
        , Request.Version.pollVersion VersionPoll
        , case model.page of
            HomePage subModel ->
                Home.subscriptions subModel
                    |> Sub.map HomeMsg

            ExplorePage subModel ->
                Explore.subscriptions subModel
                    |> Sub.map ExploreMsg

            FoodBuilderPage subModel ->
                FoodBuilder.subscriptions subModel
                    |> Sub.map FoodBuilderMsg

            TextileSimulatorPage subModel ->
                TextileSimulator.subscriptions subModel
                    |> Sub.map TextileSimulatorMsg

            _ ->
                Sub.none
        ]


view : Model -> Document Msg
view model =
    let
        pageConfig =
            Page.Config model.session
                model.mobileNavigationOpened
                CloseMobileNavigation
                OpenMobileNavigation
                LoadUrl
                ReloadPage
                CloseNotification

        mapMsg msg ( title, content ) =
            ( title, content |> List.map (Html.map msg) )
    in
    case model.db of
        Ok db ->
            case model.page of
                HomePage homeModel ->
                    Home.view model.session homeModel
                        |> mapMsg HomeMsg
                        |> Page.frame (pageConfig Page.Home)

                ApiPage examplesModel ->
                    Api.view model.session examplesModel
                        |> mapMsg ApiMsg
                        |> Page.frame (pageConfig Page.Api)

                ChangelogPage changelogModel ->
                    Changelog.view model.session changelogModel
                        |> mapMsg ChangelogMsg
                        |> Page.frame (pageConfig Page.Changelog)

                EditorialPage editorialModel ->
                    Editorial.view model.session editorialModel
                        |> mapMsg EditorialMsg
                        |> Page.frame (pageConfig (Page.Editorial editorialModel.slug))

                ExplorePage examplesModel ->
                    Explore.view db examplesModel
                        |> mapMsg ExploreMsg
                        |> Page.frame (pageConfig Page.Explore)

                FoodBuilderPage foodModel ->
                    FoodBuilder.view db model.session foodModel
                        |> mapMsg FoodBuilderMsg
                        |> Page.frame (pageConfig Page.FoodBuilder)

                TextileSimulatorPage simulatorModel ->
                    TextileSimulator.view db model.session simulatorModel
                        |> mapMsg TextileSimulatorMsg
                        |> Page.frame (pageConfig Page.TextileSimulator)

                StatsPage statsModel ->
                    Stats.view model.session statsModel
                        |> mapMsg StatsMsg
                        |> Page.frame (pageConfig Page.Stats)

                NotFoundPage ->
                    ( "Page manquante", [ Page.notFound ] )
                        |> Page.frame (pageConfig Page.Other)

                LoadingPage ->
                    ( "Chargement…", [ Page.loading ] )
                        |> Page.frame (pageConfig Page.Other)

                BadData error ->
                    { title = "Erreur lors du chargement…"
                    , body =
                        [ Html.p [] [ Html.text <| "Database couldn't be parsed: " ]
                        , Html.pre [] [ Html.text error ]
                        ]
                    }

        Err error ->
            { title = "Erreur lors du chargement…"
            , body =
                [ Html.p [] [ Html.text <| "Database couldn't be parsed: " ]
                , Html.pre [] [ Html.text error ]
                ]
            }


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }
