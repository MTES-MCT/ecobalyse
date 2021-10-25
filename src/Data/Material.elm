module Data.Material exposing (..)

import Data.Material.Category as Category exposing (Category)
import Data.Process as Process exposing (Process)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Material =
    { uuid : Process.Uuid -- Note: we use the material + spinning process uuid here
    , name : String
    , category : Category
    }


fromProcesses : List Process -> List Material
fromProcesses =
    Process.cat1 Process.Textile
        >> Process.cat2 Process.Material
        >> List.map
            (\{ uuid, name, cat3 } ->
                { uuid = uuid
                , name = name
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


decode : Decoder Material
decode =
    Decode.map3 Material
        (Decode.field "uuid" (Decode.map Process.Uuid Decode.string))
        (Decode.field "name" Decode.string)
        (Decode.field "category" Category.decode)


encode : Material -> Encode.Value
encode v =
    Encode.object
        [ ( "uuid", Encode.string (Process.uuidToString v.uuid) )
        , ( "name", Encode.string v.name )
        , ( "category", Category.encode v.category )
        ]


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
