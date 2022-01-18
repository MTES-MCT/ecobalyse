module Data.Material exposing (..)

import Data.Country as Country
import Data.Material.Category as Category exposing (Category)
import Data.Process as Process exposing (Process)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as DecodePipeline
import Json.Encode as Encode


type alias Material =
    { uuid : Process.Uuid -- Note: we use the material + spinning process uuid here
    , name : String
    , shortName : String
    , category : Category
    , materialProcess : Process
    , recycledProcess : Maybe Process
    , primary : Bool
    , continent : String
    , defaultCountry : Country.Code
    }


findByUuid : Process.Uuid -> List Material -> Result String Material
findByUuid uuid =
    List.filter (\m -> m.uuid == uuid)
        >> List.head
        >> Result.fromMaybe ("Impossible de récupérer la matière uuid=" ++ Process.uuidToString uuid ++ ".")


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


groupByCategories : List Material -> ( List Material, List Material, List Material )
groupByCategories materials =
    ( materials |> List.filter (.category >> (==) Category.Natural)
    , materials |> List.filter (.category >> (==) Category.Synthetic)
    , materials |> List.filter (.category >> (==) Category.Recycled)
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
        |> DecodePipeline.required "uuid" (Decode.map Process.Uuid Decode.string)
        |> DecodePipeline.required "name" Decode.string
        |> DecodePipeline.required "shortName" Decode.string
        |> DecodePipeline.required "category" Category.decode
        |> DecodePipeline.required "materialProcessUuid" (Process.decodeFromUuid processes)
        |> DecodePipeline.required "recycledProcessUuid" (Decode.maybe (Process.decodeFromUuid processes))
        |> DecodePipeline.required "primary" Decode.bool
        |> DecodePipeline.required "continent" Decode.string
        |> DecodePipeline.required "defaultCountry" (Decode.string |> Decode.map Country.codeFromString)


decodeList : List Process -> Decoder (List Material)
decodeList processes =
    Decode.list (decode processes)


encode : Material -> Encode.Value
encode v =
    Encode.object
        [ ( "uuid", v.uuid |> Process.uuidToString |> Encode.string )
        , ( "name", v.name |> Encode.string )
        , ( "shortName", Encode.string v.shortName )
        , ( "category", v.category |> Category.toString |> Encode.string )
        , ( "materialProcessUuid", v.materialProcess.uuid |> Process.uuidToString |> Encode.string )
        , ( "recycledProcessUuid"
          , v.recycledProcess
                |> Maybe.map (.uuid >> Process.uuidToString >> Encode.string)
                |> Maybe.withDefault Encode.null
          )
        , ( "primary", Encode.bool v.primary )
        , ( "continent", Encode.string v.continent )
        , ( "defaultCountry", v.defaultCountry |> Country.codeToString |> Encode.string )
        ]


encodeAll : List Material -> String
encodeAll =
    Encode.list encode >> Encode.encode 0
