module Page.Admin exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Autocomplete exposing (Autocomplete)
import Browser.Events
import Data.Component as Component exposing (Component, Index, Item, TargetItem)
import Data.Impact.Definition as Definition
import Data.Key as Key
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category)
import Data.Scope as Scope
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData exposing (WebData)
import Request.Common
import Request.Component as ComponentApi
import Route
import Static.Db exposing (Db)
import Views.Alert as Alert
import Views.AutocompleteSelector as AutocompleteSelectorView
import Views.Component as ComponentView
import Views.Container as Container
import Views.Format as Format
import Views.Icon as Icon
import Views.Modal as Modal
import Views.Spinner as Spinner
import Views.Table as Table


type alias Model =
    { components : WebData (List Component)
    , modals : List Modal
    }


type Modal
    = DeleteComponentModal Component
    | EditComponentModal Item
    | SelectProcessModal Category TargetItem (Maybe Index) (Autocomplete Process)


type Msg
    = ComponentDeleted (WebData String)
    | ComponentListResponse (WebData (List Component))
    | ComponentUpdated (WebData Component)
    | NoOp
    | OnAutocompleteAddProcess Category TargetItem (Maybe Index) (Autocomplete.Msg Process)
    | OnAutocompleteSelectProcess Category TargetItem (Maybe Index)
    | SaveComponent
    | SetModals (List Modal)
    | UpdateComponent Item


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { components = RemoteData.NotAsked
      , modals = []
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
            ( { model | components = response }
            , case response of
                RemoteData.Success components ->
                    session |> Session.updateDb (\db -> { db | components = components })

                _ ->
                    session
            , Cmd.none
            )

        -- PATCH
        ComponentUpdated (RemoteData.Failure err) ->
            ( model, session |> Session.notifyError "Erreur" (Request.Common.errorToString err), Cmd.none )

        ComponentUpdated (RemoteData.Success _) ->
            ( model, session, ComponentApi.getComponents session ComponentListResponse )

        ComponentUpdated _ ->
            ( model, session, Cmd.none )

        NoOp ->
            ( model, session, Cmd.none )

        OnAutocompleteAddProcess category targetItem maybeElementIndex autocompleteMsg ->
            case model.modals of
                [ SelectProcessModal _ _ _ autocompleteState, EditComponentModal item ] ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    ( { model
                        | modals =
                            [ SelectProcessModal category targetItem maybeElementIndex newAutocompleteState
                            , EditComponentModal item
                            ]
                      }
                    , session
                    , Cmd.map (OnAutocompleteAddProcess category targetItem maybeElementIndex) autoCompleteCmd
                    )

                _ ->
                    ( model, session, Cmd.none )

        OnAutocompleteSelectProcess category targetItem maybeElementIndex ->
            case model.modals of
                [ SelectProcessModal _ _ _ autocompleteState, EditComponentModal item ] ->
                    ( model, session, Cmd.none )
                        |> selectProcess category targetItem maybeElementIndex autocompleteState item

                _ ->
                    ( model, session, Cmd.none )

        SaveComponent ->
            case model.modals of
                [ DeleteComponentModal component ] ->
                    ( { model | modals = [] }
                    , session
                    , ComponentApi.deleteComponent session ComponentDeleted component
                    )

                [ EditComponentModal item ] ->
                    case Component.itemToComponent session.db item of
                        Err error ->
                            ( { model | modals = [] }
                            , session |> Session.notifyError "Erreur" error
                            , Cmd.none
                            )

                        Ok component ->
                            ( { model | modals = [] }
                            , session
                            , ComponentApi.patchComponent session ComponentUpdated component
                            )

                _ ->
                    ( model, session, Cmd.none )

        SetModals modals ->
            ( { model | modals = modals }, session, Cmd.none )

        UpdateComponent customItem ->
            case model.modals of
                (EditComponentModal _) :: others ->
                    ( { model | modals = EditComponentModal customItem :: others }, session, Cmd.none )

                _ ->
                    ( model, session, Cmd.none )


selectProcess :
    Category
    -> TargetItem
    -> Maybe Index
    -> Autocomplete Process
    -> Item
    -> ( Model, Session, Cmd Msg )
    -> ( Model, Session, Cmd Msg )
selectProcess category targetItem maybeElementIndex autocompleteState item ( model, session, _ ) =
    case Autocomplete.selectedValue autocompleteState of
        Just process ->
            case
                [ item ]
                    |> Component.addOrSetProcess category targetItem maybeElementIndex process
                    |> Result.andThen (List.head >> Result.fromMaybe "Pas d'élément résultant")
            of
                Err err ->
                    ( model, session |> Session.notifyError "Erreur" err, Cmd.none )

                Ok updatedItem ->
                    ( { model | modals = [ EditComponentModal updatedItem ] }, session, Cmd.none )

        Nothing ->
            ( model, session |> Session.notifyError "Erreur" "Aucun composant sélectionné", Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view { db } model =
    ( "admin"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "Ecobalyse Admin" ]
            , warning
            , model.components
                |> mapRemoteData (componentListView db)
            , model.modals
                |> List.reverse
                |> List.map (modalView db model.modals)
                |> div []
            ]
      ]
    )


componentListView : Db -> List Component -> Html Msg
componentListView db components =
    Table.responsiveDefault []
        [ thead []
            [ tr []
                [ th [] [ text "Nom" ]
                , th [] [ text "Description" ]
                , th [ colspan 4 ] []
                ]
            ]
        , components
            |> List.map
                (\component ->
                    tr []
                        [ th [ class "align-middle" ]
                            [ text component.name
                            , small [ class "d-block fw-normal" ]
                                [ code [] [ text (Component.idToString component.id) ] ]
                            ]
                        , td [ class "align-middle" ]
                            [ case Component.elementsToString db component of
                                Err error ->
                                    span [ class "text-danger" ] [ text <| "Erreur: " ++ error ]

                                Ok string ->
                                    text string
                            ]
                        , td [ class "align-middle text-end fw-bold" ]
                            [ component
                                |> Component.computeImpacts db.processes
                                |> Result.map
                                    (Component.extractImpacts
                                        >> Format.formatImpact (Definition.get Definition.Ecs db.definitions)
                                    )
                                |> Result.withDefault (text "N/A")
                            ]
                        , td [ class "align-middle px-0" ]
                            [ button
                                [ class "btn btn-sm btn-outline-primary"
                                , title "Modifier le composant"
                                , onClick <| SetModals [ EditComponentModal (Component.createItem component.id) ]
                                ]
                                [ Icon.pencil ]
                            ]
                        , td [ class "align-middle px-0" ]
                            [ a
                                [ class "btn btn-sm btn-outline-primary"
                                , title "Utiliser dans le simulateur"
                                , Just { components = [ Component.createItem component.id ] }
                                    |> Route.ObjectSimulator Scope.Object Definition.Ecs
                                    |> Route.href
                                ]
                                [ Icon.puzzle ]
                            ]
                        , td [ class "align-middle px-0" ]
                            [ button
                                [ class "btn btn-sm btn-outline-danger"
                                , title "Supprimer le composant"
                                , onClick <| SetModals [ DeleteComponentModal component ]
                                ]
                                [ Icon.trash ]
                            ]
                        ]
                )
            |> tbody []
        ]


modalView : Db -> List Modal -> Modal -> Html Msg
modalView db modals modal =
    let
        ( title, content, footer ) =
            case modal of
                DeleteComponentModal component ->
                    ( "Supprimer le composant"
                    , [ text "Êtes-vous sûr de vouloir supprimer le composant "
                      , strong [] [ text component.name ]
                      , text "\u{00A0}?"
                      ]
                    , button [ class "btn btn-danger" ] [ text "Supprimer" ]
                    )

                EditComponentModal item ->
                    ( "Modifier le composant"
                    , [ ComponentView.editorView
                            { addLabel = ""
                            , customizable = True
                            , db = db
                            , debug = False
                            , detailed = [ 0 ]
                            , docsUrl = Nothing
                            , explorerRoute = Nothing
                            , impact = db.definitions |> Definition.get Definition.Ecs
                            , items = [ item ]
                            , maxItems = Just 1
                            , noOp = NoOp
                            , openSelectComponentModal = \_ -> NoOp
                            , openSelectProcessModal =
                                \p ti ei s ->
                                    SetModals (SelectProcessModal p ti ei s :: modals)
                            , removeElement =
                                \targetElement ->
                                    item |> updateSingleItem (Component.removeElement targetElement)
                            , removeElementTransform =
                                \targetElement transformIndex ->
                                    item |> updateSingleItem (Component.removeElementTransform targetElement transformIndex)
                            , removeItem = \_ -> NoOp
                            , results =
                                [ item ]
                                    |> Component.compute db
                                    |> Result.withDefault Component.emptyResults
                            , scopes = Scope.all
                            , setDetailed = \_ -> NoOp
                            , title = ""
                            , updateElementAmount =
                                \targetElement ->
                                    Maybe.map
                                        (\amount ->
                                            item |> updateSingleItem (Component.updateElementAmount targetElement amount)
                                        )
                                        >> Maybe.withDefault NoOp
                            , updateItemName =
                                \targetItem name ->
                                    item |> updateSingleItem (Component.updateItemCustomName targetItem name)
                            , updateItemQuantity = \_ _ -> NoOp
                            }
                      ]
                    , button [ class "btn btn-primary" ] [ text "Sauvegarder" ]
                    )

                SelectProcessModal category targetItem maybeElementIndex autocompleteState ->
                    ( "Sélectionner un procédé"
                    , let
                        ( placeholderText, title_ ) =
                            case category of
                                Category.Material ->
                                    ( "tapez ici le nom d'une matière pour la rechercher"
                                    , "Sélectionnez une matière première"
                                    )

                                Category.Transform ->
                                    ( "tapez ici le nom d'un procédé de transformation pour le rechercher"
                                    , "Sélectionnez un procédé de transformation"
                                    )

                                _ ->
                                    ( "tapez ici le nom d'un procédé pour le rechercher"
                                    , "Sélectionnez un procédé"
                                    )
                      in
                      [ AutocompleteSelectorView.view
                            { autocompleteState = autocompleteState
                            , closeModal = SetModals <| List.drop 1 modals
                            , footer = []
                            , noOp = NoOp
                            , onAutocomplete = OnAutocompleteAddProcess category targetItem maybeElementIndex
                            , onAutocompleteSelect = OnAutocompleteSelectProcess category targetItem maybeElementIndex
                            , placeholderText = placeholderText
                            , title = title_
                            , toLabel = Process.getDisplayName
                            , toCategory = \_ -> ""
                            }
                      ]
                    , text ""
                    )
    in
    Modal.view
        { close = SetModals <| List.drop 1 modals
        , content = [ div [ class "card-body p-3" ] content ]
        , footer = [ footer ]
        , formAction = Just SaveComponent
        , noOp = NoOp
        , size = Modal.Large
        , subTitle = Nothing
        , title = title
        }


updateSingleItem : (List Item -> List Item) -> Item -> Msg
updateSingleItem fn item =
    item
        |> List.singleton
        |> fn
        |> List.head
        |> Maybe.withDefault item
        |> UpdateComponent


warning : Html msg
warning =
    Alert.simple
        { close = Nothing
        , content =
            [ small [ class "d-flex align-items-center gap-1" ]
                [ Icon.warning
                , text "Attention, la base de données mobilisée peut être réinitialisée à tout moment et vos modifications avec."
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
subscriptions model =
    case model.modals of
        [] ->
            Sub.none

        modals ->
            modals
                |> List.drop 1
                |> SetModals
                |> Key.escape
                |> Browser.Events.onKeyDown
