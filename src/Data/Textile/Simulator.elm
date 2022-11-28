module Data.Textile.Simulator exposing
    ( Simulator
    , compute
    , encode
    , lifeCycleImpacts
    )

import Array
import Data.Impact as Impact exposing (Impacts)
import Data.Textile.Db exposing (Db)
import Data.Textile.Formula as Formula
import Data.Textile.Inputs as Inputs exposing (Inputs)
import Data.Textile.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Process as Process
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
        , ( "impacts", Impact.encodeImpacts v.impacts )
        , ( "transport", Transport.encode v.transport )
        , ( "daysOfWear", v.daysOfWear |> Duration.inDays |> Encode.float )
        , ( "useNbCycles", Encode.int v.useNbCycles )
        ]


init : Db -> Inputs.Query -> Result String Simulator
init db =
    let
        defaultImpacts =
            Impact.impactsFromDefinitons db.impacts
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
compute : Db -> Inputs.Query -> Result String Simulator
compute db query =
    let
        next fn =
            Result.map fn

        nextWithDb fn =
            Result.andThen (fn db)

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
        |> nextIf Label.Fabric computeFabricStepWaste
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
        |> nextIf Label.Fabric computeFabricImpacts
        -- Compute Ennobling step Dyeing impacts
        |> nextWithDbIf Label.Ennobling computeDyeingImpacts
        -- Compute Ennobling step Printing impacts
        |> nextWithDbIf Label.Ennobling computePrintingImpacts
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
        |> next (computeTotalTransportImpacts db)
        --
        -- PEF scores
        --
        -- Compute PEF impact scores
        |> next (computePefScores db)
        --
        -- Final impacts
        --
        |> next (computeFinalImpacts db)


initializeFinalMass : Simulator -> Simulator
initializeFinalMass ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleSteps Label.all (Step.initMass inputs.mass)


computeEndOfLifeImpacts : Db -> Simulator -> Result String Simulator
computeEndOfLifeImpacts { processes } simulator =
    processes
        |> Process.loadWellKnown
        |> Result.map
            (\{ passengerCar, endOfLife } ->
                simulator
                    |> updateLifeCycleStep Label.EndOfLife
                        (\({ country } as step) ->
                            let
                                { kwh, heat, impacts } =
                                    step.outputMass
                                        |> Formula.endOfLifeImpacts step.impacts
                                            { volume = simulator.inputs.product.endOfLife.volume
                                            , passengerCar = passengerCar
                                            , endOfLife = endOfLife
                                            , countryElecProcess = country.electricityProcess
                                            , heatProcess = country.heatProcess
                                            }
                            in
                            { step | impacts = impacts, kwh = kwh, heat = heat }
                        )
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


computeMakingImpacts : Db -> Simulator -> Result String Simulator
computeMakingImpacts { processes } ({ inputs } as simulator) =
    processes
        |> Process.loadWellKnown
        |> Result.map
            (\{ fading } ->
                simulator
                    |> updateLifeCycleStep Label.Making
                        (\({ country } as step) ->
                            let
                                { kwh, heat, impacts } =
                                    step.outputMass
                                        |> Formula.makingImpacts step.impacts
                                            { makingProcess = inputs.product.making.process
                                            , fadingProcess =
                                                -- Note: in the future, we may have distinct fading processes per countries
                                                if inputs.product.making.fadable && inputs.disabledFading /= Just True then
                                                    Just fading

                                                else
                                                    Nothing
                                            , countryElecProcess = country.electricityProcess
                                            , countryHeatProcess = country.heatProcess
                                            }
                            in
                            { step | impacts = impacts, kwh = kwh, heat = heat }
                        )
            )


computeDyeingImpacts : Db -> Simulator -> Result String Simulator
computeDyeingImpacts db ({ inputs } as simulator) =
    db.processes
        |> Process.loadWellKnown
        |> Result.map
            (\wellKnown ->
                simulator
                    |> updateLifeCycleStep Label.Ennobling
                        (\({ country, dyeingMedium } as step) ->
                            let
                                productDefaultMedium =
                                    dyeingMedium
                                        |> Maybe.withDefault inputs.product.dyeing.defaultMedium

                                dyeingProcess =
                                    Process.getDyeingProcess productDefaultMedium wellKnown

                                { heat, kwh, impacts } =
                                    step.outputMass
                                        |> Formula.dyeingImpacts step.impacts
                                            dyeingProcess
                                            country.heatProcess
                                            country.electricityProcess
                            in
                            { step
                                | heat = step.heat |> Quantity.plus heat
                                , kwh = step.kwh |> Quantity.plus kwh
                                , impacts = Impact.sumImpacts db.impacts [ step.impacts, impacts ]
                            }
                        )
            )


computePrintingImpacts : Db -> Simulator -> Result String Simulator
computePrintingImpacts db ({ inputs } as simulator) =
    db.processes
        |> Process.loadWellKnown
        |> Result.map
            (\wellKnown ->
                simulator
                    |> updateLifeCycleStep Label.Ennobling
                        (\({ country } as step) ->
                            case step.printing of
                                Just { kind, ratio } ->
                                    let
                                        { heat, kwh, impacts } =
                                            step.outputMass
                                                |> Formula.printingImpacts step.impacts
                                                    { printingProcess = Process.getPrintingProcess kind wellKnown
                                                    , heatProcess = country.heatProcess
                                                    , elecProcess = country.electricityProcess
                                                    , surfaceMass = Maybe.withDefault inputs.product.surfaceMass inputs.surfaceMass
                                                    , ratio = ratio
                                                    }
                                    in
                                    { step
                                        | heat = step.heat |> Quantity.plus heat
                                        , kwh = step.kwh |> Quantity.plus kwh
                                        , impacts = Impact.sumImpacts db.impacts [ step.impacts, impacts ]
                                    }

                                Nothing ->
                                    step
                        )
            )


stepMaterialImpacts : Db -> Material -> Step -> Impacts
stepMaterialImpacts db material step =
    case Material.getRecyclingData material db.materials of
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
                                        |> Impact.mapImpacts (\_ -> Quantity.multiplyBy (Unit.ratioToFloat share))
                                )
                            |> Impact.sumImpacts db.impacts
                }
            )


stepSpinningImpacts : Db -> Material -> Step -> { impacts : Impacts, kwh : Energy }
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


computeSpinningImpacts : Db -> Simulator -> Simulator
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
                                        |> Quantity.multiplyBy (Unit.ratioToFloat share)
                                )
                            |> List.foldl Quantity.plus Quantity.zero
                    , impacts =
                        inputs.materials
                            |> List.map
                                (\{ material, share } ->
                                    step
                                        |> stepSpinningImpacts db material
                                        |> .impacts
                                        |> Impact.mapImpacts (\_ -> Quantity.multiplyBy (Unit.ratioToFloat share))
                                )
                            |> Impact.sumImpacts db.impacts
                }
            )


computeFabricImpacts : Simulator -> Simulator
computeFabricImpacts ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Label.Fabric
            (\({ country } as step) ->
                let
                    { kwh, impacts } =
                        step.outputMass
                            |> (case inputs.product.fabric of
                                    Product.Knitted process ->
                                        Formula.knittingImpacts step.impacts
                                            { elec = process.elec
                                            , countryElecProcess = country.electricityProcess
                                            }

                                    Product.Weaved process defaultPicking ->
                                        Formula.weavingImpacts step.impacts
                                            { pickingElec = process.elec_pppm
                                            , countryElecProcess = country.electricityProcess
                                            , surfaceMass = Maybe.withDefault inputs.product.surfaceMass inputs.surfaceMass
                                            , picking = Maybe.withDefault defaultPicking inputs.picking
                                            }
                               )
                in
                { step | impacts = impacts, kwh = kwh }
            )


computeMakingStepWaste : Simulator -> Simulator
computeMakingStepWaste ({ inputs } as simulator) =
    let
        { mass, waste } =
            inputs.mass
                |> Formula.makingWaste
                    { processWaste = inputs.product.making.process.waste
                    , pcrWaste = Maybe.withDefault inputs.product.making.pcrWaste inputs.makingWaste
                    }
    in
    simulator
        |> updateLifeCycleStep Label.Making (Step.updateWaste waste mass)
        |> updateLifeCycleSteps
            [ Label.Material, Label.Spinning, Label.Fabric, Label.Ennobling ]
            (Step.initMass mass)


computeFabricStepWaste : Simulator -> Simulator
computeFabricStepWaste ({ inputs, lifeCycle } as simulator) =
    let
        { mass, waste } =
            lifeCycle
                |> LifeCycle.getStepProp Label.Making .inputMass Quantity.zero
                |> Formula.genericWaste (Product.getFabricProcess inputs.product |> .waste)
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
                                        (inputMass |> Quantity.multiplyBy (Unit.ratioToFloat share))
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
                                        (inputMass |> Quantity.multiplyBy (Unit.ratioToFloat share))
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


computeStepsTransport : Db -> Simulator -> Result String Simulator
computeStepsTransport db simulator =
    simulator.lifeCycle
        |> LifeCycle.computeStepsTransport db
        |> Result.map (\lifeCycle -> { simulator | lifeCycle = lifeCycle })


computeTotalTransportImpacts : Db -> Simulator -> Simulator
computeTotalTransportImpacts db simulator =
    { simulator | transport = simulator.lifeCycle |> LifeCycle.computeTotalTransportImpacts db }


computeFinalImpacts : Db -> Simulator -> Simulator
computeFinalImpacts db ({ lifeCycle } as simulator) =
    { simulator | impacts = LifeCycle.computeFinalImpacts db lifeCycle }


computePefScores : Db -> Simulator -> Simulator
computePefScores db =
    updateLifeCycle
        (LifeCycle.mapSteps
            (\({ impacts } as step) ->
                { step | impacts = Impact.updatePefImpact db.impacts impacts }
            )
        )


lifeCycleImpacts : Db -> Simulator -> List ( String, List ( String, Float ) )
lifeCycleImpacts db simulator =
    -- cch:
    --     matiere: 25%
    --     tissage: 10%
    --     transports: 10%
    --     etc.
    -- wtu:
    --     ...
    db.impacts
        |> List.filter .primary
        |> List.filter (.scopes >> List.member Impact.Textile)
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
