module Data.Product exposing (..)

import Data.Process as Process exposing (Process)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Product =
    { id : String
    , name : String
    , mass : Unit.Kg
    , pcrWaste : Float -- PCR product waste ratio
    , ppm : Int -- pick per meter
    , grammage : Int -- grammes per kg
    , knitted : Bool -- True: Tricotage (Knitting); False: Tissage (Weaving)
    , makingProcessUuid : String
    }


choices : List Product
choices =
    -- Note: we could probably attach the making process directly
    -- Process uuid:
    -- Confection (jeans);1f428a50-73c0-4fc1-ab39-00fd312458ee
    -- Confection (gilet, jupe, pantalon, pull);387059fc-72cb-4a92-b1e7-2ef9242f8380
    -- Confection (débardeur, tee-shirt, combinaison);26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5
    -- Confection (chemisier, manteau, veste, cape, robe);7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe
    -- Confection (ceinture, châle, chapeau, sac, écharpe);0a260a3f-260e-4b43-a0df-0cf673fda960
    [ { id = "1", name = "Cape", mass = Unit.Kg 0.95, pcrWaste = 0.2, ppm = 1600, grammage = 140, knitted = False, makingProcessUuid = "7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe" }
    , { id = "2", name = "Châle", mass = Unit.Kg 0.11, pcrWaste = 0.1, ppm = 1600, grammage = 140, knitted = False, makingProcessUuid = "0a260a3f-260e-4b43-a0df-0cf673fda960" }
    , { id = "3", name = "Chemisier", mass = Unit.Kg 0.25, pcrWaste = 0.2, ppm = 5000, grammage = 40, knitted = False, makingProcessUuid = "7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe" }
    , { id = "4", name = "Débardeur", mass = Unit.Kg 0.17, pcrWaste = 0.15, ppm = 0, grammage = 0, knitted = True, makingProcessUuid = "26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5" }
    , { id = "5", name = "Echarpe", mass = Unit.Kg 0.11, pcrWaste = 0.1, ppm = 1600, grammage = 140, knitted = False, makingProcessUuid = "0a260a3f-260e-4b43-a0df-0cf673fda960" }
    , { id = "6", name = "Gilet", mass = Unit.Kg 0.5, pcrWaste = 0.2, ppm = 0, grammage = 0, knitted = True, makingProcessUuid = "387059fc-72cb-4a92-b1e7-2ef9242f8380" }
    , { id = "7", name = "Jean", mass = Unit.Kg 0.45, pcrWaste = 0.22, ppm = 3000, grammage = 140, knitted = False, makingProcessUuid = "1f428a50-73c0-4fc1-ab39-00fd312458ee" }
    , { id = "8", name = "Jupe", mass = Unit.Kg 0.3, pcrWaste = 0.2, ppm = 5000, grammage = 40, knitted = False, makingProcessUuid = "387059fc-72cb-4a92-b1e7-2ef9242f8380" }
    , { id = "9", name = "Manteau", mass = Unit.Kg 0.95, pcrWaste = 0.2, ppm = 1600, grammage = 140, knitted = False, makingProcessUuid = "7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe" }
    , { id = "10", name = "Pantalon", mass = Unit.Kg 0.45, pcrWaste = 0.2, ppm = 3000, grammage = 140, knitted = False, makingProcessUuid = "387059fc-72cb-4a92-b1e7-2ef9242f8380" }
    , { id = "11", name = "Pull", mass = Unit.Kg 0.5, pcrWaste = 0.2, ppm = 0, grammage = 0, knitted = True, makingProcessUuid = "387059fc-72cb-4a92-b1e7-2ef9242f8380" }
    , { id = "12", name = "Robe", mass = Unit.Kg 0.3, pcrWaste = 0.2, ppm = 5000, grammage = 40, knitted = False, makingProcessUuid = "7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe" }
    , tShirt
    , { id = "14", name = "Veste", mass = Unit.Kg 0.95, pcrWaste = 0.2, ppm = 3000, grammage = 140, knitted = False, makingProcessUuid = "7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe" }
    ]


findById : String -> Maybe Product
findById id =
    choices |> List.filter (.id >> (==) id) |> List.head


findByName : String -> Product
findByName name =
    choices |> List.filter (.name >> (==) name) |> List.head |> Maybe.withDefault invalid


tShirt : Product
tShirt =
    { id = "13"
    , name = "T-shirt"
    , mass = Unit.Kg 0.17
    , pcrWaste = 0.15
    , ppm = 0
    , grammage = 0
    , knitted = True
    , makingProcessUuid = "26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5"
    }


invalid : Product
invalid =
    { id = ""
    , name = "<invalide>"
    , mass = Unit.Kg 0.17
    , pcrWaste = 0.15
    , ppm = 0
    , grammage = 0
    , knitted = True
    , makingProcessUuid = "26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5"
    }


getWeavingKnittingProcess : Product -> Process
getWeavingKnittingProcess { knitted } =
    if knitted then
        Process.findByName "Tricotage"

    else
        Process.findByName "Tissage (habillement)"


decode : Decoder Product
decode =
    Decode.map8 Product
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "mass" Unit.decodeKg)
        (Decode.field "pcrWaste" Decode.float)
        (Decode.field "ppm" Decode.int)
        (Decode.field "grammage" Decode.int)
        (Decode.field "knitted" Decode.bool)
        (Decode.field "makingProcessUuid" Decode.string)


encode : Product -> Encode.Value
encode v =
    Encode.object
        [ ( "id", Encode.string v.id )
        , ( "name", Encode.string v.name )
        , ( "mass", Unit.encodeKg v.mass )
        , ( "pcrWaste", Encode.float v.pcrWaste )
        , ( "ppm", Encode.int v.ppm )
        , ( "grammage", Encode.int v.grammage )
        , ( "knitted", Encode.bool v.knitted )
        , ( "makingProcessUuid", Encode.string v.makingProcessUuid )
        ]
