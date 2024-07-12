module Views.BaseElement exposing (Config, deleteItemButton, view)

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Country as Country exposing (Country)
import Data.Impact exposing (Impacts)
import Data.Impact.Definition exposing (Definition, Definitions)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Views.Format as Format
import Views.Icon as Icon


type alias BaseElement element quantity =
    { element : element
    , quantity : quantity
    , country : Maybe Country
    }


type alias Db element =
    { elements : List element
    , countries : List Country
    , definitions : Definitions
    }


type alias Config element quantity msg =
    { allowEmptyList : Bool
    , baseElement : BaseElement element quantity
    , db : Db element
    , defaultCountry : String
    , delete : element -> msg
    , excluded : List element
    , impact : Impacts

    -- TODO: introduce complementsView
    , quantityView : { quantity : quantity, onChange : Maybe quantity -> msg } -> Html msg
    , selectedImpact : Definition
    , selectElement : element -> Autocomplete element -> msg
    , toId : element -> String
    , toString : element -> String
    , toTooltip : element -> String
    , update : BaseElement element quantity -> BaseElement element quantity -> msg
    }


view : Config element quantity msg -> List (Html msg)
view { allowEmptyList, baseElement, db, defaultCountry, delete, excluded, impact, quantityView, selectedImpact, selectElement, toId, toString, toTooltip, update } =
    let
        updateEvent =
            update baseElement

        deleteEvent =
            delete baseElement.element

        autocompleteState =
            db.elements
                |> List.filter (\component -> not (List.member component excluded))
                |> List.sortBy toString
                |> AutocompleteSelector.init toString
    in
    [ span [ class "QuantityInputWrapper" ]
        [ quantityView
            { quantity = baseElement.quantity
            , onChange =
                \maybeQuantity ->
                    case maybeQuantity of
                        Just quantity ->
                            updateEvent { baseElement | quantity = quantity }

                        _ ->
                            updateEvent baseElement
            }
        ]
    , autocompleteState
        |> selectElement baseElement.element
        |> selectorView baseElement.element toId toTooltip toString
    , db.countries
        |> List.sortBy .name
        |> List.map
            (\{ code, name } ->
                option
                    [ selected (Maybe.map .code baseElement.country == Just code)
                    , value <| Country.codeToString code
                    ]
                    [ text name ]
            )
        |> (::)
            (option
                [ value ""
                , selected (baseElement.country == Nothing)
                ]
                [ text <| "Par défaut (" ++ defaultCountry ++ ")" ]
            )
        |> select
            [ class "form-select form-select CountrySelector"
            , onInput
                (\val ->
                    updateEvent
                        { baseElement
                            | country =
                                if val /= "" then
                                    Country.codeFromString val
                                        |> (\countryCode -> Country.findByCode countryCode db.countries)
                                        |> Result.toMaybe

                                else
                                    Nothing
                        }
                )
            ]
    , span [ class "text-end ImpactDisplay fs-7" ]
        [ impact
            |> Format.formatImpact selectedImpact
        ]
    , deleteItemButton { disabled = List.length excluded == 1 && not allowEmptyList } deleteEvent
    ]


deleteItemButton : { disabled : Bool } -> msg -> Html msg
deleteItemButton { disabled } event =
    button
        [ type_ "button"
        , class "ElementDelete d-flex justify-content-center align-items-center btn btn-outline-primary"
        , title "Supprimer ce composant"
        , onClick event
        , Attr.disabled disabled
        ]
        [ Icon.trash ]


selectorView : element -> (element -> String) -> (element -> String) -> (element -> String) -> msg -> Html msg
selectorView selectedElement toId toTooltip toString selectElement =
    button
        [ class "form-select ElementSelector text-start"
        , id <| "selector-" ++ toId selectedElement
        , title (toTooltip selectedElement)
        , onClick selectElement
        ]
        [ span
            []
            [ text <| toString selectedElement ]
        ]
