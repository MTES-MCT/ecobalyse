module Data.Textile.Simulator exposing
    ( Simulator
    , compute
    , encode
    , getTotalImpactsWithoutComplements
    , getTotalImpactsWithoutDurability
    , stageMaterialImpacts
    , toStagesImpacts
    )

import Array
import Data.Common.EncodeUtils as EU
import Data.Component as Component
import Data.Country as Country
import Data.Env as Env
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition
import Data.Scope as Scope
import Data.Split as Split
import Data.Textile.Dyeing as Dyeing
import Data.Textile.Economics as Economics
import Data.Textile.Fabric as Fabric
import Data.Textile.Formula as Formula
import Data.Textile.Inputs as Inputs exposing (Inputs)
import Data.Textile.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Origin as Origin
import Data.Textile.Material.Spinning as Spinning exposing (Spinning)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Query as Query exposing (Query)
import Data.Textile.Stage as Stage exposing (Stage)
import Data.Textile.Stage.Label as Label exposing (Label)
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
    { complementsImpacts : Impact.ComplementsImpacts
    , componentConfig : Component.Config
    , daysOfWear : Duration
    , durability : Unit.HolisticDurability
    , impacts : Impacts
    , inputs : Inputs
    , lifeCycle : LifeCycle
    , transport : Transport
    , trimsImpacts : Impacts
    , useNbCycles : Int
    }


encode : Maybe String -> Simulator -> Encode.Value
encode webUrl v =
    EU.optionalPropertiesObject
        [ ( "complementsImpacts", Impact.encodeComplementsImpacts v.complementsImpacts |> Just )
        , ( "daysOfWear", v.daysOfWear |> Duration.inDays |> round |> Encode.int |> Just )
        , ( "durability", v.durability |> Unit.floatDurabilityFromHolistic |> Encode.float |> Just )
        , ( "impacts", Impact.encode v.impacts |> Just )
        , ( "impactsWithoutDurability", Impact.encode (getTotalImpactsWithoutDurability v) |> Just )
        , ( "inputs", Inputs.encode v.inputs |> Just )
        , ( "lifeCycle", LifeCycle.encode v.lifeCycle |> Just )
        , ( "transport", Transport.encode v.transport |> Just )
        , ( "useNbCycles", Encode.int v.useNbCycles |> Just )
        , ( "webUrl", webUrl |> Maybe.map Encode.string )
        ]


init : Db -> Component.Config -> Query -> Result String Simulator
init db componentConfig =
    Query.handleUpcycling
        >> Inputs.fromQuery db
        >> Result.map
            (\({ product } as inputs) ->
                inputs
                    |> LifeCycle.init db
                    |> (\lifeCycle ->
                            { complementsImpacts = Impact.noComplementsImpacts
                            , componentConfig = componentConfig
                            , daysOfWear = inputs.product.use.daysOfWear
                            , durability =
                                { nonPhysical = Unit.standardDurability Unit.NonPhysicalDurability
                                , physical = inputs.physicalDurability |> Maybe.withDefault (Unit.maxDurability Unit.PhysicalDurability)
                                }
                            , impacts = Impact.empty
                            , inputs = inputs
                            , lifeCycle = lifeCycle
                            , transport = Transport.default Impact.empty
                            , trimsImpacts = Impact.empty
                            , useNbCycles = Product.customDaysOfWear product.use
                            }
                       )
            )


{-| Computes simulation impacts.
-}
compute : Db -> Component.Config -> Query -> Result String Simulator
compute db componentConfig query =
    let
        next fn =
            Result.map fn

        andNext fn =
            Result.andThen fn

        nextWithDb fn =
            next (fn db)

        andNextWithDb fn =
            andNext (fn db)

        nextIf label fn =
            if not (List.member label query.disabledStages) then
                next fn

            else
                identity

        nextWithDbIf label fn =
            if not (List.member label query.disabledStages) then
                nextWithDb fn

            else
                identity
    in
    init db componentConfig query
        -- Ensure end product mass is first applied to the final Distribution stage
        |> next initializeFinalMass
        --
        -- WASTE: compute the initial required material mass
        --
        -- Compute Making mass waste - Confection
        |> nextIf Label.Making computeMakingStageWaste
        -- Compute Making dead stock - Confection
        |> nextIf Label.Making computeMakingStageDeadStock
        -- Compute Knitting/Weawing waste - Tissage/Tricotage
        |> nextWithDbIf Label.Fabric computeFabricStageWaste
        -- Compute Spinning waste - Filature
        |> nextIf Label.Spinning computeSpinningStageWaste
        -- Compute Material waste - Matière
        -- We always need to compute the Material's stage waste otherwise the input mass
        -- for the next stage (spinning) would never be computed.
        |> next computeMaterialStageWaste
        --
        -- DURABILITY
        --
        |> next computeDurability
        -- Compute Making air transport ratio (depends on durability) - Confection
        |> nextIf Label.Making computeMakingAirTransportRatio
        --
        -- TRIMS WEIGHT
        -- trims are added at the Making stage and are carried through the next stages of the lifecycle
        --
        |> nextWithDb handleTrimsWeight
        --
        -- LIFECYCLE STEP IMPACTS
        --
        -- Compute Material stage impacts
        |> nextIf Label.Material (computeMaterialImpacts db)
        -- Compute Spinning stage impacts
        |> nextIf Label.Spinning computeSpinningImpacts
        -- Compute Weaving & Knitting stage impacts
        |> nextWithDbIf Label.Fabric computeFabricImpacts
        -- Compute Ennobling stage Dyeing impacts
        |> nextWithDbIf Label.Ennobling computeDyeingImpacts
        -- Compute Ennobling stage Printing impacts
        |> nextWithDbIf Label.Ennobling computePrintingImpacts
        -- Compute Ennobling stage Finishing impacts
        |> nextWithDbIf Label.Ennobling computeFinishingImpacts
        -- Compute Making stage impacts
        |> nextWithDbIf Label.Making computeMakingImpacts
        -- Compute product Use impacts
        |> nextWithDbIf Label.Use computeUseImpacts
        -- Compute product Use impacts
        |> nextWithDbIf Label.EndOfLife computeEndOfLifeImpacts
        --
        -- TRANSPORTS
        --
        -- Compute stage transport
        |> nextWithDb computeStagesTransport
        -- Compute transport summary
        |> next computeTotalTransportImpacts
        --
        -- TRIMS
        --
        -- Compute trims
        |> andNextWithDb computeTrims
        --
        -- Final impacts
        --
        |> next computeFinalImpacts


initializeFinalMass : Simulator -> Simulator
initializeFinalMass ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStages Label.all (Stage.initMass inputs.mass)


handleTrimsWeight : Db -> Simulator -> Simulator
handleTrimsWeight db ({ componentConfig, inputs } as simulator) =
    -- We need to substract trims weight at the Material, Spinning, Fabric and Ennobling stages
    -- because they're added at the Making stage and carried through the next stages of the lifecycle
    let
        trimsMass =
            Component.emptyQuery
                |> Component.setQueryItems inputs.trims
                |> Component.compute { config = componentConfig, db = db, scope = Scope.Textile }
                |> Result.map (.production >> Component.extractMass)
                |> Result.withDefault Quantity.zero
    in
    simulator
        |> updateLifeCycleStages [ Label.Material, Label.Spinning, Label.Fabric, Label.Ennobling ]
            (\stage ->
                { stage
                    | inputMass = stage.inputMass |> Quantity.minus trimsMass
                    , outputMass = stage.outputMass |> Quantity.minus trimsMass
                }
            )


computeDurability : Simulator -> Simulator
computeDurability ({ inputs } as simulator) =
    let
        nonPhysicalDurability =
            Economics.computeNonPhysicalDurabilityIndex
                { business =
                    inputs.business
                        |> Maybe.withDefault inputs.product.economics.business
                , numberOfReferences =
                    inputs.numberOfReferences
                        |> Maybe.withDefault inputs.product.economics.numberOfReferences
                , price =
                    inputs.price
                        |> Maybe.withDefault inputs.product.economics.price
                , repairCost = inputs.product.economics.repairCost
                }

        newDurability =
            { nonPhysical = nonPhysicalDurability
            , physical = simulator.durability.physical
            }
    in
    { simulator
        | daysOfWear =
            simulator.daysOfWear
                |> Quantity.multiplyBy (Unit.floatDurabilityFromHolistic newDurability)
        , durability = newDurability
        , useNbCycles =
            round (toFloat simulator.useNbCycles * Unit.floatDurabilityFromHolistic newDurability)
    }


computeMakingAirTransportRatio : Simulator -> Simulator
computeMakingAirTransportRatio ({ durability, inputs } as simulator) =
    simulator
        |> updateLifeCycleStage Label.Making
            (\({ country } as stage) ->
                { stage
                    | airTransportRatio =
                        case inputs.airTransportRatio of
                            Just airTransportRatio ->
                                -- User-provided value always takes precedence
                                airTransportRatio

                            Nothing ->
                                if Country.isEuropeOrTurkey country then
                                    -- If Making country is Europe or Turkey, airTransportRatio is always 0
                                    Split.zero

                                else if Unit.floatDurabilityFromHolistic durability >= 1 then
                                    -- Durable garments outside of Europe and Turkey
                                    Split.third

                                else
                                    -- FIXME: how about falling back to country default?
                                    -- country.airTransportRatio
                                    Split.full
                }
            )


computeEndOfLifeImpacts : Db -> Simulator -> Simulator
computeEndOfLifeImpacts { textile } simulator =
    simulator
        |> updateLifeCycleStage Label.EndOfLife
            (\({ country } as stage) ->
                let
                    { heat, impacts, kwh } =
                        stage.outputMass
                            |> Formula.endOfLifeImpacts stage.impacts
                                { countryElecProcess = country.electricityProcess
                                , endOfLife = textile.wellKnown.endOfLife
                                , heatProcess = country.heatProcess
                                , passengerCar = textile.wellKnown.passengerCar
                                , volume = simulator.inputs.product.endOfLife.volume
                                }
                in
                { stage
                    | heat = heat
                    , impacts = impacts
                    , kwh = kwh
                }
            )


computeUseImpacts : Db -> Simulator -> Simulator
computeUseImpacts { textile } ({ inputs, useNbCycles } as simulator) =
    simulator
        |> updateLifeCycleStage Label.Use
            (\stage ->
                let
                    { impacts, kwh } =
                        stage.outputMass
                            |> Formula.useImpacts stage.impacts
                                -- Note: The use stage is always located in France using low voltage electricity
                                { countryElecProcess = textile.wellKnown.lowVoltageFranceElec
                                , ironingElec = inputs.product.use.ironingElec
                                , nonIroningProcess = inputs.product.use.nonIroningProcess
                                , useNbCycles = useNbCycles
                                }
                in
                { stage | impacts = impacts, kwh = kwh }
            )


computeMakingImpacts : Db -> Simulator -> Simulator
computeMakingImpacts { textile } ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStage Label.Making
            (\({ country } as stage) ->
                let
                    { heat, impacts, kwh } =
                        stage.outputMass
                            |> Formula.makingImpacts stage.impacts
                                { countryElecProcess = country.electricityProcess
                                , countryHeatProcess = country.heatProcess
                                , fadingProcess =
                                    -- Note: in the future, we may have distinct fading processes per countries
                                    if inputs.fading == Just True then
                                        Just textile.wellKnown.fading

                                    else
                                        Nothing
                                , makingComplexity =
                                    inputs.fabricProcess
                                        |> Fabric.getMakingComplexity inputs.product.making.complexity inputs.makingComplexity
                                }
                in
                { stage | heat = heat, impacts = impacts, kwh = kwh }
            )


computeDyeingImpacts : Db -> Simulator -> Simulator
computeDyeingImpacts { textile } ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStage Label.Ennobling
            (\({ country, dyeingProcessType } as stage) ->
                let
                    heatProcess =
                        WellKnown.getEnnoblingHeatProcess textile.wellKnown country

                    dyeingProcess =
                        Dyeing.toProcess textile.wellKnown dyeingProcessType

                    dyeingToxicity =
                        inputs.materials
                            |> List.map
                                (\{ material, share } ->
                                    Formula.materialDyeingToxicityImpacts stage.impacts
                                        { aquaticPollutionScenario = stage.country.aquaticPollutionScenario
                                        , dyeingToxicityProcess =
                                            if Origin.isSynthetic material.origin then
                                                textile.wellKnown.dyeingSynthetic

                                            else
                                                textile.wellKnown.dyeingCellulosic
                                        }
                                        stage.outputMass
                                        share
                                )
                            |> Impact.sumImpacts

                    preTreatments =
                        stage |> Stage.computePreTreatments textile.wellKnown inputs.materials

                    { heat, impacts, kwh } =
                        stage.outputMass
                            |> Formula.dyeingImpacts stage.impacts
                                dyeingProcess
                                heatProcess
                                country.electricityProcess
                in
                { stage
                    | heat = Quantity.sum [ stage.heat, heat, preTreatments.heat ]
                    , impacts = Impact.sumImpacts [ stage.impacts, impacts, dyeingToxicity, preTreatments.energy, preTreatments.toxicity ]
                    , kwh = Quantity.sum [ stage.kwh, kwh, preTreatments.kwh ]
                    , preTreatments = preTreatments
                }
            )


computePrintingImpacts : Db -> Simulator -> Simulator
computePrintingImpacts { textile } ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStage Label.Ennobling
            (\({ country } as stage) ->
                case stage.printing of
                    Just { kind, ratio } ->
                        let
                            { printingProcess, printingToxicityProcess } =
                                WellKnown.getPrintingProcess kind textile.wellKnown

                            { heat, impacts, kwh } =
                                stage.outputMass
                                    |> Formula.printingImpacts stage.impacts
                                        { elecProcess = country.electricityProcess
                                        , heatProcess = WellKnown.getEnnoblingHeatProcess textile.wellKnown country
                                        , printingProcess = printingProcess
                                        , ratio = ratio
                                        , surfaceMass = inputs.surfaceMass |> Maybe.withDefault inputs.product.surfaceMass
                                        }

                            printingToxicity =
                                stage.outputMass
                                    |> Formula.materialPrintingToxicityImpacts
                                        stage.impacts
                                        { aquaticPollutionScenario = stage.country.aquaticPollutionScenario
                                        , printingToxicityProcess = printingToxicityProcess
                                        , surfaceMass = inputs.surfaceMass |> Maybe.withDefault inputs.product.surfaceMass
                                        }
                                        ratio
                        in
                        { stage
                            | heat = stage.heat |> Quantity.plus heat
                            , impacts = Impact.sumImpacts [ stage.impacts, impacts, printingToxicity ]
                            , kwh = stage.kwh |> Quantity.plus kwh
                        }

                    Nothing ->
                        stage
            )


computeFinishingImpacts : Db -> Simulator -> Simulator
computeFinishingImpacts { textile } simulator =
    simulator
        |> updateLifeCycleStage Label.Ennobling
            (\({ country } as stage) ->
                let
                    { heat, impacts, kwh } =
                        stage.outputMass
                            |> Formula.finishingImpacts stage.impacts
                                { elecProcess = country.electricityProcess
                                , finishingProcess = textile.wellKnown.finishing
                                , heatProcess = WellKnown.getEnnoblingHeatProcess textile.wellKnown country
                                }
                in
                { stage
                    | heat = stage.heat |> Quantity.plus heat
                    , impacts = Impact.sumImpacts [ stage.impacts, impacts ]
                    , kwh = stage.kwh |> Quantity.plus kwh
                }
            )


stageMaterialImpacts : Db -> Material -> Stage -> Impacts
stageMaterialImpacts { textile } material stage =
    case Material.getRecyclingData material textile.materials of
        -- Recycled material: apply CFF
        Just ( sourceMaterial, cffData ) ->
            stage.outputMass
                |> Formula.recycledMaterialImpacts stage.impacts
                    { cffData = cffData
                    , nonRecycledProcess = sourceMaterial.process
                    , recycledProcess = material.process
                    }

        -- Non-recycled Material
        Nothing ->
            stage.outputMass
                |> Formula.pureMaterialImpacts stage.impacts material.process


computeMaterialImpacts : Db -> Simulator -> Simulator
computeMaterialImpacts db ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStage Label.Material
            (\stage ->
                { stage
                    | impacts =
                        inputs.materials
                            |> List.map
                                (\{ material, share } ->
                                    stage
                                        |> stageMaterialImpacts db material
                                        |> Impact.mapImpacts (\_ -> Quantity.multiplyBy (Split.toFloat share))
                                )
                            |> Impact.sumImpacts
                }
            )


stageSpinningImpacts : Material -> Maybe Spinning -> Product -> Stage -> { heat : Energy, impacts : Impacts, kwh : Energy }
stageSpinningImpacts material maybeSpinning product stage =
    let
        yarnSize =
            stage.yarnSize
                |> Maybe.withDefault product.yarnSize

        spinning =
            maybeSpinning
                |> Maybe.withDefault (Spinning.getDefault material.origin)

        kwh =
            spinning
                |> Spinning.getElec stage.outputMass yarnSize
                |> Energy.kilowattHours
    in
    Formula.spinningImpacts stage.impacts
        { countryElecProcess = stage.country.electricityProcess
        , spinningKwh = kwh
        }


computeSpinningImpacts : Simulator -> Simulator
computeSpinningImpacts ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStage Label.Spinning
            (\stage ->
                { stage
                    | impacts =
                        inputs.materials
                            |> List.map
                                (\{ material, share, spinning } ->
                                    stage
                                        |> stageSpinningImpacts material spinning inputs.product
                                        |> .impacts
                                        |> Impact.mapImpacts (\_ -> Quantity.multiplyBy (Split.toFloat share))
                                )
                            |> Impact.sumImpacts
                    , kwh =
                        inputs.materials
                            |> List.map
                                (\{ material, share, spinning } ->
                                    stage
                                        |> stageSpinningImpacts material spinning inputs.product
                                        |> .kwh
                                        |> Quantity.multiplyBy (Split.toFloat share)
                                )
                            |> List.foldl Quantity.plus Quantity.zero
                }
            )


computeFabricImpacts : Db -> Simulator -> Simulator
computeFabricImpacts { textile } ({ inputs, lifeCycle } as simulator) =
    let
        fabricOutputMass =
            lifeCycle
                |> LifeCycle.getStageProp Label.Fabric .outputMass Quantity.zero
    in
    simulator
        |> updateLifeCycleStage Label.Fabric
            (\({ country } as stage) ->
                let
                    process =
                        inputs.fabricProcess
                            |> Maybe.withDefault inputs.product.fabric
                            |> Fabric.getProcess textile.wellKnown

                    { impacts, kwh, picking, threadDensity } =
                        if
                            inputs.fabricProcess
                                |> Maybe.withDefault inputs.product.fabric
                                |> Fabric.isKnitted
                        then
                            stage.outputMass
                                |> Formula.knittingImpacts stage.impacts
                                    { countryElecProcess = country.electricityProcess
                                    , elec = process.elec
                                    }

                        else
                            let
                                surfaceMass =
                                    inputs.surfaceMass
                                        |> Maybe.withDefault inputs.product.surfaceMass
                            in
                            Formula.weavingImpacts stage.impacts
                                { countryElecProcess = country.electricityProcess
                                , outputMass = fabricOutputMass
                                , pickingElec = WellKnown.weavingElecPPPM
                                , surfaceMass = surfaceMass
                                , yarnSize = inputs.yarnSize |> Maybe.withDefault inputs.product.yarnSize
                                }
                in
                { stage
                    | impacts = impacts
                    , kwh = kwh
                    , picking = picking
                    , threadDensity = threadDensity
                }
            )


computeMakingStageWaste : Simulator -> Simulator
computeMakingStageWaste ({ inputs } as simulator) =
    let
        { fabricProcess, makingWaste, product } =
            inputs

        { mass, waste } =
            inputs.mass
                |> Formula.genericWaste
                    (fabricProcess
                        |> Fabric.getMakingWaste product.making.pcrWaste makingWaste
                    )
    in
    simulator
        |> updateLifeCycleStage Label.Making (Stage.updateWasteAndMasses waste mass)
        |> updateLifeCycleStages Label.upcyclables (Stage.initMass mass)


computeMakingStageDeadStock : Simulator -> Simulator
computeMakingStageDeadStock ({ inputs, lifeCycle } as simulator) =
    let
        { deadstock, mass } =
            lifeCycle
                |> LifeCycle.getStageProp Label.Making .inputMass Quantity.zero
                |> Formula.makingDeadStock (Maybe.withDefault Env.defaultDeadStock inputs.makingDeadStock)
    in
    simulator
        |> updateLifeCycleStage Label.Making (Stage.updateDeadStock deadstock mass)
        |> updateLifeCycleStages Label.upcyclables (Stage.initMass mass)


computeFabricStageWaste : Db -> Simulator -> Simulator
computeFabricStageWaste { textile } ({ inputs, lifeCycle } as simulator) =
    let
        { mass, waste } =
            lifeCycle
                |> LifeCycle.getStageProp Label.Making .inputMass Quantity.zero
                |> Formula.genericWaste
                    (inputs.fabricProcess
                        |> Maybe.withDefault inputs.product.fabric
                        |> Fabric.getProcess textile.wellKnown
                        |> .waste
                    )
    in
    simulator
        |> updateLifeCycleStage Label.Fabric (Stage.updateWasteAndMasses waste mass)
        |> updateLifeCycleStages [ Label.Material, Label.Spinning ] (Stage.initMass mass)


computeMaterialStageWaste : Simulator -> Simulator
computeMaterialStageWaste ({ inputs, lifeCycle } as simulator) =
    let
        { mass, waste } =
            lifeCycle
                |> LifeCycle.getStageProp Label.Spinning .inputMass Quantity.zero
                |> (\inputMass ->
                        inputs.materials
                            |> List.map
                                (\{ material, share } ->
                                    inputMass
                                        |> Quantity.multiplyBy (Split.toFloat share)
                                        |> Formula.genericWaste material.process.waste
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
        |> updateLifeCycleStage Label.Material (Stage.updateWasteAndMasses waste mass)


computeSpinningStageWaste : Simulator -> Simulator
computeSpinningStageWaste ({ inputs, lifeCycle } as simulator) =
    let
        { mass, waste } =
            lifeCycle
                |> LifeCycle.getStageProp Label.Fabric .inputMass Quantity.zero
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
                                            -- The output mass is the input mass of the next stage
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
                                    { mass = inputMaterialMass
                                    , waste = Quantity.difference inputMaterialMass outputMaterialMass
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
        |> updateLifeCycleStage Label.Spinning (Stage.updateWasteAndMasses waste mass)


computeStagesTransport : Db -> Simulator -> Simulator
computeStagesTransport db simulator =
    simulator |> updateLifeCycle (LifeCycle.computeStagesTransport db simulator.inputs)


computeTotalTransportImpacts : Simulator -> Simulator
computeTotalTransportImpacts simulator =
    { simulator
        | transport =
            simulator.lifeCycle
                |> LifeCycle.computeTotalTransportImpacts
    }


computeTrims : Db -> Simulator -> Result String Simulator
computeTrims db ({ componentConfig, durability, inputs } as simulator) =
    Component.emptyQuery
        |> Component.setQueryItems inputs.trims
        |> Component.compute { config = componentConfig, db = db, scope = Scope.Textile }
        -- FIXME: atm we don't include eol impacts, would we ever want that for textile?
        |> Result.map (.production >> Component.extractImpacts)
        |> Result.map
            (\trimsImpacts ->
                { simulator
                    | impacts =
                        Impact.sumImpacts
                            [ simulator.impacts
                            , trimsImpacts
                                |> Impact.divideBy (Unit.floatDurabilityFromHolistic durability)
                            ]
                    , trimsImpacts = trimsImpacts
                }
            )


computeFinalImpacts : Simulator -> Simulator
computeFinalImpacts ({ durability, lifeCycle } as simulator) =
    let
        complementsImpacts =
            lifeCycle
                |> Array.filter .enabled
                |> LifeCycle.sumComplementsImpacts
                |> Impact.divideComplementsImpactsBy (Unit.floatDurabilityFromHolistic durability)
    in
    { simulator
        | complementsImpacts = complementsImpacts
        , impacts =
            Impact.sumImpacts
                [ simulator.impacts
                , lifeCycle
                    |> LifeCycle.computeFinalImpacts
                    |> Impact.divideBy (Unit.floatDurabilityFromHolistic durability)
                    |> Impact.impactsWithComplements complementsImpacts
                ]
    }


getTotalImpactsWithoutComplements : Simulator -> Impacts
getTotalImpactsWithoutComplements { durability, lifeCycle } =
    lifeCycle
        |> Array.filter .enabled
        |> Array.map Stage.getTotalImpactsWithoutComplements
        |> Array.toList
        |> Impact.sumImpacts
        |> Impact.divideBy (Unit.floatDurabilityFromHolistic durability)


getTotalImpactsWithoutDurability : Simulator -> Impacts
getTotalImpactsWithoutDurability { lifeCycle, trimsImpacts } =
    let
        complementsImpactsWithoutDurability =
            lifeCycle
                |> Array.filter .enabled
                |> LifeCycle.sumComplementsImpacts
    in
    Impact.sumImpacts
        [ lifeCycle
            |> LifeCycle.computeFinalImpacts
            |> Impact.impactsWithComplements complementsImpactsWithoutDurability
        , trimsImpacts
        ]


updateLifeCycle : (LifeCycle -> LifeCycle) -> Simulator -> Simulator
updateLifeCycle update simulator =
    { simulator | lifeCycle = update simulator.lifeCycle }


updateLifeCycleStage : Label -> (Stage -> Stage) -> Simulator -> Simulator
updateLifeCycleStage label update =
    updateLifeCycle (LifeCycle.updateStage label update)


updateLifeCycleStages : List Label -> (Stage -> Stage) -> Simulator -> Simulator
updateLifeCycleStages labels update =
    updateLifeCycle (LifeCycle.updateStages labels update)


toStagesImpacts : Definition.Trigram -> Simulator -> Impact.StagesImpacts
toStagesImpacts trigram simulator =
    let
        getImpacts label =
            simulator.lifeCycle
                |> Array.filter .enabled
                |> LifeCycle.getStage label
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
                            |> Quantity.multiplyBy (Unit.floatDurabilityFromHolistic simulator.durability)
                        )
                    )

            else
                identity
    in
    { distribution = Nothing
    , endOfLife =
        getImpacts Label.EndOfLife
            |> getImpact
            |> applyComplement simulator.complementsImpacts.outOfEuropeEOL
    , materials =
        getImpacts Label.Material
            |> getImpact
            |> applyComplement simulator.complementsImpacts.microfibers
    , packaging = Nothing
    , transform =
        [ getImpacts Label.Spinning
        , getImpacts Label.Fabric
        , getImpacts Label.Ennobling
        , getImpacts Label.Making
        ]
            |> Impact.sumImpacts
            |> getImpact
    , transports = getImpact simulator.transport.impacts
    , trims = getImpact simulator.trimsImpacts
    , usage = getImpacts Label.Use |> getImpact
    }
        |> Impact.divideStagesImpactsBy (Unit.floatDurabilityFromHolistic simulator.durability)
