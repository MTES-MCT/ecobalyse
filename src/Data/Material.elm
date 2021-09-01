module Data.Material exposing (..)

import Data.Material.Category as Category exposing (Category)
import Data.Process as Process
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Material =
    { process_uuid : String
    , name : String
    , category : Category
    }


choices : List Material
choices =
    Process.processes
        |> Process.cat1 Process.Textile
        |> Process.cat2 Process.Material
        |> List.map
            (\{ uuid, name, cat3 } ->
                { process_uuid = uuid
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
    choices
        |> List.filter (.name >> (==) "Fil de coton conventionnel, inventaire partiellement agrégé")
        |> List.head
        |> Maybe.withDefault { process_uuid = "", name = "", category = Category.Natural }


decode : Decoder Material
decode =
    Decode.map3 Material
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "category" Category.decode)


encode : Material -> Encode.Value
encode v =
    Encode.object
        [ ( "process_uuid", Encode.string v.process_uuid )
        , ( "name", Encode.string v.name )
        , ( "category", Category.encode v.category )
        ]


findByProcessUuid : String -> Maybe Material
findByProcessUuid process_uuid =
    choices |> List.filter (\m -> m.process_uuid == process_uuid) |> List.head
