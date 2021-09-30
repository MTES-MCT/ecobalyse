module Views.Step exposing (..)

import Data.Country as Country exposing (Country)
import Data.Product exposing (Product)
import Data.Step as Step exposing (Label(..), Step)
import Energy
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Views.Format as Format
import Views.Icon as Icon
import Views.Transport as TransportView


type alias Config msg =
    { detailed : Bool
    , index : Int
    , product : Product
    , current : Step
    , next : Maybe Step
    , updateCountry : Int -> Country -> msg
    , updateDyeingWeighting : Maybe Float -> msg
    }


dyeingWeightingField : Config msg -> Html msg
dyeingWeightingField { current, updateDyeingWeighting } =
    div [ class "d-flex justify-content-between mt-2", style "height" "1em" ]
        [ label [ for "dyeingWeighting", class "form-label fs-7", style "margin-top" "2px" ]
            [ text <| Step.dyeingWeightingToString current.dyeingWeighting ]
        , input
            [ type_ "range"
            , class "form-range"
            , style "width" "50%"
            , id "dyeingWeighting"
            , onInput (String.toFloat >> updateDyeingWeighting)
            , value (String.fromFloat current.dyeingWeighting)
            , Attr.min "0"
            , Attr.max "1"
            , step "0.1"
            ]
            []
        ]


countryField : Config msg -> Html msg
countryField { current, index, updateCountry } =
    div []
        [ Country.choices
            |> List.map
                (\c ->
                    option [ selected (current.country == c) ]
                        [ text (Step.countryLabel { current | country = c }) ]
                )
            |> select
                [ class "form-select"
                , disabled (not current.editable)
                , onInput (Country.fromString >> updateCountry index)
                ]
        , case current.label of
            Step.MaterialAndSpinning ->
                div [ class "form-text fs-7 mb-0" ]
                    [ Icon.info
                    , text " Ce champ sera bientôt paramétrable"
                    ]

            Step.Distribution ->
                div [ class "form-text fs-7 mb-0" ]
                    [ Icon.exclamation
                    , text " Champ non paramétrable"
                    ]

            _ ->
                text ""
        ]


simpleView : Config msg -> Html msg
simpleView ({ product, index, current } as config) =
    let
        stepLabel =
            case ( current.label, product.knitted ) of
                ( Step.WeavingKnitting, True ) ->
                    "Tricotage"

                ( Step.WeavingKnitting, False ) ->
                    "Tissage"

                _ ->
                    Step.labelToString current.label
    in
    div [ class "card" ]
        [ div [ class "card-header d-flex align-items-center" ]
            [ span [ class "badge rounded-pill bg-primary me-1" ]
                [ text (String.fromInt (index + 1)) ]
            , text stepLabel
            ]
        , div [ class "card-body row align-items-center" ]
            [ div [ class "col-sm-6 col-lg-7" ]
                [ countryField config
                , if current.label == Step.Ennoblement then
                    dyeingWeightingField config

                  else
                    text ""
                ]
            , div [ class "col-sm-6 col-lg-5 text-center text-muted" ]
                [ if current.label == Step.Distribution && current.co2 == 0 then
                    div [ class "fs-7" ]
                        [ Icon.info
                        , text " Le coût du transport a été ajouté au transport total"
                        ]

                  else
                    div [ class "fs-3 fw-normal text-secondary" ]
                        [ Format.kgCo2 3 current.co2 ]
                ]
            ]
        ]


detailedView : Config msg -> Html msg
detailedView ({ product, index, next, current } as config) =
    let
        transportLabel =
            case next of
                Just { country } ->
                    "Transport vers " ++ Country.toString country

                Nothing ->
                    "Transport"

        stepLabel =
            case ( current.label, product.knitted ) of
                ( Step.WeavingKnitting, True ) ->
                    "Tricotage"

                ( Step.WeavingKnitting, False ) ->
                    "Tissage"

                _ ->
                    Step.labelToString current.label

        listItem maybeValue =
            case maybeValue of
                Just value ->
                    li [ class "list-group-item text-muted" ] [ text value ]

                Nothing ->
                    text ""
    in
    div [ class "card-group" ]
        [ div [ class "card" ]
            [ div [ class "card-header d-flex align-items-center" ]
                [ span [ class "badge rounded-pill bg-primary me-1" ]
                    [ text (String.fromInt (index + 1)) ]
                , text stepLabel
                ]
            , ul [ class "list-group list-group-flush fs-7" ]
                [ li [ class "list-group-item text-muted" ] [ countryField config ]
                , listItem current.processInfo.heat
                , listItem current.processInfo.electricity
                , listItem current.processInfo.dyeingWeighting
                ]
            ]
        , div
            [ class "card text-center" ]
            [ div [ class "card-header text-muted" ]
                [ if current.co2 > 0 then
                    span [ class "fw-bold" ] [ Format.kgCo2 3 current.co2 ]

                  else
                    text "\u{00A0}"
                ]
            , ul [ class "list-group list-group-flush fs-7" ]
                [ li [ class "list-group-item text-muted d-flex justify-content-around" ]
                    [ span [] [ text "Masse\u{00A0}: ", Format.kg current.mass ]
                    , span [] [ text "Perte\u{00A0}: ", Format.kg current.waste ]
                    ]
                , if Energy.inKilojoules current.heat > 0 || Energy.inKilowattHours current.kwh > 0 then
                    li [ class "list-group-item text-muted d-flex justify-content-around" ]
                        [ span [] [ text "Chaleur\u{00A0}: ", Format.megajoules current.heat ]
                        , span [] [ text "Électricité\u{00A0}: ", Format.kilowattHours current.kwh ]
                        ]

                  else
                    text ""
                , li [ class "list-group-item text-muted" ]
                    [ TransportView.view True current.transport ]
                , li [ class "list-group-item text-muted" ]
                    [ strong [] [ text <| transportLabel ++ "\u{00A0}:\u{00A0}" ]
                    , Format.kgCo2 3 current.transport.co2
                    ]
                ]
            ]
        ]


view : Config msg -> Html msg
view ({ detailed } as config) =
    if detailed then
        detailedView config

    else
        simpleView config
