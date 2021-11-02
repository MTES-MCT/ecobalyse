module Data.Simulator exposing (..)

import Data.Co2 as Co2 exposing (Co2e)
import Data.Db exposing (Db)
import Data.Formula as Formula
import Data.Inputs as Inputs exposing (Inputs)
import Data.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Process as Process
import Data.Step as Step exposing (Step)
import Data.Transport as Transport
import Json.Encode as Encode
import Quantity


type alias Simulator =
    { inputs : Inputs
    , lifeCycle : LifeCycle
    , co2 : Co2e
    , transport : Transport.Summary
    }


encode : Simulator -> Encode.Value
encode v =
    Encode.object
        [ ( "inputs", Inputs.encode v.inputs )
        , ( "lifeCycle", LifeCycle.encode v.lifeCycle )
        , ( "co2", Co2.encodeKgCo2e v.co2 )
        , ( "transport", Transport.encodeSummary v.transport )
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
                            , transport = Transport.defaultSummary
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
        |> next computeMaterialAndSpinningWaste
        --
        -- WASTE
        --
        -- Compute inital required material mass
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
        |> nextWithDb computeTransportSummaries
        -- Compute transport summary
        |> next computeTransportSummary
        --
        -- FINAL CO2 SCORE
        --
        |> next computeFinalCo2Score


computeMaterialAndSpinningWaste : Simulator -> Simulator
computeMaterialAndSpinningWaste ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.Distribution (\step -> { step | mass = inputs.mass })


computeMakingCo2Score : Simulator -> Simulator
computeMakingCo2Score ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.Making
            (\({ country } as step) ->
                let
                    { kwh, co2 } =
                        step.mass
                            |> Formula.makingCo2
                                { makingCC = inputs.product.makingProcess.climateChange
                                , makingElec = inputs.product.makingProcess.elec
                                , countryElecCC = country.electricityProcess.climateChange
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
                                    step.mass
                                        |> Formula.dyeingCo2 ( dyeingLow, dyeingHigh )
                                            dyeingWeighting
                                            country.heatProcess.climateChange
                                            country.electricityProcess.climateChange
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
                                step.mass
                                    |> Co2.ratioedCo2eForMass
                                        ( recycledProcess.climateChange
                                        , inputs.material.materialProcess.climateChange
                                        )
                                        ratio

                            _ ->
                                step.mass
                                    |> Co2.co2eForMass inputs.material.materialProcess.climateChange
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
                                    , elecCC = country.electricityProcess.climateChange
                                    }

                        else
                            step.mass
                                |> Formula.weavingCo2
                                    { elecPppm = inputs.product.fabricProcess.elec_pppm
                                    , elecCC = country.electricityProcess.climateChange
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
        |> updateLifeCycleStep Step.Making (\step -> { step | mass = mass, waste = waste })
        |> updateLifeCycleSteps
            [ Step.MaterialAndSpinning, Step.WeavingKnitting, Step.Ennoblement ]
            (\step -> { step | mass = mass })


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
            (\step -> { step | mass = mass, waste = waste })
        |> updateLifeCycleSteps [ Step.MaterialAndSpinning ]
            (\step -> { step | mass = mass })


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
            (\step -> { step | mass = mass, waste = waste })


computeTransportSummaries : Db -> Simulator -> Result String Simulator
computeTransportSummaries db simulator =
    simulator.lifeCycle
        |> LifeCycle.computeTransportSummaries db
        |> Result.map (\lifeCycle -> simulator |> updateLifeCycle (always lifeCycle))


computeTransportSummary : Simulator -> Simulator
computeTransportSummary simulator =
    { simulator | transport = simulator.lifeCycle |> LifeCycle.computeTransportSummary }


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
