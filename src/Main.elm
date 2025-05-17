module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Data.Example as Example
import Data.Food.Query as FoodQuery
import Data.Github as Github
import Data.Impact as Impact
import Data.Object.Query as ObjectQuery
import Data.Session as Session exposing (Session)
import Data.Textile.Query as TextileQuery
import Html
import Http
import Page.Admin as Admin
import Page.Api as Api
import Page.Auth as Auth
import Page.Auth2 as Auth2
import Page.Editorial as Editorial
import Page.Explore as Explore
import Page.Food as FoodBuilder
import Page.Home as Home
import Page.Object as ObjectSimulator
import Page.Stats as Stats
import Page.Textile as TextileSimulator
import Ports
import RemoteData exposing (WebData)
import Request.Auth
import Request.Common
import Request.Github
import Request.Version exposing (VersionData)
import Route
import Static.Db as StaticDb exposing (Db)
import Static.Json as StaticJson
import Url exposing (Url)
import Views.Page as Page


type alias Flags =
    { backendApiUrl : String
    , clientUrl : String
    , enabledSections : Session.EnabledSections
    , matomo : { host : String, siteId : String }
    , rawStore : String
    }


type Page
    = AdminPage Admin.Model
    | ApiPage Api.Model
    | Auth2Page Auth2.Model
    | AuthPage Auth.Model
    | EditorialPage Editorial.Model
    | ExplorePage Explore.Model
    | FoodBuilderPage FoodBuilder.Model
    | HomePage Home.Model
    | LoadingPage
    | NotFoundPage
    | ObjectSimulatorPage ObjectSimulator.Model
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
    , url : Url
    }


type Msg
    = AdminMsg Admin.Msg
    | ApiMsg Api.Msg
    | Auth2Msg Auth2.Msg
    | AuthMsg Auth.Msg
    | CloseMobileNavigation
    | CloseNotification Session.Notification
    | DetailedProcessesReceived (Result Http.Error String)
    | EditorialMsg Editorial.Msg
    | ExploreMsg Explore.Msg
    | FoodBuilderMsg FoodBuilder.Msg
    | HomeMsg Home.Msg
    | LoadUrl String
    | ObjectSimulatorMsg ObjectSimulator.Msg
    | OpenMobileNavigation
    | ReleasesReceived (WebData (List Github.Release))
    | ReloadPage
    | ResetSessionStore
    | StatsMsg Stats.Msg
    | StoreChanged String
    | SwitchVersion String
    | TextileSimulatorMsg TextileSimulator.Msg
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest
    | VersionPoll
    | VersionReceived (WebData VersionData)


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags requestedUrl navKey =
    setRoute requestedUrl <|
        case StaticDb.db StaticJson.processesJson of
            Err err ->
                ( { mobileNavigationOpened = False
                  , navKey = navKey
                  , state = Errored err
                  , url = requestedUrl
                  }
                , Cmd.none
                )

            Ok db ->
                let
                    session =
                        setupSession navKey flags db
                in
                ( { mobileNavigationOpened = False
                  , navKey = navKey
                  , state = Loaded session LoadingPage
                  , url = requestedUrl
                  }
                , Cmd.batch
                    [ Ports.appStarted ()
                    , Request.Version.loadVersion VersionReceived
                    , Request.Github.getReleases ReleasesReceived
                    , case session.store.auth of
                        Session.Authenticated user ->
                            Request.Auth.processes DetailedProcessesReceived user.token

                        Session.NotAuthenticated ->
                            Cmd.none
                    ]
                )


setupSession : Nav.Key -> Flags -> Db -> Session
setupSession navKey flags db =
    Session.decodeRawStore flags.rawStore
        { backendApiUrl = flags.backendApiUrl
        , clientUrl = flags.clientUrl
        , currentVersion = Request.Version.Unknown
        , db = db
        , enabledSections = flags.enabledSections
        , matomo = flags.matomo
        , navKey = navKey
        , notifications = []
        , queries =
            { food = FoodQuery.empty
            , object = ObjectQuery.default
            , textile =
                db.textile.examples
                    |> Example.findByName "Tshirt coton (150g) - Majorant par défaut"
                    |> Result.map .query
                    |> Result.withDefault TextileQuery.default
            , veli = ObjectQuery.default
            }
        , releases = RemoteData.NotAsked
        , store = Session.defaultStore
        }


setRoute : Url -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
setRoute url ( { state } as model, cmds ) =
    case state of
        Errored _ ->
            -- FIXME: Static database decoding error, highly unlikely to ever happen
            ( model, cmds )

        Loaded session _ ->
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
                    ( { model | state = Loaded newSession (page subModel) }
                    , Cmd.batch
                        [ cmds
                        , Cmd.map subMsg subCmds
                        , storeCmd
                        ]
                    )
            in
            case Route.fromUrl url of
                Just Route.Admin ->
                    if Session.isStaff session then
                        Admin.init session
                            |> toPage AdminPage AdminMsg

                    else
                        ( { model | state = Loaded session RestrictedAccessPage }
                        , Cmd.none
                        )

                Just Route.Api ->
                    Api.init session
                        |> toPage ApiPage ApiMsg

                Just Route.Auth2 ->
                    Auth2.init session
                        |> toPage Auth2Page Auth2Msg

                Just (Route.Auth2Login email token) ->
                    Auth2.initLogin session email token
                        |> toPage Auth2Page Auth2Msg

                Just (Route.Auth data) ->
                    Auth.init session data
                        |> toPage AuthPage AuthMsg

                Just (Route.Editorial slug) ->
                    Editorial.init slug session
                        |> toPage EditorialPage EditorialMsg

                Just (Route.Explore scope dataset) ->
                    Explore.init scope dataset session
                        |> toPage ExplorePage ExploreMsg

                Just (Route.FoodBuilder trigram maybeQuery) ->
                    FoodBuilder.init session trigram maybeQuery
                        |> toPage FoodBuilderPage FoodBuilderMsg

                Just (Route.FoodBuilderExample uuid) ->
                    FoodBuilder.initFromExample session uuid
                        |> toPage FoodBuilderPage FoodBuilderMsg

                Just Route.FoodBuilderHome ->
                    FoodBuilder.init session Impact.default Nothing
                        |> toPage FoodBuilderPage FoodBuilderMsg

                Just Route.Home ->
                    Home.init session
                        |> toPage HomePage HomeMsg

                Just (Route.ObjectSimulator scope trigram maybeQuery) ->
                    ObjectSimulator.init scope trigram maybeQuery session
                        |> toPage ObjectSimulatorPage ObjectSimulatorMsg

                Just (Route.ObjectSimulatorExample scope uuid) ->
                    ObjectSimulator.initFromExample session scope uuid
                        |> toPage ObjectSimulatorPage ObjectSimulatorMsg

                Just (Route.ObjectSimulatorHome scope) ->
                    ObjectSimulator.init scope Impact.default Nothing session
                        |> toPage ObjectSimulatorPage ObjectSimulatorMsg

                Just Route.Stats ->
                    Stats.init session
                        |> toPage StatsPage StatsMsg

                Just (Route.TextileSimulator trigram maybeQuery) ->
                    TextileSimulator.init trigram maybeQuery session
                        |> toPage TextileSimulatorPage TextileSimulatorMsg

                Just (Route.TextileSimulatorExample uuid) ->
                    TextileSimulator.initFromExample session uuid
                        |> toPage TextileSimulatorPage TextileSimulatorMsg

                Just Route.TextileSimulatorHome ->
                    TextileSimulator.init Impact.default Nothing session
                        |> toPage TextileSimulatorPage TextileSimulatorMsg

                Nothing ->
                    ( { model | state = Loaded session NotFoundPage }
                    , Cmd.none
                    )


update : Msg -> Model -> ( Model, Cmd Msg )
update rawMsg ({ state } as model) =
    case ( state, rawMsg ) of
        ( Loaded session page, msg ) ->
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
                    ( { model | state = Loaded newSession (toModel newModel) }
                    , Cmd.map toMsg (Cmd.batch [ newCmd, storeCmd ])
                    )
            in
            case ( msg, page ) of
                -- Pages
                ( HomeMsg homeMsg, HomePage homeModel ) ->
                    Home.update session homeMsg homeModel
                        |> toPage HomePage HomeMsg

                ( AdminMsg adminMsg, AdminPage adminModel ) ->
                    Admin.update session adminMsg adminModel
                        |> toPage AdminPage AdminMsg

                ( ApiMsg apiMsg, ApiPage apiModel ) ->
                    Api.update session apiMsg apiModel
                        |> toPage ApiPage ApiMsg

                ( Auth2Msg auth2Msg, Auth2Page auth2Model ) ->
                    Auth2.update session auth2Msg auth2Model
                        |> toPage Auth2Page Auth2Msg

                ( AuthMsg authMsg, AuthPage authModel ) ->
                    Auth.update session authMsg authModel
                        |> toPage AuthPage AuthMsg

                ( DetailedProcessesReceived (Ok rawDetailedProcessesJson), currentPage ) ->
                    -- When detailed processes are received, rebuild the entire static db using them
                    case StaticDb.db rawDetailedProcessesJson of
                        Err error ->
                            ( { model | state = Errored error }, Cmd.none )

                        Ok detailedDb ->
                            ( { model | state = currentPage |> Loaded { session | db = detailedDb } }, Cmd.none )

                ( DetailedProcessesReceived (Err httpError), _ ) ->
                    ( { model | state = Errored (Request.Common.errorToString httpError) }
                    , Cmd.none
                    )

                ( EditorialMsg editorialMsg, EditorialPage editorialModel ) ->
                    Editorial.update session editorialMsg editorialModel
                        |> toPage EditorialPage EditorialMsg

                ( ExploreMsg examplesMsg, ExplorePage examplesModel ) ->
                    Explore.update session examplesMsg examplesModel
                        |> toPage ExplorePage ExploreMsg

                -- Food
                ( FoodBuilderMsg foodMsg, FoodBuilderPage foodModel ) ->
                    FoodBuilder.update session foodMsg foodModel
                        |> toPage FoodBuilderPage FoodBuilderMsg

                -- Object
                ( ObjectSimulatorMsg objectMsg, ObjectSimulatorPage objectModel ) ->
                    ObjectSimulator.update session objectMsg objectModel
                        |> toPage ObjectSimulatorPage ObjectSimulatorMsg

                -- Textile
                ( TextileSimulatorMsg textileMsg, TextileSimulatorPage textileModel ) ->
                    TextileSimulator.update session textileMsg textileModel
                        |> toPage TextileSimulatorPage TextileSimulatorMsg

                -- Stats
                ( StatsMsg statsMsg, StatsPage statsModel ) ->
                    Stats.update session statsMsg statsModel
                        |> toPage StatsPage StatsMsg

                -- Notifications
                ( CloseNotification notification, currentPage ) ->
                    ( { model
                        | state =
                            currentPage
                                |> Loaded (session |> Session.closeNotification notification)
                      }
                    , Cmd.none
                    )

                -- Store
                ( StoreChanged json, currentPage ) ->
                    ( { model
                        | state =
                            currentPage
                                |> Loaded (session |> Session.decodeRawStore json)
                      }
                    , Cmd.none
                    )

                ( ResetSessionStore, currentPage ) ->
                    let
                        newSession =
                            { session | notifications = [], store = Session.defaultStore }
                                |> Session.notifyInfo "Session" "La session a été réinitialisée."
                    in
                    ( { model | state = currentPage |> Loaded newSession }
                    , newSession.store |> Session.serializeStore |> Ports.saveStore
                    )

                -- Version switch
                ( SwitchVersion version, _ ) ->
                    ( model
                    , Nav.load <|
                        "/versions/"
                            ++ version
                            ++ "/#"
                            ++ Maybe.withDefault "" model.url.fragment
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
                    ( { model | mobileNavigationOpened = False, url = url }, Cmd.none )
                        |> setRoute url

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


subscriptions : Model -> Sub Msg
subscriptions { state } =
    Sub.batch
        [ Ports.storeChanged StoreChanged
        , Request.Version.pollVersion VersionPoll
        , case state of
            Loaded _ (AdminPage subModel) ->
                Admin.subscriptions subModel
                    |> Sub.map AdminMsg

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
view { mobileNavigationOpened, state } =
    case state of
        Errored error ->
            { body =
                [ Html.h1 [] [ Html.text <| "Erreur" ]
                , Html.p [] [ Html.text error ]
                ]
            , title = "Erreur"
            }

        Loaded session page ->
            let
                pageConfig =
                    Page.Config session
                        mobileNavigationOpened
                        CloseMobileNavigation
                        OpenMobileNavigation
                        LoadUrl
                        ReloadPage
                        CloseNotification
                        ResetSessionStore
                        SwitchVersion

                mapMsg msg ( title, content ) =
                    ( title, content |> List.map (Html.map msg) )
            in
            case page of
                AdminPage examplesModel ->
                    Admin.view session examplesModel
                        |> mapMsg AdminMsg
                        |> Page.frame (pageConfig Page.Admin)

                ApiPage examplesModel ->
                    Api.view session examplesModel
                        |> mapMsg ApiMsg
                        |> Page.frame (pageConfig Page.Api)

                Auth2Page auth2Model ->
                    Auth2.view session auth2Model
                        |> mapMsg Auth2Msg
                        |> Page.frame (pageConfig Page.Auth2)

                AuthPage authModel ->
                    Auth.view session authModel
                        |> mapMsg AuthMsg
                        |> Page.frame (pageConfig Page.Auth)

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

                HomePage _ ->
                    Home.view session
                        |> mapMsg HomeMsg
                        |> Page.frame (pageConfig Page.Home)

                LoadingPage ->
                    ( "Chargement…", [ Page.loading ] )
                        |> Page.frame (pageConfig Page.Other)

                NotFoundPage ->
                    ( "404", [ Page.notFound ] )
                        |> Page.frame (pageConfig Page.Other)

                ObjectSimulatorPage simulatorModel ->
                    ObjectSimulator.view session simulatorModel
                        |> mapMsg ObjectSimulatorMsg
                        |> Page.frame (pageConfig (Page.Object simulatorModel.scope))

                RestrictedAccessPage ->
                    ( "Accès restreint", [ Page.restricted session ] )
                        |> Page.frame (pageConfig Page.Other)

                StatsPage statsModel ->
                    Stats.view session statsModel
                        |> mapMsg StatsMsg
                        |> Page.frame (pageConfig Page.Stats)

                TextileSimulatorPage simulatorModel ->
                    TextileSimulator.view session simulatorModel
                        |> mapMsg TextileSimulatorMsg
                        |> Page.frame (pageConfig Page.TextileSimulator)


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
