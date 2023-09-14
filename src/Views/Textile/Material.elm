module Views.Textile.Material exposing (formSet)

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Env as Env
import Data.Split as Split exposing (Split)
import Data.Textile.Inputs as Inputs
import Data.Textile.Material as Material exposing (Material)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Views.Icon as Icon


type alias FormSetConfig msg =
    { materials : List Material
    , inputs : List Inputs.MaterialInput
    , remove : Int -> msg
    , update : Int -> Material.Id -> msg
    , updateShare : Int -> Split -> msg
    , selectInputText : String -> msg
    , selectMaterial : Maybe Inputs.MaterialInput -> Autocomplete Material -> msg
    }


formSet : FormSetConfig msg -> Html msg
formSet ({ inputs, selectMaterial } as config) =
    let
        ( length, exclude ) =
            ( List.length inputs
            , List.map (.material >> .id) inputs
            )

        totalShares =
            inputs
                |> List.map (.share >> Split.toFloat >> clamp 0 1)
                |> List.sum

        valid =
            round (totalShares * 100) == 100

        availableMaterials =
            config.materials
                |> List.filter (\{ id } -> not (List.member id exclude))

        autocompleteState =
            AutocompleteSelector.init availableMaterials
    in
    div [ class "Materials" ]
        [ div [ class "d-flex align-items-end gap-1 mb-2" ]
            [ span [ class "fw-bold" ]
                [ text "Matières premières" ]
            , span [ class "text-muted fs-7" ]
                [ text <| "jusqu'à " ++ String.fromInt Env.maxMaterials ++ " maximum" ]
            ]
        , inputs
            |> List.indexedMap
                (\index input ->
                    field config
                        { index = index
                        , length = length
                        , exclude = exclude
                        , valid = valid
                        }
                        (selectMaterial (Just input) autocompleteState)
                        input
                )
            |> div [ class "d-flex flex-column gap-1" ]
        , div [ class "input-group mt-1" ]
            [ if length > 1 then
                span
                    [ class "SharesTotal form-control text-end"
                    , class "d-flex justify-content-between align-items-center gap-1"
                    , classList
                        [ ( "text-success feedback-valid", valid )
                        , ( "text-danger feedback-invalid", not valid )
                        ]
                    ]
                    [ if valid then
                        Icon.check

                      else
                        Icon.warning
                    , round (totalShares * 100) |> String.fromInt |> text
                    , text "%"
                    ]

              else
                text ""
            , button
                [ class "btn btn-outline-primary flex-fill"
                , class "d-flex justify-content-center align-items-center gap-1 no-outline"
                , onClick (selectMaterial Nothing autocompleteState)
                , disabled <| length >= Env.maxMaterials
                ]
                [ Icon.plus
                , text "Ajouter une matière"
                ]
            ]
        ]


field :
    FormSetConfig msg
    ->
        { index : Int
        , length : Int
        , exclude : List Material.Id
        , valid : Bool
        }
    -> msg
    -> Inputs.MaterialInput
    -> Html msg
field config { index, length, valid } selectMaterial input =
    div [ class "mb-2" ]
        [ [ if length > 1 then
                [ button
                    [ class "btn btn-primary no-outline"
                    , onClick (config.remove index)
                    , disabled (length < 2)
                    , title "Supprimer cette matière"
                    , attribute "aria-label" "Supprimer cette matière"
                    , tabindex -1
                    ]
                    [ Icon.times ]
                ]

            else
                []
          , input.share
                |> shareField index
                    { length = length
                    , valid = valid
                    , selectInputText = config.selectInputText
                    , update = config.updateShare
                    }
          , materialSelector selectMaterial input
          ]
            |> List.concat
            |> div [ class "input-group" ]
        ]


materialSelector : msg -> Inputs.MaterialInput -> List (Html msg)
materialSelector event selectedMaterial =
    [ div
        [ class "form-select MaterialSelector"
        , style "overflow" "hidden"
        , style "white-space" "nowrap"
        , onClick event
        ]
        [ span
            [ style "display" "block"
            , style "overflow" "hidden"
            ]
            [ text selectedMaterial.material.name ]
        ]
    ]


shareField :
    Int
    ->
        { length : Int
        , valid : Bool
        , selectInputText : String -> msg
        , update : Int -> Split -> msg
        }
    -> Split
    -> List (Html msg)
shareField index { length, valid, selectInputText, update } share =
    let
        domId =
            "material-" ++ String.fromInt index
    in
    [ input
        [ type_ "number"
        , id domId
        , class "ShareInput form-control border-end-0 text-end pe-2"
        , classList
            [ ( "incdec-arrows-left", length > 1 )
            , ( "feedback-invalid", not valid )
            , ( "text-danger", not valid )
            ]
        , placeholder "100%"
        , maxlength 3
        , Attr.step "1"
        , Attr.min "0"
        , Attr.max "100"
        , Split.toPercentString share
            |> value
        , Attr.disabled <| length == 1
        , onInput
            (String.toInt
                >> Maybe.withDefault 0
                >> Split.fromPercent
                >> Result.toMaybe
                >> Maybe.withDefault Split.zero
                >> update index
            )
        , onFocus (selectInputText domId)
        ]
        []
    , span
        [ class "input-group-text px-1 fs-7"
        , classList [ ( "text-danger feedback-invalid", not valid ) ]
        ]
        [ text "%" ]
    ]
