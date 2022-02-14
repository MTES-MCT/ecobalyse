module Data.Material exposing
    ( Id(..)
    , Material
    , decodeList
    , encode
    , encodeId
    , findById
    , fullName
    , groupAll
    , idToString
    , recycledRatioToString
    )

import Data.Country as Country
import Data.Material.Category as Category exposing (Category)
import Data.Process as Process exposing (Process)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as DecodePipeline
import Json.Encode as Encode


type alias Material =
    { id : Id
    , name : String
    , shortName : String
    , category : Category
    , materialProcess : Process
    , recycledProcess : Maybe Process
    , primary : Bool
    , continent : String
    , defaultCountry : Country.Code
    , priority : Int
    }


type Id
    = Id String


findById : Id -> List Material -> Result String Material
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Matière non trouvée id=" ++ idToString id ++ ".")


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
        ++ (case recycledRatio of
                Nothing ->
                    ""

                Just ratio ->
                    if Unit.ratioToFloat ratio == 0 then
                        ""

                    else
                        " (" ++ recycledRatioToString "♲" ratio ++ ")"
           )


recycledRatioToString : String -> Unit.Ratio -> String
recycledRatioToString unit (Unit.Ratio recycledRatio) =
    String.fromInt (round (recycledRatio * 100)) ++ "\u{202F}%\u{00A0}" ++ unit


decode : List Process -> Decoder Material
decode processes =
    Decode.succeed Material
        |> DecodePipeline.required "id" (Decode.map Id Decode.string)
        |> DecodePipeline.required "name" Decode.string
        |> DecodePipeline.required "shortName" Decode.string
        |> DecodePipeline.required "category" Category.decode
        |> DecodePipeline.required "materialProcessUuid" (Process.decodeFromUuid processes)
        |> DecodePipeline.required "recycledProcessUuid" (Decode.maybe (Process.decodeFromUuid processes))
        |> DecodePipeline.required "primary" Decode.bool
        |> DecodePipeline.required "continent" Decode.string
        |> DecodePipeline.required "defaultCountry" (Decode.string |> Decode.map Country.codeFromString)
        |> DecodePipeline.required "priority" Decode.int


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
