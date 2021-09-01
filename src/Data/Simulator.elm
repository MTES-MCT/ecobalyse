module Data.Simulator exposing (Simulator, compute, decode, default, encode)

import Array exposing (Array)
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
    , steps : Array Step
    , score : Float
    , transport : Transport.Summary
    }


default : Simulator
default =
    { mass = Product.tShirt.mass
    , material = Material.cotton
    , product = Product.tShirt
    , steps = Step.default
    , score = 0
    , transport = Transport.defaultSummary
    }


decode : Decoder Simulator
decode =
    Decode.map6 Simulator
        (Decode.field "mass" Decode.float)
        (Decode.field "material" Material.decode)
        (Decode.field "product" Product.decode)
        (Decode.field "steps" (Decode.array Step.decode))
        (Decode.field "score" Decode.float)
        (Decode.field "transport" Transport.decodeSummary)


encode : Simulator -> Encode.Value
encode v =
    Encode.object
        [ ( "mass", Encode.float v.mass )
        , ( "material", Material.encode v.material )
        , ( "product", Product.encode v.product )
        , ( "steps", Encode.array Step.encode v.steps )
        , ( "score", Encode.float v.score )
        , ( "transport", Transport.encodeSummary v.transport )
        ]


type alias Results =
    { confection :
        { waste : Float
        , mass : Float
        }
    }


compute : Simulator -> Results
compute { mass, product } =
    let
        -- materialProcess =
        --     Process.findByUuid material.process_uuid
        --         |> Maybe.withDefault Process.cotton
        confectionProcess =
            Process.findByUuid product.process_uuid
                |> Maybe.withDefault Process.cotton
                |> Debug.log "confectionProcess"
    in
    { confection =
        { waste = mass * confectionProcess.waste

        -- (Poids Habit + textile waste confection) / (1 - taux de perte (PCR))
        , mass = (mass + (mass * confectionProcess.waste)) / (1 - product.waste)
        }
    }
