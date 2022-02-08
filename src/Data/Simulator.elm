module Data.Simulator exposing
    ( Simulator
    , compute
    , encode
    )

import Data.Db exposing (Db)
import Data.Formula as Formula
import Data.Impact as Impact exposing (Impacts)
import Data.Inputs as Inputs exposing (Inputs)
import Data.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Process as Process
import Data.Product as Product
import Data.Step as Step exposing (Step)
import Data.Transport as Transport exposing (Transport)
import Duration exposing (Duration)
import Json.Encode as Encode
import Quantity
import Route exposing (Route(..))


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
            (\inputs ->
                inputs
                    |> LifeCycle.init db
                    |> (\lifeCycle ->
                            let
                                { daysOfWear, useNbCycles } =
                                    inputs.product
                                        |> Product.customDaysOfWear inputs.quality
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
        -- Compute product Use impacts
        |> next computeUseImpacts
        -- Compute product Use impacts
        |> nextWithDb computeEndOfLifeImpacts
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
        |> updateLifeCycleSteps [ Step.Distribution, Step.Use, Step.EndOfLife ]
            (Step.initMass inputs.mass)


computeEndOfLifeImpacts : Db -> Simulator -> Result String Simulator
computeEndOfLifeImpacts { processes } simulator =
    processes
        |> Process.loadWellKnown
        |> Result.map
            (\{ passengerCar, endOfLife } ->
                simulator
                    |> updateLifeCycleStep Step.EndOfLife
                        (\({ country } as step) ->
                            let
                                { kwh, heat, impacts } =
                                    step.outputMass
                                        |> Formula.endOfLifeImpacts step.impacts
                                            { passengerCar = passengerCar
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
        |> updateLifeCycleStep Step.Use
            (\({ country } as step) ->
                let
                    { kwh, impacts } =
                        step.outputMass
                            |> Formula.useImpacts step.impacts
                                { useNbCycles = useNbCycles
                                , ironingProcess = inputs.product.useIroningProcess
                                , nonIroningProcess = inputs.product.useNonIroningProcess
                                , countryElecProcess = country.electricityProcess
                                }
                in
                { step | impacts = impacts, kwh = kwh }
            )


computeMakingImpacts : Simulator -> Simulator
computeMakingImpacts ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.Making
            (\({ country } as step) ->
                let
                    { kwh, impacts } =
                        step.outputMass
                            |> Formula.makingImpacts step.impacts
                                { makingProcess = inputs.product.makingProcess
                                , countryElecProcess = country.electricityProcess
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
                                            country.electricityProcess
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
                                    |> Formula.materialAndSpinningImpacts step.impacts
                                        ( recycledProcess, inputs.material.materialProcess )
                                        ratio

                            _ ->
                                step.outputMass
                                    |> Formula.pureMaterialAndSpinningImpacts step.impacts
                                        inputs.material.materialProcess
                }
            )


computeWeavingKnittingImpacts : Simulator -> Simulator
computeWeavingKnittingImpacts ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.WeavingKnitting
            (\({ country } as step) ->
                let
                    { kwh, impacts } =
                        if inputs.product.knitted then
                            step.outputMass
                                |> Formula.knittingImpacts step.impacts
                                    { elec = inputs.product.fabricProcess.elec
                                    , countryElecProcess = country.electricityProcess
                                    }

                        else
                            step.outputMass
                                |> Formula.weavingImpacts step.impacts
                                    { elecPppm = inputs.product.fabricProcess.elec_pppm
                                    , countryElecProcess = country.electricityProcess
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


updateLifeCycle : (LifeCycle -> LifeCycle) -> Simulator -> Simulator
updateLifeCycle update simulator =
    { simulator | lifeCycle = update simulator.lifeCycle }


updateLifeCycleStep : Step.Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleStep label update =
    updateLifeCycle (LifeCycle.updateStep label update)


updateLifeCycleSteps : List Step.Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleSteps labels update =
    updateLifeCycle (LifeCycle.updateSteps labels update)
