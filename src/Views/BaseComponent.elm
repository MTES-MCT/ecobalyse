module Views.BaseComponent exposing (Config, view)

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


type alias Component a =
    { a | name : String }


type alias BaseComponent a b =
    { component : Component a
    , quantity : b
    , country : Maybe Country
    }


type alias Db a =
    { components : List (Component a)
    , countries : List Country
    , definitions : Definitions
    }


type alias Config a b msg =
    { excluded : List (Component a)
    , db : Db a
    , baseComponent : BaseComponent a b
    , defaultCountry : String
    , impact : Impacts
    , selectedImpact : Definition
    , update : BaseComponent a b -> BaseComponent a b -> msg
    , delete : Component a -> msg
    , selectComponent : Component a -> Autocomplete (Component a) -> msg
    , quantityView : { disabled : Bool, quantity : b, onChange : Maybe b -> msg } -> Html msg
    , toString : Component a -> String
    }


view : Config a b msg -> List (Html msg)
view { excluded, db, baseComponent, defaultCountry, impact, selectedImpact, update, delete, selectComponent, quantityView, toString } =
    let
        updateEvent =
            update baseComponent

        deleteEvent =
            delete baseComponent.component

        autocompleteState =
            AutocompleteSelector.init
                (db.components
                    |> List.filter (\component -> not (List.member component excluded))
                )
    in
    [ span [ class "QuantityInputWrapper" ]
        [ quantityView
            { disabled = False
            , quantity = baseComponent.quantity
            , onChange =
                \maybeQuantity ->
                    case maybeQuantity of
                        Just quantity ->
                            updateEvent { baseComponent | quantity = quantity }

                        _ ->
                            updateEvent baseComponent
            }
        ]
    , selectorView baseComponent.component toString (selectComponent baseComponent.component autocompleteState)
    , db.countries
        |> List.sortBy .name
        |> List.map
            (\{ code, name } ->
                option
                    [ selected (Maybe.map .code baseComponent.country == Just code)
                    , value <| Country.codeToString code
                    ]
                    [ text name ]
            )
        |> (::)
            (option
                [ value ""
                , selected (baseComponent.country == Nothing)
                ]
                [ text <| "Par défaut (" ++ defaultCountry ++ ")" ]
            )
        |> select
            [ class "form-select form-select CountrySelector"
            , onInput
                (\val ->
                    updateEvent
                        { baseComponent
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
    , deleteItemButton deleteEvent
    ]


deleteItemButton : msg -> Html msg
deleteItemButton event =
    button
        [ type_ "button"
        , class "BaseComponentDelete d-flex justify-content-center align-items-center btn btn-outline-primary"
        , title "Supprimer ce composant"
        , onClick event
        ]
        [ Icon.trash ]


selectorView : Component a -> (Component a -> String) -> msg -> Html msg
selectorView selectedComponent toString selectComponent =
    div
        [ class "form-select ComponentSelector"
        , style "overflow" "hidden"
        , style "white-space" "nowrap"
        , onClick selectComponent
        ]
        [ span
            [ style "display" "block"
            , style "overflow" "hidden"
            ]
            [ text <| toString selectedComponent ]
        ]
