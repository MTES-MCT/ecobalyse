module Data.Process exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Process =
    { step : Int
    , name : String
    }


spinning : Process
spinning =
    { step = 1
    , name = "Matière & filature"
    }


weaving : Process
weaving =
    { step = 2
    , name = "Tissage & tricotage"
    }


confection : Process
confection =
    { step = 3
    , name = "Confection"
    }


ennoblement : Process
ennoblement =
    { step = 4
    , name = "Ennoblissement"
    }


transport : Process
transport =
    { step = 5
    , name = "Transport"
    }


distribution : Process
distribution =
    { step = 6
    , name = "Distribution"
    }


default : List Process
default =
    [ spinning
    , weaving
    , confection
    , ennoblement
    , transport
    , distribution
    ]


decode : Decoder Process
decode =
    Decode.map2 Process
        (Decode.field "step" Decode.int)
        (Decode.field "name" Decode.string)


encode : Process -> Encode.Value
encode v =
    Encode.object
        [ ( "step", Encode.int v.step )
        , ( "name", Encode.string v.name )
        ]
