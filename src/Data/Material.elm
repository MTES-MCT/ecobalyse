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
    , recycledUuid : Maybe Process.Uuid
    , primary : Bool
    }


getRecycledProcess : Material -> List Process -> Result String (Maybe Process)
getRecycledProcess material processes =
    case material.recycledUuid of
        Just uuid ->
            processes
                |> Process.findByUuid uuid
                |> Result.map Just

        Nothing ->
            Ok Nothing


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


recycledRatioToString : Float -> String
recycledRatioToString recycledRatio =
    case round (recycledRatio * 100) of
        0 ->
            "Pas d'origine recyclée"

        p ->
            String.fromInt p ++ "% d'origine recyclée"


decode : Decoder Material
decode =
    Decode.map6 Material
        (Decode.field "uuid" (Decode.map Process.Uuid Decode.string))
        (Decode.field "name" Decode.string)
        (Decode.field "shortName" Decode.string)
        (Decode.field "category" Category.decode)
        (Decode.field "recycledUuid" (Decode.maybe (Decode.map Process.Uuid Decode.string)))
        (Decode.field "primary" Decode.bool)


decodeList : Decoder (List Material)
decodeList =
    Decode.list decode


encode : Material -> Encode.Value
encode v =
    Encode.object
        [ ( "uuid", v.uuid |> Process.uuidToString |> Encode.string )
        , ( "name", v.name |> Encode.string )
        , ( "shortName", Encode.string v.shortName )
        , ( "category", v.category |> Category.toString |> Encode.string )
        , ( "recycledUuid"
          , v.recycledUuid
                |> Maybe.map (Process.uuidToString >> Encode.string)
                |> Maybe.withDefault Encode.null
          )
        , ( "primary", Encode.bool v.primary )
        ]


encodeAll : List Material -> String
encodeAll =
    Encode.list encode >> Encode.encode 0
