module Data.Product exposing (Product, choices, decode, encode, findById, tShirt)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Product =
    { id : String
    , name : String
    , defaultMass : Float
    , waste : Float
    }


choices : List Product
choices =
    [ { id = "1", name = "Cape", defaultMass = 0.95, waste = 0.2 }
    , { id = "2", name = "Châle", defaultMass = 0.11, waste = 0.1 }
    , { id = "3", name = "Chemisier", defaultMass = 0.25, waste = 0.2 }
    , { id = "4", name = "Débardeur", defaultMass = 0.17, waste = 0.15 }
    , { id = "5", name = "Echarpe", defaultMass = 0.11, waste = 0.1 }
    , { id = "6", name = "Gilet", defaultMass = 0.5, waste = 0.2 }
    , { id = "7", name = "Jean", defaultMass = 0.45, waste = 0.22 }
    , { id = "8", name = "Jupe", defaultMass = 0.3, waste = 0.2 }
    , { id = "9", name = "Manteau", defaultMass = 0.95, waste = 0.2 }
    , { id = "10", name = "Pantalon", defaultMass = 0.45, waste = 0.2 }
    , { id = "11", name = "Pull", defaultMass = 0.5, waste = 0.2 }
    , { id = "12", name = "Robe", defaultMass = 0.3, waste = 0.2 }
    , { id = "13", name = "T-shirt", defaultMass = 0.17, waste = 0.15 }
    , { id = "14", name = "Veste", defaultMass = 0.95, waste = 0.2 }
    ]


findById : String -> Maybe Product
findById id =
    choices |> List.filter (\p -> p.id == id) |> List.head


tShirt : Product
tShirt =
    { id = "13", name = "T-shirt", defaultMass = 0.17, waste = 0.15 }


decode : Decoder Product
decode =
    Decode.map4 Product
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "defaultMass" Decode.float)
        (Decode.field "waste" Decode.float)


encode : Product -> Encode.Value
encode v =
    Encode.object
        [ ( "id", Encode.string v.id )
        , ( "name", Encode.string v.name )
        , ( "defaultMass", Encode.float v.defaultMass )
        , ( "waste", Encode.float v.waste )
        ]
