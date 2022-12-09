module Views.Bookmark exposing (manager)

import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Impact as Impact
import Data.Session exposing (Session)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Textile.Simulator.ViewMode exposing (ViewMode)
import Route
import Time
import Views.Icon as Icon


type alias ManagerConfig msg =
    { session : Session
    , bookmarks : List Bookmark
    , bookmarkName : String
    , currentQuery : Bookmark.Query
    , impact : Impact.Definition
    , funit : Unit.Functional
    , viewMode : ViewMode
    , showComparatorButton : Bool

    -- Messages
    , compare : msg
    , delete : Bookmark -> msg
    , save : msg
    , update : String -> msg
    }


manager : ManagerConfig msg -> Html msg
manager ({ bookmarks, bookmarkName, currentQuery } as config) =
    let
        ( queryExists, nameExists ) =
            ( bookmarks
                |> List.map .query
                |> List.member currentQuery
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
                [ text "Donnez un nom à cette simulation pour la retrouver plus tard" ]
            ]
        , bookmarksView config
        ]


bookmarksView : ManagerConfig msg -> Html msg
bookmarksView ({ bookmarks, compare, showComparatorButton } as config) =
    div []
        [ div [ class "card-header border-top rounded-0 d-flex justify-content-between align-items-center" ]
            [ span [] [ text "Simulations sauvegardées" ]
            , if showComparatorButton then
                button
                    [ class "btn btn-sm btn-primary"
                    , title "Comparer vos simulations sauvegardées"
                    , disabled (List.length bookmarks < 2)
                    , onClick compare
                    ]
                    [ span [ class "me-1" ] [ Icon.stats ]
                    , text "Comparer"
                    ]

              else
                text ""
            ]
        , if List.length bookmarks == 0 then
            div [ class "card-body form-text fs-7 pt-2" ]
                [ text "Pas de simulations sauvegardées sur cet ordinateur" ]

          else
            bookmarks
                |> List.sortBy (.created >> Time.posixToMillis)
                |> List.reverse
                |> List.map (bookmarkView config)
                |> ul
                    [ class "list-group list-group-flush rounded-bottom overflow-auto"
                    , style "max-height" "50vh"
                    ]
        ]


bookmarkView : ManagerConfig msg -> Bookmark -> Html msg
bookmarkView { currentQuery, impact, funit, viewMode, delete, session } ({ name, query } as bookmark) =
    let
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
