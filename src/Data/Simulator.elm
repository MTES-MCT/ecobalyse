module Data.Simulator exposing (..)

import Data.Co2 as Co2 exposing (Co2e)
import Data.Db exposing (Db)
import Data.Formula as Formula
import Data.Inputs as Inputs exposing (Inputs)
import Data.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Material as Material
import Data.Process as Process
import Data.Step as Step exposing (Step)
import Data.Transport as Transport
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Simulator =
    { inputs : Inputs
    , lifeCycle : LifeCycle
    , co2 : Co2e
    , transport : Transport.Summary
    }


decode : Decoder Simulator
decode =
    Decode.map4 Simulator
        (Decode.field "inputs" Inputs.decode)
        (Decode.field "lifeCycle" LifeCycle.decode)
        (Decode.field "co2" Co2.decodeKgCo2e)
        (Decode.field "transport" Transport.decodeSummary)


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
                    |> LifeCycle.init db
                    |> (\lifeCycle ->
                            { inputs = inputs
                            , lifeCycle = lifeCycle
                            , co2 = Co2.kgCo2e 0
                            , transport = Transport.defaultSummary
                            }
                       )
            )


compute : Db -> Inputs.Query -> Result String Simulator
compute db query =
    init db query
        -- Ensure end product mass is first applied to the final Distribution step
        |> Result.map computeMaterialAndSpinningWaste
        --
        -- WASTE
        --
        -- Compute inital required material mass
        |> Result.andThen (computeMakingStepWaste db)
        -- Compute Knitting/Weawing material waste
        |> Result.andThen (computeWeavingKnittingStepWaste db)
        -- Compute Material&Spinning material waste
        |> Result.andThen (computeMaterialStepWaste db)
        --
        -- CO2 SCORES
        --
        -- Compute Material & Spinning step co2 score
        |> Result.andThen (computeMaterialAndSpinningCo2Score db)
        -- Compute Weaving & Knitting step co2 score
        |> Result.andThen (computeWeavingKnittingCo2Score db)
        -- Compute Ennoblement step co2 score
        |> Result.andThen (computeDyeingCo2Score db)
        -- Compute Making step co2 score
        |> Result.andThen (computeMakingCo2Score db)
        --
        -- TRANSPORTS
        --
        -- Compute step transport
        |> Result.andThen (computeTransportSummaries db)
        -- Compute transport summary
        |> Result.map computeTransportSummary
        --
        -- FINAL CO2 SCORE
        --
        |> Result.map computeFinalCo2Score


computeMaterialAndSpinningWaste : Simulator -> Simulator
computeMaterialAndSpinningWaste ({ inputs } as simulator) =
    simulator
        |> updateLifeCycleStep Step.Distribution (\step -> { step | mass = inputs.mass })


computeMakingCo2Score : Db -> Simulator -> Result String Simulator
computeMakingCo2Score { processes } ({ inputs } as simulator) =
    processes
        |> Process.findByUuid inputs.product.makingProcessUuid
        |> Result.map
            (\makingProcess ->
                simulator
                    |> updateLifeCycleStep Step.Making
                        (\({ country } as step) ->
                            let
                                countryElecCC =
                                    processes
                                        -- FIXME: handle result or provide direct access
                                        |> Process.findByUuid country.electricity
                                        |> Result.map .climateChange
                                        |> Result.withDefault (Co2.kgCo2e 0)

                                { kwh, co2 } =
                                    step.mass
                                        |> Formula.makingCo2
                                            { makingClimateChange = makingProcess.climateChange
                                            , makingElec = makingProcess.elec
                                            , countryElecClimateChange = countryElecCC
                                            }
                            in
                            { step | kwh = kwh, co2 = co2 }
                        )
            )


computeDyeingCo2Score : Db -> Simulator -> Result String Simulator
computeDyeingCo2Score { processes } simulator =
    Result.map2
        (\dyeingHigh dyeingLow ->
            simulator
                |> updateLifeCycleStep Step.Ennoblement
                    (\({ dyeingWeighting, country } as step) ->
                        let
                            elecCC =
                                processes
                                    -- FIXME: handle result or provide direct access
                                    |> Process.findByUuid country.electricity
                                    |> Result.map .climateChange
                                    |> Result.withDefault (Co2.kgCo2e 0)

                            heatCC =
                                processes
                                    -- FIXME: handle result or provide direct access
                                    |> Process.findByUuid country.heat
                                    |> Result.map .climateChange
                                    |> Result.withDefault (Co2.kgCo2e 0)

                            { co2, heat, kwh } =
                                step.mass
                                    |> Formula.dyeingCo2 ( dyeingLow, dyeingHigh ) dyeingWeighting heatCC elecCC
                        in
                        { step | co2 = co2, heat = heat, kwh = kwh }
                    )
        )
        (Process.findByUuid Process.wellKnownUuids.dyeingHigh processes)
        (Process.findByUuid Process.wellKnownUuids.dyeingLow processes)


computeMaterialAndSpinningCo2Score : Db -> Simulator -> Result String Simulator
computeMaterialAndSpinningCo2Score { processes } ({ inputs } as simulator) =
    Result.map2
        (\materialProcess maybeRecycledProcess ->
            simulator
                |> updateLifeCycleStep Step.MaterialAndSpinning
                    (\step ->
                        { step
                            | co2 =
                                case ( maybeRecycledProcess, inputs.recycledRatio ) of
                                    ( Just recycledProcess, Just ratio ) ->
                                        step.mass
                                            |> Formula.materialRecycledCo2
                                                { pristineClimateChange = materialProcess.climateChange
                                                , recycledClimateChange = recycledProcess.climateChange
                                                , recycledRatio = ratio
                                                }

                                    _ ->
                                        step.mass
                                            |> Co2.co2ePerMass materialProcess.climateChange
                        }
                    )
        )
        (Process.findByUuid inputs.material.uuid processes)
        (Material.getRecycledProcess inputs.material processes)


computeWeavingKnittingCo2Score : Db -> Simulator -> Result String Simulator
computeWeavingKnittingCo2Score { processes } ({ inputs, lifeCycle } as simulator) =
    processes
        |> Process.findByUuid inputs.product.fabricProcessUuid
        |> Result.map
            (\fabricProcess ->
                simulator
                    |> updateLifeCycleStep Step.WeavingKnitting
                        (\({ country } as step) ->
                            let
                                elecCC =
                                    processes
                                        -- FIXME: handle result or provide direct access
                                        |> Process.findByUuid country.electricity
                                        |> Result.map .climateChange
                                        |> Result.withDefault (Co2.kgCo2e 0)

                                { kwh, co2 } =
                                    -- NOTE: knitted elec is computed against previous step mass,
                                    -- weaved elec is computed against current step mass
                                    if inputs.product.knitted then
                                        lifeCycle
                                            |> LifeCycle.getStepMass Step.Ennoblement
                                            |> Formula.knittingCo2 fabricProcess elecCC

                                    else
                                        step.mass
                                            |> Formula.weavingCo2 fabricProcess
                                                elecCC
                                                inputs.product.ppm
                                                inputs.product.grammage
                            in
                            { step | co2 = co2, kwh = kwh }
                        )
            )


computeMakingStepWaste : Db -> Simulator -> Result String Simulator
computeMakingStepWaste { processes } ({ inputs } as simulator) =
    processes
        |> Process.findByUuid inputs.product.makingProcessUuid
        |> Result.map
            (\makingProcess ->
                let
                    { mass, waste } =
                        inputs.mass
                            |> Formula.makingWaste
                                { processWaste = makingProcess.waste
                                , pcrWaste = inputs.product.pcrWaste
                                }
                in
                simulator
                    |> updateLifeCycleStep Step.Making (\step -> { step | mass = mass, waste = waste })
                    |> updateLifeCycleSteps
                        [ Step.MaterialAndSpinning, Step.WeavingKnitting, Step.Ennoblement ]
                        (\step -> { step | mass = mass })
            )


computeWeavingKnittingStepWaste : Db -> Simulator -> Result String Simulator
computeWeavingKnittingStepWaste { processes } ({ inputs, lifeCycle } as simulator) =
    processes
        |> Process.findByUuid inputs.product.fabricProcessUuid
        |> Result.map
            (\fabricProcess ->
                let
                    { mass, waste } =
                        lifeCycle
                            |> LifeCycle.getStepMass Step.Making
                            |> Formula.genericWaste fabricProcess.waste
                in
                simulator
                    |> updateLifeCycleStep Step.WeavingKnitting
                        (\step -> { step | mass = mass, waste = waste })
                    |> updateLifeCycleSteps [ Step.MaterialAndSpinning ]
                        (\step -> { step | mass = mass })
            )


computeMaterialStepWaste : Db -> Simulator -> Result String Simulator
computeMaterialStepWaste { processes } ({ inputs, lifeCycle } as simulator) =
    Result.map2
        (\materialProcess maybeRecycledProcess ->
            let
                { mass, waste } =
                    lifeCycle
                        |> LifeCycle.getStepMass Step.WeavingKnitting
                        |> (case ( maybeRecycledProcess, inputs.recycledRatio ) of
                                ( Just recycledProcess, Just ratio ) ->
                                    Formula.materialRecycledWaste
                                        { pristineWaste = materialProcess.waste
                                        , recycledWaste = recycledProcess.waste
                                        , recycledRatio = ratio
                                        }

                                _ ->
                                    Formula.genericWaste materialProcess.waste
                           )
            in
            simulator
                |> updateLifeCycleStep Step.MaterialAndSpinning
                    (\step -> { step | mass = mass, waste = waste })
        )
        (Process.findByUuid inputs.material.uuid processes)
        (Material.getRecycledProcess inputs.material processes)


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
