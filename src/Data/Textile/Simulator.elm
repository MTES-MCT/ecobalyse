module Data.Textile.Simulator exposing
    ( Simulator
    , compute
    , encode
    , stepMaterialImpacts
    , toStepsImpacts
    )

import Data.Env as Env
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition
import Data.Split as Split
import Data.Textile.Economics as Economics
import Data.Textile.Fabric as Fabric
import Data.Textile.Formula as Formula
import Data.Textile.Inputs as Inputs exposing (Inputs)
import Data.Textile.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Origin as Origin
import Data.Textile.Material.Spinning as Spinning exposing (Spinning)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Query exposing (Query)
import Data.Textile.Step as Step exposing (Step)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Textile.WellKnown as WellKnown
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Duration exposing (Duration)
import Energy exposing (Energy)
import Json.Encode as Encode
import Mass
import Quantity
import Static.Db exposing (Db)


type alias Simulator =
    { inputs : Inputs
    , lifeCycle : LifeCycle
    , impacts : Impacts
    , complementsImpacts : Impact.ComplementsImpacts
    , durability : Unit.Durability
    , transport : Transport
    , daysOfWear : Duration
    , useNbCycles : Int
    }


encode : Simulator -> Encode.Value
encode v =
    Encode.object
        [ ( "inputs", Inputs.encode v.inputs )
        , ( "lifeCycle", LifeCycle.encode v.lifeCycle )
        , ( "impacts", Impact.encode v.impacts )
        , ( "complementsImpacts", Impact.encodeComplementsImpacts v.complementsImpacts )
        , ( "transport", Transport.encode v.transport )
        , ( "durability", v.durability |> Unit.durabilityToFloat |> Encode.float )
        , ( "daysOfWear", v.daysOfWear |> Duration.inDays |> round |> Encode.int )
        , ( "useNbCycles", Encode.int v.useNbCycles )
        ]


init : Db -> Query -> Result String Simulator
init db =
    let
        defaultImpacts =
            Impact.empty
    in
    Inputs.fromQuery db
        >> Result.map
            (\({ product } as inputs) ->
                inputs
                    |> LifeCycle.init db
                    |> (\lifeCycle ->
                            { inputs = inputs
                            , lifeCycle = lifeCycle
                            , impacts = defaultImpacts
                            , complementsImpacts = Impact.noComplementsImpacts
                            , durability = Unit.standardDurability
                            , transport = Transport.default defaultImpacts
                            , daysOfWear = inputs.product.use.daysOfWear
                            , useNbCycles = Product.customDaysOfWear product.use
                            }
                       )
            )


{-| Computes simulation impacts.
-}
compute : Db -> Query -> Result String Simulator
compute db query =
    let
        next fn =
            Result.map fn

        nextWithDb fn =
            next (fn db)

        nextIf label fn =
            if not (List.member label query.disabledSteps) then
                next fn

            else
                identity

        nextWithDbIf label fn =
            if not (List.member label query.disabledSteps) then
                nextWithDb fn

            else
                identity
    in
    init db query
        -- Ensure end product mass is first applied to the final Distribution step
        |> next initializeFinalMass
        --
        -- WASTE: compute the initial required material mass
        --
        -- Compute Making mass waste - Confection
        |> nextIf Label.Making computeMakingStepWaste
        -- Compute Making dead stock - Confection
        |> nextIf Label.Making computeMakingStepDeadStock
        -- Compute Knitting/Weawing waste - Tissage/Tricotage
        |> nextWithDbIf Label.Fabric computeFabricStepWaste
        -- Compute Spinning waste - Filature
        |> nextIf Label.Spinning computeSpinningStepWaste
        -- Compute Material waste - Matière
        -- We always need to compute the Material's step waste otherwise the input mass
        -- for the next step (spinning) would never be computed.
        |> next computeMaterialStepWaste
        --
        -- DURABILITY
        --
        |> next computeDurability
        --
        -- LIFECYCLE STEP IMPACTS
        --
        -- Compute Material step impacts
        |> nextIf Label.Material (computeMaterialImpacts db)
        -- Compute Spinning step impacts
        |> nextIf Label.Spinning computeSpinningImpacts
        -- Compute Weaving & Knitting step impacts
        |> nextWithDbIf Label.Fabric computeFabricImpacts
        -- Compute Ennobling step bleaching impacts
        |> nextWithDbIf Label.Ennobling computeBleachingImpacts
        -- Compute Ennobling step desizing impacts
        |> nextWithDbIf Label.Ennobling computeDesizingImpacts
        -- Compute Ennobling step scouring impacts
        |> nextWithDbIf Label.Ennobling computeScouringImpacts
        -- Compute Ennobling step mercerising impacts
        |> nextWithDbIf Label.Ennobling computeMercerisingImpacts
        -- Compute Ennobling step washing impacts
        |> nextWithDbIf Label.Ennobling computeWashingImpacts
        -- Compute Ennobling step Dyeing impacts
        |> nextWithDbIf Label.Ennobling computeDyeingImpacts
        -- Compute Ennobling step Printing impacts
        |> nextWithDbIf Label.Ennobling computePrintingImpacts
        -- Compute Ennobling step Finishing impacts
        |> nextWithDbIf Label.Ennobling computeFinishingImpacts
        -- Compute Making step impacts
        |> nextWithDbIf Label.Making computeMakingImpacts
        -- Compute product Use impacts
        |> nextIf Label.Use computeUseImpacts
        -- Compute product Use impacts
        |> nextWithDbIf Label.EndOfLife computeEndOfLifeImpacts
        --
        -- TRANSPORTS
        --
        -- Compute step transport
        |> nextWithDb computeStepsTransport
        -- Compute transport summary
        |> next computeTotalTransportImpacts
        --
        -- Final impacts
        --
        |> next computeFinalImpacts


initializeFinalMass : Simulator -> Simulator
initializeFinalMass ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleSteps Label.all (Step.initMass inputs.mass)


computeDurability : Simulator -> Simulator
computeDurability ({ inputs } as simulator) =
    let
        materialOriginShares =
            Inputs.getMaterialsOriginShares inputs.materials

        durability =
            Economics.computeDurabilityIndex materialOriginShares
                { business =
                    inputs.business
                        |> Maybe.withDefault inputs.product.economics.business
                , marketingDuration =
                    inputs.marketingDuration
                        |> Maybe.withDefault inputs.product.economics.marketingDuration
                , numberOfReferences =
                    inputs.numberOfReferences
                        |> Maybe.withDefault inputs.product.economics.numberOfReferences
                , price =
                    inputs.price
                        |> Maybe.withDefault inputs.product.economics.price
                , repairCost = inputs.product.economics.repairCost
                , traceability =
                    inputs.traceability
                        |> Maybe.withDefault inputs.product.economics.traceability
                }
    in
    { simulator
        | durability = durability
        , daysOfWear =
            simulator.daysOfWear |> Quantity.multiplyBy (Unit.durabilityToFloat durability)
        , useNbCycles =
            round (toFloat simulator.useNbCycles * Unit.durabilityToFloat durability)
    }


computeEndOfLifeImpacts : Db -> Simulator -> Simulator
computeEndOfLifeImpacts { textile } simulator =
    simulator
        |> updateLifeCycleStep Label.EndOfLife
            (\({ country } as step) ->
                let
                    { kwh, heat, impacts } =
                        step.outputMass
                            |> Formula.endOfLifeImpacts step.impacts
                                { volume = simulator.inputs.product.endOfLife.volume
                                , passengerCar = textile.wellKnown.passengerCar
                                , endOfLife = textile.wellKnown.endOfLife
                                , countryElecProcess = country.electricityProcess
                                , heatProcess = country.heatProcess
                                }
                in
                { step
                    | impacts = impacts
                    , kwh = kwh
                    , heat = heat
                }
            )


computeUseImpacts : Simulator -> Simulator
computeUseImpacts ({ inputs, useNbCycles } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Use
            (\({ country } as step) ->
                let
                    { kwh, impacts } =
                        step.outputMass
                            |> Formula.useImpacts step.impacts
                                { useNbCycles = useNbCycles
                                , ironingElec = inputs.product.use.ironingElec
                                , nonIroningProcess = inputs.product.use.nonIroningProcess
                                , countryElecProcess = country.electricityProcess
                                }
                in
                { step | impacts = impacts, kwh = kwh }
            )


computeMakingImpacts : Db -> Simulator -> Simulator
computeMakingImpacts { textile } ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Making
            (\({ country } as step) ->
                let
                    { kwh, heat, impacts } =
                        step.outputMass
                            |> Formula.makingImpacts step.impacts
                                { makingComplexity = inputs.makingComplexity |> Maybe.withDefault inputs.product.making.complexity
                                , fadingProcess =
                                    -- Note: in the future, we may have distinct fading processes per countries
                                    if Inputs.isFaded inputs then
                                        Just textile.wellKnown.fading

                                    else
                                        Nothing
                                , countryElecProcess = country.electricityProcess
                                , countryHeatProcess = country.heatProcess
                                }
                in
                { step | impacts = impacts, kwh = kwh, heat = heat }
            )


computeDyeingImpacts : Db -> Simulator -> Simulator
computeDyeingImpacts { textile } ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Ennobling
            (\({ country, dyeingMedium } as step) ->
                let
                    heatProcess =
                        WellKnown.getEnnoblingHeatProcess textile.wellKnown country

                    productDefaultMedium =
                        dyeingMedium
                            |> Maybe.withDefault inputs.product.dyeing.defaultMedium

                    dyeingProcess =
                        textile.wellKnown
                            |> WellKnown.getDyeingProcess productDefaultMedium

                    dyeingToxicity =
                        inputs.materials
                            |> List.map
                                (\{ material, share } ->
                                    Formula.materialDyeingToxicityImpacts step.impacts
                                        { dyeingToxicityProcess =
                                            if Origin.isSynthetic material.origin then
                                                textile.wellKnown.dyeingSynthetic

                                            else
                                                textile.wellKnown.dyeingCellulosic
                                        , aquaticPollutionScenario = step.country.aquaticPollutionScenario
                                        }
                                        step.outputMass
                                        share
                                )
                            |> Impact.sumImpacts

                    { heat, kwh, impacts } =
                        step.outputMass
                            |> Formula.dyeingImpacts step.impacts
                                dyeingProcess
                                heatProcess
                                country.electricityProcess
                in
                { step
                    | heat = step.heat |> Quantity.plus heat
                    , kwh = step.kwh |> Quantity.plus kwh
                    , impacts = Impact.sumImpacts [ step.impacts, impacts, dyeingToxicity ]
                }
            )


computePrintingImpacts : Db -> Simulator -> Simulator
computePrintingImpacts { textile } ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Ennobling
            (\({ country } as step) ->
                case step.printing of
                    Just { kind, ratio } ->
                        let
                            { printingProcess, printingToxicityProcess } =
                                WellKnown.getPrintingProcess kind textile.wellKnown

                            { heat, kwh, impacts } =
                                step.outputMass
                                    |> Formula.printingImpacts step.impacts
                                        { printingProcess = printingProcess
                                        , heatProcess = WellKnown.getEnnoblingHeatProcess textile.wellKnown country
                                        , elecProcess = country.electricityProcess
                                        , surfaceMass = Maybe.withDefault inputs.product.surfaceMass inputs.surfaceMass
                                        , ratio = ratio
                                        }

                            printingToxicity =
                                step.outputMass
                                    |> Formula.materialPrintingToxicityImpacts
                                        step.impacts
                                        { printingToxicityProcess = printingToxicityProcess
                                        , aquaticPollutionScenario = step.country.aquaticPollutionScenario
                                        }
                                        ratio
                        in
                        { step
                            | heat = step.heat |> Quantity.plus heat
                            , kwh = step.kwh |> Quantity.plus kwh
                            , impacts = Impact.sumImpacts [ step.impacts, impacts, printingToxicity ]
                        }

                    Nothing ->
                        step
            )


computeFinishingImpacts : Db -> Simulator -> Simulator
computeFinishingImpacts { textile } simulator =
    simulator
        |> updateLifeCycleStep Label.Ennobling
            (\({ country } as step) ->
                let
                    { heat, kwh, impacts } =
                        step.outputMass
                            |> Formula.finishingImpacts step.impacts
                                { finishingProcess = textile.wellKnown.finishing
                                , heatProcess = WellKnown.getEnnoblingHeatProcess textile.wellKnown country
                                , elecProcess = country.electricityProcess
                                }
                in
                { step
                    | heat = step.heat |> Quantity.plus heat
                    , kwh = step.kwh |> Quantity.plus kwh
                    , impacts = step.impacts |> Impact.addImpacts impacts
                }
            )


computeBleachingImpacts : Db -> Simulator -> Simulator
computeBleachingImpacts { textile } ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Ennobling
            (\step ->
                -- Note: bleaching only applies to non-synthetic materials
                { step
                    | impacts =
                        step.outputMass
                            -- Note: bleaching only applies to non-synthetic materials
                            |> Quantity.multiplyBy (Inputs.getMaterialsShareForOrigin Origin.nonSynthetic inputs.materials)
                            |> Formula.bleachingImpacts step.impacts
                                { bleachingProcess = textile.wellKnown.bleaching
                                , aquaticPollutionScenario = step.country.aquaticPollutionScenario
                                , countryElecProcess = inputs.countryDyeing.electricityProcess
                                , countryHeatProcess = inputs.countryDyeing.heatProcess
                                }
                            |> Impact.addImpacts step.impacts
                }
            )


computeDesizingImpacts : Db -> Simulator -> Simulator
computeDesizingImpacts { textile } ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Ennobling
            (\step ->
                -- Note: desizing only applies to weaved products
                if inputs.product.fabric == Fabric.Weaving then
                    { step
                        | impacts =
                            step.outputMass
                                |> Formula.genericImpacts step.impacts
                                    { process = textile.wellKnown.desizing
                                    , countryElecProcess = inputs.countryDyeing.electricityProcess
                                    , countryHeatProcess = inputs.countryDyeing.heatProcess
                                    }
                                |> Impact.addImpacts step.impacts
                    }

                else
                    step
            )


computeScouringImpacts : Db -> Simulator -> Simulator
computeScouringImpacts { textile } ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Ennobling
            (\step ->
                { step
                    | impacts =
                        step.outputMass
                            -- Note: scouring only applies to natural materials
                            |> Quantity.multiplyBy (Inputs.getMaterialsShareForOrigin Origin.natural inputs.materials)
                            |> Formula.genericImpacts step.impacts
                                { process = textile.wellKnown.scouring
                                , countryElecProcess = inputs.countryDyeing.electricityProcess
                                , countryHeatProcess = inputs.countryDyeing.heatProcess
                                }
                            |> Impact.addImpacts step.impacts
                }
            )


computeMercerisingImpacts : Db -> Simulator -> Simulator
computeMercerisingImpacts { textile } ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Ennobling
            (\step ->
                { step
                    | impacts =
                        step.outputMass
                            -- Note: mercerising only applies to cotton (conventional and organic)
                            |> Quantity.multiplyBy (Inputs.getCottonShare inputs.materials)
                            |> Formula.mercerisingImpacts step.impacts
                                { mercerisingProcess = textile.wellKnown.mercerising
                                , countryElecProcess = inputs.countryDyeing.electricityProcess
                                , countryHeatProcess = inputs.countryDyeing.heatProcess
                                }
                            |> Impact.addImpacts step.impacts
                }
            )


computeWashingImpacts : Db -> Simulator -> Simulator
computeWashingImpacts { textile } ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Ennobling
            (\step ->
                { step
                    | impacts =
                        step.outputMass
                            -- Note: washing only applies to synthetic and artificial materials
                            |> Quantity.multiplyBy (Inputs.getMaterialsShareForOrigin Origin.syntheticAndArtificial inputs.materials)
                            |> Formula.genericImpacts step.impacts
                                { process = textile.wellKnown.washing
                                , countryElecProcess = inputs.countryDyeing.electricityProcess
                                , countryHeatProcess = inputs.countryDyeing.heatProcess
                                }
                            |> Impact.addImpacts step.impacts
                }
            )


stepMaterialImpacts : Db -> Material -> Step -> Impacts
stepMaterialImpacts { textile } material step =
    case Material.getRecyclingData material textile.materials of
        -- Non-recycled Material
        Nothing ->
            step.outputMass
                |> Formula.pureMaterialImpacts step.impacts material.materialProcess

        -- Recycled material: apply CFF
        Just ( sourceMaterial, cffData ) ->
            step.outputMass
                |> Formula.recycledMaterialImpacts step.impacts
                    { recycledProcess = material.materialProcess
                    , nonRecycledProcess = sourceMaterial.materialProcess
                    , cffData = cffData
                    }


computeMaterialImpacts : Db -> Simulator -> Simulator
computeMaterialImpacts db ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Material
            (\step ->
                { step
                    | impacts =
                        inputs.materials
                            |> List.map
                                (\{ material, share } ->
                                    step
                                        |> stepMaterialImpacts db material
                                        |> Impact.mapImpacts (\_ -> Quantity.multiplyBy (Split.toFloat share))
                                )
                            |> Impact.sumImpacts
                }
            )


stepSpinningImpacts : Material -> Maybe Spinning -> Product -> Step -> { impacts : Impacts, kwh : Energy }
stepSpinningImpacts material maybeSpinning product step =
    let
        yarnSize =
            step.yarnSize
                |> Maybe.withDefault product.yarnSize

        spinning =
            maybeSpinning
                |> Maybe.withDefault (Spinning.getDefault material.origin)

        kwh =
            spinning
                |> Spinning.getElec step.outputMass yarnSize
                |> Energy.kilowattHours
    in
    Formula.spinningImpacts step.impacts
        { spinningKwh = kwh
        , countryElecProcess = step.country.electricityProcess
        }


computeSpinningImpacts : Simulator -> Simulator
computeSpinningImpacts ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Spinning
            (\step ->
                { step
                    | kwh =
                        inputs.materials
                            |> List.map
                                (\{ material, share, spinning } ->
                                    step
                                        |> stepSpinningImpacts material spinning inputs.product
                                        |> .kwh
                                        |> Quantity.multiplyBy (Split.toFloat share)
                                )
                            |> List.foldl Quantity.plus Quantity.zero
                    , impacts =
                        inputs.materials
                            |> List.map
                                (\{ material, share, spinning } ->
                                    step
                                        |> stepSpinningImpacts material spinning inputs.product
                                        |> .impacts
                                        |> Impact.mapImpacts (\_ -> Quantity.multiplyBy (Split.toFloat share))
                                )
                            |> Impact.sumImpacts
                }
            )


computeFabricImpacts : Db -> Simulator -> Simulator
computeFabricImpacts { textile } ({ inputs, lifeCycle } as simulator) =
    let
        fabricOutputMass =
            lifeCycle
                |> LifeCycle.getStepProp Label.Fabric .outputMass Quantity.zero
    in
    simulator
        |> updateLifeCycleStep Label.Fabric
            (\({ country } as step) ->
                let
                    process =
                        inputs.fabricProcess
                            |> Fabric.getProcess textile.wellKnown

                    { kwh, threadDensity, picking, impacts } =
                        if Fabric.isKnitted inputs.fabricProcess then
                            Formula.knittingImpacts step.impacts
                                { elec = process.elec
                                , countryElecProcess = country.electricityProcess
                                }
                                step.outputMass

                        else
                            let
                                surfaceMass =
                                    inputs.surfaceMass
                                        |> Maybe.withDefault inputs.product.surfaceMass
                            in
                            Formula.weavingImpacts step.impacts
                                { countryElecProcess = country.electricityProcess
                                , outputMass = fabricOutputMass
                                , pickingElec = process.elec_pppm
                                , surfaceMass = surfaceMass
                                , yarnSize = inputs.yarnSize |> Maybe.withDefault inputs.product.yarnSize
                                }
                in
                { step | impacts = impacts, threadDensity = threadDensity, kwh = kwh, picking = picking }
            )


computeMakingStepWaste : Simulator -> Simulator
computeMakingStepWaste ({ inputs } as simulator) =
    let
        { mass, waste } =
            inputs.mass
                |> Formula.makingWaste (Maybe.withDefault inputs.product.making.pcrWaste inputs.makingWaste)
    in
    simulator
        |> updateLifeCycleStep Label.Making (Step.updateWaste waste mass)
        |> updateLifeCycleSteps
            [ Label.Material, Label.Spinning, Label.Fabric, Label.Ennobling ]
            (Step.initMass mass)


computeMakingStepDeadStock : Simulator -> Simulator
computeMakingStepDeadStock ({ inputs, lifeCycle } as simulator) =
    let
        { mass, deadstock } =
            lifeCycle
                |> LifeCycle.getStepProp Label.Making .inputMass Quantity.zero
                |> Formula.makingDeadStock (Maybe.withDefault Env.defaultDeadStock inputs.makingDeadStock)
    in
    simulator
        |> updateLifeCycleStep Label.Making (Step.updateDeadStock deadstock mass)
        |> updateLifeCycleSteps
            [ Label.Material, Label.Spinning, Label.Fabric, Label.Ennobling ]
            (Step.initMass mass)


computeFabricStepWaste : Db -> Simulator -> Simulator
computeFabricStepWaste { textile } ({ inputs, lifeCycle } as simulator) =
    let
        { mass, waste } =
            lifeCycle
                |> LifeCycle.getStepProp Label.Making .inputMass Quantity.zero
                |> Formula.genericWaste
                    (inputs.fabricProcess
                        |> Fabric.getProcess textile.wellKnown
                        |> .waste
                    )
    in
    simulator
        |> updateLifeCycleStep Label.Fabric (Step.updateWaste waste mass)
        |> updateLifeCycleSteps [ Label.Material, Label.Spinning ] (Step.initMass mass)


computeMaterialStepWaste : Simulator -> Simulator
computeMaterialStepWaste ({ inputs, lifeCycle } as simulator) =
    let
        { mass, waste } =
            lifeCycle
                |> LifeCycle.getStepProp Label.Spinning .inputMass Quantity.zero
                |> (\inputMass ->
                        inputs.materials
                            |> List.map
                                (\{ material, share } ->
                                    inputMass
                                        |> Quantity.multiplyBy (Split.toFloat share)
                                        |> Formula.genericWaste material.materialProcess.waste
                                )
                            |> List.foldl
                                (\curr acc ->
                                    { mass = curr.mass |> Quantity.plus acc.mass
                                    , waste = curr.waste |> Quantity.plus acc.waste
                                    }
                                )
                                { mass = Quantity.zero, waste = Quantity.zero }
                   )
    in
    simulator
        |> updateLifeCycleStep Label.Material (Step.updateWaste waste mass)


computeSpinningStepWaste : Simulator -> Simulator
computeSpinningStepWaste ({ inputs, lifeCycle } as simulator) =
    let
        { mass, waste } =
            lifeCycle
                |> LifeCycle.getStepProp Label.Fabric .inputMass Quantity.zero
                |> (\inputMass ->
                        inputs.materials
                            |> List.map
                                (\{ material, share, spinning } ->
                                    let
                                        spinningProcess =
                                            spinning
                                                |> Maybe.withDefault (Spinning.getDefault material.origin)

                                        processWaste =
                                            Spinning.waste spinningProcess

                                        outputMaterialMass =
                                            -- The output mass is the input mass of the next step
                                            inputMass
                                                |> Quantity.multiplyBy (Split.toFloat share)

                                        inputMaterialMass =
                                            -- Formula : inputMass - inputMass * waste = outputMass
                                            -- => inputMass * (1 - waste) = outputMass
                                            -- => inputMass = outputMass / (1 - waste)
                                            Split.complement processWaste
                                                |> Split.divideBy (Mass.inKilograms outputMaterialMass)
                                                |> Mass.kilograms
                                    in
                                    { waste = Quantity.difference inputMaterialMass outputMaterialMass
                                    , mass = inputMaterialMass
                                    }
                                )
                            |> List.foldl
                                (\curr acc ->
                                    { mass = curr.mass |> Quantity.plus acc.mass
                                    , waste = curr.waste |> Quantity.plus acc.waste
                                    }
                                )
                                { mass = Quantity.zero, waste = Quantity.zero }
                   )
    in
    simulator
        |> updateLifeCycleStep Label.Spinning (Step.updateWaste waste mass)


computeStepsTransport : Db -> Simulator -> Simulator
computeStepsTransport db simulator =
    simulator |> updateLifeCycle (LifeCycle.computeStepsTransport db simulator.inputs)


computeTotalTransportImpacts : Simulator -> Simulator
computeTotalTransportImpacts simulator =
    { simulator
        | transport =
            simulator.lifeCycle
                |> LifeCycle.computeTotalTransportImpacts
    }


computeFinalImpacts : Simulator -> Simulator
computeFinalImpacts ({ durability, lifeCycle } as simulator) =
    let
        complementsImpacts =
            lifeCycle
                |> LifeCycle.sumComplementsImpacts
                |> Impact.divideComplementsImpactsBy (Unit.durabilityToFloat durability)
    in
    { simulator
        | complementsImpacts = complementsImpacts
        , impacts =
            lifeCycle
                |> LifeCycle.computeFinalImpacts
                |> Impact.divideBy (Unit.durabilityToFloat durability)
                |> Impact.impactsWithComplements complementsImpacts
    }


updateLifeCycle : (LifeCycle -> LifeCycle) -> Simulator -> Simulator
updateLifeCycle update simulator =
    { simulator | lifeCycle = update simulator.lifeCycle }


updateLifeCycleStep : Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleStep label update =
    updateLifeCycle (LifeCycle.updateStep label update)


updateLifeCycleSteps : List Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleSteps labels update =
    updateLifeCycle (LifeCycle.updateSteps labels update)


toStepsImpacts : Definition.Trigram -> Simulator -> Impact.StepsImpacts
toStepsImpacts trigram simulator =
    let
        getImpacts label =
            LifeCycle.getStep label simulator.lifeCycle
                |> Maybe.map .impacts
                |> Maybe.withDefault Impact.empty

        getImpact =
            Impact.getImpact trigram
                >> Just

        applyComplement complementImpact =
            if trigram == Definition.Ecs then
                Maybe.map
                    (Quantity.minus
                        (complementImpact
                            |> Quantity.multiplyBy (Unit.durabilityToFloat simulator.durability)
                        )
                    )

            else
                identity
    in
    { materials =
        getImpacts Label.Material
            |> getImpact
            |> applyComplement simulator.complementsImpacts.microfibers
    , transform =
        [ getImpacts Label.Spinning
        , getImpacts Label.Fabric
        , getImpacts Label.Ennobling
        , getImpacts Label.Making
        ]
            |> Impact.sumImpacts
            |> getImpact
    , packaging = Nothing
    , transports = getImpact simulator.transport.impacts
    , distribution = Nothing
    , usage = getImpacts Label.Use |> getImpact
    , endOfLife =
        getImpacts Label.EndOfLife
            |> getImpact
            |> applyComplement simulator.complementsImpacts.outOfEuropeEOL
    }
        |> Impact.divideStepsImpactsBy (Unit.durabilityToFloat simulator.durability)
