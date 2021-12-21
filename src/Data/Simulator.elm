module Data.Simulator exposing (..)

import Data.Db exposing (Db)
import Data.Formula as Formula
import Data.Impact as Impact exposing (Impacts)
import Data.Inputs as Inputs exposing (Inputs)
import Data.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Process as Process
import Data.Step as Step exposing (Step)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Json.Encode as Encode
import Quantity
import Result.Extra as RE


type alias Simulator =
    { inputs : Inputs
    , lifeCycle : LifeCycle
    , impact : Unit.Impact
    , transport : Transport
    }


encode : Simulator -> Encode.Value
encode v =
    Encode.object
        [ ( "inputs", Inputs.encode v.inputs )
        , ( "lifeCycle", LifeCycle.encode v.lifeCycle )
        , ( "impact", Unit.encodeImpact v.impact )
        , ( "transport", Transport.encode v.transport )
        ]


init : Db -> Inputs.Query -> Result String Simulator
init db =
    Inputs.fromQuery db
        >> Result.map
            (\inputs ->
                inputs
                    |> LifeCycle.init db
                    |> (\lifeCycle ->
                            { inputs = inputs
                            , lifeCycle = lifeCycle
                            , impact = Quantity.zero
                            , transport = Transport.default
                            }
                       )
            )


{-| Computes all impacts. Takes a Query and runs a simulation for each known impact.
-}
computeAll : Db -> Inputs.Query -> Result String Impacts
computeAll ({ impacts } as db) query =
    impacts
        |> List.map (\{ trigram } -> compute db { query | impact = trigram })
        |> RE.combine
        |> Result.map
            (List.map (\{ impact, inputs } -> ( inputs.impact.trigram, impact ))
                >> Impact.impactsFromList
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
        -- Compute Material & Spinning step impact
        |> next computeMaterialAndSpinningImpact
        -- Compute Weaving & Knitting step impact
        |> next computeWeavingKnittingImpact
        -- Compute Ennoblement step impact
        |> nextWithDb computeDyeingImpact
        -- Compute Making step impact
        |> next computeMakingImpact
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


computeMakingImpact : Simulator -> Simulator
computeMakingImpact ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.Making
            (\step ->
                let
                    { kwh, impact } =
                        step.outputMass
                            |> Formula.makingImpact
                                inputs.impact.trigram
                                { makingProcess = inputs.product.makingProcess
                                , countryElecProcess = Step.getCountryElectricityProcess step
                                }
                in
                { step | impact = impact, kwh = kwh }
            )


computeDyeingImpact : Db -> Simulator -> Result String Simulator
computeDyeingImpact { processes } ({ inputs } as simulator) =
    processes
        |> Process.loadWellKnown
        |> Result.map
            (\{ dyeingHigh, dyeingLow } ->
                simulator
                    |> updateLifeCycleStep Step.Ennoblement
                        (\({ dyeingWeighting, country } as step) ->
                            let
                                { heat, kwh, impact } =
                                    step.outputMass
                                        |> Formula.dyeingImpact inputs.impact.trigram
                                            ( dyeingLow, dyeingHigh )
                                            dyeingWeighting
                                            country.heatProcess
                                            (Step.getCountryElectricityProcess step)
                            in
                            { step | heat = heat, kwh = kwh, impact = impact }
                        )
            )


computeMaterialAndSpinningImpact : Simulator -> Simulator
computeMaterialAndSpinningImpact ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.MaterialAndSpinning
            (Step.updateImpact
                (\mass ->
                    case ( inputs.material.recycledProcess, inputs.recycledRatio ) of
                        ( Just recycledProcess, Just ratio ) ->
                            mass
                                |> Formula.materialAndSpinningImpact
                                    inputs.impact.trigram
                                    ( recycledProcess, inputs.material.materialProcess )
                                    ratio

                        _ ->
                            mass
                                |> Formula.pureMaterialAndSpinningImpact
                                    inputs.impact.trigram
                                    inputs.material.materialProcess
                )
            )


computeWeavingKnittingImpact : Simulator -> Simulator
computeWeavingKnittingImpact ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.WeavingKnitting
            (\step ->
                let
                    { kwh, impact } =
                        if inputs.product.knitted then
                            step.outputMass
                                |> Formula.knittingImpact
                                    inputs.impact.trigram
                                    { elec = inputs.product.fabricProcess.elec
                                    , countryElecProcess = Step.getCountryElectricityProcess step
                                    }

                        else
                            step.outputMass
                                |> Formula.weavingImpact
                                    inputs.impact.trigram
                                    { elecPppm = inputs.product.fabricProcess.elec_pppm
                                    , countryElecProcess = Step.getCountryElectricityProcess step
                                    , grammage = inputs.product.grammage
                                    , ppm = inputs.product.ppm
                                    }
                in
                { step | impact = impact, kwh = kwh }
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
    { simulator | impact = LifeCycle.computeFinalImpactScore lifeCycle }


updateLifeCycle : (LifeCycle -> LifeCycle) -> Simulator -> Simulator
updateLifeCycle update simulator =
    { simulator | lifeCycle = update simulator.lifeCycle }


updateLifeCycleStep : Step.Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleStep label update =
    updateLifeCycle (LifeCycle.updateStep label update)


updateLifeCycleSteps : List Step.Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleSteps labels update =
    updateLifeCycle (LifeCycle.updateSteps labels update)
