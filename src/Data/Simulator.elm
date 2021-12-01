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
    , co2 : Unit.Co2e
    , fwe : Unit.Pe
    , transport : Transport
    }


encode : Simulator -> Encode.Value
encode v =
    Encode.object
        [ ( "inputs", Inputs.encode v.inputs )
        , ( "lifeCycle", LifeCycle.encode v.lifeCycle )
        , ( "co2", Unit.encodeKgCo2e v.co2 )
        , ( "fwe", Unit.encodeKgPe v.fwe )
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
                            , co2 = Quantity.zero
                            , fwe = Quantity.zero
                            , transport = Transport.default
                            }
                       )
            )


compute : Db -> Inputs.Query -> Result String Simulator
compute db query =
    let
        next =
            Result.map

        nextWithDb =
            \fn -> Result.andThen (fn db)
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
        -- Compute Material & Spinning step co2 score
        |> next computeMaterialAndSpinningImpacts
        -- Compute Weaving & Knitting step co2 score
        |> next computeWeavingKnittingImpacts
        -- Compute Ennoblement step co2 score
        |> nextWithDb computeDyeingImpacts
        -- Compute Making step co2 score
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
                    { kwh, co2 } =
                        step.outputMass
                            |> Formula.makingImpacts
                                { makingProcess = inputs.product.makingProcess
                                , countryElecProcess = Step.getCountryElectricityProcess step
                                }
                in
                { step | kwh = kwh, co2 = co2 }
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
                                { co2, fwe, heat, kwh } =
                                    step.outputMass
                                        |> Formula.dyeingImpacts ( dyeingLow, dyeingHigh )
                                            dyeingWeighting
                                            country.heatProcess
                                            (Step.getCountryElectricityProcess step)
                            in
                            { step | co2 = co2, fwe = fwe, heat = heat, kwh = kwh }
                        )
            )


computeMaterialAndSpinningImpacts : Simulator -> Simulator
computeMaterialAndSpinningImpacts ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.MaterialAndSpinning
            (\step ->
                { step
                    | co2 =
                        case ( inputs.material.recycledProcess, inputs.recycledRatio ) of
                            ( Just recycledProcess, Just ratio ) ->
                                step.outputMass
                                    |> Unit.ratioedForKg
                                        ( recycledProcess.climateChange
                                        , inputs.material.materialProcess.climateChange
                                        )
                                        ratio

                            _ ->
                                step.outputMass
                                    |> Unit.forKg inputs.material.materialProcess.climateChange
                }
            )


computeWeavingKnittingImpacts : Simulator -> Simulator
computeWeavingKnittingImpacts ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.WeavingKnitting
            (\({ country } as step) ->
                let
                    { kwh, co2 } =
                        if inputs.product.knitted then
                            step.outputMass
                                |> Formula.knittingCo2
                                    { elec = inputs.product.fabricProcess.elec
                                    , elecCC =
                                        step.customCountryMix
                                            |> Maybe.withDefault country.electricityProcess.climateChange
                                    }

                        else
                            step.outputMass
                                |> Formula.weavingCo2
                                    { elecPppm = inputs.product.fabricProcess.elec_pppm
                                    , elecCC =
                                        step.customCountryMix
                                            |> Maybe.withDefault country.electricityProcess.climateChange
                                    , grammage = inputs.product.grammage
                                    , ppm = inputs.product.ppm
                                    }
                in
                { step | co2 = co2, kwh = kwh }
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
        |> LifeCycle.computeStepsTransport db
        |> Result.map (\lifeCycle -> simulator |> updateLifeCycle (always lifeCycle))


computeTotalTransports : Simulator -> Simulator
computeTotalTransports simulator =
    { simulator | transport = simulator.lifeCycle |> LifeCycle.computeTotalTransports }


computeFinalImpacts : Simulator -> Simulator
computeFinalImpacts ({ lifeCycle } as simulator) =
    { simulator
        | co2 = LifeCycle.computeFinalCo2Score lifeCycle
        , fwe = LifeCycle.computeFinalFwEScore lifeCycle
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
