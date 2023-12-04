module Views.Textile.Step exposing (view)

import Autocomplete exposing (Autocomplete)
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Country as Country
import Data.Dataset as Dataset
import Data.Env as Env
import Data.Gitbook as Gitbook
import Data.Impact as Impact exposing (noComplementsImpacts)
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Scope as Scope
import Data.Split as Split exposing (Split)
import Data.Textile.Db as TextileDb
import Data.Textile.DyeingMedium as DyeingMedium exposing (DyeingMedium)
import Data.Textile.Formula as Formula
import Data.Textile.HeatSource as HeatSource exposing (HeatSource)
import Data.Textile.Inputs as Inputs exposing (Inputs)
import Data.Textile.Knitting as Knitting exposing (Knitting)
import Data.Textile.MakingComplexity as MakingComplexity exposing (MakingComplexity)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Origin as Origin
import Data.Textile.Material.Spinning as Spinning exposing (Spinning)
import Data.Textile.Printing as Printing exposing (Printing)
import Data.Textile.Process as Process
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Simulator exposing (stepMaterialImpacts)
import Data.Textile.Step as Step exposing (Step)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Transport as Transport
import Data.Unit as Unit
import Duration exposing (Duration)
import Energy
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Mass exposing (Mass)
import Quantity
import Route
import Views.BaseElement as BaseElement
import Views.Button as Button
import Views.ComplementsDetails as ComplementsDetails
import Views.Component.SplitInput as SplitInput
import Views.Component.StepsBorder as StepsBorder
import Views.CountrySelect as CountrySelect
import Views.Format as Format
import Views.Icon as Icon
import Views.Link as Link
import Views.RangeSlider as RangeSlider
import Views.Transport as TransportView


type alias Config msg modal =
    { addMaterialModal : Maybe Inputs.MaterialInput -> Autocomplete Material -> modal
    , current : Step
    , daysOfWear : Duration
    , db : TextileDb.Db
    , deleteMaterial : Material -> msg
    , detailedStep : Maybe Int
    , index : Int
    , inputs : Inputs
    , next : Maybe Step
    , selectedImpact : Definition
    , setModal : modal -> msg
    , toggleDisabledFading : Bool -> msg
    , toggleStep : Label -> msg
    , toggleStepDetails : Int -> msg
    , updateAirTransportRatio : Maybe Split -> msg
    , updateCountry : Label -> Country.Code -> msg
    , updateDyeingMedium : DyeingMedium -> msg
    , updateEnnoblingHeatSource : Maybe HeatSource -> msg
    , updateKnittingProcess : Knitting -> msg
    , updateMakingComplexity : MakingComplexity -> msg
    , updateMakingWaste : Maybe Split -> msg
    , updateMaterial : Inputs.MaterialQuery -> Inputs.MaterialQuery -> msg
    , updateMaterialSpinning : Material -> Spinning -> msg
    , updatePrinting : Maybe Printing -> msg
    , updateQuality : Maybe Unit.Quality -> msg
    , updateReparability : Maybe Unit.Reparability -> msg
    , updateSurfaceMass : Maybe Unit.SurfaceMass -> msg
    , updateYarnSize : Maybe Unit.YarnSize -> msg
    }


type alias ViewWithTransport msg =
    { step : Html msg, transport : Html msg }


countryField : Config msg modal -> Html msg
countryField { db, current, updateCountry } =
    div []
        [ if current.editable then
            CountrySelect.view
                { attributes =
                    [ class "form-select"
                    , disabled (not current.enabled)
                    , onInput (Country.codeFromString >> updateCountry current.label)
                    ]
                , countries = db.countries
                , onSelect = updateCountry current.label
                , scope = Scope.Textile
                , selectedCountry = current.country.code
                }

          else
            div [ class "fs-6 text-muted d-flex align-items-center gap-2 " ]
                [ span
                    [ class "cursor-help"
                    , title "Le pays n'est pas modifiable à cet étape"
                    ]
                    [ Icon.lock ]
                , text current.country.name
                ]
        ]


airTransportRatioField : Config msg modal -> Html msg
airTransportRatioField { current, updateAirTransportRatio } =
    span
        [ title "Part de transport aérien pour le transport entre la confection et l'entrepôt en France."
        ]
        [ RangeSlider.percent
            { id = "airTransportRatio"
            , update = updateAirTransportRatio
            , value = current.airTransportRatio
            , toString = Step.airTransportRatioToString
            , disabled = Step.airTransportDisabled current
            , min = 0
            , max = 100
            }
        ]


dyeingMediumField : Config msg modal -> Html msg
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
                , class "form-select form-select-sm w-75"
                , onInput
                    (DyeingMedium.fromString
                        >> Result.withDefault inputs.product.dyeing.defaultMedium
                        >> updateDyeingMedium
                    )
                ]
        ]


spinningProcessField : Config msg modal -> Html msg
spinningProcessField { inputs, updateMaterialSpinning } =
    li [ class "list-group-item d-flex align-items-center gap-2" ]
        [ div [ class "d-flex flex-column gap-1 w-100" ]
            (inputs.materials
                |> List.map
                    (\{ material, spinning } ->
                        div [ class "d-flex justify-content-between align-items-center fs-7" ]
                            [ label
                                [ for <| "spinning-for-" ++ Material.idToString material.id
                                , class "text-truncate w-25"
                                ]
                                [ text material.shortName ]
                            , case Spinning.getAvailableProcesses material.origin of
                                [ spinningProcess ] ->
                                    span
                                        [ class " w-75" ]
                                        [ text <| Spinning.toLabel spinningProcess
                                        ]

                                availableSpinningProcesses ->
                                    availableSpinningProcesses
                                        |> List.map
                                            (\spinningProcess ->
                                                option
                                                    [ value <| Spinning.toString spinningProcess
                                                    , selected <| Just spinningProcess == spinning
                                                    ]
                                                    [ text <| Spinning.toLabel spinningProcess
                                                    ]
                                            )
                                        |> select
                                            [ class "form-select form-select-sm w-75"
                                            , id <| "spinning-for-" ++ Material.idToString material.id
                                            , onInput
                                                (Spinning.fromString
                                                    >> Result.withDefault (Spinning.getDefault material.origin)
                                                    >> updateMaterialSpinning material
                                                )
                                            ]
                            ]
                    )
            )
        ]


knittingProcessField : Config msg modal -> Html msg
knittingProcessField { inputs, updateKnittingProcess } =
    -- Note: This field is only rendered in the detailed step view
    li [ class "list-group-item d-flex align-items-center gap-2" ]
        [ label [ class "text-nowrap w-25", for "knitting-process" ] [ text "Procédé" ]
        , [ Knitting.Mix
          , Knitting.FullyFashioned
          , Knitting.Integral
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


printingFields : Config msg modal -> Html msg
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
                    , class "form-select form-select-sm"
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
                                    [ value (String.fromInt percent)
                                    , selected <| Ok ratio == Split.fromPercent percent
                                    ]
                                    [ text <| String.fromInt percent ++ "%" ]
                            )
                        |> select
                            [ class "form-select form-select-sm"
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


fadingField : Config msg modal -> Html msg
fadingField { inputs, toggleDisabledFading } =
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


qualityField : Config msg modal -> Html msg
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


reparabilityField : Config msg modal -> Html msg
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


makingComplexityField : Config msg modal -> Html msg
makingComplexityField ({ inputs, updateMakingComplexity } as config) =
    -- Note: This field is only rendered in the detailed step view
    let
        makingComplexity =
            inputs.makingComplexity
                |> Maybe.withDefault inputs.product.making.complexity
    in
    li [ class "list-group-item d-flex align-items-center gap-2" ]
        [ label [ class "text-nowrap w-25", for "making-complexity" ] [ text "Complexité" ]
        , inlineDocumentationLink config Gitbook.TextileMakingComplexity
        , if inputs.knittingProcess == Just Knitting.Integral then
            text "Non applicable"

          else
            [ MakingComplexity.VeryHigh
            , MakingComplexity.High
            , MakingComplexity.Medium
            , MakingComplexity.Low
            , MakingComplexity.VeryLow
            ]
                |> List.map
                    (\complexity ->
                        option
                            [ value <| MakingComplexity.toString complexity
                            , selected <| complexity == makingComplexity
                            ]
                            [ text <| MakingComplexity.toLabel complexity ]
                    )
                |> select
                    [ id "making-complexity"
                    , class "form-select form-select-sm w-75"
                    , disabled (inputs.knittingProcess == Just Knitting.FullyFashioned)
                    , onInput
                        (MakingComplexity.fromString
                            >> Result.withDefault inputs.product.making.complexity
                            >> updateMakingComplexity
                        )
                    ]
        ]


makingWasteField : Config msg modal -> Html msg
makingWasteField { current, db, inputs, updateMakingWaste } =
    let
        processName =
            db.wellKnown
                |> Product.getFabricProcess inputs.knittingProcess inputs.product
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
                    || (inputs.knittingProcess == Just Knitting.Integral)
            , min = 0
            , max = Split.toPercent Env.maxMakingWasteRatio
            }
        ]


surfaceMassField : Config msg modal -> Product -> Html msg
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


yarnSizeField : Config msg modal -> Product -> Html msg
yarnSizeField { current, updateYarnSize } product =
    span
        [ title "Le titrage indique la grosseur d’un fil textile" ]
        [ RangeSlider.yarnSize
            { id = "yarnSize"
            , update = updateYarnSize
            , value = current.yarnSize |> Maybe.withDefault product.yarnSize
            , toString = Step.yarnSizeToString
            , disabled = not current.enabled
            }
        ]


inlineDocumentationLink : Config msg modal -> Gitbook.Path -> Html msg
inlineDocumentationLink _ path =
    Button.smallPillLink
        [ href (Gitbook.publicUrlFromPath path)
        , target "_blank"
        ]
        [ Icon.question ]


stepActions : Config msg modal -> Label -> Html msg
stepActions { current, detailedStep, index, toggleStep, toggleStepDetails } label =
    let
        materialStep =
            label == Label.Material
    in
    div [ class "StepActions ms-2" ]
        [ div [ class "btn-group" ]
            [ Button.docsPillLink
                [ class "btn btn-secondary py-1"
                , classList
                    [ ( "rounded", materialStep || not current.enabled )
                    , ( "rounded-end", not materialStep && current.enabled )
                    ]
                , href (Gitbook.publicUrlFromPath (Label.toGitbookPath label))
                , title "Documentation"
                , target "_blank"
                ]
                [ Icon.question ]
            , if not materialStep && current.enabled then
                Button.docsPill
                    [ class "btn btn-secondary py-1 rounded-start"
                    , detailedStep
                        |> Maybe.map (always <| title "Affichage simplifie")
                        |> Maybe.withDefault (title "Détailler cette étape")
                    , onClick (toggleStepDetails index)
                    ]
                    [ detailedStep
                        |> Maybe.map
                            (\currentIndex ->
                                if index == currentIndex then
                                    Icon.zoomout

                                else
                                    Icon.zoomin
                            )
                        |> Maybe.withDefault Icon.zoomin
                    ]

              else
                text ""
            , if materialStep then
                input
                    [ type_ "checkbox"
                    , class "form-check-input ms-1 no-outline"
                    , attribute "role" "switch"
                    , checked current.enabled
                    , onCheck (always (toggleStep current.label))
                    , title
                        (if current.enabled then
                            "Étape activée, cliquez pour la désactiver"

                         else
                            "Étape desactivée, cliquez pour la réactiver"
                        )
                    ]
                    []

              else
                text ""
            ]
        ]


stepHeader : Config msg modal -> Html msg
stepHeader { current, inputs } =
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
        [ h2 [ class "h5 mb-0" ]
            [ current.label
                |> Step.displayLabel
                    { knitted = Product.isKnitted inputs.product
                    , fadable = inputs.product.making.fadable
                    }
                |> text
            , if current.label == Label.Material then
                Link.smallPillExternal
                    [ Route.href (Route.Explore Scope.Textile (Dataset.TextileMaterials Nothing))
                    , title "Explorer"
                    , attribute "aria-label" "Explorer"
                    ]
                    [ Icon.search ]

              else
                text ""
            ]
        ]


simpleView : Config msg modal -> ViewWithTransport msg
simpleView ({ inputs, selectedImpact, current, toggleStep } as config) =
    let
        materialStep =
            current.label == Label.Material
    in
    { transport = viewTransport config
    , step =
        div [ class "Step card shadow-sm" ]
            [ div
                [ class "StepHeader card-header"
                , StepsBorder.style <| Label.toColor current.label
                , id <| Label.toId current.label
                ]
                [ div [ class "row d-flex align-items-center" ]
                    [ div [ class "col-9 col-sm-6" ] [ stepHeader config ]
                    , div [ class "col-3 col-sm-6 d-flex text-end justify-content-end" ]
                        [ div [ class "d-none d-sm-block text-center" ]
                            [ viewStepImpacts selectedImpact current
                            ]
                        , stepActions config current.label
                        ]
                    ]
                ]
            , if not materialStep then
                if current.enabled then
                    div
                        [ class "StepBody card-body row align-items-center" ]
                        [ div [ class "col-11 col-lg-7" ]
                            [ countryField config
                            , case current.label of
                                Label.Spinning ->
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
                                        , if inputs.product.making.fadable then
                                            fadingField config

                                          else
                                            text ""
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
                        , div [ class "col-1 col-lg-5 ps-0 align-self-stretch text-end" ]
                            [ BaseElement.deleteItemButton { disabled = False } (toggleStep current.label)
                            ]
                        ]

                else
                    button
                        [ class "btn btn-outline-primary"
                        , class "d-flex justify-content-center align-items-center"
                        , class " gap-1 w-100"
                        , id "add-new-element"
                        , onClick (toggleStep current.label)
                        ]
                        [ i [ class "icon icon-plus" ] []
                        , text <| "Ajouter une " ++ String.toLower (Label.toName current.label)
                        ]

              else
                viewMaterials config
            ]
    }


viewStepImpacts : Definition -> Step -> Html msg
viewStepImpacts selectedImpact { impacts, complementsImpacts } =
    if Quantity.greaterThanZero (Impact.getImpact selectedImpact.trigram impacts) then
        let
            stepComplementsImpact =
                complementsImpacts
                    |> Impact.getTotalComplementsImpacts

            totalImpacts =
                impacts
                    |> Impact.applyComplements stepComplementsImpact
        in
        div []
            [ span [ class "flex-fill" ]
                [ totalImpacts
                    |> Format.formatImpact selectedImpact
                ]
            ]

    else
        text ""


viewMaterials : Config msg modal -> Html msg
viewMaterials ({ addMaterialModal, db, inputs, selectedImpact, setModal } as config) =
    ul [ class "CardList list-group list-group-flush" ]
        ((inputs.materials
            |> List.map
                (\materialInput ->
                    let
                        nextCountry =
                            config.next
                                |> Maybe.withDefault config.current
                                |> .country

                        transport =
                            materialInput
                                |> Step.computeMaterialTransportAndImpact db nextCountry config.current.outputMass
                    in
                    li [ class "ElementFormWrapper list-group-item" ]
                        (List.concat
                            [ materialInput
                                |> createElementSelectorConfig config
                                |> BaseElement.view
                            , if selectedImpact.trigram == Definition.Ecs then
                                [ materialInput
                                    |> viewMaterialComplements inputs.mass
                                ]

                              else
                                []
                            , [ span [ class "text-muted d-flex fs-7 gap-3 justify-content-left ElementTransportDistances" ]
                                    (transport
                                        |> TransportView.viewDetails
                                            { fullWidth = False
                                            , hideNoLength = True
                                            , onlyIcons = False
                                            , airTransportLabel = Nothing
                                            , seaTransportLabel = Nothing
                                            , roadTransportLabel = Nothing
                                            }
                                    )
                              , span
                                    [ class "text-black-50 text-end ElementTransportImpact fs-8"
                                    , title "Impact du transport pour cette matière"
                                    ]
                                    [ text "(+ "
                                    , Format.formatImpact selectedImpact transport.impacts
                                    , text ")"
                                    ]
                              ]
                            ]
                        )
                )
         )
            ++ [ let
                    length =
                        List.length inputs.materials

                    excluded =
                        inputs.materials
                            |> List.map .material

                    availableMaterials =
                        db.materials
                            |> List.filter (\element -> not (List.member element excluded))

                    totalShares =
                        inputs.materials
                            |> List.map (.share >> Split.toFloat >> clamp 0 1)
                            |> List.sum

                    valid =
                        round (totalShares * 100) == 100
                 in
                 li
                    [ class "input-group AddElementFormWrapper ps-3" ]
                    [ span
                        [ class "SharesTotal ext-end"
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
                    , button
                        [ class "AddElementButton btn btn-outline-primary flex-fill"
                        , class "d-flex justify-content-center align-items-center gap-1 no-outline"
                        , id "add-new-element"
                        , availableMaterials
                            |> List.sortBy .shortName
                            |> AutocompleteSelector.init .shortName
                            |> addMaterialModal Nothing
                            |> setModal
                            |> onClick
                        , disabled <| length >= Env.maxMaterials
                        ]
                        [ Icon.plus
                        , if length >= Env.maxMaterials then
                            text "Nombre maximal de matières atteint"

                          else
                            text "Ajouter une matière"
                        ]
                    ]
               ]
        )


viewMaterialComplements : Mass -> Inputs.MaterialInput -> Html msg
viewMaterialComplements finalProductMass materialInput =
    let
        materialComplement =
            Inputs.getMaterialMicrofibersComplement finalProductMass materialInput

        materialComplementsImpacts =
            { noComplementsImpacts | microfibers = materialComplement }
    in
    ComplementsDetails.view { complementsImpacts = materialComplementsImpacts }
        [ div [ class "ElementComplement", title "Microfibres" ]
            [ span [ class "ComplementName d-flex align-items-center text-nowrap text-muted" ]
                [ text "Microfibres"
                , Button.smallPillLink
                    [ href (Gitbook.publicUrlFromPath Gitbook.TextileComplementMicrofibers)
                    , target "_blank"
                    ]
                    [ Icon.question ]
                ]
            , span [ class "ComplementRange" ] []
            , div [ class "ComplementValue d-flex" ] []
            , div [ class "ComplementImpact text-black-50 text-muted text-end" ]
                [ text "("
                , Format.complement materialComplement
                , text ")"
                ]
            ]
        ]


createElementSelectorConfig : Config msg modal -> Inputs.MaterialInput -> BaseElement.Config Material Split msg
createElementSelectorConfig { addMaterialModal, db, deleteMaterial, current, selectedImpact, inputs, setModal, updateMaterial } materialInput =
    let
        materialQuery : Inputs.MaterialQuery
        materialQuery =
            { id = materialInput.material.id
            , share = materialInput.share
            , spinning = materialInput.spinning
            , country = materialInput.country |> Maybe.map .code
            }

        baseElement =
            { element = materialInput.material
            , quantity = materialInput.share
            , country = materialInput.country
            }

        excluded =
            inputs.materials
                |> List.map .material

        impacts =
            current
                |> stepMaterialImpacts db materialInput.material
                |> Impact.mapImpacts (\_ -> Quantity.multiplyBy (Split.toFloat materialInput.share))
    in
    { allowEmptyList = False
    , baseElement = baseElement
    , db =
        { elements = db.materials
        , countries =
            db.countries
                |> Scope.only Scope.Textile
                |> List.sortBy .name
        , definitions = db.impactDefinitions
        }
    , defaultCountry = materialInput.material.geographicOrigin
    , delete = deleteMaterial
    , excluded = excluded
    , impact = impacts
    , selectedImpact = selectedImpact
    , selectElement = \_ autocompleteState -> setModal (addMaterialModal (Just materialInput) autocompleteState)
    , quantityView =
        \{ quantity, onChange } ->
            SplitInput.view
                { disabled = False
                , share = quantity
                , onChange = onChange
                }
    , toId = .id >> Material.idToString
    , toString = .shortName
    , update =
        \_ newElement ->
            updateMaterial
                materialQuery
                { materialQuery
                    | id = newElement.element.id
                    , share = newElement.quantity
                    , country = newElement.country |> Maybe.map .code
                }
    }


viewTransport : Config msg modal -> Html msg
viewTransport ({ selectedImpact, current } as config) =
    div []
        [ span []
            [ text "Masse\u{00A0}: ", Format.kg current.outputMass ]
        , if Transport.totalKm current.transport > 0 then
            div [ class "d-flex justify-content-between gap-3 align-items-center" ]
                [ div [ class "d-flex justify-content-between gap-3 flex-column flex-md-row" ]
                    (current.transport
                        |> TransportView.viewDetails
                            { fullWidth = False
                            , hideNoLength = True
                            , onlyIcons = False
                            , airTransportLabel = Nothing
                            , seaTransportLabel = Nothing
                            , roadTransportLabel = Nothing
                            }
                    )
                , span []
                    [ current.transport.impacts
                        |> Format.formatImpact selectedImpact
                    , inlineDocumentationLink config Gitbook.TextileTransport
                    ]
                ]

          else
            text ""
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


ennoblingGenericFields : Config msg modal -> Html msg
ennoblingGenericFields config =
    -- Note: this fieldset is rendered in both simple and detailed step views
    div [ class "d-flex flex-column gap-1" ]
        [ dyeingMediumField config
        , printingFields config
        ]


ennoblingHeatSourceField : Config msg modal -> Html msg
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
                , class "form-select form-select-sm w-75"
                , onInput
                    (HeatSource.fromString
                        >> Result.toMaybe
                        >> config.updateEnnoblingHeatSource
                    )
                ]
        ]


detailedView : Config msg modal -> ViewWithTransport msg
detailedView ({ inputs, selectedImpact, current } as config) =
    let
        infoListElement =
            ul
                [ class "StepBody list-group list-group-flush fs-7 border-bottom-0"
                , classList [ ( "disabled", not current.enabled ) ]
                ]
    in
    { transport = viewTransport config
    , step =
        div [ class "Step card-group shadow-sm" ]
            [ div [ class "card" ]
                [ div
                    [ class "StepHeader card-header d-flex justify-content-between align-items-center"
                    , StepsBorder.style <| Label.toColor current.label
                    , id <| Label.toId current.label
                    ]
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
                    , if current.label == Label.Spinning then
                        spinningProcessField config

                      else
                        text ""
                    , if current.label == Label.Fabric && Product.isKnitted inputs.product then
                        knittingProcessField config

                      else
                        viewProcessInfo current.processInfo.fabric
                    , if current.label == Label.Making then
                        makingComplexityField config

                      else
                        text ""
                    , if inputs.product.making.fadable && inputs.disabledFading /= Just True then
                        viewProcessInfo current.processInfo.fading

                      else
                        text ""
                    ]
                , ul
                    [ class "StepBody p-0 list-group list-group-flush border-bottom-0"
                    , classList [ ( "disabled", not current.enabled ) ]
                    ]
                    (List.map
                        (\line -> li [ class "list-group-item fs-7" ] [ line ])
                        (case current.label of
                            Label.Spinning ->
                                [ yarnSizeField config inputs.product
                                ]

                            Label.Fabric ->
                                [ surfaceMassField config inputs.product ]

                            Label.Ennobling ->
                                [ div [ class "mb-2" ]
                                    [ text "Pré-traitement\u{00A0}: non applicable" ]
                                , ennoblingGenericFields config
                                , div [ class "mt-2" ]
                                    [ text "Finition\u{00A0}: apprêt chimique" ]
                                ]

                            Label.Making ->
                                List.filterMap identity
                                    [ Just <| makingWasteField config
                                    , Just <| airTransportRatioField config
                                    , if inputs.product.making.fadable then
                                        Just (fadingField config)

                                      else
                                        Nothing
                                    ]

                            Label.Use ->
                                [ qualityField config
                                , reparabilityField config
                                , daysOfWearInfo inputs
                                ]

                            _ ->
                                []
                        )
                    )
                ]
            , div
                [ class "card text-center mb-0" ]
                [ div [ class "StepHeader card-header d-flex justify-content-end align-items-center" ]
                    [ if (current.impacts |> Impact.getImpact selectedImpact.trigram |> Unit.impactToFloat) > 0 then
                        div [ class "d-none d-sm-block text-center" ]
                            [ viewStepImpacts selectedImpact current
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
                    [ if Energy.inKilojoules current.heat > 0 || Energy.inKilowattHours current.kwh > 0 then
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
                    , ennoblingToxicityView config current
                    , pickingView current.picking
                    , threadDensityView current.threadDensity
                    , if current.label == Label.EndOfLife then
                        li [ class "list-group-item text-muted d-flex flex-wrap justify-content-center" ]
                            [ span [ class "me-2" ] [ text "Probabilité de fin de vie hors-Europe" ]
                            , inputs.materials
                                |> Inputs.getOutOfEuropeEOLProbability
                                |> Format.splitAsPercentage
                            , inlineDocumentationLink config Gitbook.TextileEndOfLifeOutOfEuropeComplement
                            ]

                      else
                        text ""
                    ]
                ]
            ]
    }


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
                , span [] [ Format.squareMeters surface ]
                ]

        Nothing ->
            text ""


ennoblingToxicityView : Config msg modal -> Step -> Html msg
ennoblingToxicityView ({ db, selectedImpact, inputs } as config) current =
    if current.label == Label.Ennobling then
        let
            bleachingToxicity =
                current.outputMass
                    |> Formula.bleachingImpacts current.impacts
                        { bleachingProcess = db.wellKnown.bleaching
                        , aquaticPollutionScenario = current.country.aquaticPollutionScenario
                        }

            dyeingToxicity =
                inputs.materials
                    |> List.map
                        (\{ material, share } ->
                            Formula.materialDyeingToxicityImpacts current.impacts
                                { dyeingToxicityProcess =
                                    if Origin.isSynthetic material.origin then
                                        db.wellKnown.dyeingSynthetic

                                    else
                                        db.wellKnown.dyeingCellulosic
                                , aquaticPollutionScenario = current.country.aquaticPollutionScenario
                                }
                                current.outputMass
                                share
                        )
                    |> Impact.sumImpacts

            printingToxicity =
                case current.printing of
                    Just { kind, ratio } ->
                        let
                            { printingToxicityProcess } =
                                Process.getPrintingProcess kind db.wellKnown
                        in
                        current.outputMass
                            |> Formula.materialPrintingToxicityImpacts
                                current.impacts
                                { printingToxicityProcess = printingToxicityProcess
                                , aquaticPollutionScenario = current.country.aquaticPollutionScenario
                                }
                                ratio

                    Nothing ->
                        Impact.empty

            toxicity =
                Impact.sumImpacts [ bleachingToxicity, dyeingToxicity, printingToxicity ]
        in
        li [ class "list-group-item text-muted d-flex justify-content-center gap-2" ]
            [ span [] [ text <| "Dont inventaires enrichis\u{00A0}:" ]
            , span [ class "text-end ImpactDisplay text-black-50 fs-7" ]
                [ text "(+\u{00A0}"
                , toxicity
                    |> Format.formatImpact selectedImpact
                , text ")"
                , inlineDocumentationLink config Gitbook.TextileEnnoblingToxicity
                ]
            ]

    else
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


view : Config msg modal -> ViewWithTransport msg
view config =
    -- FIXME: Step views should decide what to render according to ViewMode; move
    -- decision to caller and use appropriate view functions accordingly
    config.detailedStep
        |> Maybe.map
            (\index ->
                if config.index == index then
                    detailedView config

                else
                    simpleView config
            )
        |> Maybe.withDefault
            (simpleView config)
