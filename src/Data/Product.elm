module Data.Product exposing (..)

import Data.Process as Process
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
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
    , fabricProcessUuid : Process.Uuid
    , makingProcessUuid : Process.Uuid
    }


type Id
    = Id String


findById : Id -> List Product -> Result String Product
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Produit non trouvé id=" ++ idToString id)


idToString : Id -> String
idToString (Id string) =
    string


decode : Decoder Product
decode =
    Decode.succeed Product
        |> Pipe.required "id" (Decode.map Id Decode.string)
        |> Pipe.required "name" Decode.string
        |> Pipe.required "mass" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "pcrWaste" Decode.float
        |> Pipe.required "ppm" Decode.int
        |> Pipe.required "grammage" Decode.int
        |> Pipe.required "knitted" Decode.bool
        |> Pipe.required "fabricProcessUuid" (Decode.map Process.Uuid Decode.string)
        |> Pipe.required "makingProcessUuid" (Decode.map Process.Uuid Decode.string)


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
        , ( "fabricProcessUuid", Encode.string (Process.uuidToString v.makingProcessUuid) )
        , ( "makingProcessUuid", Encode.string (Process.uuidToString v.makingProcessUuid) )
        ]
