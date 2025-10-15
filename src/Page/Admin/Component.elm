module Page.Admin.Component exposing
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
import Data.JournalEntry as JournalEntry exposing (JournalEntry)
import Data.Key as Key
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category)
import Data.Scope as Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Data.Text as Text
import Data.Unit as Unit
import Diff
import Diff.ToString as DiffToString
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Page.Admin.Section as AdminSection
import Ports
import RemoteData
import Request.BackendHttp exposing (WebData)
import Request.Component as ComponentApi
import Route
import Static.Db exposing (Db)
import Views.Admin as AdminView
import Views.Alert as Alert
import Views.AutocompleteSelector as AutocompleteSelectorView
import Views.Component as ComponentView
import Views.Container as Container
import Views.Format as Format
import Views.Icon as Icon
import Views.Modal as Modal
import Views.Scope as ScopeView
import Views.Table as Table
import Views.WebData as WebDataView


type alias Model =
    { components : WebData (List Component)
    , scopes : List Scope
    , search : String
    , section : AdminSection.Section
    , selected : List Component.Id
    , modals : List Modal
    }


type Modal
    = DeleteComponentModal Component
    | EditComponentModal Component Item
    | HistoryModal (WebData (List (JournalEntry Component)))
    | JournalEntryModal (JournalEntry Component)
    | SelectProcessModal Category TargetItem (Maybe Index) (Autocomplete Process)


type Msg
    = ComponentCreated (WebData Component)
    | ComponentDeleted (WebData ())
    | ComponentEditResponse (WebData Component)
    | ComponentJournalResponse (WebData (List (JournalEntry Component)))
    | ComponentListResponse (WebData (List Component))
    | ComponentUpdated (WebData Component)
    | DuplicateComponent Component
    | NoOp
    | OnAutocompleteAddProcess Category TargetItem (Maybe Index) (Autocomplete.Msg Process)
    | OnAutocompleteSelectProcess Category TargetItem (Maybe Index)
    | OpenEditModal Component
    | OpenHistoryModal Component
    | OpenJournalEntryModal (JournalEntry Component)
    | SaveComponent
    | SetModals (List Modal)
    | ToggleSelected Component.Id Bool
    | ToggleSelectedAll Bool
    | UpdateComponent Item
    | UpdateComponentComment String
    | UpdateScopeFilters (List Scope)
    | UpdateSearch String


init : Session -> AdminSection.Section -> PageUpdate Model Msg
init session section =
    { components = RemoteData.Loading
    , modals = []
    , scopes = Scope.all
    , search = ""
    , section = section
    , selected = []
    }
        |> App.createUpdate session
        |> App.withCmds [ ComponentApi.getComponents session ComponentListResponse ]


update : Session -> Msg -> Model -> PageUpdate Model Msg
update session msg model =
    case msg of
        ComponentCreated (RemoteData.Failure err) ->
            model
                |> App.createUpdate (session |> Session.notifyBackendError err)

        ComponentCreated (RemoteData.Success component) ->
            { model | modals = [ EditComponentModal component (Component.createItem component.id) ] }
                |> App.createUpdate session
                |> App.withCmds [ ComponentApi.getComponents session ComponentListResponse ]

        ComponentCreated _ ->
            App.createUpdate session model

        ComponentDeleted (RemoteData.Failure err) ->
            App.createUpdate (session |> Session.notifyBackendError err) model

        ComponentDeleted (RemoteData.Success _) ->
            App.createUpdate session model
                |> App.withCmds [ ComponentApi.getComponents session ComponentListResponse ]

        ComponentDeleted _ ->
            App.createUpdate session model

        ComponentEditResponse (RemoteData.Success component) ->
            { model | modals = [ EditComponentModal component (Component.createItem component.id) ] }
                |> App.createUpdate session

        ComponentEditResponse (RemoteData.Failure err) ->
            App.createUpdate (session |> Session.notifyBackendError err) model

        ComponentEditResponse _ ->
            App.createUpdate session model

        ComponentJournalResponse response ->
            { model | modals = [ HistoryModal response ] }
                |> App.createUpdate session

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

        OpenEditModal component ->
            { model | modals = [] }
                |> App.createUpdate session
                |> App.withCmds [ ComponentApi.getComponent session ComponentEditResponse component.id ]

        OpenHistoryModal component ->
            { model | modals = [ HistoryModal RemoteData.Loading ] }
                |> App.createUpdate session
                |> App.withCmds [ ComponentApi.getJournal session ComponentJournalResponse component.id ]

        OpenJournalEntryModal journalEntry ->
            { model | modals = JournalEntryModal journalEntry :: model.modals }
                |> App.createUpdate session

        SaveComponent ->
            case model.modals of
                [ DeleteComponentModal component ] ->
                    App.createUpdate session { model | modals = [] }
                        |> App.withCmds [ ComponentApi.deleteComponent session ComponentDeleted component ]

                [ EditComponentModal { comment } item ] ->
                    case Component.itemToComponent session.db item of
                        Err error ->
                            { model | modals = [] }
                                |> App.createUpdate session
                                |> App.notifyError "Erreur lors de la sauvegarde du composant" error

                        Ok component ->
                            { model | modals = [] }
                                |> App.createUpdate session
                                |> App.withCmds [ ComponentApi.patchComponent session ComponentUpdated { component | comment = comment } ]
                                |> App.notifySuccess "Composant sauvegardé"

                _ ->
                    App.createUpdate session model

        SetModals modals ->
            { model | modals = modals }
                |> App.createUpdate session
                |> App.withCmds [ commandsForModal modals ]

        ToggleSelected componentId add ->
            { model | selected = model.selected |> AdminView.toggleSelected componentId add }
                |> App.createUpdate session

        ToggleSelectedAll flag ->
            { model | selected = model.components |> AdminView.selectAll flag }
                |> App.createUpdate session

        UpdateComponent customItem ->
            model
                |> updateComponent customItem
                |> App.createUpdate session

        UpdateComponentComment comment ->
            model
                |> updateComponentComment comment
                |> App.createUpdate session

        UpdateScopeFilters scopes ->
            App.createUpdate session { model | scopes = scopes }

        UpdateSearch search ->
            App.createUpdate session { model | search = String.toLower search }


updateComponent : Item -> Model -> Model
updateComponent customItem model =
    case model.modals of
        (EditComponentModal component _) :: others ->
            { model | modals = EditComponentModal component customItem :: others }

        _ ->
            model


updateComponentComment : String -> Model -> Model
updateComponentComment comment model =
    case model.modals of
        (EditComponentModal component item) :: others ->
            { model | modals = EditComponentModal { component | comment = Just comment } item :: others }

        _ ->
            model


commandsForModal : List Modal -> Cmd Msg
commandsForModal modals =
    case modals of
        [] ->
            Ports.removeBodyClass "prevent-scrolling"

        _ ->
            Ports.addBodyClass "prevent-scrolling"


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
                    App.createUpdate session model
                        |> App.notifyError "Erreur de sélection" err

                Ok updatedItem ->
                    App.createUpdate session { model | modals = [ EditComponentModal component updatedItem ] }

        Nothing ->
            App.createUpdate session model
                |> App.notifyError "Erreur de sélection" "Aucun composant sélectionné"


view : Session -> Model -> ( String, List (Html Msg) )
view { db } model =
    ( "Admin Composants"
    , [ Container.centered [ class "d-flex flex-column gap-3 pb-5" ]
            [ AdminView.header model.section
            , warning
            , AdminView.scopedSearchForm
                { scopes = model.scopes
                , search = UpdateSearch
                , searched = model.search
                , updateScopes = UpdateScopeFilters
                }
            , model.components
                |> WebDataView.map
                    (processFilters model.scopes model.search
                        >> componentListView db model.selected
                    )
            , model.components
                |> WebDataView.map (AdminView.downloadElementsButton "components.json" Component.encode model.selected)
            , model.modals
                |> List.indexedMap (modalView db model.modals)
                |> div []
            ]
      ]
    )


processFilters : List Scope -> String -> List Component -> List Component
processFilters scopes search =
    (if scopes == [] then
        List.filter (\p -> p.scopes == [])

     else
        Scope.anyOf scopes
    )
        >> Text.search
            { minQueryLength = 2
            , query = search
            , sortBy = Nothing
            , toString = .name
            }


componentListView : Db -> List Component.Id -> List Component -> Html Msg
componentListView db selected components =
    Table.responsiveDefault []
        [ thead []
            [ tr []
                [ th [ class "align-start text-center" ]
                    [ AdminView.selectAllCheckbox ToggleSelectedAll components selected
                    ]
                , th [] [ label [ for AdminView.selectAllId ] [ text "Nom" ] ]
                , th [] [ text "Verticales" ]
                , th [ colspan 3 ] [ text "Description" ]
                ]
            ]
        , components
            |> List.map (componentRowView db selected)
            |> tbody []
        ]


componentRowView : Db -> List Component.Id -> Component -> Html Msg
componentRowView db selected component =
    tr []
        [ td [ class "align-start text-center" ]
            [ selected
                |> AdminView.toggleElementCheckbox Component.idToString ToggleSelected component.id
            ]
        , th [ class "align-middle" ]
            [ label [ for <| AdminView.toggleElementId Component.idToString component.id ]
                [ text component.name ]
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
                    , onClick <| OpenEditModal component
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
                    , Just
                        { components = [ Component.createItem component.id ]
                        , durability = Unit.ratio 1
                        }
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
                    [ class "btn btn-outline-primary"
                    , title "Historique des modifications"
                    , onClick <| OpenHistoryModal component
                    ]
                    [ Icon.list ]
                , button
                    [ class "btn btn-outline-danger"
                    , title "Supprimer le composant"
                    , onClick <| SetModals [ DeleteComponentModal component ]
                    ]
                    [ Icon.trash ]
                ]
            ]
        ]


modalView : Db -> List Modal -> Int -> Modal -> Html Msg
modalView db modals index modal =
    let
        { title, content, footer, size } =
            case modal of
                DeleteComponentModal component ->
                    { title = "Supprimer le composant"
                    , content =
                        [ div [ class "card-body p-3" ]
                            [ text "Êtes-vous sûr de vouloir supprimer le composant "
                            , strong [] [ text component.name ]
                            , text "\u{00A0}?"
                            ]
                        ]
                    , footer = [ button [ class "btn btn-danger" ] [ text "Supprimer" ] ]
                    , size = Modal.Large
                    }

                EditComponentModal component item ->
                    { title = "Modifier le composant"
                    , content =
                        [ ComponentView.editorView
                            { addLabel = ""
                            , customizable = True
                            , db = db
                            , debug = False
                            , detailed = [ 0 ]
                            , docsUrl = Nothing
                            , explorerRoute = Nothing
                            , impact = db.definitions |> Definition.get Definition.Ecs
                            , items = [ item ]
                            , lifeCycle =
                                [ item ]
                                    |> Component.compute db
                                    |> Result.withDefault Component.emptyLifeCycle
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
                        , div [ class "p-3 pt-2" ]
                            [ label [ class "form-label fw-bold", for "comment" ] [ text "Commentaire" ]
                            , textarea
                                [ class "form-control"
                                , id "comment"
                                , placeholder "Ce composant est utilisé pour…"
                                , rows 3
                                , onInput UpdateComponentComment
                                ]
                                [ component.comment
                                    |> Maybe.withDefault ""
                                    |> text
                                ]
                            ]
                        ]
                    , footer =
                        [ div [ class "d-flex flex-row justify-content-between align-items-center gap-3 w-100" ]
                            [ componentScopesForm component item
                            , button [ class "btn btn-primary" ] [ text "Sauvegarder le composant" ]
                            ]
                        ]
                    , size = Modal.Large
                    }

                HistoryModal response ->
                    { title = "Historique des modifications"
                    , content = [ response |> WebDataView.map historyView ]
                    , footer =
                        [ button
                            [ class "btn btn-primary"
                            , onClick <| SetModals <| List.drop 1 modals
                            ]
                            [ text "Fermer" ]
                        ]
                    , size = Modal.ExtraLarge
                    }

                JournalEntryModal { action, value, user, createdAt } ->
                    { title =
                        JournalEntry.actionToString action
                            ++ " — "
                            ++ value.name
                    , content =
                        [ div [ class "row" ]
                            [ div [ class "col-12 col-md-6" ]
                                [ pre [ class "bg-light p-3 mb-0 border-end overflow-auto" ]
                                    [ text <| Encode.encode 2 <| Component.encode value ]
                                ]
                            , div [ class "col-12 col-md-6" ]
                                [ dl [ class "mt-3" ]
                                    [ dt [] [ text "Action" ]
                                    , dd [] [ text <| JournalEntry.actionToString action ]
                                    , dt [] [ text "Utilisateur" ]
                                    , dd [] [ text user.email ]
                                    , dt [] [ text "Date" ]
                                    , dd [] [ text <| Format.frenchDatetime createdAt ]
                                    ]
                                ]
                            ]
                        ]
                    , footer =
                        [ button
                            [ class "btn btn-primary"
                            , onClick <| SetModals <| List.drop 1 modals
                            ]
                            [ text "Fermer" ]
                        ]
                    , size = Modal.ExtraLarge
                    }

                SelectProcessModal category targetItem maybeElementIndex autocompleteState ->
                    { title = "Sélectionner un procédé"
                    , content =
                        let
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
                    , footer = []
                    , size = Modal.Large
                    }

        modal_ =
            Modal.view
                { close = SetModals <| List.drop 1 modals
                , content = content
                , footer = footer
                , formAction = Just SaveComponent
                , noOp = NoOp
                , size = size
                , subTitle = Nothing
                , title = title
                }
    in
    if index == 0 then
        modal_

    else
        div [ class "d-none" ] [ modal_ ]


componentScopesForm : Component -> Item -> Html Msg
componentScopesForm component item =
    item.custom
        |> Maybe.map .scopes
        |> Maybe.withDefault component.scopes
        |> List.head
        |> Maybe.withDefault Scope.Object
        |> ScopeView.singleScopeForm
            (\scope ->
                item
                    |> Component.toggleCustomScope component scope True
                    |> UpdateComponent
            )


historyView : List (JournalEntry Component) -> Html Msg
historyView entries =
    let
        differences =
            entries
                |> List.drop 1
                |> List.map2
                    (\to from ->
                        { action = to.action
                        , createdAt = to.createdAt
                        , diff =
                            Diff.diffLinesWith Diff.defaultOptions
                                (from.value |> Component.encode |> Encode.encode 2)
                                (to.value |> Component.encode |> Encode.encode 2)
                                |> DiffToString.diffToString { context = 2, color = False }
                        , id = to.id
                        , journalEntry = to
                        , user = to.user
                        }
                    )
                    entries
    in
    Table.responsiveDefault []
        [ thead []
            [ tr []
                [ th [] [ text "Action" ]
                , th [] [ text "Modification" ]
                , th [] [ text "Utilisateur" ]
                , th [] [ text "Date" ]
                , th [] []
                ]
            ]
        , if List.isEmpty differences then
            tbody [] [ tr [] [ td [ colspan 4 ] [ text "Aucun historique disponible" ] ] ]

          else
            differences
                |> List.map
                    (\{ action, createdAt, id, journalEntry, diff, user } ->
                        tr [ attribute "data-test-id" <| JournalEntry.idToString id ]
                            [ td [] [ text <| JournalEntry.actionToString action ]
                            , td [] [ Format.diff diff ]
                            , td [] [ text <| user.email ]
                            , td [] [ text <| Format.frenchDatetime createdAt ]
                            , td []
                                [ button
                                    [ type_ "button"
                                    , class "btn btn-outile-primary p-0"
                                    , title "Voir le composant au format JSON à cette date"
                                    , onClick <| OpenJournalEntryModal journalEntry
                                    ]
                                    [ Icon.search ]
                                ]
                            ]
                    )
                |> tbody []
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
        { attributes = []
        , close = Nothing
        , content =
            [ text "Attention, la base de données mobilisée peut être réinitialisée à tout moment et vos modifications avec."
            ]
        , level = Alert.Warning
        , title = Nothing
        }


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
