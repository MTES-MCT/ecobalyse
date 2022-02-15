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
            [ div [ class "col-7 fw-bold" ] [ text "Matières premières" ]
            , div [ class "col-5 fw-bold" ] [ text "Part d'origine recyclée" ]
            ]
         ]
            ++ fields
            ++ [ div [ class "row mb-2" ]
                    [ div [ class "col-7" ]
                        [ div [ class "input-group" ]
                            [ if length > 1 then
                                span
                                    [ class "form-control text-end"
                                    , class "d-flex justify-content-between align-items-center gap-1"
                                    , classList
                                        [ ( "text-success feedback-valid", valid )
                                        , ( "text-danger feedback-invalid", not valid )
                                        ]
                                    , style "width" "125px"
                                    , style "min-width" "125px"
                                    , style "max-width" "125px"
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
                                , class "d-flex justify-content-center align-items-center gap-1"
                                , onClick config.add
                                , disabled <| length >= 3
                                ]
                                [ Icon.plus
                                , text "Ajouter une matière"
                                ]
                            ]
                        ]
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
        [ div [ class "col-7" ]
            [ [ if length > 1 then
                    [ button
                        [ class "btn btn-primary"
                        , onClick (config.remove index)
                        , disabled <| length < 2
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
                        , update = config.updateShare
                        }
              , input.material.id
                    |> materialSelector index
                        { materials = config.db.materials
                        , exclude = exclude
                        , update = config.update
                        }
              ]
                |> List.concat
                |> div [ class "input-group" ]
            ]
        , div [ class "col-5" ]
            [ input
                |> recycledRatioField index config.updateRecycledRatio
            ]
        ]


materialSelector :
    Int
    ->
        { materials : List Material
        , exclude : List Material.Id
        , update : Int -> Material.Id -> msg
        }
    -> Material.Id
    -> List (Html msg)
materialSelector index { materials, exclude, update } id =
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
    [ [ toGroup "Matières naturelles" natural1
      , toGroup "Matières synthétiques" synthetic1
      , toGroup "Matières recyclées" recycled1
      , toGroup "Autres matières naturelles" natural2
      , toGroup "Autres matières synthétiques" synthetic2
      , toGroup "Autres matières recyclées" recycled2
      ]
        |> select
            [ Attr.id "material"
            , class "form-select flex-fill"
            , onInput (Material.Id >> update index)
            ]
    ]


shareField :
    Int
    -> { length : Int, valid : Bool, update : Int -> Unit.Ratio -> msg }
    -> Unit.Ratio
    -> List (Html msg)
shareField index { length, valid, update } share =
    [ Html.input
        [ type_ "number"
        , class "form-control bg-white border-end-0 text-end pe-2"
        , classList
            [ ( "incdec-arrows-left", length > 1 )
            , ( "feedback-valid", valid )
            , ( "feedback-invalid", not valid )
            , ( "text-danger", not valid )
            ]
        , style "flex" ".5 1 auto"
        , style "max-width" "70px"
        , placeholder "100%"
        , maxlength 3
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
        [ class "input-group-text bg-white ps-0 pe-1 fs-7"
        , classList [ ( "text-danger", not valid ) ]
        ]
        [ text "%" ]
    ]


recycledRatioField :
    Int
    -> (Int -> Unit.Ratio -> msg)
    -> Inputs.MaterialInput
    -> Html msg
recycledRatioField index update { material, recycledRatio } =
    div [ class "d-flex gap-2 align-items-center" ]
        [ span [ class "fs-5 text-primary lh-1" ] [ Icon.recycle ]
        , input
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
