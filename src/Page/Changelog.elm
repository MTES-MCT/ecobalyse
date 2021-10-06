module Page.Changelog exposing (..)

import Data.Github as Github
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import List.Extra as LE
import RemoteData exposing (WebData)
import Request.Common as HttpCommon
import Request.Github as GithubApi
import Task
import Time
import Time.Distance as TimeDistance
import Time.Distance.I18n as TimeDistanceI18n
import Views.Container as Container
import Views.Link as Link
import Views.Spinner as SpinnerView


type Msg
    = ChangelogReceived (WebData (List Github.Commit))
    | NewTime Time.Posix


type alias Model =
    { changelog : WebData (List Github.Commit)
    , time : Maybe Time.Posix
    }


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { changelog = RemoteData.NotAsked, time = Just (Time.millisToPosix 0) }
    , session
    , Cmd.batch
        [ GithubApi.getChangelog session ChangelogReceived
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
            ( { model | time = Just posix }
            , session
            , Cmd.none
            )


commitView : Maybe Time.Posix -> Github.Commit -> Html msg
commitView maybeTime commit =
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
    div [ class "list-group-item list-group-item-action" ]
        [ div [ class "d-flex w-100 justify-content-between" ]
            [ div []
                [ h5 [ class "m-0" ]
                    [ img
                        [ src commit.authorAvatar
                        , alt commit.authorName
                        , width 24
                        , class "rounded-circle shadow-sm align-top me-2"
                        ]
                        []
                    , Link.external [ class "text-decoration-none", href commit.sha ]
                        [ text title ]
                    ]
                , if List.length rest > 0 then
                    rest
                        |> List.map (\item -> li [] [ item |> String.replace "* " "" |> text ])
                        |> ul [ class "mt-2 mb-0" ]

                  else
                    text ""
                ]
            , small []
                [ text <| "Par " ++ commit.authorName ++ " "
                , case maybeTime of
                    Just time ->
                        TimeDistance.inWordsWithConfig { withAffix = True }
                            TimeDistanceI18n.fr
                            commit.date
                            time
                            |> text

                    Nothing ->
                        text ""
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
                    commits
                        |> List.map (commitView model.time)
                        |> div [ class "list-group" ]

                RemoteData.Failure error ->
                    div [ class "alert alert-danger" ]
                        [ text <| HttpCommon.errorToString error ]

                RemoteData.Loading ->
                    SpinnerView.view

                RemoteData.NotAsked ->
                    text ""
            ]
      ]
    )
