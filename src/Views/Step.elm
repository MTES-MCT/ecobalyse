module Views.Step exposing (view)

import Data.Country as Country
import Data.Db exposing (Db)
import Data.Gitbook as Gitbook
import Data.Impact as Impact
import Data.Inputs as Inputs exposing (Inputs)
import Data.Product as Product
import Data.Step as Step exposing (Step)
import Data.Transport as Transport
import Data.Unit as Unit
import Duration exposing (Duration)
import Energy
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route
import Views.Button as Button
import Views.Format as Format
import Views.Icon as Icon
import Views.RangeSlider as RangeSlider
import Views.Transport as TransportView


type alias Config msg =
    { db : Db
    , inputs : Inputs
    , daysOfWear : Duration
    , detailed : Bool
    , impact : Impact.Definition
    , funit : Unit.Functional
    , index : Int
    , current : Step
    , next : Maybe Step
    , openDocModal : Gitbook.Path -> msg
    , updateCountry : Int -> Country.Code -> msg
    , updateDyeingWeighting : Maybe Unit.Ratio -> msg
    , updateQuality : Maybe Unit.Quality -> msg
    , updateAirTransportRatio : Maybe Unit.Ratio -> msg
    }


stepIcon : Step.Label -> Html msg
stepIcon label =
    span [ class "StepIcon bg-primary text-white rounded-pill" ]
        [ case label of
            Step.MaterialAndSpinning ->
                Icon.material

            Step.WeavingKnitting ->
                Icon.fabric

            Step.Ennoblement ->
                Icon.dyeing

            Step.Making ->
                Icon.making

            Step.Distribution ->
                Icon.bus

            Step.Use ->
                Icon.use

            Step.EndOfLife ->
                Icon.recycle
        ]


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
                                inputs.materials
                                    |> List.head
                                    |> Maybe.map (.material >> .continent)
                                    |> Maybe.withDefault "N/A"
                                    |> text

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
    span
        [ title "Part de transport aérien pour le transport entre la confection et l'entrepôt en France."
        ]
        [ RangeSlider.ratio
            { id = "airTransportRatio"
            , update = updateAirTransportRatio
            , value = current.airTransportRatio
            , toString = Step.airTransportRatioToString
            , disabled = False
            }
        ]


dyeingWeightingField : Config msg -> Html msg
dyeingWeightingField { current, updateDyeingWeighting } =
    span
        [ [ "Procédé représentatif\u{00A0}: traitement très efficace des eaux usées."
          , "Procédé majorant\u{00A0}: traitement inefficace des eaux usées."
          ]
            |> String.join " "
            |> title
        ]
        [ RangeSlider.ratio
            { id = "dyeingWeighting"
            , update = updateDyeingWeighting
            , value = current.dyeingWeighting
            , toString = Step.dyeingWeightingToString
            , disabled = False
            }
        ]


qualityField : Config msg -> Html msg
qualityField { current, updateQuality } =
    span
        [ [ "Le coefficient de qualité intrinsèque représente à quel point le produit va durer dans le temps."
          , "Il varie entre 0.67 (peu durable) et 1.45 (très durable)."
          , "Il est calculé à partir du résultat d’une série de tests de durabilité."
          , "Il est utilisé en coefficient multiplicateur du nombre de jours d’utilisation du produit."
          ]
            |> String.join " "
            |> title
        ]
        [ RangeSlider.quality
            { id = "quality"
            , update = updateQuality
            , value = current.quality
            , toString = Step.qualityToString
            , disabled = False
            }
        ]


inlineDocumentationLink : Config msg -> Gitbook.Path -> Html msg
inlineDocumentationLink { openDocModal } path =
    Button.smallPill
        [ onClick (openDocModal path) ]
        [ Icon.question ]


stepActions : Config msg -> Step.Label -> Html msg
stepActions { detailed, inputs, impact, funit, openDocModal } label =
    div [ class "btn-group" ]
        [ button
            [ class "d-inline-flex align-items-center"
            , class "btn btn-secondary btn-sm gap-1 rounded-pill fs-7 py-1 rounded-end"
            , onClick (openDocModal (Step.getStepGitbookPath label))
            , title "Documentation"
            ]
            [ Icon.question ]
        , let
            query =
                Inputs.toQuery inputs
          in
          a
            [ class "d-inline-flex align-items-center"
            , class "btn btn-secondary btn-sm gap-1 rounded-pill fs-7 py-1 rounded-start"
            , title <|
                "Affichage "
                    ++ (if detailed then
                            "simplifié"

                        else
                            "détaillé"
                       )
            , Just query
                |> Route.Simulator impact.trigram funit { detailed = not detailed }
                |> Route.href
            ]
            [ if detailed then
                Icon.zoomout

              else
                Icon.zoomin
            ]
        ]


simpleView : Config msg -> Html msg
simpleView ({ funit, inputs, daysOfWear, impact, current } as config) =
    div [ class "card" ]
        [ div [ class "card-header" ]
            [ div [ class "row" ]
                [ div [ class "col-6 d-flex align-items-center" ]
                    [ stepIcon current.label
                    , current.label
                        |> Step.displayLabel { knitted = inputs.product.knitted }
                        |> text
                    ]
                , div [ class "col-6 text-end" ]
                    [ stepActions config current.label
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
                        div [ class "mt-2" ] [ qualityField config ]

                    _ ->
                        text ""
                ]
            , div [ class "col-sm-6 col-lg-5 text-center text-muted" ]
                [ div []
                    [ if current.label /= Step.Distribution then
                        div [ class "fs-3 fw-normal text-secondary" ]
                            [ current.impacts
                                |> Format.formatImpact funit impact daysOfWear
                            ]

                      else
                        text ""
                    , div [ class "fs-7" ]
                        [ span [ class "me-1 align-bottom" ] [ Icon.info ]
                        , text "Transport\u{00A0}"
                        , current.transport.impacts
                            |> Format.formatImpact funit impact daysOfWear
                        ]
                    ]
                ]
            ]
        ]


viewProcessInfo : Maybe String -> Html msg
viewProcessInfo processName =
    case processName of
        Just name ->
            li
                [ class "list-group-item text-muted text-truncate"
                , title name
                , style "cursor" "help"
                ]
                [ text name ]

        Nothing ->
            text ""


detailedView : Config msg -> Html msg
detailedView ({ inputs, funit, impact, daysOfWear, next, current } as config) =
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
                    [ stepIcon current.label
                    , current.label
                        |> Step.displayLabel { knitted = inputs.product.knitted }
                        |> text
                    ]
                , stepActions config current.label
                ]
            , ul [ class "list-group list-group-flush fs-7" ]
                [ li [ class "list-group-item text-muted" ] [ countryField config ]
                , viewProcessInfo current.processInfo.countryElec
                , viewProcessInfo current.processInfo.countryHeat
                , viewProcessInfo current.processInfo.distribution
                , viewProcessInfo current.processInfo.useIroning
                , viewProcessInfo current.processInfo.useNonIroning
                , viewProcessInfo current.processInfo.passengerCar
                , viewProcessInfo current.processInfo.endOfLife
                , viewProcessInfo current.processInfo.knittingWeaving
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
                    let
                        info =
                            inputs.product
                                |> Product.customDaysOfWear inputs.quality
                    in
                    div [ class "card-body py-2 text-muted" ]
                        [ qualityField config
                        , small [ class "fs-7" ]
                            [ Format.days info.daysOfWear
                            , text " portés, "
                            , text <| String.fromInt info.useNbCycles
                            , text <|
                                " cycle"
                                    ++ (if info.useNbCycles > 1 then
                                            "s"

                                        else
                                            ""
                                       )
                                    ++ " d'entretien"
                            ]
                        ]

                _ ->
                    text ""
            ]
        , div
            [ class "card text-center mb-0" ]
            [ div [ class "card-header text-muted" ]
                [ if (current.impacts |> Impact.getImpact impact.trigram |> Unit.impactToFloat) > 0 then
                    span [ class "fw-bold" ]
                        [ current.impacts
                            |> Format.formatImpact funit impact daysOfWear
                        ]

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
                                , airTransportLabel = current.processInfo.airTransport
                                , seaTransportLabel = current.processInfo.seaTransport
                                , roadTransportLabel = current.processInfo.roadTransport
                                }
                        ]

                  else
                    text ""
                , if Transport.totalKm current.transport > 0 then
                    li [ class "list-group-item text-muted" ]
                        [ div [ class "d-flex justify-content-center align-items-center" ]
                            [ strong [] [ text <| transportLabel ++ "\u{00A0}:\u{00A0}" ]
                            , current.transport.impacts
                                |> Format.formatImpact funit impact daysOfWear
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
