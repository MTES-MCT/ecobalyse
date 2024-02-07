module Data.Textile.Simulator exposing
    ( Simulator
    , compute
    , encode
    , getCompute
    , stepMaterialImpacts
    , toStepsImpacts
    )

import Data.Country exposing (Country)
import Data.Env as Env
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition
import Data.Session exposing (Session)
import Data.Split as Split
import Data.Textile.Economics as Economics
import Data.Textile.Fabric as Fabric
import Data.Textile.Formula as Formula
import Data.Textile.HeatSource exposing (HeatSource)
import Data.Textile.Inputs as Inputs exposing (Inputs)
import Data.Textile.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Origin as Origin
import Data.Textile.Material.Spinning as Spinning exposing (Spinning)
import Data.Textile.Process exposing (Process)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Step as Step exposing (Step)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Textile.WellKnown as WellKnown exposing (WellKnown)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Energy exposing (Energy)
import Http
import Json.Decode as Decode
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass
import Page.Api as Api
import Quantity
import RemoteData exposing (WebData)
import Static.Db exposing (Db)


type alias Simulator =
    { inputs : Inputs
    , lifeCycle : LifeCycle
    , impacts : Impacts
    , complementsImpacts : Impact.ComplementsImpacts
    , durability : Unit.Durability
    , transport : Transport
    , useNbCycles : Int
    }


encode : Simulator -> Encode.Value
encode v =
    Encode.object
        [ ( "inputs", Inputs.encode v.inputs )
        , ( "lifeCycle", LifeCycle.encode v.lifeCycle )
        , ( "impacts", Impact.encode v.impacts )
        , ( "complementsImpacts", Impact.encodeComplementsImpacts v.complementsImpacts )
        , ( "durability", Unit.encodeDurability v.durability )
        , ( "transport", Transport.encode v.transport )
        , ( "useNbCycles", Encode.int v.useNbCycles )
        ]


decode : Db -> Decode.Decoder Simulator
decode db =
    Decode.succeed Simulator
        |> Pipe.required "inputs" (Inputs.decodeQuery |> Decode.andThen (Inputs.fromQuery db >> DE.fromResult))
        |> Pipe.required "lifeCycle" (LifeCycle.decode db)
        |> Pipe.required "impacts" Impact.decodeFullImpacts
        |> Pipe.required "complementsImpacts" Impact.decodeComplementsImpacts
        |> Pipe.required "durability" Unit.decodeDurability
        |> Pipe.required "transport" (Transport.decode db.definitions)
        |> Pipe.required "useNbCycles" Decode.int


init : Db -> Inputs.Query -> Result String Simulator
init db =
    Inputs.fromQuery db
        >> Result.map
            (\({ product } as inputs) ->
                inputs
                    |> LifeCycle.init db
                    |> (\lifeCycle ->
                            { inputs = inputs
                            , lifeCycle = lifeCycle
                            , impacts = Impact.empty
                            , complementsImpacts = Impact.noComplementsImpacts
                            , durability = Unit.standardDurability
                            , transport = Transport.default Nothing
                            , useNbCycles = Product.customDaysOfWear product.use
                            }
                       )
            )


{-| Computes simulation impacts.
-}
compute : Db -> Inputs.Query -> Result String Simulator
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
        -- CO2 SCORES
        --
        -- Compute Material step impacts
        |> nextIf Label.Material (computeMaterialImpacts db)
        -- Compute Spinning step impacts
        |> nextIf Label.Spinning computeSpinningImpacts
        -- Compute Weaving & Knitting step impacts
        |> nextWithDbIf Label.Fabric computeFabricImpacts
        -- Compute Ennobling step Dyeing impacts
        |> nextWithDbIf Label.Ennobling computeDyeingImpacts
        -- Compute Ennobling step Printing impacts
        |> nextWithDbIf Label.Ennobling computePrintingImpacts
        -- Compute Ennobling step Finishing impacts
        |> nextWithDbIf Label.Ennobling computeFinishingImpacts
        -- Compute Ennobling step bleaching impacts
        |> nextWithDbIf Label.Ennobling computeBleachingImpacts
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
        |> nextWithDb computeFinalImpacts


getCompute : Session -> Inputs.Query -> (WebData Simulator -> msg) -> Cmd msg
getCompute session query onApiReceived =
    let
        apiUrl =
            Api.getApiServerUrl session
    in
    Http.post
        { url = apiUrl ++ "/textile/simulator/detailed"
        , body = Http.jsonBody (Inputs.encodeQuery query)
        , expect = Http.expectJson (RemoteData.fromResult >> onApiReceived) (decode session.db)
        }


initializeFinalMass : Simulator -> Simulator
initializeFinalMass ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleSteps Label.all (Step.initMass inputs.mass)


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
                                , ironingProcess = inputs.product.use.ironingProcess
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


getEnnoblingHeatProcess : Country -> WellKnown -> Maybe HeatSource -> Process
getEnnoblingHeatProcess country wellKnown =
    Maybe.map (WellKnown.getEnnoblingHeatProcess wellKnown country.zone)
        >> Maybe.withDefault country.heatProcess


computeDyeingImpacts : Db -> Simulator -> Simulator
computeDyeingImpacts { textile } ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Ennobling
            (\({ country, dyeingMedium } as step) ->
                let
                    heatProcess =
                        inputs.ennoblingHeatSource
                            |> getEnnoblingHeatProcess country textile.wellKnown

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
                                        , heatProcess = getEnnoblingHeatProcess country textile.wellKnown inputs.ennoblingHeatSource
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
computeFinishingImpacts { textile } ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Ennobling
            (\({ country } as step) ->
                let
                    { heat, kwh, impacts } =
                        step.outputMass
                            |> Formula.finishingImpacts step.impacts
                                { finishingProcess = textile.wellKnown.finishing
                                , heatProcess = getEnnoblingHeatProcess country textile.wellKnown inputs.ennoblingHeatSource
                                , elecProcess = country.electricityProcess
                                }
                in
                { step
                    | heat = step.heat |> Quantity.plus heat
                    , kwh = step.kwh |> Quantity.plus kwh
                    , impacts = Impact.sumImpacts [ step.impacts, impacts ]
                }
            )


computeBleachingImpacts : Db -> Simulator -> Simulator
computeBleachingImpacts { textile } simulator =
    simulator
        |> updateLifeCycleStep Label.Ennobling
            (\step ->
                let
                    impacts =
                        step.outputMass
                            |> Formula.bleachingImpacts step.impacts
                                { bleachingProcess = textile.wellKnown.bleaching
                                , aquaticPollutionScenario = step.country.aquaticPollutionScenario
                                }
                in
                { step
                    | impacts = Impact.sumImpacts [ step.impacts, impacts ]
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
                |> Formula.genericWaste (Fabric.getProcess textile.wellKnown inputs.product.fabric |> .waste)
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
                                            Split.divideBy (Mass.inKilograms outputMaterialMass) (Split.complement processWaste)
                                                |> Mass.kilograms
                                    in
                                    { waste = Quantity.difference inputMaterialMass outputMaterialMass, mass = inputMaterialMass }
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


computeFinalImpacts : Db -> Simulator -> Simulator
computeFinalImpacts { definitions } ({ inputs, lifeCycle } as simulator) =
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

        complementsImpacts =
            lifeCycle
                |> LifeCycle.sumComplementsImpacts
                |> Impact.divideComplementsImpactsBy (Unit.durabilityToFloat durability)
    in
    { simulator
        | complementsImpacts = complementsImpacts
        , durability = durability
        , impacts =
            lifeCycle
                |> LifeCycle.computeFinalImpacts
                |> Impact.updateAggregatedScores definitions
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
    , transports = getImpact (simulator.transport.impacts |> Maybe.withDefault Impact.empty)
    , distribution = Nothing
    , usage = getImpacts Label.Use |> getImpact
    , endOfLife =
        getImpacts Label.EndOfLife
            |> getImpact
            |> applyComplement simulator.complementsImpacts.outOfEuropeEOL
    }
