module Page.Admin exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Events
import Data.Component exposing (Component)
import Data.Key as Key
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData exposing (WebData)
import Request.Common
import Request.Component as ComponentApi
import Views.Alert as Alert
import Views.Container as Container
import Views.Icon as Icon
import Views.Modal as Modal
import Views.Spinner as Spinner
import Views.Table as Table


type alias Model =
    { components : WebData (List Component)
    , modal : Maybe Modal
    }


type Modal
    = DeleteComponentModal Component
    | EditComponentModal Component


type Msg
    = ComponentDeleted (WebData String)
    | ComponentListResponse (WebData (List Component))
    | ComponentUpdated (WebData Component)
    | NoOp
    | SaveComponent
    | SetModal (Maybe Modal)
    | UpdateComponent Component


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { components = RemoteData.NotAsked
      , modal = Nothing
      }
    , session
    , ComponentApi.getComponents session ComponentListResponse
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        -- DELETE
        ComponentDeleted (RemoteData.Failure err) ->
            ( model, session |> Session.notifyError "Erreur" (Request.Common.errorToString err), Cmd.none )

        ComponentDeleted (RemoteData.Success _) ->
            ( model, session, ComponentApi.getComponents session ComponentListResponse )

        ComponentDeleted _ ->
            ( model, session, Cmd.none )

        -- GET
        ComponentListResponse response ->
            ( { model | components = response }, session, Cmd.none )

        -- PATCH
        ComponentUpdated (RemoteData.Failure err) ->
            ( model, session |> Session.notifyError "Erreur" (Request.Common.errorToString err), Cmd.none )

        ComponentUpdated (RemoteData.Success _) ->
            ( model, session, ComponentApi.getComponents session ComponentListResponse )

        ComponentUpdated _ ->
            ( model, session, Cmd.none )

        NoOp ->
            ( model, session, Cmd.none )

        SaveComponent ->
            case model.modal of
                Just (DeleteComponentModal component) ->
                    ( { model | modal = Nothing }
                    , session
                    , ComponentApi.deleteComponent session ComponentDeleted component
                    )

                Just (EditComponentModal component) ->
                    ( { model | modal = Nothing }
                    , session
                    , ComponentApi.patchComponent session ComponentUpdated component
                    )

                Nothing ->
                    ( model, session, Cmd.none )

        SetModal modal ->
            ( { model | modal = modal }, session, Cmd.none )

        UpdateComponent newComponent ->
            case model.modal of
                Just (EditComponentModal _) ->
                    ( { model | modal = Just (EditComponentModal newComponent) }, session, Cmd.none )

                _ ->
                    ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "admin"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "Ecobalyse Admin" ]
            , warning
            , model.components
                |> mapRemoteData componentListView
            , model.modal
                |> Maybe.map modalView
                |> Maybe.withDefault (text "")
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
                                , onClick <| SetModal (Just (EditComponentModal component))
                                ]
                                [ Icon.pencil ]
                            ]
                        , td []
                            [ button
                                [ class "btn btn-sm btn-outline-danger"
                                , onClick <| SetModal (Just (DeleteComponentModal component))
                                ]
                                [ Icon.trash ]
                            ]
                        ]
                )
            |> tbody []
        ]


modalView : Modal -> Html Msg
modalView modal =
    Modal.view
        { close = SetModal Nothing
        , content =
            [ div [ class "card-body p-3" ] <|
                case modal of
                    DeleteComponentModal component ->
                        [ text "Êtes-vous sûr de vouloir supprimer le composant "
                        , strong [] [ text component.name ]
                        , text "\u{00A0}?"
                        ]

                    EditComponentModal component ->
                        [ label [] [ text "Nom du composant" ]
                        , input
                            [ type_ "text"
                            , class "form-control"
                            , value component.name
                            , onInput <| \name -> UpdateComponent { component | name = name }
                            ]
                            []
                        ]
            ]
        , footer =
            [ case modal of
                DeleteComponentModal _ ->
                    button [ class "btn btn-danger" ] [ text "Supprimer" ]

                EditComponentModal _ ->
                    button [ class "btn btn-primary" ] [ text "Sauvegarder" ]
            ]
        , formAction = Just SaveComponent
        , noOp = NoOp
        , size = Modal.Large
        , subTitle = Nothing
        , title =
            case modal of
                DeleteComponentModal _ ->
                    "Supprimer le composant"

                EditComponentModal _ ->
                    "Modifier le composant"
        }


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


subscriptions : Model -> Sub Msg
subscriptions { modal } =
    case modal of
        Nothing ->
            Sub.none

        _ ->
            Browser.Events.onKeyDown (Key.escape (SetModal Nothing))
