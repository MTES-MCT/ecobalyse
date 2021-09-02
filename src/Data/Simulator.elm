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
        |> computeConfectionWaste
        -- Compute transport summary
        |> computeTransportSummary


computeConfectionWaste : Simulator -> Simulator
computeConfectionWaste ({ mass, product } as simulator) =
    let
        confectionProcess =
            Process.findByUuid product.process_uuid |> Maybe.withDefault Process.cotton

        stepMass =
            -- (product weight + textile waste for confection) / (1 - PCR waste rate)
            (mass + (mass * confectionProcess.waste)) / (1 - product.waste)

        waste =
            stepMass - mass
    in
    simulator
        |> updateLifeCycleStep Step.Making (\step -> { step | waste = waste, mass = stepMass })
        |> updateLifeCycleSteps
            [ Step.Material, Step.Spinning, Step.Weaving, Step.Ennoblement ]
            (\step -> { step | mass = stepMass })


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
