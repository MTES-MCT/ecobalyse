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
import Route exposing (Route(..))


type alias Simulator =
    { inputs : Inputs
    , lifeCycle : LifeCycle
    , impacts : Impacts
    , pefScore : Unit.PefScore
    , transport : Transport
    }


encode : Simulator -> Encode.Value
encode v =
    Encode.object
        [ ( "inputs", Inputs.encode v.inputs )
        , ( "lifeCycle", LifeCycle.encode v.lifeCycle )
        , ( "impacts", Impact.encodeImpacts v.impacts )
        , ( "pefScore", Unit.encodePefScore v.pefScore )
        , ( "transport", Transport.encode v.transport )
        ]


init : Db -> Inputs.Query -> Result String Simulator
init db =
    let
        defaultImpacts =
            Impact.impactsFromDefinitons db.impacts
    in
    Inputs.fromQuery db
        >> Result.map
            (\inputs ->
                inputs
                    |> LifeCycle.init db
                    |> (\lifeCycle ->
                            { inputs = inputs
                            , lifeCycle = lifeCycle
                            , impacts = defaultImpacts
                            , pefScore = Unit.pefScore 0
                            , transport = Transport.default defaultImpacts
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
        -- Compute Material & Spinning step impacts
        |> next computeMaterialAndSpinningImpacts
        -- Compute Weaving & Knitting step impacts
        |> next computeWeavingKnittingImpacts
        -- Compute Ennoblement step impacts
        |> nextWithDb computeDyeingImpacts
        -- Compute Making step impacts
        |> next computeMakingImpacts
        --
        -- TRANSPORTS
        --
        -- Compute step transport
        |> nextWithDb computeStepsTransport
        -- Compute transport summary
        |> next (computeTotalTransports db)
        --
        -- Final impacts
        --
        |> next (computeFinalImpacts db)
        |> next (computePefScore db)


computePefScore : Db -> Simulator -> Simulator
computePefScore db ({ impacts } as simulator) =
    { simulator | pefScore = Impact.computePefScore db.impacts impacts }


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
                    { kwh, impacts } =
                        step.outputMass
                            |> Formula.makingImpacts
                                step.impacts
                                { makingProcess = inputs.product.makingProcess
                                , countryElecProcess = Step.getCountryElectricityProcess step
                                }
                in
                { step | impacts = impacts, kwh = kwh }
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
                                { heat, kwh, impacts } =
                                    step.outputMass
                                        |> Formula.dyeingImpacts step.impacts
                                            ( dyeingLow, dyeingHigh )
                                            dyeingWeighting
                                            country.heatProcess
                                            (Step.getCountryElectricityProcess step)
                            in
                            { step | heat = heat, kwh = kwh, impacts = impacts }
                        )
            )


computeMaterialAndSpinningImpacts : Simulator -> Simulator
computeMaterialAndSpinningImpacts ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.MaterialAndSpinning
            (\step ->
                { step
                    | impacts =
                        case ( inputs.material.recycledProcess, inputs.recycledRatio ) of
                            ( Just recycledProcess, Just ratio ) ->
                                step.outputMass
                                    |> Formula.materialAndSpinningImpacts
                                        step.impacts
                                        ( recycledProcess, inputs.material.materialProcess )
                                        ratio

                            _ ->
                                step.outputMass
                                    |> Formula.pureMaterialAndSpinningImpacts
                                        step.impacts
                                        inputs.material.materialProcess
                }
            )


computeWeavingKnittingImpacts : Simulator -> Simulator
computeWeavingKnittingImpacts ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.WeavingKnitting
            (\step ->
                let
                    { kwh, impacts } =
                        if inputs.product.knitted then
                            step.outputMass
                                |> Formula.knittingImpacts
                                    step.impacts
                                    { elec = inputs.product.fabricProcess.elec
                                    , countryElecProcess = Step.getCountryElectricityProcess step
                                    }

                        else
                            step.outputMass
                                |> Formula.weavingImpacts
                                    step.impacts
                                    { elecPppm = inputs.product.fabricProcess.elec_pppm
                                    , countryElecProcess = Step.getCountryElectricityProcess step
                                    , grammage = inputs.product.grammage
                                    , ppm = inputs.product.ppm
                                    }
                in
                { step | impacts = impacts, kwh = kwh }
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


computeTotalTransports : Db -> Simulator -> Simulator
computeTotalTransports db simulator =
    { simulator | transport = simulator.lifeCycle |> LifeCycle.computeTotalTransports db }


computeFinalImpacts : Db -> Simulator -> Simulator
computeFinalImpacts db ({ lifeCycle } as simulator) =
    { simulator | impacts = LifeCycle.computeFinalImpacts db lifeCycle }


updateLifeCycle : (LifeCycle -> LifeCycle) -> Simulator -> Simulator
updateLifeCycle update simulator =
    { simulator | lifeCycle = update simulator.lifeCycle }


updateLifeCycleStep : Step.Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleStep label update =
    updateLifeCycle (LifeCycle.updateStep label update)


updateLifeCycleSteps : List Step.Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleSteps labels update =
    updateLifeCycle (LifeCycle.updateSteps labels update)
