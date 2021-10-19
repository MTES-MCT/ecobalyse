module Data.Material exposing (..)

import Data.Material.Category as Category exposing (Category)
import Data.Process as Process exposing (Process, findByName)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Material =
    { materialProcessUuid : Process.Uuid
    , name : String
    , category : Category
    }


choices : List Material
choices =
    fromProcesses Process.processes


fromProcesses : List Process -> List Material
fromProcesses =
    Process.cat1 Process.Textile
        >> Process.cat2 Process.Material
        >> List.map
            (\{ uuid, name, cat3 } ->
                { materialProcessUuid = uuid
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


cotton : Material
cotton =
    findByName "Fil de coton conventionnel, inventaire partiellement agrégé"


findByName : String -> Material
findByName name =
    choices
        |> List.filter (.name >> (==) name)
        |> List.head
        |> Maybe.withDefault invalid


findByProcessUuid : Process.Uuid -> Material
findByProcessUuid materialProcessUuid =
    choices
        |> List.filter (\m -> m.materialProcessUuid == materialProcessUuid)
        |> List.head
        |> Maybe.withDefault invalid


invalid : Material
invalid =
    -- FIXME: eradicate this
    { materialProcessUuid = Process.Uuid "<invalid>"
    , name = "<invalid>"
    , category = Category.Natural
    }


decode : Decoder Material
decode =
    Decode.map3 Material
        (Decode.field "materialProcessUuid" (Decode.map Process.Uuid Decode.string))
        (Decode.field "name" Decode.string)
        (Decode.field "category" Category.decode)


encode : Material -> Encode.Value
encode v =
    Encode.object
        [ ( "materialProcessUuid", Encode.string (Process.uuidToString v.materialProcessUuid) )
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
