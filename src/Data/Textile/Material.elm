module Data.Textile.Material exposing
    ( CFFData
    , Id(..)
    , Material
    , decodeList
    , encode
    , encodeId
    , findById
    , getRecyclingData
    , groupAll
    , idToString
    )

import Data.Country as Country
import Data.Split as Split exposing (Split)
import Data.Textile.Material.Category as Category exposing (Category)
import Data.Textile.Process as Process exposing (Process)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Material =
    { id : Id
    , name : String
    , shortName : String
    , category : Category
    , recycled : Bool
    , materialProcess : Process
    , recycledProcess : Maybe Process
    , recycledFrom : Maybe Id
    , spinningProcess : Maybe Process -- Optional, as some materials are not spinned (eg. Neoprene)
    , geographicOrigin : String -- A textual information about the geographic origin of the material
    , defaultCountry : Country.Code -- Default country for Material and Spinning steps
    , priority : Int -- Used to sort materials
    , cffData : Maybe CFFData
    }


type Id
    = Id String


type alias CFFData =
    -- Circular Footprint Formula data
    { manufacturerAllocation : Split
    , recycledQualityRatio : Split
    }


getRecyclingData : Material -> List Material -> Maybe ( Material, CFFData )
getRecyclingData material materials =
    -- If material is non-recycled, retrieve relevant recycled equivalent material & CFF data
    Maybe.map2 Tuple.pair
        (material.recycledFrom
            |> Maybe.andThen
                (\id ->
                    findById id materials
                        |> Result.toMaybe
                )
        )
        material.cffData


findById : Id -> List Material -> Result String Material
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Matière non trouvée id=" ++ idToString id ++ ".")


groupAll :
    List Material
    -> ( List Material, List Material, List Material )
groupAll =
    List.sortBy .shortName >> groupByCategories


fromCategory : Category -> List Material -> List Material
fromCategory category =
    List.filter (.category >> (==) category)


groupByCategories : List Material -> ( List Material, List Material, List Material )
groupByCategories materials =
    ( materials |> fromCategory Category.Natural
    , materials |> fromCategory Category.Synthetic
    , materials |> fromCategory Category.Recycled
    )


decode : List Process -> Decoder Material
decode processes =
    Decode.succeed Material
        |> JDP.required "id" (Decode.map Id Decode.string)
        |> JDP.required "name" Decode.string
        |> JDP.required "shortName" Decode.string
        |> JDP.required "category" Category.decode
        |> JDP.required "recycled" Decode.bool
        |> JDP.required "materialProcessUuid" (Process.decodeFromUuid processes)
        |> JDP.required "recycledProcessUuid" (Decode.maybe (Process.decodeFromUuid processes))
        |> JDP.required "recycledFrom" (Decode.maybe (Decode.map Id Decode.string))
        |> JDP.required "spinningProcessUuid" (Decode.maybe (Process.decodeFromUuid processes))
        |> JDP.required "geographicOrigin" Decode.string
        |> JDP.required "defaultCountry" (Decode.string |> Decode.map Country.codeFromString)
        |> JDP.required "priority" Decode.int
        |> JDP.required "cff" (Decode.maybe decodeCFFData)


decodeCFFData : Decoder CFFData
decodeCFFData =
    Decode.succeed CFFData
        |> JDP.required "manufacturerAllocation" Split.decodeFloat
        |> JDP.required "recycledQualityRatio" Split.decodeFloat


decodeList : List Process -> Decoder (List Material)
decodeList processes =
    Decode.list (decode processes)


encode : Material -> Encode.Value
encode v =
    Encode.object
        [ ( "id", encodeId v.id )
        , ( "name", v.name |> Encode.string )
        , ( "shortName", Encode.string v.shortName )
        , ( "category", v.category |> Category.toString |> Encode.string )
        , ( "recycled", v.recycled |> Encode.bool )
        , ( "materialProcessUuid", Process.encodeUuid v.materialProcess.uuid )
        , ( "recycledProcessUuid"
          , v.recycledProcess |> Maybe.map (.uuid >> Process.encodeUuid) |> Maybe.withDefault Encode.null
          )
        , ( "recycledFrom", v.recycledFrom |> Maybe.map encodeId |> Maybe.withDefault Encode.null )
        , ( "spinningProcessUuid"
          , v.spinningProcess |> Maybe.map (.uuid >> Process.encodeUuid) |> Maybe.withDefault Encode.null
          )
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
