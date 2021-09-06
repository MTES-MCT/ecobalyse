module Data.Simulator exposing (..)

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
    , score : Float
    , transport : Transport.Summary
    }


default : Simulator
default =
    { mass = Product.tShirt.mass
    , material = Material.cotton
    , product = Product.tShirt
    , lifeCycle = LifeCycle.default
    , score = 0
    , transport = Transport.defaultSummary
    }


decode : Decoder Simulator
decode =
    Decode.map6 Simulator
        (Decode.field "mass" Decode.float)
        (Decode.field "material" Material.decode)
        (Decode.field "product" Product.decode)
        (Decode.field "lifeCycle" LifeCycle.decode)
        (Decode.field "score" Decode.float)
        (Decode.field "transport" Transport.decodeSummary)


encode : Simulator -> Encode.Value
encode v =
    Encode.object
        [ ( "mass", Encode.float v.mass )
        , ( "material", Material.encode v.material )
        , ( "product", Product.encode v.product )
        , ( "lifeCycle", LifeCycle.encode v.lifeCycle )
        , ( "score", Encode.float v.score )
        , ( "transport", Transport.encodeSummary v.transport )
        ]


compute : Simulator -> Simulator
compute simulator =
    simulator
        -- Ensure end product mass is applied to the final Distribution step
        |> updateLifeCycleStep Step.Distribution (\step -> { step | mass = simulator.mass })
        -- Compute inital required material mass
        |> computeMakingStepWaste
        -- Compute Knitting/Weawing material waste
        |> computeWeavingKnittingStepWaste
        -- Compute Material&Spinning material waste
        |> computeMaterialStepWaste
        -- Compute step transport
        |> computeTransportSummaries
        -- Compute transport summary
        |> computeTransportSummary


computeMakingStepWaste : Simulator -> Simulator
computeMakingStepWaste ({ mass, product } as simulator) =
    let
        confectionWaste =
            Process.findByUuid product.process_uuid |> .waste

        stepMass =
            -- (product weight + textile waste for confection) / (1 - PCR waste rate)
            (mass + (mass * confectionWaste)) / (1 - product.pcrWaste)

        waste =
            stepMass - mass
    in
    simulator
        |> updateLifeCycleStep Step.Making (\step -> { step | waste = waste, mass = stepMass })
        |> updateLifeCycleSteps
            [ Step.Material, Step.Spinning, Step.WeavingKnitting, Step.Ennoblement ]
            (\step -> { step | mass = stepMass })


computeWeavingKnittingStepWaste : Simulator -> Simulator
computeWeavingKnittingStepWaste ({ product } as simulator) =
    let
        baseMass =
            simulator.lifeCycle |> LifeCycle.getStep Step.Making |> Maybe.map .mass |> Maybe.withDefault 0

        wasteProcessName =
            -- Note: process names are unique, so let's use them as is
            if product.knitted then
                "Tricotage"

            else
                "Tissage (habillement)"

        weavingKnittingWaste =
            Process.findByName wasteProcessName |> .waste |> (*) baseMass

        stepMass =
            baseMass + weavingKnittingWaste
    in
    simulator
        |> updateLifeCycleStep Step.WeavingKnitting (\step -> { step | mass = stepMass, waste = weavingKnittingWaste })
        |> updateLifeCycleSteps
            [ Step.Material, Step.Spinning ]
            (\step -> { step | mass = stepMass })


computeMaterialStepWaste : Simulator -> Simulator
computeMaterialStepWaste ({ material } as simulator) =
    let
        baseMass =
            simulator.lifeCycle |> LifeCycle.getStep Step.WeavingKnitting |> Maybe.map .mass |> Maybe.withDefault 0

        stepWaste =
            Process.findByUuid material.process_uuid |> .waste |> (*) baseMass

        stepMass =
            baseMass + stepWaste
    in
    simulator
        |> updateLifeCycleStep Step.Material (\step -> { step | mass = stepMass, waste = stepWaste })
        |> updateLifeCycleSteps
            [ Step.Spinning ]
            (\step -> { step | mass = stepMass })


computeTransportSummaries : Simulator -> Simulator
computeTransportSummaries =
    updateLifeCycle LifeCycle.computeTransportSummaries


computeTransportSummary : Simulator -> Simulator
computeTransportSummary simulator =
    { simulator | transport = simulator.lifeCycle |> LifeCycle.computeTransportSummary }


updateLifeCycle : (LifeCycle -> LifeCycle) -> Simulator -> Simulator
updateLifeCycle update simulator =
    { simulator | lifeCycle = update simulator.lifeCycle }


updateLifeCycleStep : Step.Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleStep label update =
    updateLifeCycle (LifeCycle.updateStep label update)


updateLifeCycleSteps : List Step.Label -> (Step -> Step) -> Simulator -> Simulator
updateLifeCycleSteps labels update =
    updateLifeCycle (LifeCycle.updateSteps labels update)
