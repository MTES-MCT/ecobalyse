module Data.Simulator exposing (Simulator, decode, default, encode)

import Data.Material as Material exposing (Material)
import Data.Process as Process exposing (Process)
import Data.Product as Product exposing (Product)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Simulator =
    { mass : Float
    , material : Material
    , product : Product
    , process : List Process
    , score : Float
    }


default : Simulator
default =
    { mass = Product.tShirt.defaultMass
    , material = Material.cotton
    , product = Product.tShirt
    , process = Process.default
    , score = 0
    }


decode : Decoder Simulator
decode =
    Decode.map5 Simulator
        (Decode.field "mass" Decode.float)
        (Decode.field "material" Material.decode)
        (Decode.field "product" Product.decode)
        (Decode.field "process" (Decode.list Process.decode))
        (Decode.field "score" Decode.float)


encode : Simulator -> Encode.Value
encode v =
    Encode.object
        [ ( "mass", Encode.float v.mass )
        , ( "material", Material.encode v.material )
        , ( "product", Product.encode v.product )
        , ( "process", Encode.list Process.encode v.process )
        , ( "score", Encode.float v.score )
        ]
