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


type alias ManagerConfig msg =
    { activeTab : ActiveTab
    , bookmarkName : String
    , compare : msg
    , copyToClipBoard : String -> msg
    , delete : Bookmark -> msg
    , impact : Definition
    , save : msg
    , scope : Scope
    , session : Session
    , switchTab : ActiveTab -> msg
    , update : String -> msg
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

                Scope.Object ->
                    ( Just session.queries.object
                        |> Route.ObjectSimulator impact.trigram
                        |> Route.toString
                        |> (++) session.clientUrl
                      -- FIXME: make this a maybe
                    , session.queries.object
                        |> ObjectQuery.buildApiQuery session.clientUrl
                      -- FIXME: make this a maybe
                    , session.queries.object
                        |> ObjectQuery.encode
                        |> Encode.encode 2
                    )

                Scope.Textile ->
                    ( Just session.queries.textile
                        |> Route.TextileSimulator impact.trigram
                        |> Route.toString
                        |> (++) session.clientUrl
                    , session.queries.textile
                        |> TextileQuery.buildApiQuery session.clientUrl
                    , session.queries.textile
                        |> TextileQuery.encode
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
bookmarksView cfg =
    let
        bookmarks =
            scopedBookmarks cfg.session cfg.scope
    in
    div []
        [ div [ class "card-header border-top rounded-0 d-flex justify-content-between align-items-center" ]
            [ span [] [ text "Simulations sauvegardées" ]
            , button
                [ class "btn btn-sm btn-primary"
                , title "Comparer vos simulations sauvegardées"
                , disabled (List.isEmpty bookmarks)
                , onClick cfg.compare
                ]
                [ span [ class "me-1" ] [ Icon.stats ]
                , text "Comparer"
                ]
            ]
        , bookmarks
            |> Bookmark.sort
            |> List.map (bookmarkView cfg)
            |> ul
                [ class "list-group list-group-flush rounded-bottom overflow-auto"
                , style "max-height" "50vh"
                ]
        ]


bookmarkView : ManagerConfig msg -> Bookmark -> Html msg
bookmarkView cfg ({ name, query } as bookmark) =
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
                        |> Route.ObjectSimulator cfg.impact.trigram

                Bookmark.Textile textileQuery ->
                    Just textileQuery
                        |> Route.TextileSimulator cfg.impact.trigram
    in
    li
        [ class "list-group-item d-flex justify-content-between align-items-center gap-1 fs-7"
        , classList [ ( "active", query == currentQuery ) ]
        ]
        [ a
            [ class "text-truncate"
            , classList [ ( "active text-white", query == currentQuery ) ]
            , bookmark
                |> Bookmark.toQueryDescription cfg.session.db
                |> title
            , bookmarkRoute
                |> Route.toString
                |> (++) cfg.session.clientUrl
                |> href
            ]
            [ text name ]
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
            )
        |> Bookmark.sort
