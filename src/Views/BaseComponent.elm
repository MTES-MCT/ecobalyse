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


type alias BaseComponent component quantity =
    { component : component
    , quantity : quantity
    , country : Maybe Country
    }


type alias Db component =
    { components : List component
    , countries : List Country
    , definitions : Definitions
    }


type alias Config component quantity msg =
    { excluded : List component
    , db : Db component
    , baseComponent : BaseComponent component quantity
    , defaultCountry : String
    , impact : Impacts
    , selectedImpact : Definition
    , update : BaseComponent component quantity -> BaseComponent component quantity -> msg
    , delete : component -> msg
    , selectComponent : component -> Autocomplete component -> msg
    , quantityView : { disabled : Bool, quantity : quantity, onChange : Maybe quantity -> msg } -> Html msg
    , toString : component -> String
    , disableCountry : Bool
    , disableQuantity : Bool
    }


view : Config component quantity msg -> List (Html msg)
view { excluded, db, baseComponent, defaultCountry, impact, selectedImpact, update, delete, selectComponent, quantityView, toString, disableCountry, disableQuantity } =
    let
        updateEvent =
            update baseComponent

        deleteEvent =
            delete baseComponent.component

        autocompleteState =
            AutocompleteSelector.init
                toString
                (db.components
                    |> List.filter (\component -> not (List.member component excluded))
                )
    in
    [ span [ class "QuantityInputWrapper" ]
        [ quantityView
            { disabled = disableQuantity
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
                    , disabled disableCountry
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
    , deleteItemButton (List.length excluded == 1) deleteEvent
    ]


deleteItemButton : Bool -> msg -> Html msg
deleteItemButton disable event =
    button
        [ type_ "button"
        , class "BaseComponentDelete d-flex justify-content-center align-items-center btn btn-outline-primary"
        , title "Supprimer ce composant"
        , onClick event
        , disabled disable
        ]
        [ Icon.trash ]


selectorView : component -> (component -> String) -> msg -> Html msg
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
