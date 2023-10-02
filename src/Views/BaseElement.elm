module Views.BaseElement exposing (Config, view)

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Country as Country exposing (Country)
import Data.Impact exposing (Impacts)
import Data.Impact.Definition exposing (Definition, Definitions)
import Html exposing (..)
import Html.Attributes exposing (..)
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
    { baseElement : BaseElement element quantity
    , db : Db element
    , defaultCountry : String
    , delete : element -> msg
    , disableCountry : Bool
    , disableQuantity : Bool
    , excluded : List element
    , impact : Impacts
    , quantityView : { disabled : Bool, quantity : quantity, onChange : Maybe quantity -> msg } -> Html msg
    , selectedImpact : Definition
    , selectElement : element -> Autocomplete element -> msg
    , toString : element -> String
    , update : BaseElement element quantity -> BaseElement element quantity -> msg
    }


view : Config element quantity msg -> List (Html msg)
view { baseElement, db, defaultCountry, delete, disableCountry, disableQuantity, excluded, impact, quantityView, selectedImpact, selectElement, toString, update } =
    let
        updateEvent =
            update baseElement

        deleteEvent =
            delete baseElement.element

        autocompleteState =
            AutocompleteSelector.init
                toString
                (db.elements
                    |> List.filter (\element -> not (List.member element excluded))
                )
    in
    [ span [ class "QuantityInputWrapper" ]
        [ quantityView
            { disabled = disableQuantity
            , quantity = baseElement.quantity
            , onChange =
                \maybeQuantity ->
                    case maybeQuantity of
                        Just quantity ->
                            updateEvent { baseElement | quantity = quantity }

                        _ ->
                            updateEvent baseElement
            }
        ]
    , selectorView baseElement.element toString (selectElement baseElement.element autocompleteState)
    , db.countries
        |> List.sortBy .name
        |> List.map
            (\{ code, name } ->
                option
                    [ selected (Maybe.map .code baseElement.country == Just code)
                    , value <| Country.codeToString code
                    , disabled disableCountry
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
    , deleteItemButton (List.length excluded == 1) deleteEvent
    ]


deleteItemButton : Bool -> msg -> Html msg
deleteItemButton disable event =
    button
        [ type_ "button"
        , class "baseElementDelete d-flex justify-content-center align-items-center btn btn-outline-primary"
        , title "Supprimer ce composant"
        , onClick event
        , disabled disable
        ]
        [ Icon.trash ]


selectorView : element -> (element -> String) -> msg -> Html msg
selectorView selectedElement toString selectElement =
    div
        [ class "form-select ElementSelector"
        , style "overflow" "hidden"
        , style "white-space" "nowrap"
        , onClick selectElement
        ]
        [ span
            [ style "display" "block"
            , style "overflow" "hidden"
            ]
            [ text <| toString selectedElement ]
        ]
