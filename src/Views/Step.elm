module Views.Step exposing (view)

import Data.Country as Country
import Data.Db exposing (Db)
import Data.Gitbook as Gitbook
import Data.Impact as Impact
import Data.Inputs exposing (Inputs)
import Data.Step as Step exposing (Step)
import Data.Transport as Transport
import Data.Unit as Unit
import Energy
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Views.Button as Button
import Views.Format as Format
import Views.Icon as Icon
import Views.RangeSlider as RangeSlider
import Views.Transport as TransportView


type alias Config msg =
    { db : Db
    , inputs : Inputs
    , detailed : Bool
    , impact : Impact.Definition
    , index : Int
    , current : Step
    , next : Maybe Step
    , openDocModal : Gitbook.Path -> msg
    , openCustomCountryMixModal : Step -> msg
    , updateCountry : Int -> Country.Code -> msg
    , updateDyeingWeighting : Maybe Unit.Ratio -> msg
    , updateUseNbCycles : Maybe Int -> msg
    , updateAirTransportRatio : Maybe Unit.Ratio -> msg
    }


countryField : Config msg -> Html msg
countryField { db, current, inputs, index, updateCountry } =
    div []
        [ db.countries
            |> List.map
                (\{ code, name } ->
                    option
                        [ selected (current.country.code == code)
                        , value <| Country.codeToString code
                        ]
                        [ -- NOTE: display a continent instead of the country for the Material & Spinning step,
                          case current.label of
                            Step.MaterialAndSpinning ->
                                text inputs.material.continent

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

            Step.Use ->
                div [ class "form-text fs-7 mb-0" ]
                    [ Icon.exclamation
                    , text " Champ non paramétrable"
                    ]

            Step.EndOfLife ->
                div [ class "form-text fs-7 mb-0" ]
                    [ Icon.exclamation
                    , text " Champ non paramétrable"
                    ]

            _ ->
                text ""
        ]


airTransportRatioField : Config msg -> Html msg
airTransportRatioField { current, updateAirTransportRatio } =
    RangeSlider.ratio
        { id = "airTransportRatio"
        , update = updateAirTransportRatio
        , value = current.airTransportRatio
        , toString = Step.airTransportRatioToString
        , disabled = False
        }


dyeingWeightingField : Config msg -> Html msg
dyeingWeightingField { current, updateDyeingWeighting } =
    RangeSlider.ratio
        { id = "dyeingWeighting"
        , update = updateDyeingWeighting
        , value = current.dyeingWeighting
        , toString = Step.dyeingWeightingToString
        , disabled = False
        }


useNbCyclesField : Config msg -> Html msg
useNbCyclesField { current, updateUseNbCycles } =
    RangeSlider.int
        { id = "useNbCycles"
        , min = 0
        , max = 100
        , step = 1
        , update = updateUseNbCycles
        , value = current.useNbCycles
        , toString = Step.useNbCyclesToString
        , disabled = False
        }


inlineDocumentationLink : Config msg -> Gitbook.Path -> Html msg
inlineDocumentationLink { openDocModal } path =
    Button.smallPill
        [ onClick (openDocModal path) ]
        [ Icon.question ]


stepDocumentationLink : Config msg -> Step.Label -> Html msg
stepDocumentationLink { openDocModal } label =
    Button.docsPill
        [ onClick (openDocModal (Step.getStepGitbookPath label)) ]
        [ Icon.question, text "docs" ]


simpleView : Config msg -> Html msg
simpleView ({ inputs, impact, index, current } as config) =
    div [ class "card" ]
        [ div [ class "card-header" ]
            [ div [ class "row" ]
                [ div [ class "col-6 d-flex align-items-center" ]
                    [ span [ class "badge rounded-pill bg-primary me-1" ]
                        [ text (String.fromInt (index + 1)) ]
                    , current.label
                        |> Step.displayLabel { knitted = inputs.product.knitted }
                        |> text
                    ]
                , div [ class "col-6 text-end" ]
                    [ stepDocumentationLink config current.label
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

                    Step.Use ->
                        div [ class "mt-2" ] [ useNbCyclesField config ]

                    _ ->
                        text ""
                ]
            , div [ class "col-sm-6 col-lg-5 text-center text-muted" ]
                [ div []
                    [ if current.label /= Step.Distribution then
                        div [ class "fs-3 fw-normal text-secondary" ]
                            [ current.impacts |> Format.formatImpact impact
                            ]

                      else
                        text ""
                    , div [ class "fs-7" ]
                        [ span [ class "me-1 align-bottom" ] [ Icon.info ]
                        , text "Transport\u{00A0}"
                        , current.transport.impacts |> Format.formatImpact impact
                        ]
                    ]
                ]
            ]
        ]


truncatableProcessDescription : String -> Html msg
truncatableProcessDescription description =
    li
        [ class "list-group-item text-muted text-truncate"
        , title description
        , style "cursor" "help"
        ]
        [ text description ]


detailedView : Config msg -> Html msg
detailedView ({ inputs, impact, index, next, current } as config) =
    let
        transportLabel =
            case next of
                Just { country } ->
                    if country /= current.country then
                        "Transport vers " ++ country.name

                    else
                        "Transport"

                Nothing ->
                    "Transport"
    in
    div [ class "card-group" ]
        [ div [ class "card" ]
            [ div [ class "card-header d-flex justify-content-between align-items-center" ]
                [ span [ class "d-flex align-items-center" ]
                    [ span [ class "badge rounded-pill bg-primary me-1" ]
                        [ text (String.fromInt (index + 1)) ]
                    , current.label
                        |> Step.displayLabel { knitted = inputs.product.knitted }
                        |> text
                    ]
                , stepDocumentationLink config current.label
                ]
            , ul [ class "list-group list-group-flush fs-7" ]
                [ li [ class "list-group-item text-muted" ] [ countryField config ]
                , case current.processInfo.countryHeat of
                    Just countryHeat ->
                        truncatableProcessDescription countryHeat

                    Nothing ->
                        text ""
                , case current.processInfo.countryElec of
                    Just countryElec ->
                        li [ class "list-group-item d-flex justify-content-between text-muted" ]
                            [ span [] [ text countryElec ]
                            , if
                                List.member current.label
                                    [ Step.WeavingKnitting, Step.Ennoblement, Step.Making ]
                              then
                                Button.smallPill
                                    [ onClick (config.openCustomCountryMixModal current) ]
                                    [ Icon.pencil ]

                              else
                                text ""
                            ]

                    Nothing ->
                        text ""
                , case current.processInfo.useIroning of
                    Just process ->
                        truncatableProcessDescription process.name

                    Nothing ->
                        text ""
                , case current.processInfo.useNonIroning of
                    Just process ->
                        truncatableProcessDescription process.name

                    Nothing ->
                        text ""
                , case current.processInfo.passengerCar of
                    Just process ->
                        truncatableProcessDescription process.name

                    Nothing ->
                        text ""
                , case current.processInfo.endOfLife of
                    Just process ->
                        truncatableProcessDescription process.name

                    Nothing ->
                        text ""
                ]
            , case current.label of
                Step.Ennoblement ->
                    div [ class "card-body py-2 text-muted" ]
                        [ dyeingWeightingField config ]

                Step.Making ->
                    div [ class "card-body py-2 text-muted" ]
                        [ airTransportRatioField config
                        ]

                Step.Use ->
                    div [ class "card-body py-2 text-muted" ]
                        [ useNbCyclesField config ]

                _ ->
                    text ""
            ]
        , div
            [ class "card text-center" ]
            [ div [ class "card-header text-muted" ]
                [ if (current.impacts |> Impact.getImpact impact.trigram |> Unit.impactToFloat) > 0 then
                    span [ class "fw-bold" ]
                        [ current.impacts |> Format.formatImpact impact ]

                  else
                    text "\u{00A0}"
                ]
            , ul [ class "list-group list-group-flush fs-7" ]
                [ li [ class "list-group-item text-muted d-flex justify-content-around" ]
                    [ span [] [ text "Masse\u{00A0}: ", Format.kg current.inputMass ]
                    , span [ class "d-flex align-items-center" ]
                        [ span [ class "me-1" ] [ text "Perte" ]
                        , Format.kg current.waste
                        , inlineDocumentationLink config Gitbook.Waste
                        ]
                    ]
                , if Energy.inKilojoules current.heat > 0 || Energy.inKilowattHours current.kwh > 0 then
                    li [ class "list-group-item text-muted d-flex justify-content-around" ]
                        [ span [ class "d-flex align-items-center" ]
                            [ span [ class "me-1" ] [ text "Chaleur" ]
                            , Format.megajoules current.heat
                            , inlineDocumentationLink config Gitbook.Heat
                            ]
                        , span [ class "d-flex align-items-center" ]
                            [ span [ class "me-1" ] [ text "Électricité" ]
                            , Format.kilowattHours current.kwh
                            , inlineDocumentationLink config Gitbook.Electricity
                            ]
                        ]

                  else
                    text ""
                , if Transport.totalKm current.transport > 0 then
                    li [ class "list-group-item text-muted" ]
                        [ current.transport
                            |> TransportView.view
                                { fullWidth = True
                                , airTransportLabel = current.processInfo.airTransport |> Maybe.map .name
                                , seaTransportLabel = current.processInfo.seaTransport |> Maybe.map .name
                                , roadTransportLabel = current.processInfo.roadTransport |> Maybe.map .name
                                }
                        ]

                  else
                    text ""
                , if Transport.totalKm current.transport > 0 then
                    li [ class "list-group-item text-muted" ]
                        [ div [ class "d-flex justify-content-center align-items-center" ]
                            [ strong [] [ text <| transportLabel ++ "\u{00A0}:\u{00A0}" ]
                            , current.transport.impacts |> Format.formatImpact impact
                            , inlineDocumentationLink config Gitbook.Transport
                            ]
                        ]

                  else
                    text ""
                ]
            ]
        ]


view : Config msg -> Html msg
view config =
    if config.detailed then
        detailedView config

    else
        simpleView config
