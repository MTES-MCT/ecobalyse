module Views.Textile.Step exposing
    ( stepIcon
    , view
    )

import Data.Country as Country
import Data.Env as Env
import Data.Gitbook as Gitbook
import Data.Impact as Impact
import Data.Scope as Scope
import Data.Split as Split exposing (Split)
import Data.Textile.Db exposing (Db)
import Data.Textile.DyeingMedium as DyeingMedium exposing (DyeingMedium)
import Data.Textile.HeatSource as HeatSource exposing (HeatSource)
import Data.Textile.Inputs as Inputs exposing (Inputs)
import Data.Textile.Knitting as Knitting exposing (Knitting)
import Data.Textile.Printing as Printing exposing (Printing)
import Data.Textile.Product as Product exposing (Product)
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
    , updateQuality : Maybe Unit.Quality -> msg
    , updateReparability : Maybe Unit.Reparability -> msg
    , updateAirTransportRatio : Maybe Split -> msg
    , updateDyeingMedium : DyeingMedium -> msg
    , updateEnnoblingHeatSource : Maybe HeatSource -> msg
    , updateKnittingProcess : Knitting -> msg
    , updatePrinting : Maybe Printing -> msg
    , updateMakingWaste : Maybe Split -> msg
    , updateSurfaceMass : Maybe Unit.SurfaceMass -> msg
    , updateYarnSize : Maybe Unit.YarnSize -> msg
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

        Label.Ennobling ->
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
                    , title "Le pays n'est pas modifiable à cet étape"
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
                    , countries = db.countries
                    , onSelect = updateCountry current.label
                    , scope = Scope.Textile
                    , selectedCountry = current.country.code
                    }
        ]


airTransportRatioField : Config msg -> Html msg
airTransportRatioField { current, updateAirTransportRatio } =
    span
        [ title "Part de transport aérien pour le transport entre la confection et l'entrepôt en France."
        ]
        [ RangeSlider.percent
            { id = "airTransportRatio"
            , update = updateAirTransportRatio
            , value = current.airTransportRatio
            , toString = Step.airTransportRatioToString
            , disabled = not current.enabled
            , min = 0
            , max = 100
            }
        ]


dyeingMediumField : Config msg -> Html msg
dyeingMediumField { inputs, updateDyeingMedium } =
    div [ class "d-flex justify-content-between align-items-center fs-7" ]
        [ label [ class "text-truncate w-25", for "dyeing-medium", title "Teinture sur" ]
            [ text "Teinture sur" ]
        , [ DyeingMedium.Yarn, DyeingMedium.Fabric, DyeingMedium.Article ]
            |> List.map
                (\medium ->
                    option
                        [ value <| DyeingMedium.toString medium
                        , selected <| inputs.dyeingMedium == Just medium || inputs.product.dyeing.defaultMedium == medium
                        ]
                        [ text <| DyeingMedium.toLabel medium ]
                )
            |> select
                [ id "dyeing-medium"
                , class "form-select form-select w-75"
                , onInput
                    (DyeingMedium.fromString
                        >> Result.withDefault inputs.product.dyeing.defaultMedium
                        >> updateDyeingMedium
                    )
                ]
        ]


knittingProcessField : Config msg -> Html msg
knittingProcessField { inputs, updateKnittingProcess } =
    -- Note: This field is only rendered in the detailed step view
    li [ class "list-group-item text-muted d-flex align-items-center gap-2" ]
        [ label [ class "text-nowrap w-25", for "knitting-process" ] [ text "Procédé" ]
        , [ Knitting.Mix
          , Knitting.FullyFashioned
          , Knitting.Seamless
          , Knitting.Circular
          , Knitting.Straight
          ]
            |> List.map
                (\knittingProcess ->
                    option
                        [ value <| Knitting.toString knittingProcess
                        , selected <| inputs.knittingProcess == Just knittingProcess
                        ]
                        [ text <| Knitting.toLabel knittingProcess ]
                )
            |> select
                [ id "knitting-process"
                , class "form-select form-select-sm w-75"
                , onInput
                    (Knitting.fromString
                        >> Result.withDefault Knitting.Mix
                        >> updateKnittingProcess
                    )
                ]
        ]


printingFields : Config msg -> Html msg
printingFields { inputs, updatePrinting } =
    div [ class "d-flex justify-content-between align-items-center fs-7" ]
        [ label [ class "text-truncate w-25", for "ennobling-printing", title "Impression" ]
            [ text "Impression" ]
        , div [ class "d-flex justify-content-between align-items-center gap-1 w-75" ]
            [ [ Printing.Pigment, Printing.Substantive ]
                |> List.map
                    (\kind ->
                        option
                            [ value (Printing.toString kind)
                            , selected <| Maybe.map .kind inputs.printing == Just kind
                            ]
                            [ text <| Printing.kindLabel kind ]
                    )
                |> (::) (option [ selected <| inputs.printing == Nothing ] [ text "Aucune" ])
                |> select
                    [ id "ennobling-printing"
                    , class "form-select form-select"
                    , style "flex" "2"
                    , onInput
                        (\str ->
                            updatePrinting
                                (case Printing.fromString str of
                                    Ok kind ->
                                        case inputs.printing of
                                            Just printing ->
                                                Just { printing | kind = kind }

                                            Nothing ->
                                                Just { kind = kind, ratio = Printing.defaultRatio }

                                    Err _ ->
                                        -- Note: we've most likely received the "Aucune" string value from
                                        -- when the user picked this choice, so it's fair to reset any
                                        -- previously selected printing process.
                                        Nothing
                                )
                        )
                    ]
            , case inputs.printing of
                Just { ratio } ->
                    [ 100, 50, 20, 5, 1 ]
                        |> List.map
                            (\percent ->
                                option
                                    [ value (String.fromFloat percent)
                                    , selected <| ratio == Split.full
                                    ]
                                    [ text <| String.fromFloat percent ++ "%" ]
                            )
                        |> select
                            [ class "form-select form-select"
                            , style "flex" "1"
                            , disabled <| inputs.printing == Nothing
                            , onInput
                                (\str ->
                                    case String.toInt str of
                                        Just percent ->
                                            inputs.printing
                                                |> Maybe.map
                                                    (\p ->
                                                        { p
                                                            | ratio =
                                                                Split.fromPercent percent
                                                                    |> Result.toMaybe
                                                                    |> Maybe.withDefault Split.zero
                                                        }
                                                    )
                                                |> updatePrinting

                                        Nothing ->
                                            updatePrinting Nothing
                                )
                            ]

                Nothing ->
                    text ""
            ]
        ]


fadingField : Config msg -> Html msg
fadingField { inputs, toggleDisabledFading } =
    if inputs.product.making.fadable then
        label
            [ class "form-check form-switch form-check-label fs-7 pt-1 text-truncate"
            , title "Délavage"
            ]
            [ input
                [ type_ "checkbox"
                , class "form-check-input no-outline"
                , checked (not (Maybe.withDefault False inputs.disabledFading))
                , onCheck (\checked -> toggleDisabledFading (not checked))
                ]
                []
            , if inputs.disabledFading == Just True then
                text "Délavage désactivé"

              else
                text "Délavage activé"
            ]

    else
        text ""


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
            , disabled = not current.enabled
            }
        ]


reparabilityField : Config msg -> Html msg
reparabilityField { current, updateReparability } =
    span
        [ [ "Le coefficient de réparabilité représente à quel point le produit est réparable."
          , "Il varie entre 1 (peu réparable) à 1.15 (très réparable)."
          , "Il est calculé à partir du résultat d’une série de tests de réparabilité."
          , "Il est utilisé en coefficient multiplicateur du nombre de jours d’utilisation du produit."
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
    let
        processName =
            if Product.isKnitted inputs.product then
                inputs.knittingProcess
                    |> Maybe.withDefault Knitting.Mix
                    |> Knitting.toString

            else
                Product.getFabricProcess inputs.product
                    |> .name
    in
    span
        [ title <| "Taux personnalisé de perte en confection, incluant notamment la découpe. Procédé utilisé : " ++ processName
        ]
        [ RangeSlider.percent
            { id = "makingWaste"
            , update = updateMakingWaste
            , value = Maybe.withDefault inputs.product.making.pcrWaste current.makingWaste
            , toString = Step.makingWasteToString
            , disabled =
                not current.enabled
                    || (inputs.knittingProcess == Just Knitting.FullyFashioned)
                    || (inputs.knittingProcess == Just Knitting.Seamless)
            , min = 0
            , max = Split.toPercent Env.maxMakingWasteRatio
            }
        ]


surfaceMassField : Config msg -> Product -> Html msg
surfaceMassField { current, updateSurfaceMass } product =
    span
        [ title "Le grammage de l'étoffe, exprimé en g/m², représente sa masse surfacique." ]
        [ RangeSlider.surfaceMass
            { id = "surface-density"
            , update = updateSurfaceMass
            , value = current.surfaceMass |> Maybe.withDefault product.surfaceMass
            , toString = Step.surfaceMassToString

            -- Note: hide for knitted products as surface mass doesn't have any impact on them
            , disabled = not current.enabled
            }
        ]


yarnSizeField : Config msg -> Product -> Html msg
yarnSizeField { current, updateYarnSize } product =
    let
        yarnSize =
            product.yarnSize
                |> Maybe.withDefault Unit.minYarnSize
    in
    span
        [ [ if Product.isKnitted product then
                "Désactivé car inopérant sur un produit tricoté."

            else
                ""
          , "Le titrage indique la grosseur d’un fil textile, exprimée en numéro métrique (Nm)."
          , "Cette unité indique un nombre de kilomètres de fil correspondant à un poids d’un kilogramme (ex : 50Nm = 50km de ce fil pèsent 1 kg)."
          ]
            |> String.join " "
            |> title
        ]
        [ RangeSlider.yarnSize
            { id = "yarnSize"
            , update = updateYarnSize
            , value = current.yarnSize |> Maybe.withDefault yarnSize
            , toString = Step.yarnSizeToString
            , disabled = not current.enabled || Product.isKnitted product
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
            [ class "btn btn-secondary py-1 rounded-end"
            , classList [ ( "btn-secondary", not current.enabled ) ]
            , href (Gitbook.publicUrlFromPath (Label.toGitbookPath label))
            , title "Documentation"
            , target "_blank"
            ]
            [ Icon.question ]
        , Button.docsPill
            [ class "btn btn-secondary py-1 rounded-start"
            , classList [ ( "btn-secondary", not current.enabled ) ]
            , case viewMode of
                ViewMode.Simple ->
                    title "Détailler cette étape"

                _ ->
                    title "Affichage simplifié"
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
        [ class "d-flex align-items-center gap-2"
        , class "text-dark cursor-pointer"
        , classList [ ( "text-secondary", not current.enabled ) ]
        , title
            (if current.enabled then
                "Étape activée, cliquez pour la désactiver"

             else
                "Étape desactivée, cliquez pour la réactiver"
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
            [ class "StepIcon rounded-pill"
            , classList [ ( "bg-secondary text-white", current.enabled ) ]
            , classList [ ( "bg-light text-dark", not current.enabled ) ]
            ]
            [ stepIcon current.label ]
        , span [ class "StepLabel" ]
            [ current.label
                |> Step.displayLabel
                    { knitted = Product.isKnitted inputs.product
                    , fadable = inputs.product.making.fadable
                    }
                |> text
            ]
        ]


simpleView : Config msg -> Html msg
simpleView ({ funit, inputs, daysOfWear, impact, current } as config) =
    div [ class "Step card shadow-sm" ]
        [ div [ class "StepHeader card-header" ]
            [ div [ class "row d-flex align-items-center" ]
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
                    Label.Spinning ->
                        if Product.isKnitted inputs.product then
                            text ""

                        else
                            div [ class "mt-2 fs-7 text-muted" ]
                                [ yarnSizeField config inputs.product
                                ]

                    Label.Fabric ->
                        div [ class "mt-2 fs-7" ]
                            [ surfaceMassField config inputs.product ]

                    Label.Ennobling ->
                        div [ class "mt-2" ]
                            [ ennoblingGenericFields config
                            ]

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
                                |> Format.formatTextileSelectedImpact funit daysOfWear impact
                            ]

                      else
                        text ""
                    , div [ class "fs-7" ]
                        [ span [ class "me-1 align-bottom" ] [ Icon.info ]
                        , text "Transport\u{00A0}"
                        , current.transport.impacts
                            |> Format.formatTextileSelectedImpact funit daysOfWear impact
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
                [ class "list-group-item text-truncate"
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
    small [ class "fs-7" ]
        [ span [ class "pe-1" ] [ Icon.info ]
        , Format.days info.daysOfWear
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


ennoblingGenericFields : Config msg -> Html msg
ennoblingGenericFields config =
    -- Note: this fieldset is rendered in both simple and detailed step views
    div [ class "d-flex flex-column gap-1" ]
        [ dyeingMediumField config
        , printingFields config
        ]


ennoblingHeatSourceField : Config msg -> Html msg
ennoblingHeatSourceField ({ inputs } as config) =
    -- Note: This field is only rendered in the detailed step view
    li [ class "list-group-item d-flex align-items-center gap-2" ]
        [ label [ class "text-nowrap w-25", for "ennobling-heat-source" ] [ text "Chaleur" ]
        , [ HeatSource.Coal, HeatSource.NaturalGas, HeatSource.HeavyFuel, HeatSource.LightFuel ]
            |> List.map
                (\heatSource ->
                    option
                        [ value (HeatSource.toString heatSource)
                        , selected <| inputs.ennoblingHeatSource == Just heatSource
                        ]
                        [ text (HeatSource.toLabelWithZone inputs.countryDyeing.zone heatSource) ]
                )
            |> (::)
                (option [ selected <| inputs.ennoblingHeatSource == Nothing ]
                    [ text "Mix régional" ]
                )
            |> select
                [ id "ennobling-heat-source"
                , class "form-select form-select w-75"
                , onInput
                    (HeatSource.fromString
                        >> Result.toMaybe
                        >> config.updateEnnoblingHeatSource
                    )
                ]
        ]


detailedView : Config msg -> Html msg
detailedView ({ inputs, funit, impact, daysOfWear, next, current } as config) =
    let
        transportLabel =
            case next of
                Just { country } ->
                    "Transport " ++ current.country.name ++ "\u{202F}→\u{202F}" ++ country.name

                Nothing ->
                    "Transport"

        infoListElement =
            ul
                [ class "StepBody list-group list-group-flush fs-7"
                , classList [ ( "disabled", not current.enabled ) ]
                ]
    in
    div [ class "Step card-group shadow-sm" ]
        [ div [ class "card" ]
            [ div [ class "StepHeader card-header d-flex justify-content-between align-items-center" ]
                [ stepHeader config
                , -- Note: hide on desktop, show on mobile
                  div [ class "d-block d-sm-none" ]
                    [ stepActions config current.label
                    ]
                ]
            , infoListElement
                [ li [ class "list-group-item" ] [ countryField config ]
                , viewProcessInfo current.processInfo.countryElec
                , case current.label of
                    Label.Ennobling ->
                        ennoblingHeatSourceField config

                    _ ->
                        viewProcessInfo current.processInfo.countryHeat
                , viewProcessInfo current.processInfo.distribution
                , viewProcessInfo current.processInfo.useIroning
                , viewProcessInfo current.processInfo.useNonIroning
                , viewProcessInfo current.processInfo.passengerCar
                , viewProcessInfo current.processInfo.endOfLife
                , if current.label == Label.Fabric && Product.isKnitted inputs.product then
                    knittingProcessField config

                  else
                    viewProcessInfo current.processInfo.fabric
                , viewProcessInfo current.processInfo.making
                , if inputs.product.making.fadable && inputs.disabledFading /= Just True then
                    viewProcessInfo current.processInfo.fading

                  else
                    text ""
                ]
            , div
                [ class "StepBody card-body py-2"
                , classList [ ( "disabled", not current.enabled ) ]
                ]
                (case current.label of
                    Label.Spinning ->
                        if Product.isKnitted inputs.product then
                            [ text "" ]

                        else
                            [ yarnSizeField config inputs.product
                            ]

                    Label.Fabric ->
                        [ surfaceMassField config inputs.product ]

                    Label.Ennobling ->
                        [ div [ class "fs-7 mb-2" ]
                            [ text "Pré-traitement\u{00A0}: non applicable" ]
                        , ennoblingGenericFields config
                        , div [ class "fs-7 mt-2" ]
                            [ text "Finition\u{00A0}: apprêt chimique" ]
                        ]

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
            [ div [ class "StepHeader card-header d-flex justify-content-end align-items-center text-muted" ]
                [ if (current.impacts |> Impact.getImpact impact.trigram |> Unit.impactToFloat) > 0 then
                    span [ class "fw-bold flex-fill" ]
                        [ current.impacts
                            |> Format.formatTextileSelectedImpact funit daysOfWear impact
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
                [ li [ class "list-group-item text-muted d-flex flex-wrap justify-content-around" ]
                    [ span []
                        [ text "Masse entrante", br [] [], Format.kg current.inputMass ]
                    , span []
                        [ text "Masse sortante", br [] [], Format.kg current.outputMass ]
                    , span []
                        [ text "Perte"
                        , br [] []
                        , Format.kg current.waste
                        , inlineDocumentationLink config Gitbook.TextileWaste
                        ]
                    ]
                , if Energy.inKilojoules current.heat > 0 || Energy.inKilowattHours current.kwh > 0 then
                    li [ class "list-group-item text-muted d-flex flex-wrap justify-content-around" ]
                        [ span [ class "d-flex align-items-center" ]
                            [ span [ class "me-1" ] [ text "Chaleur" ]
                            , Format.megajoules current.heat
                            , inlineDocumentationLink config Gitbook.TextileHeat
                            ]
                        , span [ class "d-flex align-items-center" ]
                            [ span [ class "me-1" ] [ text "Électricité" ]
                            , Format.kilowattHours current.kwh
                            , inlineDocumentationLink config Gitbook.TextileElectricity
                            ]
                        ]

                  else
                    text ""
                , surfaceInfoView inputs current
                , pickingView current.picking
                , threadDensityView current.threadDensity
                , if Transport.totalKm current.transport > 0 then
                    li [ class "list-group-item text-muted" ]
                        [ current.transport
                            |> TransportView.view
                                { fullWidth = True
                                , hideNoLength = False
                                , onlyIcons = False
                                , airTransportLabel = current.processInfo.airTransport
                                , seaTransportLabel = current.processInfo.seaTransport
                                , roadTransportLabel = current.processInfo.roadTransport
                                }
                        ]

                  else
                    text ""
                , li [ class "list-group-item text-muted" ]
                    [ div [ class "d-flex flex-wrap justify-content-center align-items-center" ]
                        (if Transport.totalKm current.transport > 0 then
                            [ strong [] [ text <| transportLabel ++ "\u{00A0}:\u{00A0}" ]
                            , current.transport.impacts
                                |> Format.formatTextileSelectedImpact funit daysOfWear impact
                            , inlineDocumentationLink config Gitbook.TextileTransport
                            ]

                         else
                            [ text "Pas de transport" ]
                        )
                    ]
                ]
            ]
        ]


surfaceInfoView : Inputs -> Step -> Html msg
surfaceInfoView inputs current =
    let
        surfaceInfo =
            if current.label == Label.Fabric then
                Just ( "sortante", Step.getOutputSurface inputs current )

            else if current.label == Label.Ennobling then
                Just ( "entrante", Step.getInputSurface inputs current )

            else
                Nothing
    in
    case surfaceInfo of
        Just ( dir, surface ) ->
            li [ class "list-group-item text-muted d-flex justify-content-center gap-2" ]
                [ span [] [ text <| "Surface étoffe (" ++ dir ++ ")\u{00A0}:" ]
                , span [] [ Format.squareMetters surface ]
                ]

        Nothing ->
            text ""


pickingView : Maybe Unit.PickPerMeter -> Html msg
pickingView maybePicking =
    case maybePicking of
        Just picking ->
            li [ class "list-group-item text-muted d-flex justify-content-center gap-2" ]
                [ text "Duitage\u{00A0}:\u{00A0}"
                , picking
                    |> Unit.pickPerMeterToFloat
                    |> Format.formatRichFloat 0 "duites.m"
                ]

        Nothing ->
            text ""


threadDensityView : Maybe Unit.ThreadDensity -> Html msg
threadDensityView threadDensity =
    case threadDensity of
        Just density ->
            let
                value =
                    Unit.threadDensityToFloat density
            in
            li [ class "list-group-item text-muted" ]
                [ span [ class "d-flex justify-content-center gap-2" ]
                    [ text "Densité de fils (approx.)\u{00A0}:\u{00A0}"
                    , value
                        |> Format.formatRichFloat 0 "fils/cm"
                    ]
                , if round value < Unit.threadDensityToInt Unit.threadDensityLow then
                    text "⚠️ la densité de fils semble très faible"

                  else if round value > Unit.threadDensityToInt Unit.threadDensityHigh then
                    text "⚠️ la densité de fils semble très élevée"

                  else
                    text ""
                ]

        Nothing ->
            text ""


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
