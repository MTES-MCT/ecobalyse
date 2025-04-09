module Page.Admin exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Component as Component exposing (Component)
import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData exposing (WebData)
import Request.Component as ComponentApi
import Views.Alert as Alert
import Views.Container as Container
import Views.Icon as Icon
import Views.Spinner as Spinner
import Views.Table as Table


type alias Model =
    { components : WebData (List Component) }


type Msg
    = ComponentListResponse (WebData (List Component))
    | EditComponent Component


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { components = RemoteData.NotAsked }
    , session
    , ComponentApi.getComponents session ComponentListResponse
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        ComponentListResponse response ->
            ( { model | components = response }, session, Cmd.none )

        EditComponent component ->
            ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "admin"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "Ecobalyse Admin" ]
            , warning
            , model.components
                |> mapRemoteData componentListView
            ]
      ]
    )


componentListView : List Component -> Html Msg
componentListView components =
    Table.responsiveDefault []
        [ components
            |> List.map
                (\component ->
                    tr []
                        [ th [ class "w-100" ] [ text component.name ]
                        , td []
                            [ button
                                [ class "btn btn-sm btn-outline-primary"
                                , onClick (EditComponent component)
                                ]
                                [ Icon.pencil ]
                            ]
                        ]
                )
            |> tbody []
        ]


warning : Html msg
warning =
    Alert.simple
        { close = Nothing
        , content =
            [ small [ class "d-flex align-items-center gap-1" ]
                [ Icon.warning
                , text "Attention, la modification de ces données ne sera pas immédiatement prise en compte dans le reste de l'application"
                ]
            ]
        , level = Alert.Warning
        , title = Nothing
        }


mapRemoteData : (a -> Html msg) -> WebData a -> Html msg
mapRemoteData fn webData =
    case webData of
        RemoteData.Failure err ->
            Alert.httpError err

        RemoteData.Loading ->
            Spinner.view

        RemoteData.NotAsked ->
            text ""

        RemoteData.Success data ->
            fn data
