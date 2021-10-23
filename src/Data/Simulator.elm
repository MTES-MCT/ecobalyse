module Data.Simulator exposing (..)

import Data.Db exposing (Db)
import Data.Inputs as Inputs exposing (Inputs)
import Data.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Process as Process
import Data.Step as Step exposing (Step)
import Data.Transport as Transport
import Energy
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Mass
import Quantity
import Result.Extra as RE


type alias Simulator =
    { inputs : Inputs
    , lifeCycle : LifeCycle
    , co2 : Float
    , transport : Transport.Summary
    }


decode : Decoder Simulator
decode =
    Decode.map4 Simulator
        (Decode.field "inputs" Inputs.decode)
        (Decode.field "lifeCycle" LifeCycle.decode)
        (Decode.field "co2" Decode.float)
        (Decode.field "transport" Transport.decodeSummary)


encode : Simulator -> Encode.Value
encode v =
    Encode.object
        [ ( "inputs", Inputs.encode v.inputs )
        , ( "lifeCycle", LifeCycle.encode v.lifeCycle )
        , ( "co2", Encode.float v.co2 )
        , ( "transport", Transport.encodeSummary v.transport )
        ]


init : Db -> Inputs.Query -> Result String Simulator
init db =
    Inputs.fromQuery db
        >> Result.map
            (\inputs ->
                inputs
                    |> LifeCycle.init db
                    |> Result.map
                        (\lifeCycle ->
                            { inputs = inputs
                            , lifeCycle = lifeCycle
                            , co2 = 0
                            , transport = Transport.defaultSummary
                            }
                        )
            )
        >> RE.join


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
        |> Result.andThen (computeEnnoblementCo2Score db)
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
        |> Process.findByUuid2 inputs.product.makingProcessUuid
        |> Result.map
            (\{ climateChange, elec } ->
                simulator
                    |> updateLifeCycleStep Step.Making
                        (\step ->
                            let
                                makingCo2 =
                                    climateChange |> (*) (Mass.inKilograms step.mass)

                                electricity =
                                    elec |> Quantity.multiplyBy (Mass.inKilograms step.mass)

                                elecCo2 =
                                    processes
                                        |> Process.findByUuid2 step.country.electricity
                                        |> Result.map .climateChange
                                        |> Result.withDefault 0
                                        |> (*) (Energy.inKilowattHours electricity)
                            in
                            { step | co2 = makingCo2 + elecCo2, kwh = electricity }
                        )
            )


computeEnnoblementCo2Score : Db -> Simulator -> Result String Simulator
computeEnnoblementCo2Score { processes } simulator =
    Result.map2
        (\dyeingHigh dyeingLow ->
            simulator
                |> updateLifeCycleStep Step.Ennoblement
                    (\step ->
                        let
                            highDyeingWeighting =
                                step.dyeingWeighting

                            lowDyeingWeighting =
                                1 - highDyeingWeighting

                            dyeingCo2 =
                                Mass.inKilograms step.mass
                                    * ((highDyeingWeighting * dyeingHigh.climateChange)
                                        + (lowDyeingWeighting * dyeingLow.climateChange)
                                      )

                            heatMJ =
                                Mass.inKilograms step.mass
                                    * ((highDyeingWeighting * Energy.inMegajoules dyeingHigh.heat)
                                        + (lowDyeingWeighting * Energy.inMegajoules dyeingLow.heat)
                                      )
                                    |> Energy.megajoules

                            heatCo2 =
                                processes
                                    |> Process.findByUuid2 step.country.heat
                                    |> Result.map .climateChange
                                    |> Result.withDefault 0
                                    |> (*) (Energy.inMegajoules heatMJ)

                            electricity =
                                Mass.inKilograms step.mass
                                    * ((highDyeingWeighting * Energy.inMegajoules dyeingHigh.elec)
                                        + (lowDyeingWeighting * Energy.inMegajoules dyeingLow.elec)
                                      )
                                    |> Energy.megajoules

                            elecCo2 =
                                processes
                                    |> Process.findByUuid2 step.country.heat
                                    |> Result.map .climateChange
                                    |> Result.withDefault 0
                                    |> (*) (Energy.inKilowattHours electricity)
                        in
                        { step
                            | co2 = dyeingCo2 + heatCo2 + elecCo2
                            , heat = heatMJ
                            , kwh = electricity
                        }
                    )
        )
        (Process.findByUuid2 Process.wellKnownUuids.dyeingHigh processes)
        (Process.findByUuid2 Process.wellKnownUuids.dyeingLow processes)


computeMaterialAndSpinningCo2Score : Db -> Simulator -> Result String Simulator
computeMaterialAndSpinningCo2Score { processes } ({ inputs } as simulator) =
    processes
        |> Process.findByUuid2 inputs.material.uuid
        |> Result.map
            (\{ climateChange } ->
                simulator
                    |> updateLifeCycleStep Step.MaterialAndSpinning
                        (\step -> { step | co2 = climateChange * Mass.inKilograms step.mass })
            )


computeWeavingKnittingCo2Score : Db -> Simulator -> Result String Simulator
computeWeavingKnittingCo2Score { processes } ({ inputs } as simulator) =
    processes
        |> Process.findByUuid2 inputs.product.weavingKnittingProcessUuid
        |> Result.map
            (\{ elec, elec_pppm } ->
                simulator
                    |> updateLifeCycleStep Step.WeavingKnitting
                        (\step ->
                            let
                                previousStepMass =
                                    simulator.lifeCycle
                                        |> LifeCycle.getStep Step.Ennoblement
                                        |> Maybe.map .mass
                                        |> Maybe.withDefault (Mass.kilograms 0)

                                electricityKWh =
                                    -- NOTE: knitted elec is computed against previous step mass,
                                    -- weaved elec is computed against current step mass
                                    if inputs.product.knitted then
                                        Mass.inKilograms previousStepMass * Energy.inKilowattHours elec

                                    else
                                        (Mass.inKilograms step.mass * 1000 * toFloat inputs.product.ppm / toFloat inputs.product.grammage)
                                            * elec_pppm

                                climateChangeKgCo2e =
                                    processes
                                        |> Process.findByUuid2 step.country.electricity
                                        |> Result.map .climateChange
                                        |> Result.withDefault 0
                            in
                            { step
                                | co2 = electricityKWh * climateChangeKgCo2e
                                , kwh = Energy.kilowattHours electricityKWh
                            }
                        )
            )


computeMakingStepWaste : Db -> Simulator -> Result String Simulator
computeMakingStepWaste { processes } ({ inputs } as simulator) =
    processes
        |> Process.findByUuid2 inputs.product.makingProcessUuid
        |> Result.map
            (\{ waste } ->
                let
                    stepMass =
                        -- (product weight + textile waste for confection) / (1 - PCR waste rate)
                        Mass.kilograms <|
                            (Mass.inKilograms inputs.mass + (Mass.inKilograms inputs.mass * Mass.inKilograms waste))
                                / (1 - inputs.product.pcrWaste)

                    stepWaste =
                        Quantity.minus inputs.mass stepMass
                in
                simulator
                    |> updateLifeCycleStep Step.Making (\step -> { step | waste = stepWaste, mass = stepMass })
                    |> updateLifeCycleSteps
                        [ Step.MaterialAndSpinning, Step.WeavingKnitting, Step.Ennoblement ]
                        (\step -> { step | mass = stepMass })
            )


computeWeavingKnittingStepWaste : Db -> Simulator -> Result String Simulator
computeWeavingKnittingStepWaste { processes } ({ inputs } as simulator) =
    processes
        |> Process.findByUuid2 inputs.product.weavingKnittingProcessUuid
        |> Result.map
            (\{ waste } ->
                let
                    baseMass =
                        simulator.lifeCycle
                            |> LifeCycle.getStep Step.Making
                            |> Maybe.map .mass
                            |> Maybe.withDefault (Mass.kilograms 0)

                    weavingKnittingWaste =
                        waste |> Quantity.multiplyBy (Mass.inKilograms baseMass)

                    stepMass =
                        Quantity.plus baseMass weavingKnittingWaste
                in
                simulator
                    |> updateLifeCycleStep Step.WeavingKnitting
                        (\step -> { step | mass = stepMass, waste = weavingKnittingWaste })
                    |> updateLifeCycleSteps [ Step.MaterialAndSpinning ]
                        (\step -> { step | mass = stepMass })
            )


computeMaterialStepWaste : Db -> Simulator -> Result String Simulator
computeMaterialStepWaste { processes } ({ inputs } as simulator) =
    processes
        |> Process.findByUuid2 inputs.material.uuid
        |> Result.map
            (\{ waste } ->
                let
                    baseMass =
                        simulator.lifeCycle
                            |> LifeCycle.getStep Step.WeavingKnitting
                            |> Maybe.map .mass
                            |> Maybe.withDefault (Mass.kilograms 0)

                    stepWaste =
                        waste |> Quantity.multiplyBy (Mass.inKilograms baseMass)

                    stepMass =
                        Quantity.plus baseMass stepWaste
                in
                simulator
                    |> updateLifeCycleStep Step.MaterialAndSpinning
                        (\step -> { step | mass = stepMass, waste = stepWaste })
            )


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
