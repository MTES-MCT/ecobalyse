module Views.AutocompleteSelector exposing (Config, view)

import Autocomplete exposing (Autocomplete)
import Autocomplete.View as AutocompleteView
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed as Keyed
import Views.Modal as ModalView


type alias Config element msg =
    { autocompleteState : Autocomplete element
    , closeModal : msg
    , footer : List (Html msg)
    , noOp : msg
    , onAutocomplete : Autocomplete.Msg element -> msg
    , onAutocompleteSelect : msg
    , placeholderText : String
    , title : String
    , toCategory : element -> String
    , toLabel : element -> String
    }


view : Config element msg -> Html msg
view ({ autocompleteState, closeModal, footer, noOp, onAutocomplete, onAutocompleteSelect, placeholderText, title } as config) =
    ModalView.view
        { close = closeModal
        , content =
            let
                { choices, query, selectedIndex } =
                    Autocomplete.viewState autocompleteState

                { choiceEvents, inputEvents } =
                    AutocompleteView.events
                        { mapHtml = onAutocomplete
                        , onSelect = onAutocompleteSelect
                        }
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
                |> List.indexedMap
                    (\index element ->
                        ( config.toLabel element
                        , renderChoice config choiceEvents selectedIndex index element
                        )
                    )
                |> Keyed.node "div"
                    [ class "ElementAutocomplete", id "element-autocomplete-choices" ]
            ]
        , footer = footer
        , formAction = Nothing
        , noOp = noOp
        , size = ModalView.Large
        , subTitle = Nothing
        , title = title
        }


renderChoice : Config element msg -> (Int -> List (Attribute msg)) -> Maybe Int -> Int -> element -> Html msg
renderChoice { toCategory, toLabel } events selectedIndex_ index element =
    let
        selected =
            Autocomplete.isSelected selectedIndex_ index
    in
    button
        (events index
            ++ [ type_ "button"
               , class "AutocompleteChoice"
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
