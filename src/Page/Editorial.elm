module Page.Editorial exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import List.Extra as LE
import Ports
import RemoteData exposing (WebData)
import Request.Common as RequestCommon
import Views.Alert as Alert
import Views.Container as Container
import Views.Markdown as Markdown
import Views.Spinner as Spinner


type alias Model =
    { slug : String
    , content : WebData String
    }


type Msg
    = ContentReceived (WebData String)


init : String -> Session -> ( Model, Session, Cmd Msg )
init slug session =
    ( { slug = slug, content = RemoteData.Loading }
    , session
    , Cmd.batch
        [ Ports.scrollTo { x = 0, y = 0 }
        , Http.get
            { url = "pages/" ++ slug ++ ".md"
            , expect =
                Http.expectString
                    (RemoteData.fromResult >> ContentReceived)
            }
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        ContentReceived content ->
            ( { model | content = content }, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    case model.content of
        RemoteData.Failure httpError ->
            ( "Erreur de chargement", [ Alert.serverError <| RequestCommon.errorToString httpError ] )

        RemoteData.Loading ->
            ( "Chargement…", [ Spinner.view ] )

        RemoteData.NotAsked ->
            ( "", [] )

        RemoteData.Success content ->
            ( content
                |> String.split "\n"
                |> List.head
                |> Maybe.andThen (String.split "# " >> LE.last)
                |> Maybe.withDefault "Sans titre"
            , [ Container.centered []
                    [ Markdown.simple [ class "pb-5" ] content
                    ]
              ]
            )
