module Views.Bookmark exposing (ActiveTab(..), view)

import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Food.Builder.Query as FoodQuery
import Data.Impact as Impact
import Data.Scope as Scope exposing (Scope)
import Data.Session exposing (Session)
import Data.Textile.Inputs as TextileInputs
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Page.Textile.Simulator.ViewMode as ViewMode exposing (ViewMode)
import Route
import Views.CardTabs as CardTabs
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


type ActiveTab
    = SaveTab
    | ShareTab


view : ManagerConfig msg -> Html msg
view ({ activeTab, switchTab } as config) =
    CardTabs.view
        { tabs =
            [ ( SaveTab, "Sauvegarder" )
            , ( ShareTab, "Partager" )
            ]
                |> List.map
                    (\( tab, label ) ->
                        { label = label
                        , onTabClick = switchTab tab
                        , active = activeTab == tab
                        }
                    )
        , content =
            [ case activeTab of
                ShareTab ->
                    shareTabView config

                SaveTab ->
                    managerView config
            ]
        }


shareTabView : ManagerConfig msg -> Html msg
shareTabView { session, impact, funit, copyToClipBoard, scope } =
    let
        ( shareableLink, apiCall, jsonParams ) =
            case scope of
                Scope.Food ->
                    ( Just session.queries.food
                        |> Route.FoodBuilder impact.trigram
                        |> Route.toString
                        |> (++) session.clientUrl
                    , session.queries.food
                        |> FoodQuery.buildApiQuery session.clientUrl
                    , session.queries.food
                        |> FoodQuery.encode
                        |> Encode.encode 2
                    )

                Scope.Textile ->
                    ( Just session.queries.textile
                        |> Route.TextileSimulator impact.trigram funit ViewMode.Simple
                        |> Route.toString
                        |> (++) session.clientUrl
                    , session.queries.textile
                        |> TextileInputs.buildApiQuery session.clientUrl
                    , session.queries.textile
                        |> TextileInputs.encodeQuery
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
            , button
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
        Scope.Food ->
            Bookmark.Food session.queries.food

        Scope.Textile ->
            Bookmark.Textile session.queries.textile


scopedBookmarks : Session -> Scope -> List Bookmark
scopedBookmarks session scope =
    session.store.bookmarks
        |> List.filter
            (case scope of
                Scope.Food ->
                    Bookmark.isFood

                Scope.Textile ->
                    Bookmark.isTextile
            )
        |> Bookmark.sort
