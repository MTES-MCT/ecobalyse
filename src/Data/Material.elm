module Data.Material exposing
    ( Material
    , choices
    , cotton
    , decode
    , encode
    , findById
    )

import Data.Material.Category as Category exposing (Category)
import Data.Process as Process
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Material =
    { id : String
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
                { id = uuid
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
        |> Maybe.withDefault { id = "", name = "", category = Category.Natural }


decode : Decoder Material
decode =
    Decode.map3 Material
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "category" Category.decode)


encode : Material -> Encode.Value
encode v =
    Encode.object
        [ ( "id", Encode.string v.id )
        , ( "name", Encode.string v.name )
        , ( "category", Category.encode v.category )
        ]


findById : String -> Maybe Material
findById id =
    choices |> List.filter (\m -> m.id == id) |> List.head
