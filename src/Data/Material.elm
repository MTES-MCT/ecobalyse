module Data.Material exposing (..)

import Data.Material.Category as Category exposing (Category)
import Data.Process as Process exposing (Process)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Material =
    { uuid : Process.Uuid -- Note: we use the material + spinning process uuid here
    , name : String
    , shortName : String
    , category : Category
    , materialProcess : Process
    , recycledProcess : Maybe Process
    , primary : Bool
    }


findByUuid : Process.Uuid -> List Material -> Result String Material
findByUuid uuid =
    List.filter (\m -> m.uuid == uuid)
        >> List.head
        >> Result.fromMaybe ("Impossible de récupérer la matière uuid=" ++ Process.uuidToString uuid)


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


fullName : Maybe Float -> Material -> String
fullName recycledRatio material =
    material.shortName
        ++ (case recycledRatio of
                Nothing ->
                    ""

                Just ratio ->
                    if ratio == 0 then
                        ""

                    else
                        " (" ++ recycledRatioToString ratio ++ ")"
           )


recycledRatioToString : Float -> String
recycledRatioToString recycledRatio =
    String.fromInt (round (recycledRatio * 100)) ++ "% d'origine recyclée"


decode : List Process -> Decoder Material
decode processes =
    Decode.map7 Material
        (Decode.field "uuid" (Decode.map Process.Uuid Decode.string))
        (Decode.field "name" Decode.string)
        (Decode.field "shortName" Decode.string)
        (Decode.field "category" Category.decode)
        (Decode.field "materialProcessUuid" (Process.decodeFromUuid processes))
        (Decode.field "recycledProcessUuid" (Decode.maybe (Process.decodeFromUuid processes)))
        (Decode.field "primary" Decode.bool)


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
        ]


encodeAll : List Material -> String
encodeAll =
    Encode.list encode >> Encode.encode 0
