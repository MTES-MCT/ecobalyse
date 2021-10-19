module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Data.Db as Db exposing (Db)
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Page.Changelog as Changelog
import Page.Editorial as Editorial
import Page.Examples as Examples
import Page.Home as Home
import Page.Simulator as Simulator
import Page.Stats as Stats
import Ports
import RemoteData exposing (WebData)
import Request.Db
import Route exposing (Route)
import Url exposing (Url)
import Views.Page as Page


type alias Flags =
    { clientUrl : String
    , rawStore : String
    }


type Page
    = BlankPage
    | HomePage Home.Model
    | ChangelogPage Changelog.Model
    | EditorialPage Editorial.Model
    | ExamplesPage Examples.Model
    | SimulatorPage Simulator.Model
    | StatsPage Stats.Model
    | NotFoundPage


type alias Model =
    { page : Page
    , session : Session
    }


type Msg
    = DbReceived Url (WebData Db)
    | HomeMsg Home.Msg
    | ChangelogMsg Changelog.Msg
    | EditorialMsg Editorial.Msg
    | ExamplesMsg Examples.Msg
    | SimulatorMsg Simulator.Msg
    | StatsMsg Stats.Msg
    | StoreChanged String
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        session =
            { clientUrl = flags.clientUrl
            , navKey = navKey
            , store = Session.deserializeStore flags.rawStore
            , db = Db.empty
            , notifications = []
            }
    in
    ( { page = BlankPage, session = session }
    , Cmd.batch
        [ Ports.appStarted ()
        , Request.Db.loadDb session (DbReceived url)
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
                , Ports.scrollTo { x = 0, y = 0 }
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

        Just Route.Changelog ->
            Changelog.init session
                |> toPage ChangelogPage ChangelogMsg

        Just (Route.Editorial slug) ->
            Editorial.init slug session
                |> toPage EditorialPage EditorialMsg

        Just Route.Examples ->
            Examples.init session
                |> toPage ExamplesPage ExamplesMsg

        Just (Route.Simulator maybeQuery) ->
            Simulator.init maybeQuery session
                |> toPage SimulatorPage SimulatorMsg

        Just Route.Stats ->
            Stats.init session
                |> toPage StatsPage StatsMsg


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

        ( ChangelogMsg changelogMsg, ChangelogPage changelogModel ) ->
            Changelog.update session changelogMsg changelogModel
                |> toPage ChangelogPage ChangelogMsg

        ( EditorialMsg editorialMsg, EditorialPage editorialModel ) ->
            Editorial.update session editorialMsg editorialModel
                |> toPage EditorialPage EditorialMsg

        ( ExamplesMsg examplesMsg, ExamplesPage examplesModel ) ->
            Examples.update session examplesMsg examplesModel
                |> toPage ExamplesPage ExamplesMsg

        ( SimulatorMsg counterMsg, SimulatorPage counterModel ) ->
            Simulator.update session counterMsg counterModel
                |> toPage SimulatorPage SimulatorMsg

        ( StatsMsg statsMsg, StatsPage statsModel ) ->
            Stats.update session statsMsg statsModel
                |> toPage StatsPage StatsMsg

        -- Db
        ( DbReceived url (RemoteData.Success db), _ ) ->
            -- Db successfully loaded, attach it to session and process to requested page.
            -- That way, the page will always access a fully loaded Db.
            setRoute (Route.fromUrl url)
                ( { model | session = { session | db = db } }, Cmd.none )

        ( DbReceived url (RemoteData.Failure httpError), _ ) ->
            setRoute (Route.fromUrl url)
                ( { model
                    | session =
                        session
                            |> Session.notifyHttpError "Erreur lors du chargement des données" httpError
                  }
                , Cmd.none
                )

        -- Store
        ( StoreChanged json, _ ) ->
            ( { model | session = { session | store = Session.deserializeStore json } }, Cmd.none )

        -- Url
        ( UrlChanged url, _ ) ->
            ( model, Cmd.none )
                |> setRoute (Route.fromUrl url)

        ( UrlRequested (Browser.Internal url), _ ) ->
            ( model, Nav.pushUrl session.navKey (Url.toString url) )

        ( UrlRequested (Browser.External href), _ ) ->
            ( model, Nav.load href )

        -- Catch-all
        ( _, NotFoundPage ) ->
            ( { model | page = NotFoundPage }, Cmd.none )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.storeChanged StoreChanged
        , case model.page of
            HomePage _ ->
                Sub.none

            ChangelogPage _ ->
                Sub.none

            EditorialPage _ ->
                Sub.none

            ExamplesPage _ ->
                Sub.none

            SimulatorPage subModel ->
                Simulator.subscriptions subModel
                    |> Sub.map SimulatorMsg

            StatsPage _ ->
                Sub.none

            NotFoundPage ->
                Sub.none

            BlankPage ->
                Sub.none
        ]


view : Model -> Document Msg
view { page, session } =
    let
        pageConfig =
            Page.Config session

        mapMsg msg ( title, content ) =
            ( title, content |> List.map (Html.map msg) )
    in
    case page of
        HomePage homeModel ->
            Home.view session homeModel
                |> mapMsg HomeMsg
                |> Page.frame (pageConfig Page.Home)

        ChangelogPage changelogModel ->
            Changelog.view session changelogModel
                |> mapMsg ChangelogMsg
                |> Page.frame (pageConfig Page.Changelog)

        EditorialPage editorialModel ->
            Editorial.view session editorialModel
                |> mapMsg EditorialMsg
                |> Page.frame (pageConfig (Page.Editorial editorialModel.slug))

        ExamplesPage examplesModel ->
            Examples.view session examplesModel
                |> mapMsg ExamplesMsg
                |> Page.frame (pageConfig Page.Examples)

        SimulatorPage simulatorModel ->
            Simulator.view session simulatorModel
                |> mapMsg SimulatorMsg
                |> Page.frame (pageConfig Page.Simulator)

        StatsPage statsModel ->
            Stats.view session statsModel
                |> mapMsg StatsMsg
                |> Page.frame (pageConfig Page.Stats)

        NotFoundPage ->
            ( "Not Found", [ Page.notFound ] )
                |> Page.frame (pageConfig Page.Other)

        BlankPage ->
            ( "", [] )
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
