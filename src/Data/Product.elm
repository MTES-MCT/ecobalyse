module Data.Product exposing (Product, choices, decode, encode, findById, tShirt)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Product =
    { id : String
    , name : String
    }


choices : List Product
choices =
    [ { id = "1", name = "Cape" }
    , { id = "2", name = "Châle" }
    , { id = "3", name = "Chemisier" }
    , { id = "4", name = "Débardeur" }
    , { id = "5", name = "Echarpe" }
    , { id = "6", name = "Gilet" }
    , { id = "7", name = "Jean" }
    , { id = "8", name = "Jupe" }
    , { id = "9", name = "Manteau" }
    , { id = "10", name = "Pantalon" }
    , { id = "11", name = "Pull" }
    , { id = "12", name = "Robe" }
    , { id = "13", name = "T-shirt" }
    , { id = "14", name = "Veste" }
    ]


findById : String -> Maybe Product
findById id =
    choices |> List.filter (\p -> p.id == id) |> List.head


tShirt : Product
tShirt =
    { id = "13", name = "T-shirt" }


decode : Decoder Product
decode =
    Decode.map2 Product
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)


encode : Product -> Encode.Value
encode v =
    Encode.object
        [ ( "id", Encode.string v.id )
        , ( "name", Encode.string v.name )
        ]
