module Data.Textile.Simulator exposing
    ( Simulator
    , compute
    , encode
    , lifeCycleImpacts
    )

import Array
import Data.Country exposing (Country)
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Split as Split
import Data.Textile.Db as TextileDb
import Data.Textile.Formula as Formula
import Data.Textile.HeatSource exposing (HeatSource)
import Data.Textile.Inputs as Inputs exposing (Inputs)
import Data.Textile.Knitting as Knitting
import Data.Textile.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as Process exposing (Process)
import Data.Textile.Product as Product
import Data.Textile.Step as Step exposing (Step)
import Data.Textile.Step.Label as Label exposing (Label)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Duration exposing (Duration)
import Energy exposing (Energy)
import Json.Encode as Encode
import Mass
import Quantity


type alias Simulator =
    { inputs : Inputs
    , lifeCycle : LifeCycle
    , impacts : Impacts
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
        , ( "transport", Transport.encode v.transport )
        , ( "daysOfWear", v.daysOfWear |> Duration.inDays |> Encode.float )
        , ( "useNbCycles", Encode.int v.useNbCycles )
        ]


init : TextileDb.Db -> Inputs.Query -> Result String Simulator
init db =
    let
        defaultImpacts =
            Impact.empty
    in
    Inputs.fromQuery db
        >> Result.map
            (\({ product, quality, reparability } as inputs) ->
                inputs
                    |> LifeCycle.init db
                    |> (\lifeCycle ->
                            let
                                { daysOfWear, useNbCycles } =
                                    product.use
                                        |> Product.customDaysOfWear quality reparability
                            in
                            { inputs = inputs
                            , lifeCycle = lifeCycle
                            , impacts = defaultImpacts
                            , transport = Transport.default defaultImpacts
                            , daysOfWear = daysOfWear
                            , useNbCycles = useNbCycles
                            }
                       )
            )


{-| Computes a single impact.
-}
compute : TextileDb.Db -> Inputs.Query -> Result String Simulator
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
        -- Compute Knitting/Weawing waste - Tissage/Tricotage
        |> nextWithDbIf Label.Fabric computeFabricStepWaste
        -- Compute Spinning waste - Filature
        |> nextIf Label.Spinning computeSpinningStepWaste
        -- Compute Material waste - Matière
        |> nextIf Label.Material computeMaterialStepWaste
        --
        -- CO2 SCORES
        --
        -- Compute Material step impacts
        |> nextIf Label.Material (computeMaterialImpacts db)
        -- Compute Spinning step impacts
        |> nextIf Label.Spinning (computeSpinningImpacts db)
        -- Compute Weaving & Knitting step impacts
        |> nextWithDbIf Label.Fabric computeFabricImpacts
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


computeEndOfLifeImpacts : TextileDb.Db -> Simulator -> Simulator
computeEndOfLifeImpacts { textileWellKnown } simulator =
    simulator
        |> updateLifeCycleStep Label.EndOfLife
            (\({ country } as step) ->
                let
                    { kwh, heat, impacts } =
                        step.outputMass
                            |> Formula.endOfLifeImpacts step.impacts
                                { volume = simulator.inputs.product.endOfLife.volume
                                , passengerCar = textileWellKnown.passengerCar
                                , endOfLife = textileWellKnown.endOfLife
                                , countryElecProcess = country.electricityProcess
                                , heatProcess = country.heatProcess
                                }
                in
                { step | impacts = impacts, kwh = kwh, heat = heat }
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


computeMakingImpacts : TextileDb.Db -> Simulator -> Simulator
computeMakingImpacts { textileWellKnown } ({ inputs } as simulator) =
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
                                    if inputs.product.making.fadable && inputs.disabledFading /= Just True then
                                        Just textileWellKnown.fading

                                    else
                                        Nothing
                                , countryElecProcess = country.electricityProcess
                                , countryHeatProcess = country.heatProcess
                                }
                in
                { step | impacts = impacts, kwh = kwh, heat = heat }
            )


getEnnoblingHeatProcess : Country -> Process.WellKnown -> Maybe HeatSource -> Process
getEnnoblingHeatProcess country wellKnown =
    Maybe.map (Process.getEnnoblingHeatProcess wellKnown country.zone)
        >> Maybe.withDefault country.heatProcess


computeDyeingImpacts : TextileDb.Db -> Simulator -> Simulator
computeDyeingImpacts db ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Ennobling
            (\({ country, dyeingMedium } as step) ->
                let
                    heatProcess =
                        inputs.ennoblingHeatSource
                            |> getEnnoblingHeatProcess country db.textileWellKnown

                    productDefaultMedium =
                        dyeingMedium
                            |> Maybe.withDefault inputs.product.dyeing.defaultMedium

                    dyeingProcess =
                        db.textileWellKnown
                            |> Process.getDyeingProcess productDefaultMedium

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
                    , impacts = Impact.sumImpacts [ step.impacts, impacts ]
                }
            )


computePrintingImpacts : TextileDb.Db -> Simulator -> Simulator
computePrintingImpacts db ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Ennobling
            (\({ country } as step) ->
                case step.printing of
                    Just { kind, ratio } ->
                        let
                            { heat, kwh, impacts } =
                                step.outputMass
                                    |> Formula.printingImpacts step.impacts
                                        { printingProcess = Process.getPrintingProcess kind db.textileWellKnown
                                        , heatProcess = getEnnoblingHeatProcess country db.textileWellKnown inputs.ennoblingHeatSource
                                        , elecProcess = country.electricityProcess
                                        , surfaceMass = Maybe.withDefault inputs.product.surfaceMass inputs.surfaceMass
                                        , ratio = ratio
                                        }
                        in
                        { step
                            | heat = step.heat |> Quantity.plus heat
                            , kwh = step.kwh |> Quantity.plus kwh
                            , impacts = Impact.sumImpacts [ step.impacts, impacts ]
                        }

                    Nothing ->
                        step
            )


computeFinishingImpacts : TextileDb.Db -> Simulator -> Simulator
computeFinishingImpacts db ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Ennobling
            (\({ country } as step) ->
                let
                    { heat, kwh, impacts } =
                        step.outputMass
                            |> Formula.finishingImpacts step.impacts
                                { finishingProcess = db.textileWellKnown.finishing
                                , heatProcess = getEnnoblingHeatProcess country db.textileWellKnown inputs.ennoblingHeatSource
                                , elecProcess = country.electricityProcess
                                }
                in
                { step
                    | heat = step.heat |> Quantity.plus heat
                    , kwh = step.kwh |> Quantity.plus kwh
                    , impacts = Impact.sumImpacts [ step.impacts, impacts ]
                }
            )


stepMaterialImpacts : TextileDb.Db -> Material -> Step -> Impacts
stepMaterialImpacts db material step =
    case Material.getRecyclingData material db.textileMaterials of
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


computeMaterialImpacts : TextileDb.Db -> Simulator -> Simulator
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


stepSpinningImpacts : TextileDb.Db -> Material -> Step -> { impacts : Impacts, kwh : Energy }
stepSpinningImpacts _ material step =
    case material.spinningProcess of
        Nothing ->
            -- Some materials, eg. Neoprene, don't use Spinning *at all*, so this step has basically no impacts.
            { impacts = step.impacts, kwh = Quantity.zero }

        Just spinningProcess ->
            step.outputMass
                |> Formula.spinningImpacts step.impacts
                    { spinningProcess = spinningProcess
                    , countryElecProcess = step.country.electricityProcess
                    }


computeSpinningImpacts : TextileDb.Db -> Simulator -> Simulator
computeSpinningImpacts db ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Spinning
            (\step ->
                { step
                    | kwh =
                        inputs.materials
                            |> List.map
                                (\{ material, share } ->
                                    step
                                        |> stepSpinningImpacts db material
                                        |> .kwh
                                        |> Quantity.multiplyBy (Split.toFloat share)
                                )
                            |> List.foldl Quantity.plus Quantity.zero
                    , impacts =
                        inputs.materials
                            |> List.map
                                (\{ material, share } ->
                                    step
                                        |> stepSpinningImpacts db material
                                        |> .impacts
                                        |> Impact.mapImpacts (\_ -> Quantity.multiplyBy (Split.toFloat share))
                                )
                            |> Impact.sumImpacts
                }
            )


computeFabricImpacts : TextileDb.Db -> Simulator -> Simulator
computeFabricImpacts db ({ inputs, lifeCycle } as simulator) =
    let
        fabricOutputMass =
            lifeCycle
                |> LifeCycle.getStepProp Label.Fabric .outputMass Quantity.zero
    in
    simulator
        |> updateLifeCycleStep Label.Fabric
            (\({ country, knittingProcess } as step) ->
                let
                    productDefaultKnittingProcess =
                        knittingProcess
                            |> Maybe.withDefault Knitting.Mix

                    knitting =
                        db.textileWellKnown
                            |> Process.getKnittingProcess productDefaultKnittingProcess

                    { kwh, threadDensity, picking, impacts } =
                        case inputs.product.fabric of
                            Product.Knitted _ ->
                                Formula.knittingImpacts step.impacts
                                    { elec = knitting.elec
                                    , countryElecProcess = country.electricityProcess
                                    }
                                    step.outputMass

                            Product.Weaved process ->
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
                                    , yarnSize =
                                        inputs.yarnSize
                                            |> Maybe.withDefault
                                                (inputs.product.yarnSize
                                                    |> Maybe.withDefault Unit.minYarnSize
                                                )
                                    }
                in
                { step | impacts = impacts, threadDensity = threadDensity, picking = picking, kwh = kwh }
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


computeFabricStepWaste : TextileDb.Db -> Simulator -> Simulator
computeFabricStepWaste { textileWellKnown } ({ inputs, lifeCycle } as simulator) =
    let
        { mass, waste } =
            lifeCycle
                |> LifeCycle.getStepProp Label.Making .inputMass Quantity.zero
                |> Formula.genericWaste (Product.getFabricProcess inputs.knittingProcess inputs.product textileWellKnown |> .waste)
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
                                    Formula.genericWaste material.materialProcess.waste
                                        (inputMass |> Quantity.multiplyBy (Split.toFloat share))
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
                                (\{ material, share } ->
                                    let
                                        processWaste =
                                            material.spinningProcess
                                                |> Maybe.map .waste
                                                |> Maybe.withDefault (Mass.kilograms 0)
                                    in
                                    Formula.genericWaste processWaste
                                        (inputMass |> Quantity.multiplyBy (Split.toFloat share))
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


computeStepsTransport : TextileDb.Db -> Simulator -> Simulator
computeStepsTransport db simulator =
    simulator.lifeCycle
        |> LifeCycle.computeStepsTransport db
        |> (\lifeCycle -> { simulator | lifeCycle = lifeCycle })


computeTotalTransportImpacts : Simulator -> Simulator
computeTotalTransportImpacts simulator =
    { simulator | transport = simulator.lifeCycle |> LifeCycle.computeTotalTransportImpacts }


computeFinalImpacts : Simulator -> Simulator
computeFinalImpacts ({ lifeCycle } as simulator) =
    { simulator | impacts = LifeCycle.computeFinalImpacts lifeCycle }


lifeCycleImpacts : Definitions -> Simulator -> List ( String, List ( String, Float ) )
lifeCycleImpacts definitions simulator =
    -- cch:
    --     matiere: 25%
    --     tissage: 10%
    --     transports: 10%
    --     etc.
    -- wtu:
    --     ...
    Definition.toList definitions
        |> List.map
            (\def ->
                ( def.label
                , simulator.lifeCycle
                    |> Array.toList
                    |> List.map
                        (\{ label, impacts } ->
                            ( Label.toString label
                            , Unit.impactToFloat (Impact.getImpact def.trigram impacts)
                                / Unit.impactToFloat (Impact.getImpact def.trigram simulator.impacts)
                                * 100
                            )
                        )
                    |> (::)
                        ( "Transports"
                        , Unit.impactToFloat (Impact.getImpact def.trigram simulator.transport.impacts)
                            / Unit.impactToFloat (Impact.getImpact def.trigram simulator.impacts)
                            * 100
                        )
                )
            )


updateLifeCycle : (LifeCycle -> LifeCycle) -> Simulator -> Simulator
updateLifeCycle update simulator =
    { simulator | lifeCycle = update simulator.lifeCycle }


updateLifeCycleStep : Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleStep label update =
    updateLifeCycle (LifeCycle.updateStep label update)


updateLifeCycleSteps : List Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleSteps labels update =
    updateLifeCycle (LifeCycle.updateSteps labels update)
