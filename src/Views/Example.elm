module Views.Example exposing (Edited, view)

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Example as Example exposing (Example)
import Data.Uuid exposing (Uuid)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route exposing (Route)
import Views.Icon as Icon


type alias Config query msg =
    { create : query -> msg
    , currentQuery : query
    , duplicate : Example query -> msg
    , emptyQuery : query
    , examples : List (Example query)
    , onOpen : Autocomplete query -> msg
    , routes :
        { explore : Route
        , load : Uuid -> Route
        , scopeHome : Route
        }
    , save : Example query -> msg
    , update : Example query -> msg
    }


type alias Edited query =
    { initial : Example query
    , current : Example query
    }


view : Config query msg -> Maybe (Edited query) -> Html msg
view config edited =
    case edited of
        Just state ->
            editor config state

        Nothing ->
            selector config


editor : Config query msg -> Edited query -> Html msg
editor config { initial, current } =
    let
        modified =
            current /= initial

        alreadyExists =
            config.examples
                |> Example.findByName current.name
                |> Result.toMaybe
                |> (==) Nothing
    in
    div [ class "d-flex flex-column gap-2" ]
        [ div [ class "row g-2" ]
            [ div [ class "col-sm-6" ]
                [ label
                    [ for "example-name"
                    , class "form-label text-truncate mb-0"
                    ]
                    [ text "Nom de l'exemple" ]
                , input
                    [ type_ "text"
                    , id "example-name"
                    , class "form-control"
                    , value current.name
                    , onInput <| \newName -> config.update { current | name = newName }
                    ]
                    []
                ]
            , div [ class "col-sm-6" ]
                [ label
                    [ for "example-category"
                    , class "form-label text-truncate mb-0"
                    ]
                    [ text "Catégorie" ]
                , input
                    [ type_ "text"
                    , id "example-category"
                    , class "form-control"
                    , value current.category
                    , onInput <| \newCategory -> config.update { current | category = newCategory }
                    ]
                    []
                ]
            ]
        , div [ class "btn-group d-flex justify-content-end gap-2" ]
            [ a
                [ class "btn btn-sm btn-light d-flex justify-content-center align-items-center gap-1"
                , Route.href config.routes.explore
                ]
                [ Icon.list
                , text "Explorateur d'exemples"
                ]
            , a
                [ class "btn btn-sm btn-light d-flex justify-content-center align-items-center gap-1"
                , Route.href config.routes.scopeHome
                ]
                [ Icon.cancel
                , text "Annuler l'édition"
                ]
            , a
                [ class "btn btn-sm btn-light d-flex justify-content-center align-items-center gap-1"
                , classList [ ( "disabled", not modified ) ]
                , Route.href <| config.routes.load initial.id
                ]
                [ Icon.undo
                , text "Réinitialiser"
                ]
            , button
                [ class "btn btn-primary d-flex justify-content-center align-items-center gap-1"
                , disabled (not modified || alreadyExists)
                , onClick <| config.save current
                ]
                [ Icon.save
                , text <|
                    "Enregistrer"
                        ++ (if modified then
                                "*"

                            else
                                ""
                           )
                ]
            ]
        ]


selector : Config query msg -> Html msg
selector config =
    let
        autocompleteState =
            config.examples
                |> List.map .query
                |> AutocompleteSelector.init (Example.toName config.examples)
    in
    div []
        [ label [ for "selector-example", class "form-label fw-bold text-truncate mb-0" ]
            [ text "Exemples" ]
        , div [ class "d-flex justify-content-between align-items-center" ]
            [ button
                [ class "form-select ElementSelector text-start"
                , id "selector-example"
                , onClick <| config.onOpen autocompleteState
                ]
                [ text <| Example.toName config.examples config.currentQuery
                ]
            , case
                ( config.currentQuery == config.emptyQuery
                , Example.findByQuery config.currentQuery config.examples
                )
              of
                ( False, Ok example ) ->
                    div [ class "btn-group" ]
                        [ a
                            [ class "btn btn-light"
                            , Route.href <| config.routes.load example.id
                            , title "Éditer cet exemple"
                            ]
                            [ Icon.pencil ]
                        , button
                            [ class "btn btn-light"
                            , title "Dupliquer cet exemple"
                            , onClick <| config.duplicate example
                            ]
                            [ Icon.copy ]
                        ]

                ( False, Err _ ) ->
                    button
                        [ class "btn btn-light"
                        , onClick <| config.create config.currentQuery
                        , title "Ajouter cet exemple"
                        ]
                        [ Icon.plus ]

                _ ->
                    text ""
            ]
        ]
