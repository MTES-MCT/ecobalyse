module Views.Material exposing (formSet)

import Data.Db exposing (Db)
import Data.Inputs as Inputs
import Data.Material as Material exposing (Material)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Views.Format as Format
import Views.Icon as Icon


type alias FormSetConfig msg =
    { db : Db
    , materials : List Inputs.MaterialInput
    , add : msg
    , remove : Int -> msg
    , update : Int -> Material.Id -> msg
    , updateRecycledRatio : Int -> Unit.Ratio -> msg
    , updateShare : Int -> Unit.Ratio -> msg
    }


formSet : FormSetConfig msg -> Html msg
formSet ({ materials } as config) =
    let
        ( length, exclude ) =
            ( List.length materials
            , List.map (.material >> .id) materials
            )

        totalShares =
            materials
                |> List.map (.share >> Unit.ratioToFloat)
                |> List.sum

        valid =
            round (totalShares * 100) == 100

        fields =
            materials
                |> List.indexedMap
                    (\index ->
                        field config
                            { index = index
                            , length = length
                            , exclude = exclude
                            , valid = valid
                            }
                    )
    in
    div []
        ([ div [ class "row mb-2" ]
            [ div [ class "col-6 fw-bold" ] [ text "Matières premières" ]
            , div [ class "col-3 fw-bold" ] [ text "Part recyclée" ]
            , div [ class "col-3 fw-bold" ] [ text "Part du vêtement" ]
            ]
         ]
            ++ fields
            ++ [ div [ class "row d-flex align-items-center mb-2" ]
                    [ div [ class "col-8 col-sm-6" ]
                        [ button
                            [ class "btn btn-outline-primary w-100 d-flex justify-content-center align-items-center gap-1"
                            , onClick config.add
                            , disabled <| length >= 3
                            ]
                            [ Icon.plus
                            , text "Ajouter une matière"
                            ]
                        ]
                    , div [ class "d-none d-sm-block col-sm-3" ] []
                    , if length > 1 then
                        div [ class "col-4 col-sm-3" ]
                            [ div [ class "input-group" ]
                                [ span
                                    [ class "form-control text-end d-flex justify-content-between align-items-center gap-1"
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
                                    ]
                                , span
                                    [ class "input-group-text fs-7"
                                    , classList [ ( "bg-danger", not valid ), ( "text-white", not valid ) ]
                                    ]
                                    [ text "%" ]
                                ]
                            ]

                      else
                        text ""
                    ]
               ]
        )


field :
    FormSetConfig msg
    ->
        { index : Int
        , length : Int
        , exclude : List Material.Id
        , valid : Bool
        }
    -> Inputs.MaterialInput
    -> Html msg
field config { index, length, exclude, valid } input =
    div [ class "row mb-2 d-flex align-items-center" ]
        [ div [ class "col-6" ]
            [ input.material.id
                |> materialSelector index
                    { materials = config.db.materials
                    , exclude = exclude
                    , length = length
                    , remove = config.remove
                    , update = config.update
                    }
            ]
        , div [ class "col-3" ]
            [ input
                |> recycledRatioField index config.updateRecycledRatio
            ]
        , div [ class "col-3" ]
            [ input.share
                |> shareField index
                    { length = length
                    , valid = valid
                    , update = config.updateShare
                    }
            ]
        ]


materialSelector :
    Int
    ->
        { materials : List Material
        , exclude : List Material.Id
        , length : Int
        , remove : Int -> msg
        , update : Int -> Material.Id -> msg
        }
    -> Material.Id
    -> Html msg
materialSelector index { materials, exclude, length, remove, update } id =
    let
        ( ( natural1, synthetic1, recycled1 ), ( natural2, synthetic2, recycled2 ) ) =
            Material.groupAll materials

        toOption m =
            option
                [ value <| Material.idToString m.id
                , selected <| id == m.id
                , disabled <| List.member m.id exclude
                , title m.name
                ]
                [ text m.shortName ]

        toGroup name materials_ =
            if materials == [] then
                text ""

            else
                materials_
                    |> List.map toOption
                    |> optgroup [ attribute "label" name ]
    in
    div [ class "input-group" ]
        [ if length > 1 then
            button
                [ class "btn btn-primary"
                , onClick (remove index)
                , disabled <| length < 2
                , tabindex -1
                ]
                [ Icon.times ]

          else
            text ""
        , [ toGroup "Matières naturelles" natural1
          , toGroup "Matières synthétiques" synthetic1
          , toGroup "Matières recyclées" recycled1
          , toGroup "Autres matières naturelles" natural2
          , toGroup "Autres matières synthétiques" synthetic2
          , toGroup "Autres matières recyclées" recycled2
          ]
            |> select
                [ Attr.id "material"
                , class "form-select"
                , onInput (Material.Id >> update index)
                ]
        ]


shareField :
    Int
    -> { length : Int, valid : Bool, update : Int -> Unit.Ratio -> msg }
    -> Unit.Ratio
    -> Html msg
shareField index { length, valid, update } share =
    div [ class "d-flex gap-1 align-items-center" ]
        [ div [ class "input-group" ]
            [ Html.input
                [ type_ "number"
                , class "form-control text-end pe-2"
                , classList
                    [ ( "incdec-arrows-left", length > 1 )
                    , ( "feedback-valid", valid )
                    , ( "feedback-invalid", not valid )
                    ]
                , placeholder "100%"
                , Attr.step "1"
                , Attr.min "0"
                , Attr.max "100"
                , Unit.ratioToFloat share
                    * 100
                    |> round
                    |> clamp 0 100
                    |> String.fromInt
                    |> value
                , Attr.disabled <| length == 1
                , onInput
                    (String.toInt
                        >> Maybe.withDefault 0
                        >> (\int -> toFloat int / 100)
                        >> Unit.ratio
                        >> update index
                    )
                ]
                []
            , span
                [ class "d-none d-sm-block input-group-text fs-7"
                , classList [ ( "bg-danger", not valid ), ( "text-white", not valid ) ]
                ]
                [ text "%" ]
            ]
        ]


recycledRatioField :
    Int
    -> (Int -> Unit.Ratio -> msg)
    -> Inputs.MaterialInput
    -> Html msg
recycledRatioField index update { material, recycledRatio } =
    div [ class "d-flex gap-1 align-items-center" ]
        [ input
            [ type_ "range"
            , class "d-block form-range"
            , onInput
                (String.toFloat
                    >> Maybe.withDefault 0
                    >> Unit.ratio
                    >> update index
                )
            , Attr.min "0"
            , Attr.max "1"
            , step "0.01"

            -- Note: 'value' attr should always be set after 'step' attr
            , recycledRatio |> Unit.ratioToFloat |> String.fromFloat |> value
            , Attr.disabled <| material.recycledProcess == Nothing
            ]
            []
        , div [ class "fs-7 text-end", style "min-width" "34px" ]
            [ Format.ratioToDecimals 0 recycledRatio
            ]
        ]
