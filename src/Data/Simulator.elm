module Data.Simulator exposing (Simulator, decode, default, encode)

import Array exposing (Array)
import Data.Material as Material exposing (Material)
import Data.Process as Process exposing (Process)
import Data.Product as Product exposing (Product)
import Data.Transport as Transport
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Simulator =
    { mass : Float
    , material : Material
    , product : Product
    , process : Array Process
    , score : Float
    , transport : Transport.Summary
    }


default : Simulator
default =
    { mass = Product.tShirt.defaultMass
    , material = Material.cotton
    , product = Product.tShirt
    , process = Process.default
    , score = 0
    , transport = Transport.defaultSummary
    }


decode : Decoder Simulator
decode =
    Decode.map6 Simulator
        (Decode.field "mass" Decode.float)
        (Decode.field "material" Material.decode)
        (Decode.field "product" Product.decode)
        (Decode.field "process" (Decode.array Process.decode))
        (Decode.field "score" Decode.float)
        (Decode.field "transport" Transport.decodeSummary)


encode : Simulator -> Encode.Value
encode v =
    Encode.object
        [ ( "mass", Encode.float v.mass )
        , ( "material", Material.encode v.material )
        , ( "product", Product.encode v.product )
        , ( "process", Encode.array Process.encode v.process )
        , ( "score", Encode.float v.score )
        , ( "transport", Transport.encodeSummary v.transport )
        ]
