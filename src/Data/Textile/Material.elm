module Data.Textile.Material exposing
    ( Id(..)
    , Material
    , decodeList
    , encode
    , encodeId
    , findById
    , idToString
    )

import Data.Country as Country
import Data.Textile.Material.Origin as Origin exposing (Origin)
import Data.Textile.Process as Process exposing (Process)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Material =
    { id : Id
    , name : String
    , shortName : String
    , origin : Origin
    , materialProcess : Process
    , geographicOrigin : String -- A textual information about the geographic origin of the material
    , defaultCountry : Country.Code -- Default country for Material and Spinning steps
    , priority : Int -- Used to sort materials
    }


type Id
    = Id String



---- Helpers


findById : Id -> List Material -> Result String Material
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Matière non trouvée id=" ++ idToString id ++ ".")


decode : List Process -> Decoder Material
decode processes =
    Decode.succeed Material
        |> JDP.required "id" (Decode.map Id Decode.string)
        |> JDP.required "name" Decode.string
        |> JDP.required "shortName" Decode.string
        |> JDP.required "origin" Origin.decode
        |> JDP.required "materialProcessUuid" (Process.decodeFromUuid processes)
        |> JDP.required "geographicOrigin" Decode.string
        |> JDP.required "defaultCountry" (Decode.string |> Decode.map Country.codeFromString)
        |> JDP.required "priority" Decode.int


decodeList : List Process -> Decoder (List Material)
decodeList processes =
    Decode.list (decode processes)


encode : Material -> Encode.Value
encode v =
    Encode.object
        [ ( "id", encodeId v.id )
        , ( "name", v.name |> Encode.string )
        , ( "shortName", Encode.string v.shortName )
        , ( "origin", v.origin |> Origin.toString |> Encode.string )
        , ( "materialProcessUuid", Process.encodeUuid v.materialProcess.uuid )
        , ( "geographicOrigin", Encode.string v.geographicOrigin )
        , ( "defaultCountry", v.defaultCountry |> Country.codeToString |> Encode.string )
        , ( "priority", Encode.int v.priority )
        ]


encodeId : Id -> Encode.Value
encodeId =
    idToString >> Encode.string


idToString : Id -> String
idToString (Id string) =
    string
