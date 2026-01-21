module Main exposing (main)

import App exposing (PageUpdate)
import Browser exposing (Document)
import Browser.Navigation as Nav
import Data.Component as Component
import Data.Component.Config as ComponentConfig
import Data.Example as Example
import Data.Food.Query as FoodQuery
import Data.Github as Github
import Data.Impact as Impact
import Data.Notification as Notification exposing (Notification)
import Data.Plausible as Plausible
import Data.Session as Session exposing (Session)
import Data.Textile.Query as TextileQuery
import Html
import Page.Admin.Account as AccountAdmin
import Page.Admin.Component as ComponentAdmin
import Page.Admin.Process as ProcessAdmin
import Page.Admin.Section as AdminSection
import Page.Api as Api
import Page.Auth as Auth
import Page.Editorial as Editorial
import Page.Explore as Explore
import Page.Food as FoodBuilder
import Page.Home as Home
import Page.Object as ObjectSimulator
import Page.Stats as Stats
import Page.Textile as TextileSimulator
import Ports
import RemoteData exposing (WebData)
import RemoteData.Http as Http
import Request.Auth
import Request.BackendHttp as BackendHttp
import Request.Github
import Request.Version exposing (VersionData)
import Route
import Static.Db as StaticDb exposing (Db)
import Static.Json as StaticJson
import Toast
import Url exposing (Url)
import Views.Page as Page


type alias Flags =
    { clientUrl : String
    , enabledSections : Session.EnabledSections
    , matomo : { host : String, siteId : String }
    , rawStore : String
    , scalingoAppName : Maybe String
    , versionPollSeconds : Int
    }


type Page
    = AccountAdminPage AccountAdmin.Model
    | ApiPage Api.Model
    | AuthPage Auth.Model
    | ComponentAdminPage ComponentAdmin.Model
    | EditorialPage Editorial.Model
    | ExplorePage Explore.Model
    | FoodBuilderPage FoodBuilder.Model
    | HomePage Home.Model
    | LoadingPage
    | NotFoundPage
    | ObjectSimulatorPage ObjectSimulator.Model
    | ProcessAdminPage ProcessAdmin.Model
    | RestrictedAccessPage
    | StatsPage Stats.Model
    | TextileSimulatorPage TextileSimulator.Model


type State
    = Errored String
    | Loaded Session Page


type alias Model =
    { mobileNavigationOpened : Bool

    -- Duplicate the nav key in the model so Parcel's hot module reloading finds it always in the same place.
    , navKey : Nav.Key
    , state : State
    , tray : Toast.Tray Notification
    , url : Url
    }


type Msg
    = AccountAdminMsg AccountAdmin.Msg
    | ApiMsg Api.Msg
    | AppMsg App.Msg
    | AuthMsg Auth.Msg
    | ComponentAdminMsg ComponentAdmin.Msg
    | ComponentConfigReceived Url (WebData Component.Config)
    | DetailedProcessesReceived Url (BackendHttp.WebData String)
    | EditorialMsg Editorial.Msg
    | ExploreMsg Explore.Msg
    | FoodBuilderMsg FoodBuilder.Msg
    | HomeMsg Home.Msg
    | ObjectSimulatorMsg ObjectSimulator.Msg
    | ProcessAdminMsg ProcessAdmin.Msg
    | ReleasesReceived (WebData (List Github.Release))
    | StatsMsg Stats.Msg
    | StoreChanged String
    | TextileSimulatorMsg TextileSimulator.Msg
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest
    | VersionPoll
    | VersionReceived (WebData VersionData)


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags requestedUrl navKey =
    setRoute requestedUrl
        (case
            StaticDb.db StaticJson.processesJson
                |> Result.andThen
                    (\db ->
                        Component.defaultConfig db
                            |> Result.map (Tuple.pair db)
                    )
         of
            Err err ->
                ( { mobileNavigationOpened = False
                  , navKey = navKey
                  , state = Errored err
                  , tray = Toast.tray
                  , url = requestedUrl
                  }
                , Cmd.none
                )

            Ok ( db, componentConfig ) ->
                let
                    session =
                        setupSession navKey flags db componentConfig
                in
                ( { mobileNavigationOpened = False
                  , navKey = navKey
                  , state = Loaded session LoadingPage
                  , tray = Toast.tray
                  , url = requestedUrl
                  }
                , Cmd.batch
                    [ Ports.appStarted ()
                    , Request.Version.loadVersion VersionReceived
                    , Request.Github.getReleases ReleasesReceived
                    , if Session.isAuthenticated session then
                        Request.Auth.processes session (DetailedProcessesReceived requestedUrl)

                      else
                        ComponentConfig.decode db
                            |> Http.get "/data/components/config.json" (ComponentConfigReceived requestedUrl)
                    , Plausible.send session <| Plausible.PageViewed requestedUrl
                    ]
                )
        )


setupSession : Nav.Key -> Flags -> Db -> Component.Config -> Session
setupSession navKey flags db componentConfig =
    Session.decodeRawStore flags.rawStore
        { clientUrl = flags.clientUrl
        , componentConfig = componentConfig
        , currentVersion = Request.Version.Unknown
        , db = db
        , enabledSections = flags.enabledSections
        , matomo = flags.matomo
        , navKey = navKey
        , notifications = []
        , queries =
            { food = FoodQuery.empty
            , object = Component.emptyQuery
            , textile =
                db.textile.examples
                    |> Example.findByName "Tshirt coton (150g) - Majorant par défaut"
                    |> Result.map .query
                    |> Result.withDefault TextileQuery.default
            , veli = Component.emptyQuery
            }
        , releases = RemoteData.NotAsked
        , scalingoAppName = flags.scalingoAppName
        , store = Session.defaultStore
        , versionPollSeconds = flags.versionPollSeconds
        }


toPage :
    Session
    -> Model
    -> Cmd Msg
    -> (pageModel -> Page)
    -> (pageMsg -> Msg)
    -> PageUpdate pageModel pageMsg
    -> ( Model, Cmd Msg )
toPage session model cmds toModel toMsg pageUpdate =
    let
        storeCmd =
            if session.store /= pageUpdate.session.store then
                pageUpdate.session.store |> Session.serializeStore |> Ports.saveStore

            else
                Cmd.none
    in
    ( { model | state = Loaded pageUpdate.session (toModel pageUpdate.model) }
    , Cmd.batch
        [ cmds
        , Cmd.map toMsg pageUpdate.cmd
        , storeCmd
        , pageUpdate |> App.mapToCmd AppMsg
        ]
    )


requireSuperuser : Session -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
requireSuperuser session ( model, cmds ) =
    if Session.isSuperuser session then
        ( model, cmds )

    else
        ( { model | state = Loaded session RestrictedAccessPage }
        , Cmd.none
        )


setRoute : Url -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
setRoute url ( { state } as model, cmds ) =
    case state of
        Errored _ ->
            -- FIXME: Static database decoding error, highly unlikely to ever happen
            ( model, cmds )

        Loaded session _ ->
            case Route.fromUrl url of
                Just Route.Api ->
                    Api.init session
                        |> toPage session model cmds ApiPage ApiMsg

                Just Route.Auth ->
                    Auth.init session
                        |> toPage session model cmds AuthPage AuthMsg

                Just (Route.AuthLogin email token) ->
                    Auth.initLogin session email token
                        |> toPage session model cmds AuthPage AuthMsg

                Just Route.AuthSignup ->
                    Auth.initSignup session
                        |> toPage session model cmds AuthPage AuthMsg

                Just (Route.Admin AdminSection.AccountSection) ->
                    AccountAdmin.init session AdminSection.AccountSection
                        |> toPage session model cmds AccountAdminPage AccountAdminMsg
                        |> requireSuperuser session

                Just (Route.Admin AdminSection.ComponentSection) ->
                    ComponentAdmin.init session AdminSection.ComponentSection
                        |> toPage session model cmds ComponentAdminPage ComponentAdminMsg
                        |> requireSuperuser session

                Just (Route.Admin AdminSection.ProcessSection) ->
                    ProcessAdmin.init session AdminSection.ProcessSection
                        |> toPage session model cmds ProcessAdminPage ProcessAdminMsg
                        |> requireSuperuser session

                Just (Route.Editorial slug) ->
                    Editorial.init slug session
                        |> toPage session model cmds EditorialPage EditorialMsg

                Just (Route.Explore scope dataset) ->
                    Explore.init scope dataset session
                        |> toPage session model cmds ExplorePage ExploreMsg

                Just (Route.FoodBuilder trigram maybeQuery) ->
                    FoodBuilder.init session trigram maybeQuery
                        |> toPage session model cmds FoodBuilderPage FoodBuilderMsg

                Just (Route.FoodBuilderExample uuid) ->
                    FoodBuilder.initFromExample session uuid
                        |> toPage session model cmds FoodBuilderPage FoodBuilderMsg

                Just Route.FoodBuilderHome ->
                    FoodBuilder.init session Impact.default Nothing
                        |> toPage session model cmds FoodBuilderPage FoodBuilderMsg

                Just Route.Home ->
                    Home.init session
                        |> toPage session model cmds HomePage HomeMsg

                Just (Route.ObjectSimulator scope trigram maybeQuery) ->
                    ObjectSimulator.init scope trigram maybeQuery session
                        |> toPage session model cmds ObjectSimulatorPage ObjectSimulatorMsg

                Just (Route.ObjectSimulatorExample scope uuid) ->
                    ObjectSimulator.initFromExample session scope uuid
                        |> toPage session model cmds ObjectSimulatorPage ObjectSimulatorMsg

                Just (Route.ObjectSimulatorHome scope) ->
                    ObjectSimulator.init scope Impact.default Nothing session
                        |> toPage session model cmds ObjectSimulatorPage ObjectSimulatorMsg

                Just Route.Stats ->
                    Stats.init session
                        |> toPage session model cmds StatsPage StatsMsg

                Just (Route.TextileSimulator trigram maybeQuery) ->
                    TextileSimulator.init trigram maybeQuery session
                        |> toPage session model cmds TextileSimulatorPage TextileSimulatorMsg

                Just (Route.TextileSimulatorExample uuid) ->
                    TextileSimulator.initFromExample session uuid
                        |> toPage session model cmds TextileSimulatorPage TextileSimulatorMsg

                Just Route.TextileSimulatorHome ->
                    TextileSimulator.init Impact.default Nothing session
                        |> toPage session model cmds TextileSimulatorPage TextileSimulatorMsg

                Nothing ->
                    ( { model | state = Loaded session NotFoundPage }
                    , Cmd.none
                    )


update : Msg -> Model -> ( Model, Cmd Msg )
update rawMsg ({ state } as model) =
    case ( state, rawMsg ) of
        ( Loaded session page, msg ) ->
            case ( msg, page ) of
                -- Global app messages
                ( AppMsg (App.AddToast notification), _ ) ->
                    let
                        ( newTray, newToastMsg ) =
                            Toast.add model.tray <|
                                case notification.level of
                                    Notification.Error ->
                                        Toast.persistent notification

                                    _ ->
                                        Toast.expireOnBlur 5000 notification
                    in
                    ( { model | tray = newTray }, Cmd.map (AppMsg << App.ToastMsg) newToastMsg )

                ( AppMsg App.CloseMobileNavigation, _ ) ->
                    ( { model | mobileNavigationOpened = False }, Cmd.none )

                ( AppMsg (App.CloseNotification notification), currentPage ) ->
                    ( { model
                        | state =
                            currentPage
                                |> Loaded (session |> Session.closeNotification notification)
                      }
                    , Cmd.none
                    )

                ( AppMsg (App.LoadUrl url), _ ) ->
                    ( model, Nav.load url )

                ( AppMsg App.OpenMobileNavigation, _ ) ->
                    ( { model | mobileNavigationOpened = True }, Cmd.none )

                ( AppMsg App.ReloadPage, _ ) ->
                    ( model, Nav.reloadAndSkipCache )

                ( AppMsg App.ResetSessionStore, currentPage ) ->
                    let
                        newSession =
                            -- FIXME: remove notifications from session
                            { session | notifications = [], store = Session.defaultStore }
                    in
                    ( { model | state = currentPage |> Loaded newSession }
                    , Cmd.batch
                        [ newSession.store |> Session.serializeStore |> Ports.saveStore
                        , Notification.info "La session a été réinitialisée."
                            |> App.AddToast
                            |> App.toCmd AppMsg
                        ]
                    )

                ( AppMsg (App.SwitchVersion version), _ ) ->
                    ( model
                    , Nav.load <|
                        "/versions/"
                            ++ version
                            ++ "/#"
                            ++ Maybe.withDefault "" model.url.fragment
                    )

                -- Toast notifications
                ( AppMsg (App.ToastMsg toastMsg), _ ) ->
                    let
                        ( newTray, newToastMsg ) =
                            Toast.update toastMsg model.tray
                    in
                    ( { model | tray = newTray }, Cmd.map (AppMsg << App.ToastMsg) newToastMsg )

                -- Pages
                ( HomeMsg homeMsg, HomePage homeModel ) ->
                    Home.update session homeMsg homeModel
                        |> toPage session model Cmd.none HomePage HomeMsg

                ( AccountAdminMsg adminMsg, AccountAdminPage adminModel ) ->
                    AccountAdmin.update session adminMsg adminModel
                        |> toPage session model Cmd.none AccountAdminPage AccountAdminMsg

                ( ApiMsg apiMsg, ApiPage apiModel ) ->
                    Api.update session apiMsg apiModel
                        |> toPage session model Cmd.none ApiPage ApiMsg

                ( AuthMsg auth2Msg, AuthPage auth2Model ) ->
                    Auth.update session auth2Msg auth2Model
                        |> toPage session model Cmd.none AuthPage AuthMsg

                ( ComponentAdminMsg adminMsg, ComponentAdminPage adminModel ) ->
                    ComponentAdmin.update session adminMsg adminModel
                        |> toPage session model Cmd.none ComponentAdminPage ComponentAdminMsg

                ( ComponentConfigReceived requestedUrl (RemoteData.Success componentConfig), currentPage ) ->
                    setRoute requestedUrl
                        ( { model | state = currentPage |> Loaded { session | componentConfig = componentConfig } }
                        , Cmd.none
                        )

                ( ComponentConfigReceived _ (RemoteData.Failure _), _ ) ->
                    notifyError model "Erreur" <|
                        "Impossible de charger la configuration des composants. Une configuration par défaut sera"
                            ++ " utilisée, les résultats fournis sont probablement invalides ou incomplets."

                ( ComponentConfigReceived _ _, _ ) ->
                    ( model, Cmd.none )

                ( ProcessAdminMsg adminMsg, ProcessAdminPage adminModel ) ->
                    ProcessAdmin.update session adminMsg adminModel
                        |> toPage session model Cmd.none ProcessAdminPage ProcessAdminMsg

                ( DetailedProcessesReceived requestedUrl (RemoteData.Success rawDetailedProcessesJson), currentPage ) ->
                    -- When detailed processes are received, rebuild the entire static db using them
                    case StaticDb.db rawDetailedProcessesJson of
                        Err _ ->
                            notifyError model "Erreur" <|
                                "Impossible de décoder les impacts détaillés; les impacts agrégés seront utilisés."

                        Ok detailedDb ->
                            ( { model | state = currentPage |> Loaded { session | db = detailedDb } }
                            , ComponentConfig.decode detailedDb
                                |> Http.get "/data/components/config.json" (ComponentConfigReceived requestedUrl)
                            )

                ( DetailedProcessesReceived _ (RemoteData.Failure _), _ ) ->
                    notifyError model "Erreur" <|
                        "Impossible de charger les impacts détaillés; les impacts agrégés seront utilisés."

                ( EditorialMsg editorialMsg, EditorialPage editorialModel ) ->
                    Editorial.update session editorialMsg editorialModel
                        |> toPage session model Cmd.none EditorialPage EditorialMsg

                ( ExploreMsg examplesMsg, ExplorePage examplesModel ) ->
                    Explore.update session examplesMsg examplesModel
                        |> toPage session model Cmd.none ExplorePage ExploreMsg

                -- Food
                ( FoodBuilderMsg foodMsg, FoodBuilderPage foodModel ) ->
                    FoodBuilder.update session foodMsg foodModel
                        |> toPage session model Cmd.none FoodBuilderPage FoodBuilderMsg

                -- Object
                ( ObjectSimulatorMsg objectMsg, ObjectSimulatorPage objectModel ) ->
                    ObjectSimulator.update session objectMsg objectModel
                        |> toPage session model Cmd.none ObjectSimulatorPage ObjectSimulatorMsg

                -- Textile
                ( TextileSimulatorMsg textileMsg, TextileSimulatorPage textileModel ) ->
                    TextileSimulator.update session textileMsg textileModel
                        |> toPage session model Cmd.none TextileSimulatorPage TextileSimulatorMsg

                -- Stats
                ( StatsMsg statsMsg, StatsPage statsModel ) ->
                    Stats.update session statsMsg statsModel
                        |> toPage session model Cmd.none StatsPage StatsMsg

                -- Store
                ( StoreChanged json, currentPage ) ->
                    ( { model
                        | state =
                            currentPage
                                |> Loaded (session |> Session.decodeRawStore json)
                      }
                    , Cmd.none
                    )

                -- Url
                ( UrlChanged url, _ ) ->
                    ( { model | mobileNavigationOpened = False, url = url }, Cmd.none )
                        |> setRoute url
                        |> Tuple.mapSecond (\cmd -> Cmd.batch [ cmd, Plausible.send session <| Plausible.PageViewed url ])

                ( UrlRequested (Browser.Internal url), _ ) ->
                    ( { model | url = url }, Nav.pushUrl session.navKey (Url.toString url) )

                ( UrlRequested (Browser.External href), _ ) ->
                    ( model, Nav.load href )

                -- Releases
                ( ReleasesReceived webData, currentPage ) ->
                    ( { model
                        | state =
                            currentPage
                                |> Loaded { session | releases = webData }
                      }
                    , Cmd.none
                    )

                -- Version check
                ( VersionReceived webData, currentPage ) ->
                    ( { model
                        | state =
                            currentPage
                                |> Loaded { session | currentVersion = Request.Version.update session.currentVersion webData }
                      }
                    , Cmd.none
                    )

                ( VersionPoll, _ ) ->
                    ( model, Request.Version.loadVersion VersionReceived )

                -- Catch-all
                ( _, RestrictedAccessPage ) ->
                    ( { model | state = Loaded session RestrictedAccessPage }
                    , Cmd.none
                    )

                ( _, NotFoundPage ) ->
                    ( { model | state = Loaded session NotFoundPage }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        ( Errored _, _ ) ->
            ( model, Cmd.none )


notifyError : Model -> String -> String -> ( Model, Cmd Msg )
notifyError model title message =
    ( model
    , Notification.error title message
        |> App.AddToast
        |> App.toCmd AppMsg
    )


subscriptions : Model -> Sub Msg
subscriptions { state } =
    Sub.batch
        [ Ports.storeChanged StoreChanged
        , case state of
            Loaded { versionPollSeconds } _ ->
                Request.Version.pollVersion versionPollSeconds VersionPoll

            _ ->
                Sub.none
        , case state of
            Loaded _ (AccountAdminPage _) ->
                AccountAdmin.subscriptions
                    |> Sub.map AccountAdminMsg

            Loaded _ (ComponentAdminPage subModel) ->
                ComponentAdmin.subscriptions subModel
                    |> Sub.map ComponentAdminMsg

            Loaded _ (ProcessAdminPage _) ->
                ProcessAdmin.subscriptions
                    |> Sub.map ProcessAdminMsg

            Loaded _ (ExplorePage subModel) ->
                Explore.subscriptions subModel
                    |> Sub.map ExploreMsg

            Loaded _ (FoodBuilderPage subModel) ->
                FoodBuilder.subscriptions subModel
                    |> Sub.map FoodBuilderMsg

            Loaded _ (ObjectSimulatorPage subModel) ->
                ObjectSimulator.subscriptions subModel
                    |> Sub.map ObjectSimulatorMsg

            Loaded _ (TextileSimulatorPage subModel) ->
                TextileSimulator.subscriptions subModel
                    |> Sub.map TextileSimulatorMsg

            _ ->
                Sub.none
        ]


view : Model -> Document Msg
view { mobileNavigationOpened, state, tray } =
    case state of
        Errored error ->
            -- FIXME: proper error page
            { body =
                [ Html.h1 [] [ Html.text <| "Erreur" ]
                , Html.pre [] [ Html.text error ]
                ]
            , title = "Erreur"
            }

        Loaded session page ->
            let
                frame activePage =
                    Page.frame
                        { activePage = activePage
                        , mobileNavigationOpened = mobileNavigationOpened
                        , session = session
                        , toMsg = AppMsg
                        , tray = tray
                        }

                mapMsg msg ( title, content ) =
                    ( title, content |> List.map (Html.map msg) )
            in
            case page of
                AccountAdminPage accountAdminModel ->
                    AccountAdmin.view accountAdminModel
                        |> mapMsg AccountAdminMsg
                        |> frame Page.Admin

                ApiPage _ ->
                    Api.view session
                        |> mapMsg ApiMsg
                        |> frame Page.Api

                AuthPage auth2Model ->
                    Auth.view session auth2Model
                        |> mapMsg AuthMsg
                        |> frame Page.Auth

                ComponentAdminPage componentAdminModel ->
                    ComponentAdmin.view session componentAdminModel
                        |> mapMsg ComponentAdminMsg
                        |> frame Page.Admin

                EditorialPage editorialModel ->
                    Editorial.view editorialModel
                        |> mapMsg EditorialMsg
                        |> frame (Page.Editorial editorialModel.slug)

                ExplorePage examplesModel ->
                    Explore.view session examplesModel
                        |> mapMsg ExploreMsg
                        |> frame Page.Explore

                FoodBuilderPage foodModel ->
                    FoodBuilder.view session foodModel
                        |> mapMsg FoodBuilderMsg
                        |> frame Page.FoodBuilder

                HomePage _ ->
                    Home.view session
                        |> mapMsg HomeMsg
                        |> frame Page.Home

                LoadingPage ->
                    ( "Chargement…", [ Page.loading ] )
                        |> frame Page.Other

                NotFoundPage ->
                    ( "404", [ Page.notFound ] )
                        |> frame Page.Other

                ObjectSimulatorPage simulatorModel ->
                    ObjectSimulator.view session simulatorModel
                        |> mapMsg ObjectSimulatorMsg
                        |> frame (Page.Object simulatorModel.scope)

                ProcessAdminPage processAdminModel ->
                    ProcessAdmin.view session processAdminModel
                        |> mapMsg ProcessAdminMsg
                        |> frame Page.Admin

                RestrictedAccessPage ->
                    ( "Accès restreint", [ Page.restricted ] )
                        |> frame Page.Other

                StatsPage statsModel ->
                    Stats.view session statsModel
                        |> mapMsg StatsMsg
                        |> frame Page.Stats

                TextileSimulatorPage simulatorModel ->
                    TextileSimulator.view session simulatorModel
                        |> mapMsg TextileSimulatorMsg
                        |> frame Page.TextileSimulator


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
