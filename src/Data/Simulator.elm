module Data.Simulator exposing (..)

import Data.Db exposing (Db)
import Data.Formula as Formula
import Data.Inputs as Inputs exposing (Inputs)
import Data.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Process as Process
import Data.Step as Step exposing (Step)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Json.Encode as Encode
import Quantity


type alias Simulator =
    { inputs : Inputs
    , lifeCycle : LifeCycle

    -- FIXME: remove cch and fwe, keep just impact
    , cch : Unit.Co2e
    , fwe : Unit.Pe
    , impact : Unit.Impact
    , transport : Transport
    }


encode : Simulator -> Encode.Value
encode v =
    Encode.object
        [ ( "inputs", Inputs.encode v.inputs )
        , ( "lifeCycle", LifeCycle.encode v.lifeCycle )

        -- FIXME: remove cch and fwe, keep just impact
        , ( "cch", Unit.encodeKgCo2e v.cch )
        , ( "fwe", Unit.encodeKgPe v.fwe )
        , ( "impact", Unit.encodeImpact v.impact )
        , ( "transport", Transport.encode v.transport )
        ]


init : Db -> Inputs.Query -> Result String Simulator
init db =
    Inputs.fromQuery db
        >> Result.map
            (\inputs ->
                inputs
                    |> LifeCycle.init
                    |> (\lifeCycle ->
                            { inputs = inputs
                            , lifeCycle = lifeCycle

                            -- FIXME: remove cch and fwe, keep just impact
                            , cch = Quantity.zero
                            , fwe = Quantity.zero
                            , impact = Quantity.zero
                            , transport = Transport.default
                            }
                       )
            )


compute : Db -> Inputs.Query -> Result String Simulator
compute db query =
    let
        next fn =
            Result.map fn

        nextWithDb fn =
            Result.andThen (fn db)
    in
    init db query
        -- Ensure end product mass is first applied to the final Distribution step
        |> next initializeFinalMass
        --
        -- WASTE: compute the initial required material mass
        --
        -- Compute Making material mass waste
        |> next computeMakingStepWaste
        -- Compute Knitting/Weawing material waste
        |> next computeWeavingKnittingStepWaste
        -- Compute Material&Spinning material waste
        |> next computeMaterialStepWaste
        --
        -- CO2 SCORES
        --
        -- Compute Material & Spinning step cch score
        |> next computeMaterialAndSpinningImpacts
        -- Compute Weaving & Knitting step cch score
        |> next computeWeavingKnittingImpacts
        -- Compute Ennoblement step cch score
        |> nextWithDb computeDyeingImpacts
        -- Compute Making step cch score
        |> next computeMakingImpacts
        --
        -- TRANSPORTS
        --
        -- Compute step transport
        |> nextWithDb computeStepsTransport
        -- Compute transport summary
        |> next computeTotalTransports
        --
        -- FINAL CO2 SCORE
        --
        |> next computeFinalImpacts


initializeFinalMass : Simulator -> Simulator
initializeFinalMass ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.Distribution (Step.initMass inputs.mass)


computeMakingImpacts : Simulator -> Simulator
computeMakingImpacts ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.Making
            (\step ->
                let
                    { kwh, cch, fwe } =
                        step.outputMass
                            |> Formula.makingImpacts
                                { makingProcess = inputs.product.makingProcess
                                , countryElecProcess = Step.getCountryElectricityProcess step
                                }
                in
                { step | cch = cch, fwe = fwe, kwh = kwh }
            )


computeDyeingImpacts : Db -> Simulator -> Result String Simulator
computeDyeingImpacts { processes } simulator =
    processes
        |> Process.loadWellKnown
        |> Result.map
            (\{ dyeingHigh, dyeingLow } ->
                simulator
                    |> updateLifeCycleStep Step.Ennoblement
                        (\({ dyeingWeighting, country } as step) ->
                            let
                                { cch, fwe, heat, kwh } =
                                    step.outputMass
                                        |> Formula.dyeingImpacts ( dyeingLow, dyeingHigh )
                                            dyeingWeighting
                                            country.heatProcess
                                            (Step.getCountryElectricityProcess step)
                            in
                            { step | cch = cch, fwe = fwe, heat = heat, kwh = kwh }
                        )
            )


computeMaterialAndSpinningImpacts : Simulator -> Simulator
computeMaterialAndSpinningImpacts ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.MaterialAndSpinning
            (\step ->
                let
                    { cch, fwe } =
                        case ( inputs.material.recycledProcess, inputs.recycledRatio ) of
                            ( Just recycledProcess, Just ratio ) ->
                                step.outputMass
                                    |> Formula.materialAndSpinningImpacts
                                        ( recycledProcess, inputs.material.materialProcess )
                                        ratio

                            _ ->
                                step.outputMass
                                    |> Formula.pureMaterialAndSpinningImpacts
                                        inputs.material.materialProcess
                in
                { step | cch = cch, fwe = fwe }
            )


computeWeavingKnittingImpacts : Simulator -> Simulator
computeWeavingKnittingImpacts ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.WeavingKnitting
            (\step ->
                let
                    { kwh, cch, fwe } =
                        if inputs.product.knitted then
                            step.outputMass
                                |> Formula.knittingImpacts
                                    { elec = inputs.product.fabricProcess.elec
                                    , countryElecProcess = Step.getCountryElectricityProcess step
                                    }

                        else
                            step.outputMass
                                |> Formula.weavingImpacts
                                    { elecPppm = inputs.product.fabricProcess.elec_pppm
                                    , countryElecProcess = Step.getCountryElectricityProcess step
                                    , grammage = inputs.product.grammage
                                    , ppm = inputs.product.ppm
                                    }
                in
                { step | cch = cch, fwe = fwe, kwh = kwh }
            )


computeMakingStepWaste : Simulator -> Simulator
computeMakingStepWaste ({ inputs } as simulator) =
    let
        { mass, waste } =
            inputs.mass
                |> Formula.makingWaste
                    { processWaste = inputs.product.makingProcess.waste
                    , pcrWaste = inputs.product.pcrWaste
                    }
    in
    simulator
        |> updateLifeCycleStep Step.Making (Step.updateWaste waste mass)
        |> updateLifeCycleSteps
            [ Step.MaterialAndSpinning, Step.WeavingKnitting, Step.Ennoblement ]
            (Step.initMass mass)


computeWeavingKnittingStepWaste : Simulator -> Simulator
computeWeavingKnittingStepWaste ({ inputs, lifeCycle } as simulator) =
    let
        { mass, waste } =
            lifeCycle
                |> LifeCycle.getStepProp Step.Making .inputMass Quantity.zero
                |> Formula.genericWaste inputs.product.fabricProcess.waste
    in
    simulator
        |> updateLifeCycleStep Step.WeavingKnitting (Step.updateWaste waste mass)
        |> updateLifeCycleSteps [ Step.MaterialAndSpinning ] (Step.initMass mass)


computeMaterialStepWaste : Simulator -> Simulator
computeMaterialStepWaste ({ inputs, lifeCycle } as simulator) =
    let
        { mass, waste } =
            lifeCycle
                |> LifeCycle.getStepProp Step.WeavingKnitting .inputMass Quantity.zero
                |> (case ( inputs.material.recycledProcess, inputs.recycledRatio ) of
                        ( Just recycledProcess, Just ratio ) ->
                            Formula.materialRecycledWaste
                                { pristineWaste = inputs.material.materialProcess.waste
                                , recycledWaste = recycledProcess.waste
                                , recycledRatio = ratio
                                }

                        _ ->
                            Formula.genericWaste inputs.material.materialProcess.waste
                   )
    in
    simulator
        |> updateLifeCycleStep Step.MaterialAndSpinning (Step.updateWaste waste mass)


computeStepsTransport : Db -> Simulator -> Result String Simulator
computeStepsTransport db simulator =
    simulator.lifeCycle
        |> LifeCycle.computeStepsTransport db simulator.inputs.impact
        |> Result.map (\lifeCycle -> simulator |> updateLifeCycle (always lifeCycle))


computeTotalTransports : Simulator -> Simulator
computeTotalTransports simulator =
    { simulator | transport = simulator.lifeCycle |> LifeCycle.computeTotalTransports }


computeFinalImpacts : Simulator -> Simulator
computeFinalImpacts ({ lifeCycle } as simulator) =
    { simulator
        | cch = LifeCycle.computeFinalCo2Score lifeCycle
        , fwe = LifeCycle.computeFinalFwEScore lifeCycle
        , impact = LifeCycle.computeFinalImpactScore lifeCycle
    }


updateLifeCycle : (LifeCycle -> LifeCycle) -> Simulator -> Simulator
updateLifeCycle update simulator =
    { simulator | lifeCycle = update simulator.lifeCycle }


updateLifeCycleStep : Step.Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleStep label update =
    updateLifeCycle (LifeCycle.updateStep label update)


updateLifeCycleSteps : List Step.Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleSteps labels update =
    updateLifeCycle (LifeCycle.updateSteps labels update)
