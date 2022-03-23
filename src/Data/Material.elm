module Data.Material exposing
    ( CFFData
    , Id(..)
    , Material
    , decodeList
    , encode
    , encodeId
    , findById
    , findByProcessUuid
    , fullName
    , groupAll
    , idToString
    )

import Data.Country as Country
import Data.Material.Category as Category exposing (Category)
import Data.Process as Process exposing (Process)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Material =
    { id : Id
    , name : String
    , shortName : String
    , category : Category
    , materialProcess : Process
    , recycledProcess : Maybe Process
    , recycledFrom : Maybe Id
    , primary : Bool
    , continent : String
    , defaultCountry : Country.Code
    , priority : Int
    , cffData : Maybe CFFData
    }


type Id
    = Id String


type alias CFFData =
    -- Circular Footprint Formula data
    { manufacturerAllocation : Unit.Ratio
    , recycledQualityRatio : Unit.Ratio
    }


findById : Id -> List Material -> Result String Material
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Matière non trouvée id=" ++ idToString id ++ ".")


findByProcessUuid : Process.Uuid -> List Material -> Maybe Material
findByProcessUuid processUuid =
    List.filter (\{ materialProcess } -> materialProcess.uuid == processUuid)
        >> List.head


groupAll :
    List Material
    ->
        ( ( List Material, List Material, List Material )
        , ( List Material, List Material, List Material )
        )
groupAll =
    List.sortBy .shortName
        >> List.partition (.primary >> (==) True)
        >> Tuple.mapBoth groupByCategories groupByCategories


fromCategory : Category -> List Material -> List Material
fromCategory category =
    List.filter (.category >> (==) category)


groupByCategories : List Material -> ( List Material, List Material, List Material )
groupByCategories materials =
    ( materials |> fromCategory Category.Natural
    , materials |> fromCategory Category.Synthetic
    , materials |> fromCategory Category.Recycled
    )


fullName : Maybe Unit.Ratio -> Material -> String
fullName recycledRatio material =
    material.shortName
        ++ (case ( material.recycledProcess, recycledRatio ) of
                ( Just _, Just ratio ) ->
                    if Unit.ratioToFloat ratio == 0 then
                        ""

                    else
                        " (" ++ recycledRatioToString "♲" ratio ++ ")"

                _ ->
                    ""
           )


recycledRatioToString : String -> Unit.Ratio -> String
recycledRatioToString unit (Unit.Ratio recycledRatio) =
    String.fromInt (round (recycledRatio * 100)) ++ "\u{202F}%\u{00A0}" ++ unit


decode : List Process -> Decoder Material
decode processes =
    Decode.succeed Material
        |> JDP.required "id" (Decode.map Id Decode.string)
        |> JDP.required "name" Decode.string
        |> JDP.required "shortName" Decode.string
        |> JDP.required "category" Category.decode
        |> JDP.required "materialProcessUuid" (Process.decodeFromUuid processes)
        |> JDP.required "recycledProcessUuid" (Decode.maybe (Process.decodeFromUuid processes))
        |> JDP.required "recycledFrom" (Decode.maybe (Decode.map Id Decode.string))
        |> JDP.required "primary" Decode.bool
        |> JDP.required "continent" Decode.string
        |> JDP.required "defaultCountry" (Decode.string |> Decode.map Country.codeFromString)
        |> JDP.required "priority" Decode.int
        |> JDP.required "cff" (Decode.maybe decodeCFFData)


decodeCFFData : Decoder CFFData
decodeCFFData =
    Decode.succeed CFFData
        |> JDP.required "manufacturerAllocation" Unit.decodeRatio
        |> JDP.required "recycledQualityRatio" Unit.decodeRatio


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
        , ( "materialProcessUuid", Process.encodeUuid v.materialProcess.uuid )
        , ( "recycledProcessUuid"
          , v.recycledProcess |> Maybe.map (.uuid >> Process.encodeUuid) |> Maybe.withDefault Encode.null
          )
        , ( "primary", Encode.bool v.primary )
        , ( "continent", Encode.string v.continent )
        , ( "defaultCountry", v.defaultCountry |> Country.codeToString |> Encode.string )
        , ( "priority", Encode.int v.priority )
        ]


encodeId : Id -> Encode.Value
encodeId =
    idToString >> Encode.string


idToString : Id -> String
idToString (Id string) =
    string
