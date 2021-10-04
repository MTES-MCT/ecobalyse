module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Page.Editorial as Editorial
import Page.Examples as Examples
import Page.Home as Home
import Page.Simulator as Simulator
import Page.Stats as Stats
import Ports
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
    | SimulatorPage Simulator.Model
    | EditorialPage Editorial.Model
    | ExamplesPage Examples.Model
    | StatsPage Stats.Model
    | NotFoundPage


type alias Model =
    { page : Page
    , session : Session
    }


type Msg
    = HomeMsg Home.Msg
    | SimulatorMsg Simulator.Msg
    | EditorialMsg Editorial.Msg
    | ExamplesMsg Examples.Msg
    | StatsMsg Stats.Msg
    | StoreChanged String
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest


setRoute : Maybe Route -> Model -> Cmd Msg -> ( Model, Cmd Msg )
setRoute maybeRoute model cmds =
    let
        toPage page subInit subMsg =
            let
                ( subModel, newSession, subCmds ) =
                    subInit model.session

                storeCmd =
                    if model.session.store /= newSession.store then
                        newSession.store |> Session.serializeStore |> Ports.saveStore

                    else
                        Cmd.none
            in
            ( { model | session = newSession, page = page subModel }
            , Cmd.batch [ cmds, Ports.scrollTo { x = 0, y = 0 }, Cmd.map subMsg subCmds, storeCmd ]
            )
    in
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFoundPage }
            , Cmd.none
            )

        Just Route.Home ->
            toPage HomePage Home.init HomeMsg

        Just (Route.Simulator maybeQuery) ->
            toPage SimulatorPage (Simulator.init maybeQuery) SimulatorMsg

        Just (Route.Editorial slug) ->
            toPage EditorialPage (Editorial.init slug) EditorialMsg

        Just Route.Examples ->
            toPage ExamplesPage Examples.init ExamplesMsg

        Just Route.Stats ->
            toPage StatsPage Stats.init StatsMsg


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        session =
            { clientUrl = flags.clientUrl
            , navKey = navKey
            , store = Session.deserializeStore flags.rawStore
            }
    in
    setRoute (Route.fromUrl url)
        { page = BlankPage
        , session = session
        }
        (Ports.appStarted ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ page, session } as model) =
    let
        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newSession, newCmd ) =
                    subUpdate session subMsg subModel

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
        ( HomeMsg homeMsg, HomePage homeModel ) ->
            toPage HomePage HomeMsg Home.update homeMsg homeModel

        ( SimulatorMsg counterMsg, SimulatorPage counterModel ) ->
            toPage SimulatorPage SimulatorMsg Simulator.update counterMsg counterModel

        ( EditorialMsg editorialMsg, EditorialPage editorialModel ) ->
            toPage EditorialPage EditorialMsg Editorial.update editorialMsg editorialModel

        ( ExamplesMsg examplesMsg, ExamplesPage examplesModel ) ->
            toPage ExamplesPage ExamplesMsg Examples.update examplesMsg examplesModel

        ( StatsMsg statsMsg, StatsPage statsModel ) ->
            toPage StatsPage StatsMsg Stats.update statsMsg statsModel

        ( StoreChanged json, _ ) ->
            ( { model | session = { session | store = Session.deserializeStore json } }
            , Cmd.none
            )

        ( UrlRequested urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl session.navKey (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            setRoute (Route.fromUrl url) model Cmd.none

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

            SimulatorPage _ ->
                Sub.none

            EditorialPage _ ->
                Sub.none

            ExamplesPage _ ->
                Sub.none

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

        SimulatorPage counterModel ->
            Simulator.view session counterModel
                |> mapMsg SimulatorMsg
                |> Page.frame (pageConfig Page.Simulator)

        EditorialPage editorialModel ->
            Editorial.view session editorialModel
                |> mapMsg EditorialMsg
                |> Page.frame (pageConfig (Page.Editorial editorialModel.slug))

        ExamplesPage editorialModel ->
            Examples.view session editorialModel
                |> mapMsg ExamplesMsg
                |> Page.frame (pageConfig Page.Examples)

        StatsPage editorialModel ->
            Stats.view session editorialModel
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
