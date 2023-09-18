module Views.AutocompleteSelector exposing (Config, view)

import Autocomplete exposing (Autocomplete)
import Autocomplete.View as AutocompleteView
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Modal as ModalView


type alias Config msg a =
    { autocompleteState : Autocomplete a
    , closeModal : msg
    , noOp : msg
    , onAutocomplete : Autocomplete.Msg a -> msg
    , onAutocompleteSelect : msg
    , placeholderText : String
    , title : String
    , toLabel : a -> String
    , toCategory : a -> String
    }


view : Config msg a -> Html msg
view { autocompleteState, closeModal, noOp, onAutocomplete, onAutocompleteSelect, placeholderText, title, toLabel, toCategory } =
    ModalView.view
        { size = ModalView.Large
        , close = closeModal
        , noOp = noOp
        , title = title
        , subTitle = Nothing
        , formAction = Nothing
        , content =
            let
                { query, choices, selectedIndex } =
                    Autocomplete.viewState autocompleteState

                { inputEvents, choiceEvents } =
                    AutocompleteView.events
                        { onSelect = onAutocompleteSelect
                        , mapHtml = onAutocomplete
                        }

                renderChoice : (Int -> List (Attribute msg)) -> Maybe Int -> Int -> a -> Html msg
                renderChoice events selectedIndex_ index element =
                    let
                        selected =
                            Autocomplete.isSelected selectedIndex_ index
                    in
                    button
                        (events index
                            ++ [ class "IngredientAutocompleteChoice"
                               , class "d-flex justify-content-between align-items-center gap-1 w-100"
                               , class "btn btn-outline-primary border-0 border-bottom text-start no-outline"
                               , classList [ ( "btn-primary selected", selected ) ]
                               , attribute "role" "option"
                               , attribute "aria-selected"
                                    (if selected then
                                        "true"

                                     else
                                        "false"
                                    )
                               ]
                        )
                        [ span [ class "text-nowrap" ] [ text <| toLabel element ]
                        , span [ class "text-muted fs-8 text-truncate" ]
                            [ text <| toCategory element ]
                        ]
            in
            [ input
                (inputEvents
                    ++ [ type_ "search"
                       , id "element-search"
                       , class "form-control"
                       , autocomplete False
                       , attribute "role" "combobox"
                       , attribute "aria-autocomplete" "list"
                       , attribute "aria-owns" "element-autocomplete-choices"
                       , placeholder placeholderText
                       , value query
                       ]
                )
                []
            , choices
                |> List.indexedMap (renderChoice choiceEvents selectedIndex)
                |> div [ class "ElementAutocomplete", id "element-autocomplete-choices" ]
            ]
        , footer = []
        }
