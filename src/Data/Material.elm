module Data.Material exposing (Material, choices, cotton, decode, encode, findById)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Material =
    { id : String
    , name : String
    }


choices : List Material
choices =
    [ { id = "1", name = "Naturelles" }
    , { id = "2", name = "Synthétiques et artificielles" }
    , { id = "3", name = "Recyclées" }
    ]


cotton : Material
cotton =
    { id = "1", name = "Coton" }


decode : Decoder Material
decode =
    Decode.map2 Material
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)


encode : Material -> Encode.Value
encode v =
    Encode.object
        [ ( "id", Encode.string v.id )
        , ( "name", Encode.string v.name )
        ]


findById : String -> Maybe Material
findById id =
    choices |> List.filter (\m -> m.id == id) |> List.head
