module Views.Textile.Step exposing
    ( stepIcon
    , view
    )

import Data.Country as Country
import Data.Env as Env
import Data.Gitbook as Gitbook
import Data.Impact as Impact
import Data.Textile.Db exposing (Db)
import Data.Textile.Inputs as Inputs exposing (Inputs)
import Data.Textile.Product as Product
import Data.Textile.Step as Step exposing (Step)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Transport as Transport
import Data.Unit as Unit
import Duration exposing (Duration)
import Energy
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Textile.Simulator.ViewMode as ViewMode exposing (ViewMode)
import Views.Button as Button
import Views.CountrySelect
import Views.Format as Format
import Views.Icon as Icon
import Views.RangeSlider as RangeSlider
import Views.Transport as TransportView


type alias Config msg =
    { db : Db
    , inputs : Inputs
    , daysOfWear : Duration
    , viewMode : ViewMode
    , impact : Impact.Definition
    , funit : Unit.Functional
    , index : Int
    , current : Step
    , next : Maybe Step
    , toggleDisabledFading : Bool -> msg
    , toggleStep : Label -> msg
    , toggleStepViewMode : Int -> msg
    , updateCountry : Label -> Country.Code -> msg
    , updateDyeingWeighting : Maybe Unit.Ratio -> msg
    , updateQuality : Maybe Unit.Quality -> msg
    , updateReparability : Maybe Unit.Reparability -> msg
    , updateAirTransportRatio : Maybe Unit.Ratio -> msg
    , updateMakingWaste : Maybe Unit.Ratio -> msg
    , updateSurfaceMass : Maybe Unit.SurfaceMass -> msg
    , updatePicking : Maybe Unit.PickPerMeter -> msg
    }


stepIcon : Label -> Html msg
stepIcon label =
    case label of
        Label.Material ->
            Icon.material

        Label.Spinning ->
            Icon.thread

        Label.Fabric ->
            Icon.fabric

        Label.Dyeing ->
            Icon.dyeing

        Label.Making ->
            Icon.making

        Label.Distribution ->
            Icon.bus

        Label.Use ->
            Icon.use

        Label.EndOfLife ->
            Icon.recycle


countryField : Config msg -> Html msg
countryField { db, current, inputs, updateCountry } =
    let
        nonEditableCountry content =
            div [ class "fs-6 text-muted d-flex align-items-center gap-2 " ]
                [ span
                    [ class "cursor-help"
                    , title "Le pays n'est pas modifiable ?? cet ??tape"
                    ]
                    [ Icon.lock ]
                , content
                ]
    in
    div []
        [ case ( current.label, current.editable ) of
            ( Label.Material, _ ) ->
                nonEditableCountry
                    (case inputs.materials |> Inputs.getMainMaterial |> Result.map .geographicOrigin of
                        Ok geographicOrigin ->
                            text <| geographicOrigin ++ " (" ++ current.country.name ++ ")"

                        Err _ ->
                            -- Would mean materials list is basically empty, which should
                            -- (can) never happen at this stage in the views;
                            -- FIXME: move to use non-empty list at some point
                            text current.country.name
                    )

            ( _, False ) ->
                nonEditableCountry (text current.country.name)

            ( _, True ) ->
                Views.CountrySelect.view
                    { attributes =
                        [ class "form-select"
                        , disabled (not current.editable || not current.enabled)
                        , onInput (Country.codeFromString >> updateCountry current.label)
                        ]
                    , selectedCountry = current.country.code
                    , onSelect = updateCountry current.label
                    , countries = db.countries
                    }
        ]


airTransportRatioField : Config msg -> Html msg
airTransportRatioField { current, updateAirTransportRatio } =
    span
        [ title "Part de transport a??rien pour le transport entre la confection et l'entrep??t en France."
        ]
        [ RangeSlider.ratio
            { id = "airTransportRatio"
            , update = updateAirTransportRatio
            , value = current.airTransportRatio
            , toString = Step.airTransportRatioToString
            , disabled = not current.enabled
            , min = 0
            , max = 100
            }
        ]


dyeingWeightingField : Config msg -> Html msg
dyeingWeightingField { current, updateDyeingWeighting } =
    span
        [ [ "Proc??d?? repr??sentatif\u{00A0}: traitement tr??s efficace des eaux us??es."
          , "Proc??d?? majorant\u{00A0}: traitement inefficace des eaux us??es."
          ]
            |> String.join " "
            |> title
        ]
        [ RangeSlider.ratio
            { id = "dyeingWeighting"
            , update = updateDyeingWeighting
            , value = current.dyeingWeighting
            , toString = Step.dyeingWeightingToString
            , disabled = not current.enabled
            , min = 0
            , max = 100
            }
        ]


fadingField : Config msg -> Html msg
fadingField { inputs, toggleDisabledFading } =
    if inputs.product.making.fadable then
        label
            [ class "form-check form-switch form-check-label fs-7 pt-1 text-truncate"
            , title "D??lavage"
            ]
            [ input
                [ type_ "checkbox"
                , class "form-check-input no-outline"
                , checked (not (Maybe.withDefault False inputs.disabledFading))
                , onCheck (\checked -> toggleDisabledFading (not checked))
                ]
                []
            , if inputs.disabledFading == Just True then
                text "D??lavage d??sactiv??"

              else
                text "D??lavage activ??"
            ]

    else
        text ""


qualityField : Config msg -> Html msg
qualityField { current, updateQuality } =
    span
        [ [ "Le coefficient de qualit?? intrins??que repr??sente ?? quel point le produit va durer dans le temps."
          , "Il varie entre 0.67 (peu durable) et 1.45 (tr??s durable)."
          , "Il est calcul?? ?? partir du r??sultat d???une s??rie de tests de durabilit??."
          , "Il est utilis?? en coefficient multiplicateur du nombre de jours d???utilisation du produit."
          ]
            |> String.join " "
            |> title
        ]
        [ RangeSlider.quality
            { id = "quality"
            , update = updateQuality
            , value = current.quality
            , toString = Step.qualityToString
            , disabled = not current.enabled
            }
        ]


reparabilityField : Config msg -> Html msg
reparabilityField { current, updateReparability } =
    span
        [ [ "Le coefficient de r??parabilit?? repr??sente ?? quel point le produit est r??parable."
          , "Il varie entre 1 (peu r??parable) ?? 1.15 (tr??s r??parable)."
          , "Il est calcul?? ?? partir du r??sultat d???une s??rie de tests de r??parabilit??."
          , "Il est utilis?? en coefficient multiplicateur du nombre de jours d???utilisation du produit."
          ]
            |> String.join " "
            |> title
        ]
        [ RangeSlider.reparability
            { id = "reparability"
            , update = updateReparability
            , value = current.reparability
            , toString = Step.reparabilityToString
            , disabled = not current.enabled
            }
        ]


makingWasteField : Config msg -> Html msg
makingWasteField { current, inputs, updateMakingWaste } =
    span
        [ title "Taux personnalis?? de perte en confection, incluant notamment la d??coupe."
        ]
        [ RangeSlider.ratio
            { id = "makingWaste"
            , update = updateMakingWaste
            , value = Maybe.withDefault inputs.product.making.pcrWaste current.makingWaste
            , toString = Step.makingWasteToString
            , disabled = not current.enabled
            , min = 0
            , max = round <| Unit.ratioToFloat Env.maxMakingWasteRatio * 100
            }
        ]


pickingField : Config msg -> Unit.PickPerMeter -> Html msg
pickingField { current, updatePicking } defaultPicking =
    span
        [ [ "Le duitage correspond au nombre de fils de trame (aussi appel??s duites) par m??tre"
          , "pour un tissu. Ce param??tre est pris en compte car il est connect?? avec la consommation"
          , "??lectrique du m??tier ?? tisser. ?? grammage ??gal, plus le duitage est important,"
          , "plus la consommation d'??lectricit?? est ??lev??e."
          ]
            |> String.join " "
            |> title
        ]
        [ RangeSlider.picking
            { id = "picking"
            , update = updatePicking
            , value = Maybe.withDefault defaultPicking current.picking
            , toString = Step.pickingToString
            , disabled = not current.enabled
            }
        ]


surfaceMassField : Config msg -> Unit.SurfaceMass -> Html msg
surfaceMassField { current, updateSurfaceMass } defaultSurfaceMass =
    span
        [ [ "Le grammage de l'??toffe, exprim?? en gr/m??, repr??sente sa masse surfacique."
          ]
            |> String.join " "
            |> title
        ]
        [ RangeSlider.surfaceMass
            { id = "surface-density"
            , update = updateSurfaceMass
            , value = Maybe.withDefault defaultSurfaceMass current.surfaceMass
            , toString = Step.surfaceMassToString
            , disabled = not current.enabled
            }
        ]


inlineDocumentationLink : Config msg -> Gitbook.Path -> Html msg
inlineDocumentationLink _ path =
    Button.smallPillLink
        [ href (Gitbook.publicUrlFromPath path)
        , target "_blank"
        ]
        [ Icon.question ]


stepActions : Config msg -> Label -> Html msg
stepActions { current, viewMode, index, toggleStepViewMode } label =
    div [ class "StepActions btn-group" ]
        [ Button.docsPillLink
            [ class "btn btn-primary py-1 rounded-end"
            , classList [ ( "btn-secondary", not current.enabled ) ]
            , href (Gitbook.publicUrlFromPath (Label.toGitbookPath label))
            , title "Documentation"
            , target "_blank"
            ]
            [ Icon.question ]
        , Button.docsPill
            [ class "btn btn-primary py-1 rounded-start"
            , classList [ ( "btn-secondary", not current.enabled ) ]
            , case viewMode of
                ViewMode.Simple ->
                    title "D??tailler cette ??tape"

                _ ->
                    title "Affichage simplifi??"
            , onClick (toggleStepViewMode index)
            ]
            [ case viewMode of
                ViewMode.Dataviz ->
                    Icon.stats

                ViewMode.DetailedAll ->
                    Icon.zoomout

                ViewMode.DetailedStep currentIndex ->
                    if index == currentIndex then
                        Icon.zoomout

                    else
                        Icon.zoomin

                ViewMode.Simple ->
                    Icon.zoomin
            ]
        ]


stepHeader : Config msg -> Html msg
stepHeader { current, inputs, toggleStep } =
    label
        [ class "d-flex align-items-center cursor-pointer gap-2"
        , classList [ ( "text-secondary", not current.enabled ) ]
        , title
            (if current.enabled then
                "??tape activ??e, cliquez pour la d??sactiver"

             else
                "??tape desactiv??e, cliquez pour la r??activer"
            )
        ]
        [ input
            [ type_ "checkbox"
            , class "form-check-input mt-0 no-outline"
            , attribute "role" "switch"
            , checked current.enabled
            , onCheck (always (toggleStep current.label))
            ]
            []
        , span
            [ class "StepIcon bg-primary text-white rounded-pill"
            , classList [ ( "bg-secondary", not current.enabled ) ]
            ]
            [ stepIcon current.label ]
        , current.label
            |> Step.displayLabel
                { knitted = Product.isKnitted inputs.product
                , fadable = inputs.product.making.fadable
                }
            |> text
        ]


simpleView : Config msg -> Html msg
simpleView ({ funit, inputs, daysOfWear, impact, current } as config) =
    div [ class "card" ]
        [ div [ class "card-header" ]
            [ div [ class "row" ]
                [ div [ class "col-6" ] [ stepHeader config ]
                , div [ class "col-6 text-end" ]
                    [ stepActions config current.label
                    ]
                ]
            ]
        , div
            [ class "StepBody card-body row align-items-center"
            , classList [ ( "disabled", not current.enabled ) ]
            ]
            [ div [ class "col-sm-6 col-lg-7" ]
                [ countryField config
                , case current.label of
                    Label.Fabric ->
                        case inputs.product.fabric of
                            Product.Knitted _ ->
                                text ""

                            Product.Weaved _ defaultPicking defaultSurfaceMass ->
                                div [ class "mt-2 fs-7 text-muted" ]
                                    [ pickingField config defaultPicking
                                    , surfaceMassField config defaultSurfaceMass
                                    ]

                    Label.Dyeing ->
                        div [ class "mt-2" ]
                            [ dyeingWeightingField config ]

                    Label.Making ->
                        div [ class "mt-2" ]
                            [ makingWasteField config
                            , airTransportRatioField config
                            , fadingField config
                            ]

                    Label.Use ->
                        div [ class "mt-2" ]
                            [ qualityField config
                            , reparabilityField config
                            , daysOfWearInfo inputs
                            ]

                    _ ->
                        text ""
                ]
            , div [ class "col-sm-6 col-lg-5 text-center text-muted" ]
                [ div []
                    [ if current.label /= Label.Distribution then
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


daysOfWearInfo : Inputs -> Html msg
daysOfWearInfo inputs =
    let
        info =
            inputs.product.use
                |> Product.customDaysOfWear inputs.quality inputs.reparability
    in
    small [ class "fs-7 text-muted" ]
        [ span [ class "pe-1" ] [ Icon.info ]
        , Format.days info.daysOfWear
        , text " port??s, "
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


detailedView : Config msg -> Html msg
detailedView ({ inputs, funit, impact, daysOfWear, next, current } as config) =
    let
        transportLabel =
            case next of
                Just { country } ->
                    "Transport " ++ current.country.name ++ "\u{202F}???\u{202F}" ++ country.name

                Nothing ->
                    "Transport"
    in
    div [ class "card-group" ]
        [ div [ class "card" ]
            [ div [ class "card-header d-flex justify-content-between align-items-center" ]
                [ stepHeader config
                , -- Note: hide on desktop, show on mobile
                  div [ class "d-block d-sm-none" ]
                    [ stepActions config current.label
                    ]
                ]
            , ul
                [ class "StepBody list-group list-group-flush fs-7"
                , classList [ ( "disabled", not current.enabled ) ]
                ]
                [ li [ class "list-group-item text-muted" ] [ countryField config ]
                , viewProcessInfo current.processInfo.countryElec
                , viewProcessInfo current.processInfo.countryHeat
                , viewProcessInfo current.processInfo.distribution
                , viewProcessInfo current.processInfo.useIroning
                , viewProcessInfo current.processInfo.useNonIroning
                , viewProcessInfo current.processInfo.passengerCar
                , viewProcessInfo current.processInfo.endOfLife
                , viewProcessInfo current.processInfo.fabric
                , viewProcessInfo current.processInfo.making
                , if inputs.product.making.fadable && inputs.disabledFading /= Just True then
                    viewProcessInfo current.processInfo.fading

                  else
                    text ""
                ]
            , div
                [ class "StepBody card-body py-2 text-muted"
                , classList [ ( "disabled", not current.enabled ) ]
                ]
                (case current.label of
                    Label.Fabric ->
                        case inputs.product.fabric of
                            Product.Knitted _ ->
                                []

                            Product.Weaved _ defaultPicking defaultSurfaceMass ->
                                [ pickingField config defaultPicking
                                , surfaceMassField config defaultSurfaceMass
                                ]

                    Label.Dyeing ->
                        [ dyeingWeightingField config ]

                    Label.Making ->
                        [ makingWasteField config
                        , airTransportRatioField config
                        , fadingField config
                        ]

                    Label.Use ->
                        [ qualityField config
                        , reparabilityField config
                        , daysOfWearInfo inputs
                        ]

                    _ ->
                        []
                )
            ]
        , div
            [ class "card text-center mb-0" ]
            [ div [ class "card-header d-flex justify-content-end align-items-center text-muted" ]
                [ if (current.impacts |> Impact.getImpact impact.trigram |> Unit.impactToFloat) > 0 then
                    span [ class "fw-bold flex-fill" ]
                        [ current.impacts
                            |> Format.formatImpact funit impact daysOfWear
                        ]

                  else
                    span [] [ text "\u{00A0}" ]
                , -- Note: show on desktop, hide on mobile
                  div [ class "d-none d-sm-block" ] [ stepActions config current.label ]
                ]
            , ul
                [ class "StepBody list-group list-group-flush fs-7"
                , classList [ ( "disabled", not current.enabled ) ]
                ]
                [ li [ class "list-group-item text-muted d-flex justify-content-around" ]
                    [ span []
                        [ text "Masse entrante", br [] [], Format.kg current.inputMass ]
                    , span []
                        [ text "Masse sortante", br [] [], Format.kg current.outputMass ]
                    , span []
                        [ text "Perte"
                        , br [] []
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
                            [ span [ class "me-1" ] [ text "??lectricit??" ]
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
                , li [ class "list-group-item text-muted" ]
                    [ div [ class "d-flex justify-content-center align-items-center" ]
                        (if Transport.totalKm current.transport > 0 then
                            [ strong [] [ text <| transportLabel ++ "\u{00A0}:\u{00A0}" ]
                            , current.transport.impacts
                                |> Format.formatImpact funit impact daysOfWear
                            , inlineDocumentationLink config Gitbook.Transport
                            ]

                         else
                            [ text "Pas de transport" ]
                        )
                    ]
                ]
            ]
        ]


view : Config msg -> Html msg
view config =
    -- FIXME: Step views should decide what to render according to ViewMode; move
    -- decision to caller and use appropriate view functions accordingly
    case config.viewMode of
        ViewMode.Dataviz ->
            text ""

        ViewMode.DetailedAll ->
            detailedView config

        ViewMode.DetailedStep index ->
            if config.index == index then
                detailedView config

            else
                simpleView config

        ViewMode.Simple ->
            simpleView config
