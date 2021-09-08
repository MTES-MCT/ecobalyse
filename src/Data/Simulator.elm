module Data.Simulator exposing (..)

import Array
import Data.CountryProcess as CountryProcess
import Data.Inputs exposing (Inputs)
import Data.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Material as Material exposing (Material)
import Data.Process as Process
import Data.Product as Product exposing (Product)
import Data.Step as Step exposing (Step)
import Data.Transport as Transport
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Simulator =
    { mass : Float
    , material : Material
    , product : Product
    , lifeCycle : LifeCycle
    , co2 : Float
    , transport : Transport.Summary
    }


default : Simulator
default =
    { mass = Product.tShirt.mass
    , material = Material.cotton
    , product = Product.tShirt
    , lifeCycle = LifeCycle.default
    , co2 = 0
    , transport = Transport.defaultSummary
    }


decode : Decoder Simulator
decode =
    Decode.map6 Simulator
        (Decode.field "mass" Decode.float)
        (Decode.field "material" Material.decode)
        (Decode.field "product" Product.decode)
        (Decode.field "lifeCycle" LifeCycle.decode)
        (Decode.field "co2" Decode.float)
        (Decode.field "transport" Transport.decodeSummary)


encode : Simulator -> Encode.Value
encode v =
    Encode.object
        [ ( "mass", Encode.float v.mass )
        , ( "material", Material.encode v.material )
        , ( "product", Product.encode v.product )
        , ( "lifeCycle", LifeCycle.encode v.lifeCycle )
        , ( "co2", Encode.float v.co2 )
        , ( "transport", Transport.encodeSummary v.transport )
        ]


fromInputs : Inputs -> Simulator
fromInputs { mass, material, product, countries } =
    compute
        { default
            | mass = mass
            , material = material
            , product = product
            , lifeCycle =
                default.lifeCycle
                    |> Array.indexedMap
                        (\index step ->
                            { step
                                | country =
                                    countries
                                        |> Array.fromList
                                        |> Array.get index
                                        |> Maybe.withDefault step.country
                            }
                        )
        }


compute : Simulator -> Simulator
compute simulator =
    simulator
        -- Ensure end product mass is applied to the final Distribution step
        |> updateLifeCycleStep Step.Distribution (\step -> { step | mass = simulator.mass })
        --
        -- WASTE
        --
        -- Compute inital required material mass
        |> computeMakingStepWaste
        -- Compute Knitting/Weawing material waste
        |> computeWeavingKnittingStepWaste
        -- Compute Material&Spinning material waste
        |> computeMaterialStepWaste
        --
        -- CO2 SCORES
        --
        -- Compute Material & Spinning step co2 score
        |> computeMaterialAndSpinningCo2Score
        -- Compute Weaving & Knitting step co2 score
        |> computeWeavingKnittingCo2Score
        -- Compute Ennoblement step co2 score
        |> computeEnnoblementCo2Score
        -- Compute Making step co2 score
        |> computeMakingCo2Score
        --
        -- TRANSPORTS
        --
        -- Compute step transport
        |> computeTransportSummaries
        -- Compute transport summary
        |> computeTransportSummary
        --
        -- FINAL CO2 SCORE
        --
        |> computeFinalCo2Score


computeMakingCo2Score : Simulator -> Simulator
computeMakingCo2Score ({ product } as simulator) =
    simulator
        |> updateLifeCycleStep Step.Making
            (\step ->
                let
                    makingCo2 =
                        Process.findByUuid product.makingProcessUuid
                            |> .climateChange
                            |> (*) step.mass

                    electricityMJ =
                        Process.findByUuid product.makingProcessUuid
                            |> .elec
                            |> (*) step.mass

                    electricityKWh =
                        electricityMJ / 3.6

                    elecCo2 =
                        CountryProcess.get step.country
                            |> Maybe.map (.electricity >> .climateChange)
                            |> Maybe.withDefault 0
                            |> (*) electricityKWh
                in
                { step | co2 = makingCo2 + elecCo2 }
            )


computeEnnoblementCo2Score : Simulator -> Simulator
computeEnnoblementCo2Score =
    updateLifeCycleStep Step.Ennoblement
        (\step ->
            let
                processes =
                    CountryProcess.get step.country

                dyeingCo2 =
                    processes
                        |> Maybe.map (.dyeing >> .climateChange)
                        |> Maybe.withDefault 0
                        |> (*) step.mass

                heatMJ =
                    processes
                        |> Maybe.map (.dyeing >> .heat)
                        |> Maybe.withDefault 0
                        |> (*) step.mass

                heatCo2 =
                    processes
                        |> Maybe.map (.heat >> .climateChange)
                        |> Maybe.withDefault 0
                        |> (*) heatMJ

                electricityMJ =
                    processes
                        |> Maybe.map (.dyeing >> .elec)
                        |> Maybe.withDefault 0
                        |> (*) step.mass

                electricityKWh =
                    electricityMJ / 3.6

                elecCo2 =
                    processes
                        |> Maybe.map (.electricity >> .climateChange)
                        |> Maybe.withDefault 0
                        |> (*) electricityKWh
            in
            { step | co2 = dyeingCo2 + heatCo2 + elecCo2 }
        )


computeMaterialAndSpinningCo2Score : Simulator -> Simulator
computeMaterialAndSpinningCo2Score ({ material } as simulator) =
    let
        climateChange =
            Process.findByUuid material.materialProcessUuid |> .climateChange
    in
    simulator
        |> updateLifeCycleStep Step.MaterialAndSpinning
            (\step -> { step | co2 = climateChange * step.mass })


computeWeavingKnittingCo2Score : Simulator -> Simulator
computeWeavingKnittingCo2Score ({ product } as simulator) =
    simulator
        |> updateLifeCycleStep Step.WeavingKnitting
            (\step ->
                let
                    previousStepMass =
                        simulator.lifeCycle
                            |> LifeCycle.getStep Step.Ennoblement
                            |> Maybe.map .mass
                            |> Maybe.withDefault 0

                    -- Note: weaving and knitting processes are the same across all
                    -- countries and are defined by product
                    weavingKnittingProcess =
                        Product.getWeavingKnittingProcess product

                    electricityKWh =
                        -- NOTE: knitted elec is computed against previous step mass,
                        -- weaved elec is computed against current step mass
                        if product.knitted then
                            previousStepMass * weavingKnittingProcess.elec / 3.6

                        else
                            (step.mass * weavingKnittingProcess.elec_pppm)
                                * (step.mass * 1000 * toFloat product.ppm / toFloat product.grammage)

                    electricity =
                        CountryProcess.get step.country
                            |> Maybe.map (.electricity >> .climateChange)
                            |> Maybe.withDefault 0
                in
                { step | co2 = electricityKWh * electricity }
            )


computeMakingStepWaste : Simulator -> Simulator
computeMakingStepWaste ({ mass, product } as simulator) =
    let
        confectionWaste =
            Process.findByUuid product.makingProcessUuid |> .waste

        stepMass =
            -- (product weight + textile waste for confection) / (1 - PCR waste rate)
            (mass + (mass * confectionWaste)) / (1 - product.pcrWaste)

        waste =
            stepMass - mass
    in
    simulator
        |> updateLifeCycleStep Step.Making (\step -> { step | waste = waste, mass = stepMass })
        |> updateLifeCycleSteps
            [ Step.MaterialAndSpinning, Step.WeavingKnitting, Step.Ennoblement ]
            (\step -> { step | mass = stepMass })


computeWeavingKnittingStepWaste : Simulator -> Simulator
computeWeavingKnittingStepWaste ({ product } as simulator) =
    let
        baseMass =
            simulator.lifeCycle |> LifeCycle.getStep Step.Making |> Maybe.map .mass |> Maybe.withDefault 0

        weavingKnittingWaste =
            product |> Product.getWeavingKnittingProcess |> .waste |> (*) baseMass

        stepMass =
            baseMass + weavingKnittingWaste
    in
    simulator
        |> updateLifeCycleStep Step.WeavingKnitting (\step -> { step | mass = stepMass, waste = weavingKnittingWaste })
        |> updateLifeCycleSteps [ Step.MaterialAndSpinning ] (\step -> { step | mass = stepMass })


computeMaterialStepWaste : Simulator -> Simulator
computeMaterialStepWaste ({ material } as simulator) =
    let
        baseMass =
            simulator.lifeCycle |> LifeCycle.getStep Step.WeavingKnitting |> Maybe.map .mass |> Maybe.withDefault 0

        stepWaste =
            Process.findByUuid material.materialProcessUuid |> .waste |> (*) baseMass

        stepMass =
            baseMass + stepWaste
    in
    simulator
        |> updateLifeCycleStep Step.MaterialAndSpinning (\step -> { step | mass = stepMass, waste = stepWaste })


computeTransportSummaries : Simulator -> Simulator
computeTransportSummaries =
    updateLifeCycle LifeCycle.computeTransportSummaries


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
