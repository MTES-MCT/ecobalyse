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
import Data.Textile.DyeingMedium as DyeingMedium exposing (DyeingMedium)
import Data.Textile.Fabric as Fabric exposing (Fabric)
import Data.Textile.Formula as Formula
import Data.Textile.Inputs as Inputs exposing (Inputs)
import Data.Textile.MakingComplexity as MakingComplexity exposing (MakingComplexity)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Origin as Origin
import Data.Textile.Material.Spinning as Spinning exposing (Spinning)
import Data.Textile.Printing as Printing exposing (Printing)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Query exposing (MaterialQuery)
import Data.Textile.Simulator exposing (stepMaterialImpacts)
import Data.Textile.Step as Step exposing (Step)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Textile.WellKnown as WellKnown
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
import Static.Db exposing (Db)
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
    { db : Db
    , addMaterialModal : Maybe Inputs.MaterialInput -> Autocomplete Material -> modal
    , current : Step
    , daysOfWear : Duration
    , useNbCycles : Int
    , deleteMaterial : Material -> msg
    , detailedStep : Maybe Int
    , index : Int
    , inputs : Inputs
    , next : Maybe Step
    , selectedImpact : Definition
    , setModal : modal -> msg
    , toggleFading : Bool -> msg
    , toggleStep : Label -> msg
    , toggleStepDetails : Int -> msg
    , updateAirTransportRatio : Maybe Split -> msg
    , updateCountry : Label -> Country.Code -> msg
    , updateDyeingMedium : DyeingMedium -> msg
    , updateFabricProcess : Fabric -> msg
    , updateMakingComplexity : MakingComplexity -> msg
    , updateMakingDeadStock : Maybe Split -> msg
    , updateMakingWaste : Maybe Split -> msg
    , updateMaterial : MaterialQuery -> MaterialQuery -> msg
    , updateMaterialSpinning : Material -> Spinning -> msg
    , updatePrinting : Maybe Printing -> msg
    , updateSurfaceMass : Maybe Unit.SurfaceMass -> msg
    , updateYarnSize : Maybe Unit.YarnSize -> msg
    }


type alias ViewWithTransport msg =
    { step : Html msg, transport : Html msg }


countryField : Config msg modal -> Html msg
countryField cfg =
    div []
        [ if cfg.current.editable then
            CountrySelect.view
                { attributes =
                    [ class "form-select"
                    , disabled (not cfg.current.enabled)
                    , onInput (Country.codeFromString >> cfg.updateCountry cfg.current.label)
                    ]
                , countries = cfg.db.countries
                , onSelect = cfg.updateCountry cfg.current.label
                , scope = Scope.Textile
                , selectedCountry = cfg.current.country.code
                }

          else
            div [ class "fs-6 text-muted d-flex align-items-center gap-2 " ]
                [ span
                    [ class "cursor-help"
                    , title "Le pays n'est pas modifiable à cette étape"
                    ]
                    [ Icon.lock ]
                , text cfg.current.country.name
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


fabricProcessField : Config msg modal -> Html msg
fabricProcessField { inputs, updateFabricProcess } =
    -- Note: This field is only rendered in the detailed step view
    li [ class "list-group-item d-flex align-items-center gap-2" ]
        [ label [ class "text-nowrap w-25", for "fabric-process" ] [ text "Procédé" ]
        , Fabric.fabricProcesses
            |> List.map
                (\fabricProcess ->
                    option
                        [ value <| Fabric.toString fabricProcess
                        , selected <| inputs.fabricProcess == fabricProcess
                        ]
                        [ text <| Fabric.toLabel fabricProcess ]
                )
            |> select
                [ id "fabric-process"
                , class "form-select form-select-sm w-75"
                , onInput
                    (Fabric.fromString
                        >> Result.withDefault Fabric.KnittingMix
                        >> updateFabricProcess
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
                                    [ value (String.fromFloat percent)
                                    , selected <| Ok ratio == Split.fromPercent percent
                                    ]
                                    [ text <| String.fromFloat percent ++ "%" ]
                            )
                        |> select
                            [ class "form-select form-select-sm"
                            , style "flex" "1"
                            , disabled <| inputs.printing == Nothing
                            , onInput
                                (\str ->
                                    case String.toFloat str of
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
fadingField { inputs, toggleFading } =
    label
        [ class "form-check form-switch form-check-label fs-7 pt-1 text-truncate"
        , title "Délavage"
        ]
        [ input
            [ type_ "checkbox"
            , class "form-check-input no-outline"
            , checked
                (inputs.fading
                    |> Maybe.withDefault (Product.isFadedByDefault inputs.product)
                )
            , onCheck (\checked -> toggleFading checked)
            ]
            []
        , if Inputs.isFaded inputs then
            text "Délavage activé"

          else
            text "Délavage désactivé"
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
        , if inputs.fabricProcess == Fabric.KnittingIntegral then
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
                    , disabled (inputs.fabricProcess == Fabric.KnittingFullyFashioned)
                    , onInput
                        (MakingComplexity.fromString
                            >> Result.withDefault inputs.product.making.complexity
                            >> updateMakingComplexity
                        )
                    ]
        ]


makingWasteField : Config msg modal -> Html msg
makingWasteField { current, inputs, updateMakingWaste } =
    span
        [ title "Taux moyen de pertes en confection"
        ]
        [ RangeSlider.percent
            { id = "makingWaste"
            , update = updateMakingWaste
            , value = Maybe.withDefault inputs.product.making.pcrWaste current.makingWaste
            , toString = Step.makingWasteToString
            , disabled =
                not current.enabled
                    || (inputs.fabricProcess == Fabric.KnittingFullyFashioned)
                    || (inputs.fabricProcess == Fabric.KnittingIntegral)
            , min = Env.minMakingWasteRatio |> Split.toPercent |> round
            , max = Env.maxMakingWasteRatio |> Split.toPercent |> round
            }
        ]


makingDeadStockField : Config msg modal -> Html msg
makingDeadStockField { current, updateMakingDeadStock } =
    span
        [ title "Taux moyen de stocks dormants (vêtements non vendus + produits semi-finis non utilisés) sur l’ensemble de la chaîne de valeur"
        ]
        [ RangeSlider.percent
            { id = "makingDeadStock"
            , update = updateMakingDeadStock
            , value = Maybe.withDefault Env.defaultDeadStock current.makingDeadStock
            , toString = Step.makingDeadStockToString
            , disabled = False
            , min = Env.minMakingDeadStockRatio |> Split.toPercent |> round
            , max = Env.maxMakingDeadStockRatio |> Split.toPercent |> round
            }
        ]


surfaceMassField : Config msg modal -> Product -> Html msg
surfaceMassField { current, updateSurfaceMass } product =
    div
        [ class "mt-2"
        , title "Le grammage de l'étoffe, exprimé en g/m², représente sa masse surfacique."
        ]
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
stepHeader { current } =
    div
        [ class "d-flex align-items-center gap-2 text-dark"
        , classList [ ( "text-secondary", not current.enabled ) ]
        ]
        [ h2 [ class "h5 mb-0" ]
            [ current.label
                |> Label.toName
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
simpleView c =
    { transport = viewTransport c
    , step =
        div [ class "Step card shadow-sm" ]
            [ div
                [ class "StepHeader card-header"
                , StepsBorder.style <| Label.toColor c.current.label
                , id <| Label.toId c.current.label
                ]
                [ div [ class "row d-flex align-items-center" ]
                    [ div [ class "col-9 col-sm-6" ] [ stepHeader c ]
                    , div [ class "col-3 col-sm-6 d-flex text-end justify-content-end" ]
                        [ div [ class "d-none d-sm-block text-center" ]
                            [ viewStepImpacts c.selectedImpact c.current
                            ]
                        , stepActions c c.current.label
                        ]
                    ]
                ]
            , if c.current.label /= Label.Material then
                if c.current.enabled then
                    div
                        [ class "StepBody card-body row align-items-center" ]
                        [ div [ class "col-11 col-lg-7" ]
                            [ countryField c
                            , case c.current.label of
                                Label.Spinning ->
                                    div [ class "mt-2 fs-7 text-muted" ]
                                        [ yarnSizeField c c.inputs.product
                                        ]

                                Label.Fabric ->
                                    div [ class "mt-2 fs-7" ]
                                        [ fabricProcessField c
                                        , surfaceMassField c c.inputs.product
                                        ]

                                Label.Ennobling ->
                                    div [ class "mt-2" ]
                                        [ ennoblingGenericFields c
                                        ]

                                Label.Making ->
                                    div [ class "mt-2" ]
                                        [ makingWasteField c
                                        , makingDeadStockField c
                                        , airTransportRatioField c
                                        , fadingField c
                                        ]

                                Label.Use ->
                                    div [ class "mt-2" ]
                                        [ daysOfWearInfo c
                                        ]

                                _ ->
                                    text ""
                            ]
                        , div [ class "col-1 col-lg-5 ps-0 align-self-stretch text-end" ]
                            [ if List.member c.current.label [ Label.Distribution, Label.Use, Label.EndOfLife ] then
                                text ""

                              else
                                BaseElement.deleteItemButton { disabled = False } (c.toggleStep c.current.label)
                            ]
                        ]

                else
                    button
                        [ class "btn btn-outline-primary"
                        , class "d-flex justify-content-center align-items-center"
                        , class " gap-1 w-100"
                        , id "add-new-element"
                        , onClick (c.toggleStep c.current.label)
                        ]
                        [ i [ class "icon icon-plus" ] []
                        , text <| "Ajouter une " ++ String.toLower (Label.toName c.current.label)
                        ]

              else
                viewMaterials c
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
viewMaterials config =
    ul [ class "CardList list-group list-group-flush" ]
        ((config.inputs.materials
            |> List.map
                (\materialInput ->
                    let
                        nextCountry =
                            config.next
                                |> Maybe.withDefault config.current
                                |> .country

                        transport =
                            materialInput
                                |> Step.computeMaterialTransportAndImpact config.db nextCountry config.current.outputMass
                    in
                    li [ class "ElementFormWrapper list-group-item" ]
                        (List.concat
                            [ materialInput
                                |> createElementSelectorConfig config
                                |> BaseElement.view
                            , if config.selectedImpact.trigram == Definition.Ecs then
                                [ materialInput
                                    |> viewMaterialComplements config.inputs.mass
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
                                    , Format.formatImpact config.selectedImpact transport.impacts
                                    , text ")"
                                    ]
                              ]
                            ]
                        )
                )
         )
            ++ [ let
                    length =
                        List.length config.inputs.materials

                    excluded =
                        config.inputs.materials
                            |> List.map .material

                    availableMaterials =
                        config.db.textile.materials
                            |> List.filter (\element -> not (List.member element excluded))

                    totalShares =
                        config.inputs.materials
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
                            |> config.addMaterialModal Nothing
                            |> config.setModal
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
    ComplementsDetails.view
        { complementsImpacts = materialComplementsImpacts
        , label = "Compléments"
        }
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
createElementSelectorConfig cfg materialInput =
    let
        materialQuery : MaterialQuery
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
            cfg.inputs.materials
                |> List.map .material

        impacts =
            cfg.current
                |> stepMaterialImpacts cfg.db materialInput.material
                |> Impact.mapImpacts (\_ -> Quantity.multiplyBy (Split.toFloat materialInput.share))
    in
    { allowEmptyList = False
    , baseElement = baseElement
    , db =
        { elements = cfg.db.textile.materials
        , countries =
            cfg.db.countries
                |> Scope.only Scope.Textile
                |> List.sortBy .name
        , definitions = cfg.db.definitions
        }
    , defaultCountry = materialInput.material.geographicOrigin
    , delete = cfg.deleteMaterial
    , excluded = excluded
    , impact = impacts
    , selectedImpact = cfg.selectedImpact
    , selectElement = \_ autocompleteState -> cfg.setModal (cfg.addMaterialModal (Just materialInput) autocompleteState)
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
            cfg.updateMaterial
                materialQuery
                { materialQuery
                    | id = newElement.element.id
                    , share = newElement.quantity
                    , country = newElement.country |> Maybe.map .code
                }
    }


viewTransport : Config msg modal -> Html msg
viewTransport ({ selectedImpact, current, inputs } as config) =
    div []
        [ span []
            [ text "Masse\u{00A0}: "
            , current |> Step.getTransportedMass inputs |> Format.kg
            ]
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


daysOfWearInfo : Config msg modal -> Html msg
daysOfWearInfo { daysOfWear, useNbCycles } =
    small
        [ class "d-flex align-items-center fs-7 cursor-help"
        , title "Nombre dépendant de la catégorie de vêtement et du coefficient de durabilité"
        ]
        [ span [ class "pe-1 text-muted" ] [ Icon.info ]
        , Format.days daysOfWear
        , text "\u{00A0}portés, "
        , text <| String.fromInt useNbCycles
        , text <|
            " cycle"
                ++ (if useNbCycles > 1 then
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


detailedView : Config msg modal -> ViewWithTransport msg
detailedView ({ db, inputs, selectedImpact, current } as config) =
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
                    , viewProcessInfo <| Maybe.map ((++) "Elec : ") current.processInfo.countryElec
                    , viewProcessInfo <| Maybe.map ((++) "Chaleur : ") current.processInfo.countryHeat
                    , viewProcessInfo current.processInfo.distribution
                    , viewProcessInfo current.processInfo.useIroning
                    , viewProcessInfo current.processInfo.useNonIroning
                    , viewProcessInfo current.processInfo.passengerCar
                    , viewProcessInfo current.processInfo.endOfLife
                    , if current.label == Label.Spinning then
                        spinningProcessField config

                      else
                        text ""
                    , if current.label == Label.Fabric then
                        fabricProcessField config

                      else
                        text ""
                    , if current.label == Label.Making then
                        makingComplexityField config

                      else
                        text ""
                    , if inputs.fading == Just True then
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
                                    , Just <| makingDeadStockField config
                                    , Just <| airTransportRatioField config
                                    , Just (fadingField config)
                                    ]

                            Label.Use ->
                                [ daysOfWearInfo config
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
                    , ennoblingToxicityView db config current
                    , pickingView current.picking
                    , threadDensityView current.threadDensity
                    , makingWasteView config current.waste
                    , deadstockView config current.deadstock
                    , if current.label == Label.EndOfLife then
                        li [ class "list-group-item text-muted" ]
                            [ div [ class "d-flex justify-content-between" ]
                                [ text "Fin de vie"
                                , Format.formatImpact selectedImpact current.impacts
                                ]
                            , if selectedImpact.trigram == Definition.Ecs then
                                div [ class "text-start mt-2" ]
                                    [ span [ class "fw-bold" ] [ text "Complément" ]
                                    , div [ class "d-flex justify-content-between" ]
                                        [ text "-\u{00A0}Export hors-Europe"
                                        , Format.complement current.complementsImpacts.outOfEuropeEOL
                                        ]
                                    , div [ class "d-flex justify-content-between" ]
                                        [ span [ class "me-2 text-truncate" ] [ text "-\u{00A0}Probabilité de fin de vie hors-Europe" ]
                                        , span [ class "text-nowrap" ]
                                            [ inputs.materials
                                                |> Inputs.getOutOfEuropeEOLProbability
                                                |> Format.splitAsPercentage 2
                                            , inlineDocumentationLink config Gitbook.TextileEndOfLifeOutOfEuropeComplement
                                            ]
                                        ]
                                    ]

                              else
                                text ""
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


ennoblingToxicityView : Db -> Config msg modal -> Step -> Html msg
ennoblingToxicityView db ({ selectedImpact, inputs } as config) current =
    if current.label == Label.Ennobling then
        let
            bleachingToxicity =
                current.outputMass
                    |> Formula.bleachingImpacts current.impacts
                        { bleachingProcess = db.textile.wellKnown.bleaching
                        , aquaticPollutionScenario = current.country.aquaticPollutionScenario
                        }

            dyeingToxicity =
                inputs.materials
                    |> List.map
                        (\{ material, share } ->
                            Formula.materialDyeingToxicityImpacts current.impacts
                                { dyeingToxicityProcess =
                                    if Origin.isSynthetic material.origin then
                                        db.textile.wellKnown.dyeingSynthetic

                                    else
                                        db.textile.wellKnown.dyeingCellulosic
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
                                WellKnown.getPrintingProcess kind db.textile.wellKnown
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


deadstockView : Config msg modal -> Mass -> Html msg
deadstockView config deadstock =
    if config.current.label == Label.Making then
        li [ class "list-group-item text-muted d-flex justify-content-center gap-2" ]
            (if deadstock /= Quantity.zero then
                [ text "Dont stocks dormants\u{00A0}:\u{00A0}"
                , Format.kgToString deadstock |> text
                , inlineDocumentationLink config Gitbook.TextileMakingDeadStock
                ]

             else
                [ text "Aucun stock dormant." ]
            )

    else
        text ""


makingWasteView : Config msg modal -> Mass -> Html msg
makingWasteView config waste =
    if config.current.label == Label.Making then
        li [ class "list-group-item text-muted d-flex justify-content-center gap-2" ]
            (if waste /= Quantity.zero then
                [ text "Pertes\u{00A0}:\u{00A0}"
                , Format.kgToString waste |> text
                , inlineDocumentationLink config Gitbook.TextileMakingMakingWaste
                ]

             else
                [ text "Aucune perte en confection." ]
            )

    else
        text ""


view : Config msg modal -> ViewWithTransport msg
view cfg =
    -- FIXME: Step views should decide what to render according to ViewMode; move
    -- decision to caller and use appropriate view functions accordingly
    cfg.detailedStep
        |> Maybe.map
            (\index ->
                if cfg.index == index then
                    detailedView cfg

                else
                    simpleView cfg
            )
        |> Maybe.withDefault (simpleView cfg)
