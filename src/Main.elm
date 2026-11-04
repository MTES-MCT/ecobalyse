module Main exposing (main)

import App exposing (PageUpdate)
import Browser exposing (Document)
import Browser.Events
import Browser.Navigation as Nav
import Data.Component as Component
import Data.Component.Config as ComponentConfig
import Data.Db exposing (Db, RawJsonString)
import Data.Env as Env
import Data.Example as Example
import Data.Food.Query as FoodQuery
import Data.Impact as Impact
import Data.Key as Key
import Data.Notification as Notification exposing (Notification)
import Data.Plausible as Plausible
import Data.Session as Session exposing (Session)
import Data.Textile.Query as TextileQuery
import Html
import Http
import Page.Api as Api
import Page.Auth as Auth
import Page.Editorial as Editorial
import Page.Explore as Explore
import Page.Food as FoodBuilder
import Page.Generic as GenericSimulator
import Page.Home as Home
import Page.Stats as Stats
import Page.Textile as TextileSimulator
import Ports
import RemoteData exposing (WebData)
import Request.Auth
import Request.BackendHttp as BackendHttp
import Request.Common as RequestCommon
import Request.Db as RequestDb exposing (LoadingState)
import Request.Version as Version exposing (VersionData)
import Route
import Toast
import Url exposing (Url)
import Views.Page as Page


type alias Flags =
    { clientUrl : String
    , enabledSections : Session.EnabledSections
    , matomo : { host : String, siteId : String }
    , plausible : { host : Maybe String }
    , rawStore : String
    , scalingoAppName : Maybe String
    , versionPollSeconds : Int
    }


type alias SessionConfig =
    { flags : Flags
    , navKey : Nav.Key
    , url : Url
    }


type Page
    = ApiPage Api.Model
    | AuthPage Auth.Model
    | EditorialPage Editorial.Model
    | ExplorePage Explore.Model
    | FoodBuilderPage FoodBuilder.Model
    | GenericSimulatorPage GenericSimulator.Model
    | HomePage Home.Model
    | LoadingPage
    | NotFoundPage
    | StatsPage Stats.Model
    | TextileSimulatorPage TextileSimulator.Model


type State
    = Errored String
    | Initializing
    | Loaded Session Page


type alias Model =
    { dbLoadingState : LoadingState
    , feedbackModalOpen : Bool
    , flags : Flags
    , mobileNavigationOpened : Bool

    -- Duplicate the nav key in the model so Parcel's hot module reloading finds it always in the same place.
    , navKey : Nav.Key
    , state : State
    , tray : Toast.Tray Notification
    , url : Url
    }


type Msg
    = ApiMsg Api.Msg
    | AppMsg App.Msg
    | AuthMsg Auth.Msg
    | CloseFeedbackModal
    | ComponentConfigReceived Db SessionConfig (WebData String)
    | DetailedProcessesReceived (BackendHttp.WebData String)
    | EditorialMsg Editorial.Msg
    | ExploreMsg Explore.Msg
    | FoodBuilderMsg FoodBuilder.Msg
    | GenericSimulatorMsg GenericSimulator.Msg
    | HomeMsg Home.Msg
    | RawDataReceived SessionConfig (WebData RawJsonString -> LoadingState -> LoadingState) (WebData RawJsonString)
    | StatsMsg Stats.Msg
    | StoreChanged String
    | TextileSimulatorMsg TextileSimulator.Msg
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest
    | VersionPoll
    | VersionReceived (WebData VersionData)


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags requestedUrl navKey =
    ( { dbLoadingState = RequestDb.initLoadingState
      , feedbackModalOpen = False
      , flags = flags
      , mobileNavigationOpened = False
      , navKey = navKey
      , state = Initializing
      , tray = Toast.tray
      , url = requestedUrl
      }
    , Cmd.batch
        [ Ports.appStarted ()
        , Version.loadVersion VersionReceived
        , loadData { flags = flags, navKey = navKey, url = requestedUrl }
        , Ports.loadJeDonneMonAvis ()
        ]
    )


{-| Loads Db raw json files in parallel.
-}
loadData : SessionConfig -> Cmd Msg
loadData sessionConfig =
    [ ( "/data/countries.json", \data raw -> { raw | countries = data } )
    , ( "/data/impacts.json", \data raw -> { raw | definitions = data } )
    , ( "/data/food2/components.json", \data raw -> { raw | food2Components = data } )
    , ( "/data/food2/categories.json", \data raw -> { raw | food2ProductCategories = data } )
    , ( "/data/food2/examples.json", \data raw -> { raw | food2Examples = data } )
    , ( "/data/food/ingredients.json", \data raw -> { raw | foodIngredients = data } )
    , ( "/data/food/examples.json", \data raw -> { raw | foodProductExamples = data } )
    , ( "/data/object/categories.json", \data raw -> { raw | objectProductCategories = data } )
    , ( "/data/object/components.json", \data raw -> { raw | objectComponents = data } )
    , ( "/data/object/examples.json", \data raw -> { raw | objectExamples = data } )
    , ( "/data/processes.json", \data raw -> { raw | processes = data } )
    , ( "/data/textile/components.json", \data raw -> { raw | textileComponents = data } )
    , ( "/data/textile/examples.json", \data raw -> { raw | textileProductExamples = data } )
    , ( "/data/textile/materials.json", \data raw -> { raw | textileMaterials = data } )
    , ( "/data/textile/products.json", \data raw -> { raw | textileProducts = data } )
    , ( "/data/transports.json", \data raw -> { raw | transports = data } )
    , ( "/data/veli/categories.json", \data raw -> { raw | veliProductCategories = data } )
    , ( "/data/veli/components.json", \data raw -> { raw | veliComponents = data } )
    , ( "/data/veli/examples.json", \data raw -> { raw | veliExamples = data } )
    ]
        |> List.map
            (\( path, onLoaded ) ->
                RequestDb.fetchJson path <| RawDataReceived sessionConfig onLoaded
            )
        |> Cmd.batch


setupSession : SessionConfig -> LoadingState -> Db -> String -> Component.Config -> Session
setupSession { flags, navKey } dbLoadingState db componentRawConfig componentConfig =
    Session.decodeRawStore flags.rawStore
        { clientUrl = flags.clientUrl
        , componentConfig = componentConfig
        , currentVersion = Version.Unknown
        , db = db
        , detailedImpacts = False
        , enabledSections = flags.enabledSections
        , matomo = flags.matomo
        , navKey = navKey
        , notifications = []
        , plausible = flags.plausible
        , queries =
            { food = FoodQuery.empty
            , food2 = Component.emptyQuery
            , object = Component.emptyQuery
            , textile =
                db.textile.examples
                    |> Example.findByName "Tshirt coton (150g) - Majorant par défaut"
                    |> Result.map .query
                    |> Result.withDefault TextileQuery.default
            , veli = Component.emptyQuery
            }
        , rawData =
            { config = componentRawConfig
            , db = RequestDb.toRawJsonStrings dbLoadingState
            }
        , scalingoAppName = flags.scalingoAppName
        , store = Session.defaultStore
        , versionPollSeconds = flags.versionPollSeconds
        }


saveStore : Session -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
saveStore previousSession ( model, cmds ) =
    ( model
    , case model.state of
        Loaded session _ ->
            if previousSession.store /= session.store then
                Cmd.batch
                    [ cmds
                    , session.store |> Session.serializeStore |> Ports.saveStore
                    ]

            else
                cmds

        _ ->
            cmds
    )


toPage :
    Model
    -> Cmd Msg
    -> (pageModel -> Page)
    -> (pageMsg -> Msg)
    -> PageUpdate pageModel pageMsg
    -> ( Model, Cmd Msg )
toPage model cmds toModel toMsg pageUpdate =
    ( { model | state = Loaded pageUpdate.session (toModel pageUpdate.model) }
    , Cmd.batch
        [ cmds
        , Cmd.map toMsg pageUpdate.cmd
        , pageUpdate |> App.mapToCmd AppMsg
        ]
    )


setRoute : Url -> Session -> Page -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
setRoute url session currentPage ( model, cmds ) =
    case Route.fromUrl url of
        Just Route.Api ->
            Api.init session
                |> toPage model cmds ApiPage ApiMsg

        Just Route.Auth ->
            let
                authInit =
                    Auth.init session
                        |> toPage model cmds AuthPage AuthMsg
            in
            case currentPage of
                AuthPage ({ skipNextAuthInit } as authModel) ->
                    if skipNextAuthInit && Session.isAuthenticated session then
                        ( { model | state = Loaded session <| AuthPage { authModel | skipNextAuthInit = False } }
                        , cmds
                        )

                    else
                        authInit

                _ ->
                    authInit

        Just (Route.AuthLogin email token) ->
            Auth.initLogin session email token
                |> toPage model cmds AuthPage AuthMsg

        Just Route.AuthSignup ->
            Auth.initSignup session
                |> toPage model cmds AuthPage AuthMsg

        Just (Route.Editorial slug) ->
            Editorial.init slug session
                |> toPage model cmds EditorialPage EditorialMsg

        Just (Route.Explore scope dataset) ->
            Explore.init scope dataset session
                |> toPage model cmds ExplorePage ExploreMsg

        Just (Route.FoodBuilder trigram maybeQuery) ->
            FoodBuilder.init session trigram maybeQuery
                |> toPage model cmds FoodBuilderPage FoodBuilderMsg

        Just (Route.FoodBuilderExample uuid) ->
            FoodBuilder.initFromExample session uuid
                |> toPage model cmds FoodBuilderPage FoodBuilderMsg

        Just Route.FoodBuilderHome ->
            FoodBuilder.init session Impact.default Nothing
                |> toPage model cmds FoodBuilderPage FoodBuilderMsg

        Just (Route.GenericSimulator genericScope trigram maybeQuery) ->
            GenericSimulator.init genericScope trigram maybeQuery session
                |> toPage model cmds GenericSimulatorPage GenericSimulatorMsg

        Just (Route.GenericSimulatorExample genericScope uuid) ->
            GenericSimulator.initFromExample session genericScope uuid
                |> toPage model cmds GenericSimulatorPage GenericSimulatorMsg

        Just Route.Home ->
            Home.init session
                |> toPage model cmds HomePage HomeMsg

        Just (Route.GenericSimulatorHome genericScope) ->
            GenericSimulator.init genericScope Impact.default Nothing session
                |> toPage model cmds GenericSimulatorPage GenericSimulatorMsg

        Just Route.Stats ->
            Stats.init session
                |> toPage model cmds StatsPage StatsMsg

        Just (Route.TextileSimulator trigram maybeQuery) ->
            TextileSimulator.init trigram maybeQuery session
                |> toPage model cmds TextileSimulatorPage TextileSimulatorMsg

        Just (Route.TextileSimulatorExample uuid) ->
            TextileSimulator.initFromExample session uuid
                |> toPage model cmds TextileSimulatorPage TextileSimulatorMsg

        Just Route.TextileSimulatorHome ->
            TextileSimulator.init Impact.default Nothing session
                |> toPage model cmds TextileSimulatorPage TextileSimulatorMsg

        Nothing ->
            ( { model | state = Loaded session NotFoundPage }
            , Cmd.none
            )


{-| Updates current page and recomputes results that were possibly cached against the previous database.
-}
refreshCachedResults : Session -> Page -> Page
refreshCachedResults session currentPage =
    case currentPage of
        GenericSimulatorPage genericModel ->
            genericModel
                |> GenericSimulator.refreshResults session
                |> GenericSimulatorPage

        TextileSimulatorPage textileModel ->
            textileModel
                |> TextileSimulator.refreshResults session
                |> TextileSimulatorPage

        _ ->
            currentPage


updateInitializing : Msg -> Model -> ( Model, Cmd Msg )
updateInitializing initMsg model =
    let
        configLoadingError err =
            "Impossible de charger la configuration des composants: " ++ err
    in
    case initMsg of
        -- Components
        ComponentConfigReceived db sessionConfig remoteData ->
            case remoteData of
                RemoteData.Failure error ->
                    ( { model
                        | state =
                            RequestCommon.errorToString error
                                |> configLoadingError
                                |> Errored
                      }
                    , Cmd.none
                    )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.NotAsked ->
                    ( model, Cmd.none )

                RemoteData.Success componentRawConfig ->
                    case ComponentConfig.parse db componentRawConfig of
                        Err error ->
                            ( { model | state = Errored <| configLoadingError error }
                            , Cmd.none
                            )

                        Ok componentConfig ->
                            let
                                session =
                                    componentConfig
                                        |> setupSession sessionConfig model.dbLoadingState db componentRawConfig
                            in
                            ( { model | state = Loaded session LoadingPage }
                            , Cmd.batch
                                [ if Session.hasAccessToDetailedImpacts session then
                                    Request.Auth.processes session DetailedProcessesReceived

                                  else
                                    Cmd.none
                                , Plausible.send session <| Plausible.PageViewed sessionConfig.url
                                ]
                            )
                                |> setRoute sessionConfig.url session LoadingPage

        -- Raw Json Db data received over HTTP
        RawDataReceived sessionConfig updateRaw data ->
            let
                rawJsonData : LoadingState
                rawJsonData =
                    updateRaw data model.dbLoadingState
            in
            case RequestDb.updateRawJson rawJsonData of
                Just (Ok db) ->
                    ( { model | dbLoadingState = rawJsonData }
                      -- trigger loading the json config over http
                    , Http.get
                        { expect = Http.expectString (RemoteData.fromResult >> ComponentConfigReceived db sessionConfig)
                        , url = "/data/components/config.json"
                        }
                    )

                Just (Err err) ->
                    ( { model | dbLoadingState = rawJsonData, state = Errored (RequestDb.dbErrorToString err) }
                    , Cmd.none
                    )

                Nothing ->
                    ( { model | dbLoadingState = rawJsonData }
                    , Cmd.none
                    )

        _ ->
            ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ state } as model) =
    case state of
        Errored _ ->
            ( model, Cmd.none )

        Initializing ->
            updateInitializing msg model

        Loaded session page ->
            updateLoaded session page msg model
                |> saveStore session


updateLoaded : Session -> Page -> Msg -> Model -> ( Model, Cmd Msg )
updateLoaded session page msg model =
    case msg of
        ApiMsg apiMsg ->
            case page of
                ApiPage apiModel ->
                    Api.update session apiMsg apiModel
                        |> toPage model Cmd.none ApiPage ApiMsg

                _ ->
                    ( model, Cmd.none )

        -- Global app messages
        AppMsg appMsg ->
            updateGlobalApp session page appMsg model

        AuthMsg authMsg ->
            case page of
                AuthPage authModel ->
                    Auth.update session authMsg authModel
                        |> toPage model Cmd.none AuthPage AuthMsg

                _ ->
                    ( model, Cmd.none )

        CloseFeedbackModal ->
            ( { model | feedbackModalOpen = False }, Cmd.none )

        -- Initial config response is handled while `Initializing`
        ComponentConfigReceived _ _ _ ->
            ( model, Cmd.none )

        -- Detailed processes
        DetailedProcessesReceived remoteData ->
            updateDetailedProcess remoteData session page model

        EditorialMsg editorialMsg ->
            case page of
                EditorialPage editorialModel ->
                    Editorial.update session editorialMsg editorialModel
                        |> toPage model Cmd.none EditorialPage EditorialMsg

                _ ->
                    ( model, Cmd.none )

        ExploreMsg examplesMsg ->
            case page of
                ExplorePage examplesModel ->
                    Explore.update session examplesMsg examplesModel
                        |> toPage model Cmd.none ExplorePage ExploreMsg

                _ ->
                    ( model, Cmd.none )

        -- Food
        FoodBuilderMsg foodMsg ->
            case page of
                FoodBuilderPage foodModel ->
                    FoodBuilder.update session foodMsg foodModel
                        |> toPage model Cmd.none FoodBuilderPage FoodBuilderMsg
                        |> trackUsage (FoodBuilder.shouldTrackUsage foodMsg)

                _ ->
                    ( model, Cmd.none )

        -- Generic simulator
        GenericSimulatorMsg genericMsg ->
            case page of
                GenericSimulatorPage genericModel ->
                    GenericSimulator.update session genericMsg genericModel
                        |> toPage model Cmd.none GenericSimulatorPage GenericSimulatorMsg
                        |> trackUsage (GenericSimulator.shouldTrackUsage genericMsg)

                _ ->
                    ( model, Cmd.none )

        -- Home
        HomeMsg homeMsg ->
            case page of
                HomePage homeModel ->
                    Home.update session homeMsg homeModel
                        |> toPage model Cmd.none HomePage HomeMsg

                _ ->
                    ( model, Cmd.none )

        RawDataReceived _ _ _ ->
            ( model, Cmd.none )

        -- Stats
        StatsMsg statsMsg ->
            case page of
                StatsPage statsModel ->
                    Stats.update session statsMsg statsModel
                        |> toPage model Cmd.none StatsPage StatsMsg

                _ ->
                    ( model, Cmd.none )

        -- Store
        StoreChanged json ->
            let
                newSession =
                    session |> Session.decodeRawStore json

                newPage =
                    if session.detailedImpacts /= newSession.detailedImpacts then
                        page |> refreshCachedResults newSession

                    else
                        page
            in
            ( { model | state = Loaded newSession newPage }
            , Cmd.none
            )

        -- Textile
        TextileSimulatorMsg textileMsg ->
            case page of
                TextileSimulatorPage textileModel ->
                    TextileSimulator.update session textileMsg textileModel
                        |> toPage model Cmd.none TextileSimulatorPage TextileSimulatorMsg
                        |> trackUsage (TextileSimulator.shouldTrackUsage textileMsg)

                _ ->
                    ( model, Cmd.none )

        -- Url
        UrlChanged url ->
            ( { model | mobileNavigationOpened = False, url = url }, Cmd.none )
                |> setRoute url session page
                |> Tuple.mapSecond (\cmd -> Cmd.batch [ cmd, Plausible.send session <| Plausible.PageViewed url ])

        UrlRequested (Browser.Internal url) ->
            ( { model | url = url }, Nav.pushUrl session.navKey (Url.toString url) )

        UrlRequested (Browser.External href) ->
            ( model, Nav.load href )

        VersionPoll ->
            ( model, Version.loadVersion VersionReceived )

        -- Version check
        VersionReceived webData ->
            ( { model
                | state =
                    page
                        |> Loaded { session | currentVersion = Version.update session.currentVersion webData }
              }
            , Cmd.none
            )


updateGlobalApp : Session -> Page -> App.Msg -> Model -> ( Model, Cmd Msg )
updateGlobalApp session page msg model =
    case msg of
        App.AddToast notification ->
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

        App.CloseMobileNavigation ->
            ( { model | mobileNavigationOpened = False }, Cmd.none )

        App.CloseNotification notification ->
            ( { model
                | state =
                    page
                        |> Loaded (session |> Session.closeNotification notification)
              }
            , Cmd.none
            )

        App.LoadUrl url ->
            ( model, Nav.load url )

        App.OpenMobileNavigation ->
            ( { model | mobileNavigationOpened = True }, Cmd.none )

        App.ReloadPage ->
            ( model, Nav.reloadAndSkipCache )

        App.ResetSessionStore ->
            let
                newSession =
                    -- FIXME: remove notifications from session
                    { session | notifications = [], store = Session.defaultStore }
            in
            ( { model
                | feedbackModalOpen = False
                , state = page |> Loaded newSession
              }
            , Notification.info "La session a été réinitialisée."
                |> App.AddToast
                |> App.toCmd AppMsg
            )

        App.SwitchVersion version ->
            ( model
            , Nav.load <|
                "/versions/"
                    ++ version
                    ++ "/#"
                    ++ Maybe.withDefault "" model.url.fragment
            )

        -- Toast notifications
        App.ToastMsg toastMsg ->
            let
                ( newTray, newToastMsg ) =
                    Toast.update toastMsg model.tray
            in
            ( { model | tray = newTray }, Cmd.map (AppMsg << App.ToastMsg) newToastMsg )


updateDetailedProcess : BackendHttp.WebData String -> Session -> Page -> Model -> ( Model, Cmd Msg )
updateDetailedProcess remoteData session page model =
    case remoteData of
        RemoteData.Failure _ ->
            ( model
            , Notification.error "Erreur"
                "Impossible de charger les impacts détaillés; les impacts agrégés seront utilisés."
                |> App.AddToast
                |> App.toCmd AppMsg
            )

        RemoteData.Loading ->
            ( model, Cmd.none )

        RemoteData.NotAsked ->
            ( model, Cmd.none )

        RemoteData.Success rawDetailedProcessesJson ->
            let
                newSession =
                    session |> Session.updateDbProcesses rawDetailedProcessesJson
            in
            ( { model
                | state =
                    page
                        |> refreshCachedResults newSession
                        |> Loaded newSession
              }
            , Cmd.none
            )


trackUsage : Bool -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
trackUsage shouldTrack ( model, cmds ) =
    if not shouldTrack then
        ( model, cmds )

    else
        case model.state of
            Errored _ ->
                ( model, cmds )

            Initializing ->
                ( model, cmds )

            Loaded session currentPage ->
                let
                    ( openPrompt, newSession ) =
                        if session.store.usageCount < Env.usageThreshold then
                            let
                                usageCount =
                                    session.store.usageCount + 1
                            in
                            ( usageCount == Env.usageThreshold
                            , session |> Session.updateStore (\store -> { store | usageCount = usageCount })
                            )

                        else
                            ( False, session )
                in
                ( { model
                    | feedbackModalOpen = model.feedbackModalOpen || openPrompt
                    , state = Loaded newSession currentPage
                  }
                , cmds
                )


subscriptions : Model -> Sub Msg
subscriptions { feedbackModalOpen, state } =
    Sub.batch
        [ Ports.storeChanged StoreChanged
        , if feedbackModalOpen then
            Browser.Events.onKeyDown (Key.escape CloseFeedbackModal)

          else
            Sub.none
        , case state of
            Loaded { versionPollSeconds } _ ->
                Version.pollVersion versionPollSeconds VersionPoll

            _ ->
                Sub.none
        , case state of
            Loaded _ (ExplorePage subModel) ->
                Explore.subscriptions subModel
                    |> Sub.map ExploreMsg

            Loaded _ (FoodBuilderPage subModel) ->
                FoodBuilder.subscriptions subModel
                    |> Sub.map FoodBuilderMsg

            Loaded _ (GenericSimulatorPage subModel) ->
                GenericSimulator.subscriptions subModel
                    |> Sub.map GenericSimulatorMsg

            Loaded _ (TextileSimulatorPage subModel) ->
                TextileSimulator.subscriptions subModel
                    |> Sub.map TextileSimulatorMsg

            _ ->
                Sub.none
        ]


view : Model -> Document Msg
view { dbLoadingState, feedbackModalOpen, flags, mobileNavigationOpened, state, tray } =
    let
        defaultPageConfig =
            { activePage = Page.Other
            , clientUrl = flags.clientUrl
            , closeFeedbackModal = CloseFeedbackModal
            , currentVersion = Version.Unknown
            , enabledSections = flags.enabledSections
            , feedbackModalOpen = feedbackModalOpen
            , isAuthenticated = False
            , isSuperuser = False
            , mobileNavigationOpened = mobileNavigationOpened
            , notifications = []
            , termsAccepted = False
            , toMsg = AppMsg
            , tray = tray
            }
    in
    case state of
        Errored error ->
            Page.frame defaultPageConfig
                ( "Erreur"
                , [ Page.errored error ]
                )

        Initializing ->
            Page.frame defaultPageConfig
                ( "Chargement des données Ecobalyse"
                , [ Page.loading <| Just (RequestDb.getProgress dbLoadingState)
                  ]
                )

        Loaded session page ->
            let
                frame activePage =
                    Page.frame
                        { defaultPageConfig
                            | activePage = activePage
                            , currentVersion = session.currentVersion
                            , isAuthenticated = Session.isAuthenticated session
                            , isSuperuser = Session.isSuperuser session
                            , notifications = session.notifications
                            , termsAccepted = Session.hasAccessToDetailedImpacts session
                            , tray = tray
                        }

                mapMsg msg ( title, content ) =
                    ( title, content |> List.map (Html.map msg) )
            in
            case page of
                ApiPage _ ->
                    Api.view session
                        |> mapMsg ApiMsg
                        |> frame Page.Api

                AuthPage authModel ->
                    Auth.view session authModel
                        |> mapMsg AuthMsg
                        |> frame Page.Auth

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
                        |> frame Page.Food

                GenericSimulatorPage simulatorModel ->
                    GenericSimulator.view session simulatorModel
                        |> mapMsg GenericSimulatorMsg
                        |> frame (Page.Generic simulatorModel.genericScope)

                HomePage _ ->
                    Home.view session
                        |> mapMsg HomeMsg
                        |> frame Page.Home

                LoadingPage ->
                    ( "Chargement…", [ Page.loading Nothing ] )
                        |> frame Page.Other

                NotFoundPage ->
                    ( "404", [ Page.notFound ] )
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
