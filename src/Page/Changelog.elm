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
import List.Extra as LE
import Ports
import RemoteData exposing (WebData)
import Request.Github as GithubApi
import Task
import Time
import Time.Distance as TimeDistance
import Time.Distance.I18n as TimeDistanceI18n
import Views.Alert as Alert
import Views.Container as Container
import Views.Link as Link
import Views.Markdown as Markdown
import Views.Spinner as SpinnerView
import Views.Table as TableView


type Msg
    = ChangelogReceived (WebData (List Github.Commit))
    | NewTime Time.Posix


type alias Model =
    { changelog : WebData (List Github.Commit)
    , time : Time.Posix
    }


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { changelog = RemoteData.NotAsked, time = Time.millisToPosix 0 }
    , session
    , Cmd.batch
        [ Ports.scrollTo { x = 0, y = 0 }
        , GithubApi.getChangelog session ChangelogReceived
        , Task.perform NewTime Time.now
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        ChangelogReceived changelog ->
            ( { model | changelog = changelog }
            , session
            , Cmd.none
            )

        NewTime posix ->
            ( { model | time = posix }
            , session
            , Cmd.none
            )


commitView : Time.Posix -> Github.Commit -> Html msg
commitView time commit =
    let
        ( first, rest ) =
            commit.message
                |> String.split "\n"
                |> List.map String.trim
                |> List.filter (String.isEmpty >> not)
                |> LE.splitAt 1

        title =
            List.head first |> Maybe.withDefault "Untitled commit"
    in
    tr []
        [ td []
            [ if List.length rest > 0 then
                details []
                    [ summary [] [ text title ]
                    , pre [ class "ms-3 mt-2 mb-0" ]
                        [ rest
                            |> String.join "\n"
                            |> Markdown.simple []
                        ]
                    ]

              else
                text title
            ]
        , td [ class "text-nowrap" ]
            [ img
                [ src commit.authorAvatar
                , alt commit.authorName
                , attribute "crossorigin" "anonymous"
                , width 24
                , class "rounded-circle shadow-sm align-top me-2"
                ]
                []
            , text commit.authorName
            ]
        , td []
            [ Link.external
                [ class "text-decoration-none"
                , href <| "https://github.com/MTES-MCT/ecobalyse/commit/" ++ commit.sha
                ]
                [ time
                    |> TimeDistance.inWordsWithConfig { withAffix = True } TimeDistanceI18n.fr commit.date
                    |> text
                ]
            ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Changelog"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "Changelog" ]
            , case model.changelog of
                RemoteData.Success commits ->
                    TableView.responsiveDefault []
                        [ thead []
                            [ tr []
                                [ th [] [ text "Quoi" ]
                                , th [] [ text "Qui" ]
                                , th [] [ text "Quand" ]
                                ]
                            ]
                        , commits
                            |> List.map (commitView model.time)
                            |> tbody []
                        ]

                RemoteData.Failure error ->
                    Alert.httpError error

                RemoteData.Loading ->
                    SpinnerView.view

                RemoteData.NotAsked ->
                    text ""
            ]
      ]
    )
