module Data.Material exposing (..)

import Data.Material.Category as Category exposing (Category)
import Data.Process as Process
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Material =
    { materialProcessUuid : String
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
    choices
        |> List.filter (.name >> (==) "Fil de coton conventionnel, inventaire partiellement agrégé")
        |> List.head
        |> Maybe.withDefault { materialProcessUuid = "", name = "", category = Category.Natural }


decode : Decoder Material
decode =
    Decode.map3 Material
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "category" Category.decode)


encode : Material -> Encode.Value
encode v =
    Encode.object
        [ ( "materialProcessUuid", Encode.string v.materialProcessUuid )
        , ( "name", Encode.string v.name )
        , ( "category", Category.encode v.category )
        ]


findByProcessUuid : String -> Maybe Material
findByProcessUuid materialProcessUuid =
    choices |> List.filter (\m -> m.materialProcessUuid == materialProcessUuid) |> List.head
