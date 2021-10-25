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
    }


fromProcesses : List Process -> List Material
fromProcesses =
    -- FIXME: obsololete once we import materials.json -> REMOVE
    Process.cat1 Process.Textile
        >> Process.cat2 Process.Material
        >> List.map
            (\{ uuid, name, cat3 } ->
                { uuid = uuid
                , name = name
                , shortName = ""
                , category =
                    case cat3 of
                        Process.SyntheticMaterials ->
                            Category.Synthetic

                        Process.RecycledMaterials ->
                            Category.Recycled

                        _ ->
                            Category.Natural
                }
            )


findByUuid : Process.Uuid -> List Material -> Result String Material
findByUuid uuid =
    List.filter (\m -> m.uuid == uuid)
        >> List.head
        >> Result.fromMaybe ("Impossible de récupérer la matière uuid=" ++ Process.uuidToString uuid)


firstFromCategory : Category -> List Material -> Result String Material
firstFromCategory category =
    List.filter (.category >> (==) category)
        >> List.head
        >> Result.fromMaybe ("Aucune matière dans la catégorie " ++ Category.toString category)


shortName : Material -> String
shortName =
    .name
        >> String.replace "Fil de " ""
        >> String.replace "Fil d'" ""
        >> String.replace "Filament de " ""
        >> String.replace "Filament d'" ""
        >> String.replace "Filament bi-composant " ""
        >> String.replace "Feuille de " ""
        >> String.replace "Production de filament de " ""
        >> String.replace "Production de fil de " ""
        >> String.replace "Production de fil d'" ""
        >> ucFirst


ucFirst : String -> String
ucFirst string =
    case String.split "" string of
        x :: rest ->
            String.toUpper x :: rest |> String.join ""

        [] ->
            string


decode : Decoder Material
decode =
    Decode.map4 Material
        (Decode.field "uuid" (Decode.map Process.Uuid Decode.string))
        (Decode.field "name" Decode.string)
        (Decode.field "shortName" Decode.string)
        (Decode.field "category" Category.decode)


decodeList : Decoder (List Material)
decodeList =
    Decode.list decode


encode : Material -> Encode.Value
encode v =
    Encode.object
        [ ( "uuid", v.uuid |> Process.uuidToString |> Encode.string )
        , ( "name", v.name |> Encode.string )
        , ( "shortName", v |> shortName |> Encode.string )
        , ( "category", v.category |> Category.toString |> Encode.string )
        ]


encodeAll : List Material -> String
encodeAll =
    Encode.list encode >> Encode.encode 0
