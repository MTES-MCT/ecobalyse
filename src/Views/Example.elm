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
        , sectorHome : Route
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
    div [ class "row align-items-center gx-2 gy-0 g-md-2" ]
        [ div [ class "SimulatorFiedlLabel col-12 col-md-auto d-flex justify-content-md-end" ]
            [ label
                [ for "selector-example"
                , class "col-form-label w-auto text-start fw-bold mb-1 mb-md-0"
                ]
                [ text "Exemples" ]
            ]
        , div [ class "col-12 col-md d-flex align-items-center min-w-0" ]
            [ button
                [ class "form-select ElementSelector text-start text-truncate flex-fill"
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
