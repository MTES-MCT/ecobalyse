module Views.Bookmark exposing (ActiveTab(..), Scope(..), view)

import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Impact as Impact
import Data.Session exposing (Session)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Textile.Simulator.ViewMode as ViewMode exposing (ViewMode)
import Route
import Views.Icon as Icon


type alias ManagerConfig msg =
    { session : Session
    , activeTab : ActiveTab
    , bookmarkName : String
    , impact : Impact.Definition
    , funit : Unit.Functional
    , viewMode : ViewMode
    , scope : Scope

    -- Messages
    , copyToClipBoard : String -> msg
    , compare : msg
    , delete : Bookmark -> msg
    , save : msg
    , update : String -> msg
    , switchTab : ActiveTab -> msg
    }


type Scope
    = Food
    | Textile


type ActiveTab
    = SaveTab
    | ShareTab


view : ManagerConfig msg -> Html msg
view ({ activeTab, switchTab } as config) =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header" ]
            [ [ ( SaveTab, "Sauvegarder" ), ( ShareTab, "Partager" ) ]
                |> List.map
                    (\( tab, label ) ->
                        li [ class "nav-item" ]
                            [ button
                                [ class "btn btn-text nav-link rounded-0 rounded-top no-outline"
                                , classList [ ( "active", activeTab == tab ) ]
                                , onClick <| switchTab tab
                                ]
                                [ text label ]
                            ]
                    )
                |> ul [ class "nav nav-tabs justify-content-end card-header-tabs" ]
            ]
        , case activeTab of
            ShareTab ->
                shareLinkView config

            SaveTab ->
                managerView config
        ]


shareLinkView : ManagerConfig msg -> Html msg
shareLinkView { session, impact, funit, copyToClipBoard, scope } =
    let
        shareableLink =
            case scope of
                Food ->
                    Just session.queries.food
                        |> Route.FoodBuilder impact.trigram
                        |> Route.toString
                        |> (++) session.clientUrl

                Textile ->
                    Just session.queries.textile
                        |> Route.TextileSimulator impact.trigram funit ViewMode.Simple
                        |> Route.toString
                        |> (++) session.clientUrl
    in
    div [ class "card-body" ]
        [ div
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


managerView : ManagerConfig msg -> Html msg
managerView ({ session, bookmarkName, scope } as config) =
    let
        bookmarks =
            scopedBookmarks session scope

        ( queryExists, nameExists ) =
            ( bookmarks
                |> List.map .query
                |> List.member (queryFromScope session scope)
            , bookmarks
                |> List.map .name
                |> List.member bookmarkName
            )

        bookmarkExists =
            queryExists || nameExists
    in
    div []
        [ div [ class "card-body pb-2" ]
            [ Html.form [ onSubmit config.save ]
                [ div [ class "input-group" ]
                    [ input
                        [ type_ "text"
                        , class "form-control"
                        , onInput config.update
                        , placeholder "Nom de la simulation"
                        , value bookmarkName
                        , required True
                        , pattern "^(?!\\s*$).+"
                        , readonly bookmarkExists
                        ]
                        []
                    , button
                        [ type_ "submit"
                        , class "btn btn-primary"
                        , title "Sauvegarder la simulation dans le stockage local au navigateur"
                        , disabled bookmarkExists
                        ]
                        [ Icon.plus ]
                    ]
                ]
            , div [ class "form-text fs-7 pb-0" ]
                [ if bookmarkExists then
                    span [ class "d-flex align-items-center gap-1" ] [ Icon.info, text "Cette simulation est déjà sauvegardée" ]

                  else
                    text "Donnez un nom à cette simulation pour la retrouver plus tard"
                ]
            ]
        , bookmarksView config
        ]


bookmarksView : ManagerConfig msg -> Html msg
bookmarksView ({ session, compare, scope } as config) =
    let
        bookmarks =
            scopedBookmarks session scope
    in
    div []
        [ div [ class "card-header border-top rounded-0 d-flex justify-content-between align-items-center" ]
            [ span [] [ text "Simulations sauvegardées" ]
            , case scope of
                Food ->
                    text ""

                Textile ->
                    button
                        [ class "btn btn-sm btn-primary"
                        , title "Comparer vos simulations sauvegardées"
                        , disabled (List.length bookmarks < 2)
                        , onClick compare
                        ]
                        [ span [ class "me-1" ] [ Icon.stats ]
                        , text "Comparer"
                        ]
            ]
        , if List.length bookmarks == 0 then
            div [ class "card-body form-text fs-7 pt-2" ]
                [ text "Pas de simulations sauvegardées sur cet ordinateur" ]

          else
            bookmarks
                |> Bookmark.sort
                |> List.map (bookmarkView config)
                |> ul
                    [ class "list-group list-group-flush rounded-bottom overflow-auto"
                    , style "max-height" "50vh"
                    ]
        ]


bookmarkView : ManagerConfig msg -> Bookmark -> Html msg
bookmarkView { session, impact, funit, viewMode, delete, scope } ({ name, query } as bookmark) =
    let
        currentQuery =
            queryFromScope session scope

        bookmarkRoute =
            case query of
                Bookmark.Food foodQuery ->
                    Just foodQuery
                        |> Route.FoodBuilder impact.trigram

                Bookmark.Textile textileQuery ->
                    Just textileQuery
                        |> Route.TextileSimulator impact.trigram funit viewMode
    in
    li
        [ class "list-group-item d-flex justify-content-between align-items-center gap-1 fs-7"
        , classList [ ( "active", query == currentQuery ) ]
        ]
        [ a
            [ class "text-truncate"
            , classList [ ( "active text-white", query == currentQuery ) ]
            , bookmark
                |> Bookmark.toQueryDescription { foodDb = session.builderDb, textileDb = session.db }
                |> title
            , bookmarkRoute
                |> Route.toString
                |> (++) session.clientUrl
                |> href
            ]
            [ text name ]
        , button
            [ type_ "button"
            , class "btn btn-sm btn-danger"
            , title "Supprimer"
            , attribute "aria-label" "Supprimer"
            , onClick (delete bookmark)
            ]
            [ Icon.trash ]
        ]


queryFromScope : Session -> Scope -> Bookmark.Query
queryFromScope session scope =
    case scope of
        Food ->
            Bookmark.Food session.queries.food

        Textile ->
            Bookmark.Textile session.queries.textile


scopedBookmarks : Session -> Scope -> List Bookmark
scopedBookmarks session scope =
    session.store.bookmarks
        |> List.filter
            (case scope of
                Food ->
                    Bookmark.isFood

                Textile ->
                    Bookmark.isTextile
            )
        |> Bookmark.sort
