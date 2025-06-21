module Page.Admin exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import App exposing (Msg, PageUpdate)
import Autocomplete exposing (Autocomplete)
import Base64
import Browser.Events
import Data.Component as Component exposing (Component, Index, Item, TargetItem)
import Data.Impact.Definition as Definition
import Data.Key as Key
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category)
import Data.Scope as Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import RemoteData
import Request.BackendHttp exposing (WebData)
import Request.BackendHttp.Error as BackendError
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
    , scopes : List Scope
    , modals : List Modal
    }


type Modal
    = DeleteComponentModal Component
    | EditComponentModal Component Item
    | SelectProcessModal Category TargetItem (Maybe Index) (Autocomplete Process)


type Msg
    = ComponentCreated (WebData Component)
    | ComponentDeleted (WebData ())
    | ComponentListResponse (WebData (List Component))
    | ComponentUpdated (WebData Component)
    | DuplicateComponent Component
    | NoOp
    | OnAutocompleteAddProcess Category TargetItem (Maybe Index) (Autocomplete.Msg Process)
    | OnAutocompleteSelectProcess Category TargetItem (Maybe Index)
    | SaveComponent
      -- TODO: use for notifications
      -- | SendParentMessage App.Msg
    | SetModals (List Modal)
    | UpdateComponent Item
    | UpdateScopeFilters (List Scope)


init : Session -> PageUpdate Model Msg
init session =
    { components = RemoteData.NotAsked
    , modals = []
    , scopes = Scope.all
    }
        |> App.createUpdate session
        |> App.withCmds [ ComponentApi.getComponents session ComponentListResponse ]


update : Session -> Msg -> Model -> PageUpdate Model Msg
update session msg model =
    case msg of
        -- POST
        ComponentCreated (RemoteData.Failure err) ->
            model
                |> App.createUpdate (session |> Session.notifyBackendError err)

        ComponentCreated (RemoteData.Success component) ->
            { model | modals = [ EditComponentModal component (Component.createItem component.id) ] }
                |> App.createUpdate session
                |> App.withCmds [ ComponentApi.getComponents session ComponentListResponse ]

        ComponentCreated _ ->
            App.createUpdate session model

        -- DELETE
        ComponentDeleted (RemoteData.Failure err) ->
            App.createUpdate (session |> Session.notifyBackendError err) model

        ComponentDeleted (RemoteData.Success _) ->
            App.createUpdate session model
                |> App.withCmds [ ComponentApi.getComponents session ComponentListResponse ]

        ComponentDeleted _ ->
            App.createUpdate session model

        -- GET
        ComponentListResponse response ->
            let
                newSession =
                    case response of
                        RemoteData.Success components ->
                            session |> Session.updateDb (\db -> { db | components = components })

                        _ ->
                            session
            in
            App.createUpdate newSession { model | components = response }

        -- PATCH
        ComponentUpdated (RemoteData.Failure err) ->
            App.createUpdate (session |> Session.notifyBackendError err) model

        ComponentUpdated (RemoteData.Success _) ->
            App.createUpdate session model
                |> App.withCmds [ ComponentApi.getComponents session ComponentListResponse ]

        ComponentUpdated _ ->
            App.createUpdate session model

        DuplicateComponent component ->
            App.createUpdate session model
                |> App.withCmds
                    [ { component | name = component.name ++ " (copie)" }
                        |> ComponentApi.createComponent session ComponentCreated
                    ]

        NoOp ->
            App.createUpdate session model

        OnAutocompleteAddProcess category targetItem maybeElementIndex autocompleteMsg ->
            case model.modals of
                [ SelectProcessModal _ _ _ autocompleteState, EditComponentModal component item ] ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    App.createUpdate session
                        { model
                            | modals =
                                [ SelectProcessModal category targetItem maybeElementIndex newAutocompleteState
                                , EditComponentModal component item
                                ]
                        }
                        |> App.withCmds
                            [ autoCompleteCmd
                                |> Cmd.map (OnAutocompleteAddProcess category targetItem maybeElementIndex)
                            ]

                _ ->
                    App.createUpdate session model

        OnAutocompleteSelectProcess category targetItem maybeElementIndex ->
            case model.modals of
                [ SelectProcessModal _ _ _ autocompleteState, EditComponentModal _ item ] ->
                    selectProcess category targetItem maybeElementIndex autocompleteState item model session

                _ ->
                    App.createUpdate session model

        SaveComponent ->
            case model.modals of
                [ DeleteComponentModal component ] ->
                    App.createUpdate session { model | modals = [] }
                        |> App.withCmds [ ComponentApi.deleteComponent session ComponentDeleted component ]

                [ EditComponentModal _ item ] ->
                    case Component.itemToComponent session.db item of
                        Err error ->
                            { model | modals = [] }
                                |> App.createUpdate (session |> Session.notifyError "Erreur" error)

                        Ok component ->
                            { model | modals = [] }
                                |> App.createUpdate session
                                |> App.withCmds [ ComponentApi.patchComponent session ComponentUpdated component ]

                _ ->
                    App.createUpdate session model

        -- TODO: should be used for notifications
        -- SendParentMessage appMsg ->
        --     App.createUpdate session model
        --         |> App.withAppMsg appMsg
        --
        --
        SetModals modals ->
            App.createUpdate session { model | modals = modals }

        UpdateComponent customItem ->
            case model.modals of
                (EditComponentModal component _) :: others ->
                    App.createUpdate session { model | modals = EditComponentModal component customItem :: others }

                _ ->
                    App.createUpdate session model

        UpdateScopeFilters scopes ->
            App.createUpdate session { model | scopes = scopes }


selectProcess :
    Category
    -> TargetItem
    -> Maybe Index
    -> Autocomplete Process
    -> Item
    -> Model
    -> Session
    -> PageUpdate Model Msg
selectProcess category (( component, _ ) as targetItem) maybeElementIndex autocompleteState item model session =
    case Autocomplete.selectedValue autocompleteState of
        Just process ->
            case
                [ item ]
                    |> Component.addOrSetProcess category targetItem maybeElementIndex process
                    |> Result.andThen (List.head >> Result.fromMaybe "Pas d'élément résultant")
            of
                Err err ->
                    App.createUpdate (session |> Session.notifyError "Erreur" err) model

                Ok updatedItem ->
                    App.createUpdate session { model | modals = [ EditComponentModal component updatedItem ] }

        Nothing ->
            App.createUpdate (session |> Session.notifyError "Erreur" "Aucun composant sélectionné") model


view : Session -> Model -> ( String, List (Html Msg) )
view { db } model =
    ( "admin"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "Ecobalyse Admin" ]
            , warning
            , model.scopes
                |> scopeFilterForm UpdateScopeFilters
            , model.components
                |> mapRemoteData (componentListView db model.scopes)
            , model.components
                |> mapRemoteData downloadDbButton
            , model.modals
                |> List.reverse
                |> List.map (modalView db model.modals)
                |> div []
            ]
      ]
    )


downloadDbButton : List Component -> Html Msg
downloadDbButton components =
    p [ class "text-end mt-3" ]
        [ a
            [ class "btn btn-primary"
            , download "components.json"
            , components
                |> Encode.list Component.encode
                |> Encode.encode 2
                |> Base64.encode
                |> (++) "data:application/json;base64,"
                |> href
            ]
            [ text "Exporter la base de données de composants" ]
        ]


componentListView : Db -> List Scope -> List Component -> Html Msg
componentListView db scopes components =
    Table.responsiveDefault []
        [ thead []
            [ tr []
                [ th [] [ text "Nom" ]
                , th [] [ text "Verticales" ]
                , th [ colspan 3 ] [ text "Description" ]
                ]
            ]
        , components
            |> Scope.allOf scopes
            |> List.map (componentRowView db)
            |> tbody []
        ]


componentRowView : Db -> Component -> Html Msg
componentRowView db component =
    tr []
        [ th [ class "align-middle" ]
            [ text component.name
            , small [ class "d-block fw-normal" ]
                [ code [] [ text (Component.idToString component.id) ] ]
            ]
        , td [ class "align-middle" ]
            [ component.scopes
                |> List.map
                    (Scope.toString
                        >> text
                        >> List.singleton
                        >> small [ class "badge bg-secondary fs-10" ]
                    )
                |> div []
            ]
        , td [ class "align-middle w-100" ]
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
        , td [ class "align-middle text-nowrap" ]
            [ div [ class "btn-group btn-group-sm", attribute "role" "group", attribute "aria-label" "Actions" ]
                [ button
                    [ class "btn btn-outline-primary"
                    , title "Modifier le composant"
                    , onClick <| SetModals [ EditComponentModal component (Component.createItem component.id) ]
                    ]
                    [ Icon.pencil ]
                , button
                    [ class "btn btn-outline-primary"
                    , title "Dupliquer le composant"
                    , onClick <| DuplicateComponent component
                    ]
                    [ Icon.copy ]
                , a
                    [ class "btn btn-outline-primary"
                    , title "Utiliser dans le simulateur"
                    , Just { components = [ Component.createItem component.id ] }
                        |> Route.ObjectSimulator Scope.Object Definition.Ecs
                        |> Route.href
                    ]
                    [ Icon.puzzle ]
                , a
                    [ class "btn btn-outline-primary"
                    , title "Exporter le composant au format JSON"
                    , Component.encode component
                        |> Encode.encode 2
                        |> Base64.encode
                        |> (++) "data:application/json;base64,"
                        |> href
                    , download <| component.name ++ ".json"
                    ]
                    [ Icon.fileExport ]
                , button
                    [ class "btn btn-outline-danger"
                    , title "Supprimer le composant"
                    , onClick <| SetModals [ DeleteComponentModal component ]
                    ]
                    [ Icon.trash ]
                ]
            ]
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

                EditComponentModal component item ->
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
                    , div [ class "d-flex flex-row justify-content-between align-items-center gap-3 w-100" ]
                        [ componentScopesForm component item
                        , button [ class "btn btn-primary" ] [ text "Sauvegarder le composant" ]
                        ]
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


componentScopesForm : Component -> Item -> Html Msg
componentScopesForm component item =
    item.custom
        |> Maybe.map .scopes
        |> Maybe.withDefault component.scopes
        |> scopesForm
            (\scope enabled ->
                item
                    |> Component.toggleCustomScope component scope enabled
                    |> UpdateComponent
            )


scopeFilterForm : (List Scope -> Msg) -> List Scope -> Html Msg
scopeFilterForm updateFilters filtered =
    scopesForm
        (\scope enabled ->
            if enabled then
                updateFilters (scope :: filtered)

            else
                updateFilters (List.filter ((/=) scope) filtered)
        )
        filtered


scopesForm : (Scope -> Bool -> Msg) -> List Scope -> Html Msg
scopesForm check scopes =
    div [ class "d-flex flex-row gap-3" ]
        [ h3 [ class "h6" ] [ text "Verticales" ]
        , Scope.all
            |> List.map
                (\scope ->
                    div [ class "form-check form-check-inline" ]
                        [ label [ class "form-check-label" ]
                            [ input
                                [ type_ "checkbox"
                                , class "form-check-input"
                                , checked <| List.member scope scopes
                                , onCheck <| check scope
                                ]
                                []
                            , text (Scope.toString scope)
                            ]
                        ]
                )
            |> div [ class "ScopeSelector" ]
        ]


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
            Alert.serverError <| BackendError.errorToString err

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
