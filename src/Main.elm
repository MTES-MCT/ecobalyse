module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Data.Food.Builder.Db as FoodBuilderDb
import Data.Food.Builder.Query as FoodQuery
import Data.Food.Explorer.Db as ExplorerDb
import Data.Session as Session exposing (Session, UnloadedSession)
import Data.Textile.Db exposing (Db)
import Data.Textile.Inputs as TextileInputs
import Html
import Page.Api as Api
import Page.Changelog as Changelog
import Page.Editorial as Editorial
import Page.Explore as Explore
import Page.Food.Builder as FoodBuilder
import Page.Food.Explore as FoodExplore
import Page.Home as Home
import Page.Stats as Stats
import Page.Textile.Examples as TextileExamples
import Page.Textile.Simulator as TextileSimulator
import Ports
import RemoteData exposing (WebData)
import Request.Food.BuilderDb
import Request.Textile.Db
import Request.Version
import Route
import Url exposing (Url)
import Views.Page as Page


type alias Flags =
    { clientUrl : String
    , rawStore : String
    }


type Page
    = ApiPage Api.Model
    | BlankPage
    | ChangelogPage Changelog.Model
    | EditorialPage Editorial.Model
    | ExplorePage Explore.Model
    | FoodBuilderPage FoodBuilder.Model
    | FoodExplorePage FoodExplore.Model
    | HomePage Home.Model
    | NotFoundPage
    | StatsPage Stats.Model
    | TextileExamplesPage TextileExamples.Model
    | TextileSimulatorPage TextileSimulator.Model


type State
    = Loading UnloadedSession
    | Loaded Page Session
    | LoadingFailed UnloadedSession


type alias Model =
    { state : State
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
    | FoodExploreMsg FoodExplore.Msg
    | FoodBuilderDbReceived Url (WebData FoodBuilderDb.Db)
    | FoodBuilderMsg FoodBuilder.Msg
    | HomeMsg Home.Msg
    | LoadUrl String
    | OpenMobileNavigation
    | ReloadPage
    | StatsMsg Stats.Msg
    | StoreChanged String
    | TextileDbReceived Url (WebData Db)
    | TextileExamplesMsg TextileExamples.Msg
    | TextileSimulatorMsg TextileSimulator.Msg
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest
    | VersionPoll
    | VersionReceived (WebData String)


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        unloadedSession =
            { clientUrl = flags.clientUrl
            , navKey = navKey
            , store = Session.deserializeStore flags.rawStore
            , currentVersion = Request.Version.Unknown
            , builderDb = RemoteData.NotAsked
            , explorerDb = ExplorerDb.empty
            , notifications = []
            , queries =
                { food = FoodQuery.carrotCake
                , textile = TextileInputs.defaultQuery
                }
            }
    in
    ( { state = Loading unloadedSession
      , mobileNavigationOpened = False
      , navKey = navKey
      }
    , Cmd.batch
        [ Ports.appStarted ()
        , Request.Textile.Db.loadDb (TextileDbReceived url)
        , Request.Version.loadVersion VersionReceived
        ]
    )


setRoute : Url -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
setRoute url ( { state } as model, cmds ) =
    let
        maybeRoute =
            Route.fromUrl url
    in
    case state of
        Loaded _ session ->
            let
                -- TODO: factor this with `update` internal `toPage`
                toPage page subMsg ( subModel, newSession, subCmds ) =
                    let
                        storeCmd =
                            if session.store /= newSession.store then
                                newSession.store |> Session.serializeStore |> Ports.saveStore

                            else
                                Cmd.none
                    in
                    ( { model | state = Loaded (page subModel) newSession }
                    , Cmd.batch
                        [ cmds
                        , Cmd.map subMsg subCmds
                        , storeCmd
                        ]
                    )
            in
            case maybeRoute of
                Nothing ->
                    ( { model | state = Loaded NotFoundPage session }, Cmd.none )

                Just Route.Home ->
                    Home.init session
                        |> toPage HomePage HomeMsg

                Just Route.Api ->
                    Api.init session
                        |> toPage ApiPage ApiMsg

                Just Route.Changelog ->
                    Changelog.init session
                        |> toPage ChangelogPage ChangelogMsg

                Just (Route.Editorial slug) ->
                    Editorial.init slug session
                        |> toPage EditorialPage EditorialMsg

                Just (Route.Explore scope dataset) ->
                    case session.builderDb of
                        RemoteData.Success builderDb ->
                            Explore.init builderDb scope dataset session
                                |> toPage ExplorePage ExploreMsg

                        RemoteData.NotAsked ->
                            ( model
                            , Request.Food.BuilderDb.loadDb session (FoodBuilderDbReceived url)
                            )

                        _ ->
                            ( model, cmds )

                Just (Route.FoodBuilder trigram maybeQuery) ->
                    case session.builderDb of
                        RemoteData.Success builderDb ->
                            FoodBuilder.init builderDb session trigram maybeQuery
                                |> toPage FoodBuilderPage FoodBuilderMsg

                        RemoteData.NotAsked ->
                            ( model
                            , Request.Food.BuilderDb.loadDb session (FoodBuilderDbReceived url)
                            )

                        _ ->
                            ( model, cmds )

                Just Route.FoodExplore ->
                    FoodExplore.init session
                        |> toPage FoodExplorePage FoodExploreMsg

                Just Route.Stats ->
                    Stats.init session
                        |> toPage StatsPage StatsMsg

                Just Route.TextileExamples ->
                    TextileExamples.init session
                        |> toPage TextileExamplesPage TextileExamplesMsg

                Just (Route.TextileSimulator trigram funit detailed maybeQuery) ->
                    TextileSimulator.init trigram funit detailed maybeQuery session
                        |> toPage TextileSimulatorPage TextileSimulatorMsg

        _ ->
            ( model, cmds )


update : Msg -> Model -> ( Model, Cmd Msg )
update rawMsg ({ state } as model) =
    case ( state, rawMsg ) of
        ( Loading unloadedSession, TextileDbReceived url (RemoteData.Success db) ) ->
            -- Db successfully loaded, attach it to session and process to requested page.
            -- That way, the page will always access a fully loaded Db.
            let
                session =
                    Session.fromUnloaded unloadedSession db
            in
            setRoute url
                ( { model | state = Loaded BlankPage session }, Cmd.none )

        ( Loading unloadedSession, TextileDbReceived url (RemoteData.Failure httpError) ) ->
            setRoute url
                ( { model | state = LoadingFailed (unloadedSession |> Session.notifyHttpError httpError) }
                , Cmd.none
                )

        ( Loading _, _ ) ->
            ( model, Cmd.none )

        ( LoadingFailed _, _ ) ->
            ( model, Cmd.none )

        ( Loaded page session, msg ) ->
            let
                -- TODO: factor this with `setRoute` internal `toPage`
                toPage toModel toMsg ( newModel, newSession, newCmd ) =
                    let
                        storeCmd =
                            if session.store /= newSession.store then
                                newSession.store |> Session.serializeStore |> Ports.saveStore

                            else
                                Cmd.none
                    in
                    ( { model | state = Loaded (toModel newModel) newSession }
                    , Cmd.map toMsg (Cmd.batch [ newCmd, storeCmd ])
                    )
            in
            case ( msg, page ) of
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
                ( FoodBuilderDbReceived url builderDb, page_ ) ->
                    setRoute url
                        ( { model | state = Loaded page_ { session | builderDb = builderDb } }, Cmd.none )

                ( FoodBuilderMsg foodMsg, FoodBuilderPage foodModel ) ->
                    FoodBuilder.update session foodMsg foodModel
                        |> toPage FoodBuilderPage FoodBuilderMsg

                ( FoodExploreMsg foodMsg, FoodExplorePage foodModel ) ->
                    FoodExplore.update session foodMsg foodModel
                        |> toPage FoodExplorePage FoodExploreMsg

                ( TextileExamplesMsg examplesMsg, TextileExamplesPage examplesModel ) ->
                    TextileExamples.update session examplesMsg examplesModel
                        |> toPage TextileExamplesPage TextileExamplesMsg

                ( TextileSimulatorMsg counterMsg, TextileSimulatorPage counterModel ) ->
                    TextileSimulator.update session counterMsg counterModel
                        |> toPage TextileSimulatorPage TextileSimulatorMsg

                -- Stats
                ( StatsMsg statsMsg, StatsPage statsModel ) ->
                    Stats.update session statsMsg statsModel
                        |> toPage StatsPage StatsMsg

                -- Notifications
                ( CloseNotification notification, currentPage ) ->
                    ( { model | state = Loaded currentPage (session |> Session.closeNotification notification) }, Cmd.none )

                -- Store
                ( StoreChanged json, currentPage ) ->
                    ( { model | state = Loaded currentPage { session | store = Session.deserializeStore json } }, Cmd.none )

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
                    ( model, Nav.pushUrl session.navKey (Url.toString url) )

                ( UrlRequested (Browser.External href), _ ) ->
                    ( model, Nav.load href )

                -- Version check
                ( VersionReceived webData, currentPage ) ->
                    ( { model | state = Loaded currentPage { session | currentVersion = Request.Version.updateVersion session.currentVersion webData } }, Cmd.none )

                ( VersionPoll, _ ) ->
                    ( model, Request.Version.loadVersion VersionReceived )

                -- Catch-all
                ( _, NotFoundPage ) ->
                    ( { model | state = Loaded NotFoundPage session }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions { state } =
    Sub.batch
        [ Ports.storeChanged StoreChanged
        , Request.Version.pollVersion VersionPoll
        , case state of
            Loaded (HomePage subModel) _ ->
                Home.subscriptions subModel
                    |> Sub.map HomeMsg

            Loaded (ExplorePage subModel) _ ->
                Explore.subscriptions subModel
                    |> Sub.map ExploreMsg

            Loaded (FoodBuilderPage subModel) _ ->
                FoodBuilder.subscriptions subModel
                    |> Sub.map FoodBuilderMsg

            Loaded (TextileSimulatorPage subModel) _ ->
                TextileSimulator.subscriptions subModel
                    |> Sub.map TextileSimulatorMsg

            _ ->
                Sub.none
        ]


view : Model -> Document Msg
view { state, mobileNavigationOpened } =
    case state of
        Loaded page session ->
            let
                pageConfig =
                    Page.Config session
                        mobileNavigationOpened
                        CloseMobileNavigation
                        OpenMobileNavigation
                        LoadUrl
                        ReloadPage
                        CloseNotification

                mapMsg msg ( title, content ) =
                    ( title, content |> List.map (Html.map msg) )
            in
            case page of
                HomePage homeModel ->
                    Home.view session homeModel
                        |> mapMsg HomeMsg
                        |> Page.frame (pageConfig Page.Home)

                ApiPage examplesModel ->
                    Api.view session examplesModel
                        |> mapMsg ApiMsg
                        |> Page.frame (pageConfig Page.Api)

                ChangelogPage changelogModel ->
                    Changelog.view session changelogModel
                        |> mapMsg ChangelogMsg
                        |> Page.frame (pageConfig Page.Changelog)

                EditorialPage editorialModel ->
                    Editorial.view session editorialModel
                        |> mapMsg EditorialMsg
                        |> Page.frame (pageConfig (Page.Editorial editorialModel.slug))

                ExplorePage examplesModel ->
                    Explore.view session examplesModel
                        |> mapMsg ExploreMsg
                        |> Page.frame (pageConfig Page.Explore)

                FoodBuilderPage foodModel ->
                    FoodBuilder.view session foodModel
                        |> mapMsg FoodBuilderMsg
                        |> Page.frame (pageConfig Page.FoodBuilder)

                FoodExplorePage foodModel ->
                    FoodExplore.view session foodModel
                        |> mapMsg FoodExploreMsg
                        |> Page.frame (pageConfig Page.FoodExplore)

                TextileExamplesPage examplesModel ->
                    TextileExamples.view session examplesModel
                        |> mapMsg TextileExamplesMsg
                        |> Page.frame (pageConfig Page.TextileExamples)

                TextileSimulatorPage simulatorModel ->
                    TextileSimulator.view session simulatorModel
                        |> mapMsg TextileSimulatorMsg
                        |> Page.frame (pageConfig Page.TextileSimulator)

                StatsPage statsModel ->
                    Stats.view session statsModel
                        |> mapMsg StatsMsg
                        |> Page.frame (pageConfig Page.Stats)

                NotFoundPage ->
                    ( "Page manquante", [ Page.notFound ] )
                        |> Page.frame (pageConfig Page.Other)

                BlankPage ->
                    ( "Chargement…", [ Page.loading ] )
                        |> Page.frame (pageConfig Page.Other)

        Loading unloadedSession ->
            let
                pageConfig =
                    Page.Config unloadedSession
                        mobileNavigationOpened
                        CloseMobileNavigation
                        OpenMobileNavigation
                        LoadUrl
                        ReloadPage
                        CloseNotification
            in
            ( "Chargement…", [ Page.loading ] )
                |> Page.frame (pageConfig Page.Other)

        LoadingFailed unloadedSession ->
            let
                pageConfig =
                    Page.Config unloadedSession
                        mobileNavigationOpened
                        CloseMobileNavigation
                        OpenMobileNavigation
                        LoadUrl
                        ReloadPage
                        CloseNotification
            in
            ( "Erreur lors du chargement…", [ Page.notFound ] )
                |> Page.frame (pageConfig Page.Other)


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
