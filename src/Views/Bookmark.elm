module Views.Bookmark exposing (ActiveTab(..), view)

import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Food.Query as FoodQuery
import Data.Impact.Definition exposing (Definition)
import Data.Object.Query as ObjectQuery
import Data.Scope as Scope exposing (Scope)
import Data.Session exposing (Session)
import Data.Textile.Query as TextileQuery
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Route
import Views.CardTabs as CardTabs
import Views.Icon as Icon
import Views.Version as VersionView


type alias ManagerConfig msg =
    { activeTab : ActiveTab
    , bookmarkBeingRenamed : Maybe Bookmark
    , bookmarkName : String
    , compare : msg
    , copyToClipBoard : String -> msg
    , delete : Bookmark -> msg
    , impact : Definition
    , rename : msg
    , save : msg
    , scope : Scope
    , session : Session
    , switchTab : ActiveTab -> msg
    , update : String -> msg
    , updateRenamedBookmarkName : Bookmark -> String -> msg
    }


type ActiveTab
    = SaveTab
    | ShareTab


view : ManagerConfig msg -> Html msg
view cfg =
    CardTabs.view
        { attrs = []
        , content =
            [ case cfg.activeTab of
                SaveTab ->
                    managerView cfg

                ShareTab ->
                    shareTabView cfg
            ]
        , tabs =
            [ ( SaveTab, text "Sauvegarder" )
            , ( ShareTab, text "Partager" )
            ]
                |> List.map
                    (\( tab, label ) ->
                        { active = cfg.activeTab == tab
                        , label = label
                        , onTabClick = cfg.switchTab tab
                        }
                    )
        }


shareTabView : ManagerConfig msg -> Html msg
shareTabView { copyToClipBoard, impact, scope, session } =
    let
        ( shareableLink, apiCall, jsonParams ) =
            case scope of
                Scope.Food ->
                    let
                        query =
                            session.queries.food
                    in
                    ( Just query
                        |> Route.FoodBuilder impact.trigram
                        |> Route.toString
                        |> (++) session.clientUrl
                    , FoodQuery.buildApiQuery session.clientUrl query
                    , FoodQuery.encode query
                        |> Encode.encode 2
                    )

                Scope.Object ->
                    let
                        query =
                            session.queries.object
                    in
                    ( Just query
                        |> Route.ObjectSimulator scope impact.trigram
                        |> Route.toString
                        |> (++) session.clientUrl
                    , ObjectQuery.buildApiQuery scope session.clientUrl query
                    , ObjectQuery.encode query
                        |> Encode.encode 2
                    )

                Scope.Textile ->
                    let
                        query =
                            session.queries.textile
                    in
                    ( Just query
                        |> Route.TextileSimulator impact.trigram
                        |> Route.toString
                        |> (++) session.clientUrl
                    , TextileQuery.buildApiQuery session.clientUrl query
                    , TextileQuery.encode query
                        |> Encode.encode 2
                    )

                Scope.Veli ->
                    let
                        query =
                            session.queries.veli
                    in
                    ( Just query
                        |> Route.ObjectSimulator scope impact.trigram
                        |> Route.toString
                        |> (++) session.clientUrl
                    , ObjectQuery.buildApiQuery scope session.clientUrl query
                    , ObjectQuery.encode query
                        |> Encode.encode 2
                    )
    in
    div []
        [ div [ class "card-body pt-0 pb-2" ]
            [ h2 [ class "h5 mt-2" ] [ text "Web" ]
            , div
                [ class "input-group" ]
                [ input
                    [ type_ "url"
                    , class "form-control"
                    , value shareableLink
                    ]
                    []
                , button
                    [ class "input-group-text"
                    , title "Copier l'adresse"
                    , onClick (copyToClipBoard shareableLink)
                    ]
                    [ Icon.clipboard
                    ]
                ]
            , div [ class "form-text fs-7" ]
                [ text "Copiez cette adresse pour partager ou sauvegarder votre simulation" ]
            ]
        , div [ class "card-body border-top pt-0 pb-2" ]
            [ h2 [ class "h5 mt-2" ] [ text "API" ]
            , pre [ class "bg-dark text-white p-2 m-0" ]
                [ code [] [ text <| "$ " ++ apiCall ] ]
            , button
                [ class "btn btn-outline-dark btn-sm w-100 d-flex justify-content-center align-items-center gap-1"
                , onClick <| copyToClipBoard apiCall
                ]
                [ Icon.clipboard, text "Copier la commande" ]
            , div [ class "form-text fs-7" ]
                [ text "Cette commande utilise l'"
                , a [ Route.href Route.Api ] [ text "API Ecobalyse" ]
                ]
            ]
        , div [ class "card-body border-top pt-0" ]
            [ h2 [ class "h5 mt-2" ] [ text "Paramètres de simulation JSON" ]
            , pre [ class "bg-dark text-white p-2 m-0", style "max-height" "200px" ]
                [ code [] [ text jsonParams ] ]
            , button
                [ class "btn btn-outline-dark btn-sm w-100 d-flex justify-content-center align-items-center gap-1"
                , onClick <| copyToClipBoard jsonParams
                ]
                [ Icon.clipboard, text "Copier" ]
            ]
        ]


managerView : ManagerConfig msg -> Html msg
managerView cfg =
    let
        bookmarks =
            scopedBookmarks cfg.session cfg.scope

        ( queryExists, nameExists ) =
            ( bookmarks
                |> List.map .query
                |> List.member (queryFromScope cfg.session cfg.scope)
            , bookmarks
                |> List.map .name
                |> List.member cfg.bookmarkName
            )
    in
    div []
        [ div [ class "card-body pb-2" ]
            [ Html.form [ onSubmit cfg.save ]
                [ div [ class "input-group" ]
                    [ input
                        [ type_ "text"
                        , class "form-control"
                        , onInput cfg.update
                        , placeholder "Nom de la simulation"
                        , value cfg.bookmarkName
                        , required True
                        , pattern "^(?!\\s*$).+"
                        , readonly queryExists
                        ]
                        []
                    , button
                        [ type_ "submit"
                        , class "btn btn-primary"
                        , title "Sauvegarder la simulation dans le stockage local au navigateur"
                        , disabled (queryExists || nameExists)
                        ]
                        [ Icon.plus ]
                    ]
                ]
            , div [ class "form-text fs-7 pb-0" ]
                [ if queryExists then
                    span [ class "d-flex align-items-center gap-1" ] [ Icon.info, text "Cette simulation est déjà sauvegardée" ]

                  else if nameExists then
                    span [ class "d-flex align-items-center gap-1" ] [ Icon.info, text "Une simulation portant ce nom existe déjà" ]

                  else
                    text "Donnez un nom à cette simulation pour la retrouver plus tard"
                ]
            ]
        , bookmarksView cfg
        ]


bookmarksView : ManagerConfig msg -> Html msg
bookmarksView ({ compare, scope, session } as cfg) =
    let
        bookmarks =
            scopedBookmarks session scope
    in
    div []
        [ div [ class "card-header border-top rounded-0 d-flex justify-content-between align-items-center" ]
            [ span [] [ text "Simulations sauvegardées" ]
            , button
                [ class "btn btn-sm btn-primary"
                , title "Comparer vos simulations sauvegardées"
                , disabled (List.isEmpty bookmarks)
                , onClick compare
                ]
                [ span [ class "me-1" ] [ Icon.stats ]
                , text "Comparer"
                ]
            ]
        , bookmarks
            |> Bookmark.sort
            |> List.filter
                (\{ subScope } ->
                    case subScope of
                        Just Scope.Object ->
                            scope == Scope.Object

                        Just Scope.Veli ->
                            scope == Scope.Veli

                        _ ->
                            True
                )
            |> List.map (bookmarkView cfg)
            |> ul
                [ class "list-group list-group-flush rounded-bottom overflow-auto"
                , style "max-height" "50vh"
                ]
        ]


bookmarkView : ManagerConfig msg -> Bookmark -> Html msg
bookmarkView cfg ({ name, query, version } as bookmark) =
    let
        currentQuery =
            queryFromScope cfg.session cfg.scope

        bookmarkRoute =
            case query of
                Bookmark.Food foodQuery ->
                    Just foodQuery
                        |> Route.FoodBuilder cfg.impact.trigram

                Bookmark.Object objectQuery ->
                    Just objectQuery
                        |> Route.ObjectSimulator Scope.Object cfg.impact.trigram

                Bookmark.Textile textileQuery ->
                    Just textileQuery
                        |> Route.TextileSimulator cfg.impact.trigram

                Bookmark.Veli veliQuery ->
                    Just veliQuery
                        |> Route.ObjectSimulator Scope.Veli cfg.impact.trigram

        beingRenamed =
            case cfg.bookmarkBeingRenamed of
                Just renamedBookmark ->
                    renamedBookmark.query == bookmark.query

                _ ->
                    False

        renameButton bk =
            button
                [ type_ "button"
                , class "btn btn-sm btn-info"
                , title "Renommer"
                , attribute "aria-label" "Renommer"
                , onClick (cfg.updateRenamedBookmarkName bk bk.name)
                ]
                [ Icon.pencil ]
    in
    li
        [ class "list-group-item d-flex justify-content-between align-items-center gap-1 fs-7"
        , classList [ ( "active", query == currentQuery ) ]
        ]
        [ VersionView.view version
        , case ( beingRenamed, cfg.bookmarkBeingRenamed ) of
            ( True, Just renamedBookmark ) ->
                input
                    [ type_ "text"
                    , class "form-control form-control-sm"
                    , onInput (cfg.updateRenamedBookmarkName bookmark)
                    , placeholder "Nom de la simulation"
                    , value renamedBookmark.name
                    , required True
                    , pattern "^(?!\\s*$).+"
                    ]
                    []

            _ ->
                a
                    [ class "flex-fill text-truncate"
                    , classList [ ( "active text-white", query == currentQuery ) ]
                    , bookmark
                        |> Bookmark.toQueryDescription cfg.session.db
                        |> title
                    , bookmarkRoute
                        |> Route.toString
                        |> (++) cfg.session.clientUrl
                        |> href
                    ]
                    [ text name
                    ]
        , if beingRenamed then
            button
                [ type_ "submit"
                , class "btn btn-sm btn-success"
                , title "Sauvegarder la simulation dans le stockage local du navigateur"
                , onClick cfg.rename
                ]
                [ Icon.check ]

          else
            renameButton bookmark
        , button
            [ type_ "button"
            , class "btn btn-sm btn-danger"
            , title "Supprimer"
            , attribute "aria-label" "Supprimer"
            , onClick (cfg.delete bookmark)
            ]
            [ Icon.trash ]
        ]


queryFromScope : Session -> Scope -> Bookmark.Query
queryFromScope session scope =
    case scope of
        Scope.Food ->
            Bookmark.Food session.queries.food

        Scope.Object ->
            Bookmark.Object session.queries.object

        Scope.Textile ->
            Bookmark.Textile session.queries.textile

        Scope.Veli ->
            Bookmark.Veli session.queries.veli


scopedBookmarks : Session -> Scope -> List Bookmark
scopedBookmarks session scope =
    session.store.bookmarks
        |> List.filter
            (case scope of
                Scope.Food ->
                    Bookmark.isFood

                Scope.Object ->
                    Bookmark.isObject

                Scope.Textile ->
                    Bookmark.isTextile

                Scope.Veli ->
                    Bookmark.isVeli
            )
        |> Bookmark.sort
