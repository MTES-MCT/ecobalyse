module Views.BaseElement exposing (Config, deleteItemButton, view)

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Geozone as Geozone exposing (Geozone)
import Data.Impact exposing (Impacts)
import Data.Impact.Definition exposing (Definition, Definitions)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Views.Format as Format
import Views.Icon as Icon


type alias BaseElement element quantity =
    { element : element
    , geozone : Maybe Geozone
    , quantity : quantity
    }


type alias Db element =
    { definitions : Definitions
    , elements : List element
    , geozones : List Geozone
    }


type alias Config element quantity msg =
    { allowEmptyList : Bool
    , baseElement : BaseElement element quantity
    , db : Db element
    , defaultGeozone : String
    , delete : element -> msg
    , excluded : List element
    , impact : Impacts
    , openExplorerDetails : element -> msg
    , quantityView : { quantity : quantity, onChange : Maybe quantity -> msg } -> Html msg
    , selectElement : element -> Autocomplete element -> msg
    , selectedImpact : Definition
    , toId : element -> String
    , toString : element -> String
    , toTooltip : element -> String
    , update : BaseElement element quantity -> BaseElement element quantity -> msg
    }


view : Config element quantity msg -> List (Html msg)
view ({ baseElement, db, impact } as config) =
    let
        updateEvent =
            config.update baseElement

        deleteEvent =
            config.delete baseElement.element

        autocompleteState =
            db.elements
                |> List.filter (\component -> not (List.member component config.excluded))
                |> List.sortBy config.toString
                |> AutocompleteSelector.init config.toString
    in
    [ span [ class "QuantityInputWrapper" ]
        [ config.quantityView
            { onChange =
                \maybeQuantity ->
                    case maybeQuantity of
                        Just quantity ->
                            updateEvent { baseElement | quantity = quantity }

                        _ ->
                            updateEvent baseElement
            , quantity = baseElement.quantity
            }
        ]
    , autocompleteState
        |> config.selectElement baseElement.element
        |> selectorView config
    , db.geozones
        |> List.sortBy .name
        |> List.map
            (\{ code, name } ->
                option
                    [ selected (Maybe.map .code baseElement.geozone == Just code)
                    , value <| Geozone.codeToString code
                    ]
                    [ text name ]
            )
        |> (::)
            (option
                [ value ""
                , selected (baseElement.geozone == Nothing)
                ]
                [ text <| "Par défaut (" ++ config.defaultGeozone ++ ")" ]
            )
        |> select
            [ class "form-select form-select GeozoneSelector"
            , onInput
                (\val ->
                    updateEvent
                        { baseElement
                            | geozone =
                                if val /= "" then
                                    Geozone.codeFromString val
                                        |> (\geozoneCode -> Geozone.findByCode geozoneCode db.geozones)
                                        |> Result.toMaybe

                                else
                                    Nothing
                        }
                )
            ]
    , span [ class "text-end ImpactDisplay fs-7" ]
        [ impact
            |> Format.formatImpact config.selectedImpact
        ]
    , deleteItemButton { disabled = List.length config.excluded == 1 && not config.allowEmptyList } deleteEvent
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


selectorView : Config element quantity msg -> msg -> Html msg
selectorView { baseElement, openExplorerDetails, toId, toString, toTooltip } selectElement =
    let
        { element } =
            baseElement
    in
    div [ class "input-group" ]
        [ button
            [ class "form-select ElementSelector text-start"
            , id <| "selector-" ++ toId element
            , title (toTooltip element)
            , onClick selectElement
            ]
            [ span [] [ text <| toString element ]
            ]
        , button
            [ type_ "button"
            , class "input-group-text"
            , title "Ouvrir les informations détaillées"
            , onClick (openExplorerDetails element)
            ]
            [ Icon.question ]
        ]
