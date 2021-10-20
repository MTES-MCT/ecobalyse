module Data.Product exposing (..)

import Data.Process as Process exposing (Process)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Mass exposing (Mass)


type alias Product =
    { id : Id
    , name : String
    , mass : Mass
    , pcrWaste : Float -- PCR product waste ratio
    , ppm : Int -- pick per meter
    , grammage : Int -- grammes per kg
    , knitted : Bool -- True: Tricotage (Knitting); False: Tissage (Weaving)
    , makingProcessUuid : Process.Uuid
    }


type Id
    = Id String


findById : Id -> List Product -> Result String Product
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Produit non trouvé id=" ++ idToString id)


getWeavingKnittingProcess : Product -> Process
getWeavingKnittingProcess { knitted } =
    if knitted then
        Process.findByName "Tricotage"

    else
        Process.findByName "Tissage (habillement)"


idToString : Id -> String
idToString (Id string) =
    string


decode : Decoder Product
decode =
    Decode.map8 Product
        (Decode.field "id" (Decode.map Id Decode.string))
        (Decode.field "name" Decode.string)
        (Decode.field "mass" (Decode.map Mass.kilograms Decode.float))
        (Decode.field "pcrWaste" Decode.float)
        (Decode.field "ppm" Decode.int)
        (Decode.field "grammage" Decode.int)
        (Decode.field "knitted" Decode.bool)
        (Decode.field "makingProcessUuid" (Decode.map Process.Uuid Decode.string))


decodeList : Decoder (List Product)
decodeList =
    Decode.list decode


encode : Product -> Encode.Value
encode v =
    Encode.object
        [ ( "id", Encode.string (idToString v.id) )
        , ( "name", Encode.string v.name )
        , ( "mass", Encode.float (Mass.inKilograms v.mass) )
        , ( "pcrWaste", Encode.float v.pcrWaste )
        , ( "ppm", Encode.int v.ppm )
        , ( "grammage", Encode.int v.grammage )
        , ( "knitted", Encode.bool v.knitted )
        , ( "makingProcessUuid", Encode.string (Process.uuidToString v.makingProcessUuid) )
        ]
