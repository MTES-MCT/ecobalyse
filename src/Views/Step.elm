module Views.Step exposing (..)

import Data.Country as Country
import Data.Db exposing (Db)
import Data.Gitbook as Gitbook
import Data.Product exposing (Product)
import Data.Step as Step exposing (Step)
import Energy
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Views.Format as Format
import Views.Icon as Icon
import Views.RangeSlider as RangeSlider
import Views.Transport as TransportView


type alias Config msg =
    { db : Db
    , detailed : Bool
    , index : Int
    , product : Product
    , current : Step
    , next : Maybe Step
    , openDocModal : Gitbook.Path -> msg
    , updateCountry : Int -> Country.Code -> msg
    , updateDyeingWeighting : Maybe Float -> msg
    , updateAirTransportRatio : Maybe Float -> msg
    }


countryField : Config msg -> Html msg
countryField { db, current, index, updateCountry } =
    div []
        [ db.countries
            |> List.map
                (\{ code, name } ->
                    option
                        [ selected (current.country.code == code)
                        , value <| Country.codeToString code
                        ]
                        [ -- NOTE: because ADEME requires Asia as default for the Material & Spinning step,
                          -- we use Asia as a label and use China behind the scene
                          case current.label of
                            Step.MaterialAndSpinning ->
                                text "Asie"

                            _ ->
                                text name
                        ]
                )
            |> select
                [ class "form-select"
                , disabled (not current.editable)
                , onInput (Country.codeFromString >> updateCountry index)
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


airTransportRatioField : Config msg -> Html msg
airTransportRatioField { current, updateAirTransportRatio } =
    RangeSlider.view
        { id = "airTransportRatio"
        , update = updateAirTransportRatio
        , value = current.airTransportRatio
        , toString = Step.airTransportRatioToString
        , disabled = False
        }


dyeingWeightingField : Config msg -> Html msg
dyeingWeightingField { current, updateDyeingWeighting } =
    RangeSlider.view
        { id = "dyeingWeighting"
        , update = updateDyeingWeighting
        , value = current.dyeingWeighting
        , toString = Step.dyeingWeightingToString
        , disabled = False
        }


documentationLink : Config msg -> Step.Label -> Html msg
documentationLink { openDocModal } label =
    button
        [ class "btn btn-sm btn-primary rounded-pill fs-7 py-0"
        , onClick (openDocModal (Step.getStepGitbookPath label))
        ]
        [ span [ class "align-middle" ] [ Icon.question ]
        , span [] [ text " docs" ]
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
        [ div [ class "card-header" ]
            [ div [ class "row" ]
                [ div [ class "col-6 d-flex align-items-center" ]
                    [ span [ class "badge rounded-pill bg-primary me-1" ]
                        [ text (String.fromInt (index + 1)) ]
                    , text stepLabel
                    ]
                , div [ class "col-6 text-end" ]
                    [ documentationLink config current.label
                    ]
                ]
            ]
        , div [ class "card-body row align-items-center" ]
            [ div [ class "col-sm-6 col-lg-7" ]
                [ countryField config
                , case current.label of
                    Step.Ennoblement ->
                        div [ class "mt-2" ] [ dyeingWeightingField config ]

                    Step.Making ->
                        div [ class "mt-2" ] [ airTransportRatioField config ]

                    _ ->
                        text ""
                ]
            , div [ class "col-sm-6 col-lg-5 text-center text-muted" ]
                [ div []
                    [ if current.label /= Step.Distribution then
                        div [ class "fs-3 fw-normal text-secondary" ]
                            [ Format.kgCo2 3 current.co2 ]

                      else
                        text ""
                    , div [ class "fs-7" ]
                        [ span [ class "me-1 align-bottom" ] [ Icon.info ]
                        , text "Transport\u{00A0}"
                        , Format.kgCo2 3 current.transport.co2
                        ]
                    ]
                ]
            ]
        ]


documentationPillLink : Config msg -> Gitbook.Path -> Html msg
documentationPillLink { openDocModal } path =
    button
        [ class "btn btn-sm text-secondary text-decoration-none btn-link p-0 ms-1"
        , onClick (openDocModal path)
        ]
        [ Icon.question ]


detailedView : Config msg -> Html msg
detailedView ({ product, index, next, current } as config) =
    let
        transportLabel =
            case next of
                Just { country } ->
                    "Transport vers " ++ country.name

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
            [ div [ class "card-header d-flex justify-content-between align-items-center" ]
                [ span [ class "d-flex align-items-center" ]
                    [ span [ class "badge rounded-pill bg-primary me-1" ]
                        [ text (String.fromInt (index + 1)) ]
                    , text stepLabel
                    ]
                , documentationLink config current.label
                ]
            , ul [ class "list-group list-group-flush fs-7" ]
                [ li [ class "list-group-item text-muted" ] [ countryField config ]
                , listItem current.processInfo.heat
                , listItem current.processInfo.electricity
                ]
            , div [ class "card-body py-2 text-muted" ]
                [ case current.label of
                    Step.Ennoblement ->
                        dyeingWeightingField config

                    Step.Making ->
                        airTransportRatioField config

                    _ ->
                        text ""
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
                    , span [ class "d-flex align-items-center" ]
                        [ span [ class "me-1" ] [ text "Perte" ]
                        , Format.kg current.waste
                        , documentationPillLink config Gitbook.Waste
                        ]
                    ]
                , if Energy.inKilojoules current.heat > 0 || Energy.inKilowattHours current.kwh > 0 then
                    li [ class "list-group-item text-muted d-flex justify-content-around" ]
                        [ span [ class "d-flex align-items-center" ]
                            [ span [ class "me-1" ] [ text "Chaleur" ]
                            , Format.megajoules current.heat
                            , documentationPillLink config Gitbook.Heat
                            ]
                        , span [ class "d-flex align-items-center" ]
                            [ span [ class "me-1" ] [ text "Électricité" ]
                            , Format.kilowattHours current.kwh
                            , documentationPillLink config Gitbook.Electricity
                            ]
                        ]

                  else
                    text ""
                , li [ class "list-group-item text-muted" ]
                    [ TransportView.view True current.transport ]
                , li [ class "list-group-item text-muted d-flex justify-content-center align-items-center" ]
                    [ strong [] [ text <| transportLabel ++ "\u{00A0}:\u{00A0}" ]
                    , Format.kgCo2 3 current.transport.co2
                    , documentationPillLink config Gitbook.Transport
                    ]
                ]
            ]
        ]


view : Config msg -> Html msg
view config =
    if config.detailed then
        detailedView config

    else
        simpleView config
