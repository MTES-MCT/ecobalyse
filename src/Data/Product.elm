module Data.Product exposing (..)

import Data.Process as Process exposing (Process)
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
    , fabricProcess : Process
    , makingProcess : Process
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


decode : List Process -> Decoder Product
decode processes =
    Decode.succeed Product
        |> Pipe.required "id" (Decode.map Id Decode.string)
        |> Pipe.required "name" Decode.string
        |> Pipe.required "mass" (Decode.map Mass.kilograms Decode.float)
        |> Pipe.required "pcrWaste" Decode.float
        |> Pipe.required "ppm" Decode.int
        |> Pipe.required "grammage" Decode.int
        |> Pipe.required "knitted" Decode.bool
        |> Pipe.required "fabricProcessUuid" (Process.decodeFromUuid processes)
        |> Pipe.required "makingProcessUuid" (Process.decodeFromUuid processes)


decodeList : List Process -> Decoder (List Product)
decodeList processes =
    Decode.list (decode processes)


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
        , ( "fabricProcessUuid", v.makingProcess.uuid |> Process.uuidToString |> Encode.string )
        , ( "makingProcessUuid", v.makingProcess.uuid |> Process.uuidToString |> Encode.string )
        ]
