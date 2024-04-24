module Views.Example exposing (view)

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Example as Example exposing (Example)
import Data.Gitbook as Gitbook
import Data.Uuid exposing (Uuid)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route exposing (Route)
import Views.Icon as Icon


type alias Config query msg =
    { currentQuery : query
    , emptyQuery : query
    , examples : List (Example query)
    , helpUrl : Maybe Gitbook.Path
    , onOpen : Autocomplete query -> msg
    , routes :
        { explore : Route
        , load : Uuid -> Route
        , scopeHome : Route
        }
    }


view : Config query msg -> Html msg
view config =
    let
        autocompleteState =
            config.examples
                |> List.sortBy .name
                |> List.map .query
                |> AutocompleteSelector.init (Example.toName config.examples)
    in
    div [ class "d-flex flex-column" ]
        [ label [ for "selector-example", class "form-label fw-bold text-truncate" ]
            [ text "Exemples" ]
        , div [ class "d-flex justify-content-between align-items-center" ]
            [ button
                [ class "form-select ElementSelector text-start"
                , id "selector-example"
                , title "Les simulations proposées ici constituent des exemples. Elles doivent être adaptées pour chaque produit modélisé"
                , onClick <| config.onOpen autocompleteState
                ]
                [ text <| Example.toName config.examples config.currentQuery
                ]
            , case config.helpUrl of
                Just helpUrl ->
                    span [ class "input-group-text" ]
                        [ a
                            [ class "text-secondary text-decoration-none p-0"
                            , href (Gitbook.publicUrlFromPath helpUrl)
                            , target "_blank"
                            ]
                            [ Icon.info ]
                        ]

                Nothing ->
                    text ""
            ]
        ]
