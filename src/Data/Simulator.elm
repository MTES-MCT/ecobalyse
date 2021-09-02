module Data.Simulator exposing (Simulator, compute, decode, default, encode)

import Data.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Material as Material exposing (Material)
import Data.Process as Process
import Data.Product as Product exposing (Product)
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


type alias Results =
    { confection :
        { waste : Float
        , mass : Float
        }
    }


compute : Simulator -> Results
compute { mass, product } =
    let
        -- TODO:
        -- - trouver un moyen de redéfinir les lifeCycle en Step.Steps
        -- - peut-être qu'on peut modéliser toutes les étapes avec ça + le résultat des calculs intermédiaires ?
        --
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
