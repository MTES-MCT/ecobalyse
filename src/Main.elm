module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Data.Food.Builder.Db as BuilderDb
import Data.Food.Builder.Query as FoodQuery
import Data.Food.Explorer.Db as ExplorerDb
import Data.Session as Session exposing (Session)
import Data.Textile.Db as Db exposing (Db)
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
import Request.Textile.Db
import Request.Version
import Route exposing (Route)
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


type alias Model =
    { page : Page
    , session : Session
    , mobileNavigationOpened : Bool
    }


type Msg
    = ApiMsg Api.Msg
    | ChangelogMsg Changelog.Msg
    | CloseMobileNavigation
    | CloseNotification Session.Notification
    | EditorialMsg Editorial.Msg
    | ExploreMsg Explore.Msg
    | FoodExploreMsg FoodExplore.Msg
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
        session =
            { clientUrl = flags.clientUrl
            , navKey = navKey
            , store = Session.deserializeStore flags.rawStore
            , currentVersion = Request.Version.Unknown
            , db = Db.empty
            , builderDb = BuilderDb.empty
            , explorerDb = ExplorerDb.empty
            , notifications = []
            , queries =
                { food = FoodQuery.carrotCake
                , textile = TextileInputs.defaultQuery
                }
            }
    in
    ( { page = BlankPage
      , mobileNavigationOpened = False
      , session = session
      }
    , Cmd.batch
        [ Ports.appStarted ()
        , Request.Textile.Db.loadDb session (TextileDbReceived url)
        , Request.Version.loadVersion VersionReceived
        ]
    )


setRoute : Maybe Route -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
setRoute maybeRoute ( { session } as model, cmds ) =
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
            ( { model | session = newSession, page = page subModel }
            , Cmd.batch
                [ cmds
                , Cmd.map subMsg subCmds
                , storeCmd
                ]
            )
    in
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFoundPage }, Cmd.none )

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
            Explore.init scope dataset session
                |> toPage ExplorePage ExploreMsg

        Just (Route.FoodBuilder trigram maybeQuery) ->
            FoodBuilder.init session trigram maybeQuery
                |> toPage FoodBuilderPage FoodBuilderMsg

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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ page, session } as model) =
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
            ( { model | session = newSession, page = toModel newModel }
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
        ( FoodBuilderMsg foodMsg, FoodBuilderPage foodModel ) ->
            FoodBuilder.update session foodMsg foodModel
                |> toPage FoodBuilderPage FoodBuilderMsg

        ( FoodExploreMsg foodMsg, FoodExplorePage foodModel ) ->
            FoodExplore.update session foodMsg foodModel
                |> toPage FoodExplorePage FoodExploreMsg

        -- Textile
        ( TextileDbReceived url (RemoteData.Success db), _ ) ->
            -- Db successfully loaded, attach it to session and process to requested page.
            -- That way, the page will always access a fully loaded Db.
            setRoute (Route.fromUrl url)
                ( { model | session = { session | db = db } }, Cmd.none )

        ( TextileDbReceived url (RemoteData.Failure httpError), _ ) ->
            setRoute (Route.fromUrl url)
                ( { model | session = session |> Session.notifyHttpError httpError }
                , Cmd.none
                )

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
        ( CloseNotification notification, _ ) ->
            ( { model | session = session |> Session.closeNotification notification }, Cmd.none )

        -- Store
        ( StoreChanged json, _ ) ->
            ( { model | session = { session | store = Session.deserializeStore json } }, Cmd.none )

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
                |> setRoute (Route.fromUrl url)

        ( UrlRequested (Browser.Internal url), _ ) ->
            ( model, Nav.pushUrl session.navKey (Url.toString url) )

        ( UrlRequested (Browser.External href), _ ) ->
            ( model, Nav.load href )

        -- Version check
        ( VersionReceived webData, _ ) ->
            ( { model | session = { session | currentVersion = Request.Version.updateVersion session.currentVersion webData } }, Cmd.none )

        ( VersionPoll, _ ) ->
            ( model, Request.Version.loadVersion VersionReceived )

        -- Catch-all
        ( _, NotFoundPage ) ->
            ( { model | page = NotFoundPage }, Cmd.none )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.storeChanged StoreChanged
        , Request.Version.pollVersion VersionPoll
        , case model.page of
            HomePage subModel ->
                Home.subscriptions subModel
                    |> Sub.map HomeMsg

            ApiPage _ ->
                Sub.none

            ChangelogPage _ ->
                Sub.none

            EditorialPage _ ->
                Sub.none

            ExplorePage subModel ->
                Explore.subscriptions subModel
                    |> Sub.map ExploreMsg

            FoodBuilderPage subModel ->
                FoodBuilder.subscriptions subModel
                    |> Sub.map FoodBuilderMsg

            FoodExplorePage _ ->
                Sub.none

            TextileExamplesPage _ ->
                Sub.none

            TextileSimulatorPage subModel ->
                TextileSimulator.subscriptions subModel
                    |> Sub.map TextileSimulatorMsg

            StatsPage _ ->
                Sub.none

            NotFoundPage ->
                Sub.none

            BlankPage ->
                Sub.none
        ]


view : Model -> Document Msg
view { page, mobileNavigationOpened, session } =
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
