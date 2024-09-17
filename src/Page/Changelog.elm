module Page.Changelog exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Github as Github
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Ports
import RemoteData exposing (WebData)
import Request.Github as GithubApi
import Time
import Views.Alert as Alert
import Views.Container as Container
import Views.Markdown as Markdown
import Views.Spinner as SpinnerView


type Msg
    = ReleasesReceived (WebData (List Github.Release))


type alias Model =
    { releases : WebData (List Github.Release)
    , time : Time.Posix
    }


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { releases = RemoteData.NotAsked, time = Time.millisToPosix 0 }
    , session
    , Cmd.batch
        [ Ports.scrollTo { x = 0, y = 0 }
        , GithubApi.getReleases ReleasesReceived
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        ReleasesReceived releases ->
            ( { model | releases = releases }
            , session
            , Cmd.none
            )


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Changelog"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "Changelog" ]
            , case model.releases of
                RemoteData.Failure error ->
                    Alert.httpError error

                RemoteData.Success releases ->
                    releases
                        |> List.map (.markdown >> Markdown.simple [])
                        |> div []

                _ ->
                    SpinnerView.view
            ]
      ]
    )
