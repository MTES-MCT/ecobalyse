module Data.Simulator exposing (..)

import Data.Co2 as Co2 exposing (Co2e)
import Data.Db exposing (Db)
import Data.Formula as Formula
import Data.Inputs as Inputs exposing (Inputs)
import Data.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Process as Process
import Data.Step as Step exposing (Step)
import Data.Transport as Transport exposing (Transport)
import Json.Encode as Encode
import Quantity


type alias Simulator =
    { inputs : Inputs
    , lifeCycle : LifeCycle
    , co2 : Co2e
    , transport : Transport
    }


encode : Simulator -> Encode.Value
encode v =
    Encode.object
        [ ( "inputs", Inputs.encode v.inputs )
        , ( "lifeCycle", LifeCycle.encode v.lifeCycle )
        , ( "co2", Co2.encodeKgCo2e v.co2 )
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
        |> next computeMaterialAndSpinningCo2Score
        -- Compute Weaving & Knitting step co2 score
        |> next computeWeavingKnittingCo2Score
        -- Compute Ennoblement step co2 score
        |> nextWithDb computeDyeingCo2Score
        -- Compute Making step co2 score
        |> next computeMakingCo2Score
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
        |> next computeFinalCo2Score


initializeFinalMass : Simulator -> Simulator
initializeFinalMass ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.Distribution (\step -> { step | inputMass = inputs.mass })


computeMakingCo2Score : Simulator -> Simulator
computeMakingCo2Score ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.Making
            (\({ country } as step) ->
                let
                    { kwh, co2 } =
                        step.inputMass
                            |> Formula.makingCo2
                                { makingCC = inputs.product.makingProcess.climateChange
                                , makingElec = inputs.product.makingProcess.elec
                                , countryElecCC =
                                    step.customCountryMix
                                        |> Maybe.withDefault country.electricityProcess.climateChange
                                }
                in
                { step | kwh = kwh, co2 = co2 }
            )


computeDyeingCo2Score : Db -> Simulator -> Result String Simulator
computeDyeingCo2Score { processes } simulator =
    processes
        |> Process.loadWellKnown
        |> Result.map
            (\{ dyeingHigh, dyeingLow } ->
                simulator
                    |> updateLifeCycleStep Step.Ennoblement
                        (\({ dyeingWeighting, country } as step) ->
                            let
                                { co2, heat, kwh } =
                                    step.inputMass
                                        |> Formula.dyeingCo2 ( dyeingLow, dyeingHigh )
                                            dyeingWeighting
                                            country.heatProcess.climateChange
                                            (step.customCountryMix
                                                |> Maybe.withDefault country.electricityProcess.climateChange
                                            )
                            in
                            { step | co2 = co2, heat = heat, kwh = kwh }
                        )
            )


computeMaterialAndSpinningCo2Score : Simulator -> Simulator
computeMaterialAndSpinningCo2Score ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.MaterialAndSpinning
            (\step ->
                { step
                    | co2 =
                        case ( inputs.material.recycledProcess, inputs.recycledRatio ) of
                            ( Just recycledProcess, Just ratio ) ->
                                step.inputMass
                                    |> Co2.ratioedForKg
                                        ( recycledProcess.climateChange
                                        , inputs.material.materialProcess.climateChange
                                        )
                                        ratio

                            _ ->
                                step.inputMass
                                    |> Co2.forKg inputs.material.materialProcess.climateChange
                }
            )


computeWeavingKnittingCo2Score : Simulator -> Simulator
computeWeavingKnittingCo2Score ({ inputs, lifeCycle } as simulator) =
    simulator
        |> updateLifeCycleStep Step.WeavingKnitting
            (\({ country } as step) ->
                let
                    { kwh, co2 } =
                        -- NOTE: knitted elec is computed against previous step mass,
                        -- weaved elec is computed against current step mass
                        if inputs.product.knitted then
                            lifeCycle
                                |> LifeCycle.getStepMass Step.Ennoblement
                                |> Formula.knittingCo2
                                    { elec = inputs.product.fabricProcess.elec
                                    , elecCC =
                                        step.customCountryMix
                                            |> Maybe.withDefault country.electricityProcess.climateChange
                                    }

                        else
                            step.inputMass
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
        |> updateLifeCycleStep Step.Making (\step -> { step | inputMass = mass, waste = waste })
        |> updateLifeCycleSteps
            [ Step.MaterialAndSpinning, Step.WeavingKnitting, Step.Ennoblement ]
            (\step -> { step | inputMass = mass })


computeWeavingKnittingStepWaste : Simulator -> Simulator
computeWeavingKnittingStepWaste ({ inputs, lifeCycle } as simulator) =
    let
        { mass, waste } =
            lifeCycle
                |> LifeCycle.getStepMass Step.Making
                |> Formula.genericWaste inputs.product.fabricProcess.waste
    in
    simulator
        |> updateLifeCycleStep Step.WeavingKnitting
            (\step -> { step | inputMass = mass, waste = waste })
        |> updateLifeCycleSteps [ Step.MaterialAndSpinning ]
            (\step -> { step | inputMass = mass })


computeMaterialStepWaste : Simulator -> Simulator
computeMaterialStepWaste ({ inputs, lifeCycle } as simulator) =
    let
        { mass, waste } =
            lifeCycle
                |> LifeCycle.getStepMass Step.WeavingKnitting
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
        |> updateLifeCycleStep Step.MaterialAndSpinning
            (\step -> { step | inputMass = mass, waste = waste })


computeStepsTransport : Db -> Simulator -> Result String Simulator
computeStepsTransport db simulator =
    simulator.lifeCycle
        |> LifeCycle.computeStepsTransport db
        |> Result.map (\lifeCycle -> simulator |> updateLifeCycle (always lifeCycle))


computeTotalTransports : Simulator -> Simulator
computeTotalTransports simulator =
    { simulator | transport = simulator.lifeCycle |> LifeCycle.computeTotalTransports }


computeFinalCo2Score : Simulator -> Simulator
computeFinalCo2Score simulator =
    { simulator | co2 = LifeCycle.computeFinalCo2Score simulator.lifeCycle }


updateLifeCycle : (LifeCycle -> LifeCycle) -> Simulator -> Simulator
updateLifeCycle update simulator =
    { simulator | lifeCycle = update simulator.lifeCycle }


updateLifeCycleStep : Step.Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleStep label update =
    updateLifeCycle (LifeCycle.updateStep label update)


updateLifeCycleSteps : List Step.Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleSteps labels update =
    updateLifeCycle (LifeCycle.updateSteps labels update)
